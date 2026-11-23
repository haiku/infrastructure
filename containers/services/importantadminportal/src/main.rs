mod config;
mod decoys;
mod ip;
mod portal;
mod store;

use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{Duration, Instant};

use axum::Router;
use axum::extract::{ConnectInfo, Form, Request, State};
use axum::http::{HeaderMap, HeaderName, HeaderValue, StatusCode, Uri, header};
use axum::middleware::{self, Next};
use axum::response::{Html, IntoResponse, Response};
use axum::routing::get;
use rand::Rng;
use rand::distributions::Alphanumeric;
use tracing_subscriber::EnvFilter;
use tracing_subscriber::fmt::time::UtcTime;

use crate::config::Config;
use crate::decoys::DecoySet;
use crate::store::IpStore;

#[derive(Clone)]
struct AppState {
    config: Arc<Config>,
    store: Arc<IpStore>,
    decoys: Arc<DecoySet>,
    hits: Arc<AtomicU64>,
    csrf: Arc<String>,
    started: Instant,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .with_timer(UtcTime::rfc_3339())
        .init();

    let config = Config::from_env()?;
    let store = Arc::new(IpStore::new(config.ip_log_file.clone()));
    store.prepare().await?;

    let state = AppState {
        config: Arc::new(config.clone()),
        store: Arc::clone(&store),
        decoys: Arc::new(DecoySet::build()),
        hits: Arc::new(AtomicU64::new(0)),
        csrf: Arc::new(random_token(32)),
        started: Instant::now(),
    };

    let app = router(state);
    let listener = tokio::net::TcpListener::bind(config.bind).await?;
    tracing::info!(
        addr = %config.bind,
        ip_log = %store.path().display(),
        compact_secs = config.compact_interval.as_secs(),
        "important admin portal listening"
    );

    let compactor = tokio::spawn(compact_loop(Arc::clone(&store), config.compact_interval));

    axum::serve(
        listener,
        app.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .with_graceful_shutdown(shutdown_signal())
    .await?;

    compactor.abort();

    match store.compact().await {
        Ok(report) => tracing::info!(
            before = report.lines_before,
            after = report.lines_after,
            "final compaction complete"
        ),
        Err(err) => tracing::error!(error = %err, "final compaction failed"),
    }

    Ok(())
}

fn router(state: AppState) -> Router {
    Router::new()
        .route("/", get(index))
        .route("/admin", get(dashboard))
        .route("/admin/", get(dashboard))
        .route("/admin/login", get(login_page).post(login_attempt))
        .route("/admin/logout", get(logout))
        .route("/admin/users", get(users))
        .route("/admin/settings", get(settings))
        .route("/admin/audit", get(audit))
        .route("/admin/backups", get(backups))
        .route("/admin/integrations", get(integrations))
        .route("/assets/portal.css", get(stylesheet))
        .route("/report.txt", get(report))
        .route("/healthz", get(healthz))
        .route("/robots.txt", get(robots))
        .route("/security.txt", get(security))
        .route("/.well-known/security.txt", get(security))
        .route("/favicon.ico", get(favicon))
        .fallback(fallback)
        .layer(middleware::from_fn_with_state(
            state.clone(),
            observe_request,
        ))
        .with_state(state)
}

// ---------------------------------------------------------------------------
// Request tracking
// ---------------------------------------------------------------------------

/// Log every hostile request and append the source to the IP report.
///
/// `/report.txt` and `/healthz` are never tracked: operators and uptime
/// checks must be able to read the report without joining it.
async fn observe_request(
    State(state): State<AppState>,
    ConnectInfo(peer): ConnectInfo<SocketAddr>,
    request: Request,
    next: Next,
) -> Response {
    let path = request.uri().path().to_string();
    let exempt = path == "/report.txt" || path == "/healthz";
    let peer_ip = peer.ip();
    let client_ip = ip::client_ip(request.headers(), peer_ip, state.config.trust_proxy_headers);

    if !exempt {
        if ip::is_public(client_ip) {
            let method = request.method().as_str().to_string();
            let uri = sanitize(&request.uri().to_string());
            let user_agent = header(request.headers(), "user-agent");
            let referer = header(request.headers(), "referer");
            let forwarded_for = header(request.headers(), "x-forwarded-for");

            let hits = state.hits.fetch_add(1, Ordering::Relaxed) + 1;
            tracing::warn!(
                ip = %client_ip,
                peer = %peer_ip,
                method = %method,
                uri = %uri,
                user_agent = %user_agent,
                referer = %referer,
                forwarded_for = %forwarded_for,
                hits = hits,
                "hostile request"
            );

            if let Err(err) = state.store.record(client_ip).await {
                tracing::error!(ip = %client_ip, error = %err, "failed to record hostile ip");
            }
        } else {
            tracing::debug!(
                ip = %client_ip,
                peer = %peer_ip,
                path = %sanitize(&path),
                "ignoring internal request"
            );
        }
    }

    let mut response = next.run(request).await;
    let response_headers = response.headers_mut();
    response_headers.insert(
        header::SERVER,
        HeaderValue::from_static("nginx/1.24.0 (Ubuntu)"),
    );
    response_headers.insert(
        HeaderName::from_static("x-powered-by"),
        HeaderValue::from_static("PHP/8.2.12"),
    );
    response_headers.insert(
        header::X_CONTENT_TYPE_OPTIONS,
        HeaderValue::from_static("nosniff"),
    );
    response_headers.insert(
        header::X_FRAME_OPTIONS,
        HeaderValue::from_static("SAMEORIGIN"),
    );
    response
}

fn header(headers: &HeaderMap, name: &str) -> String {
    headers
        .get(name)
        .and_then(|value| value.to_str().ok())
        .map(sanitize)
        .unwrap_or_default()
}

fn sanitize(value: &str) -> String {
    let mut output = String::with_capacity(value.len().min(512));
    for character in value.chars().take(512) {
        if character.is_control() {
            output.push('?');
        } else {
            output.push(character);
        }
    }
    output
}

// ---------------------------------------------------------------------------
// Portal pages
// ---------------------------------------------------------------------------

async fn index(State(state): State<AppState>) -> Html<String> {
    Html(portal::login_page(&state.csrf, None))
}

async fn login_page(State(state): State<AppState>) -> Html<String> {
    Html(portal::login_page(&state.csrf, None))
}

async fn login_attempt(
    State(state): State<AppState>,
    Form(form): Form<HashMap<String, String>>,
) -> Response {
    let username = form
        .get("username")
        .map(|value| sanitize(value))
        .unwrap_or_default();
    let password_length = form.get("password").map(String::len).unwrap_or(0);
    let domain = form
        .get("domain")
        .map(|value| sanitize(value))
        .unwrap_or_default();

    tracing::warn!(
        username = %username,
        domain = %domain,
        password_len = password_length,
        "failed portal login"
    );

    let body = portal::login_page(
        &state.csrf,
        Some("Invalid username or password. The account may be locked after 5 failed attempts."),
    );
    let cookie = format!(
        "JSESSIONID={}; Path=/; HttpOnly; SameSite=Lax",
        random_token(26)
    );
    let mut response = (StatusCode::UNAUTHORIZED, Html(body)).into_response();
    if let Ok(value) = HeaderValue::from_str(&cookie) {
        response.headers_mut().insert(header::SET_COOKIE, value);
    }
    response
}

async fn logout(State(state): State<AppState>) -> Html<String> {
    Html(portal::login_page(
        &state.csrf,
        Some("You have been signed out."),
    ))
}

async fn dashboard(State(state): State<AppState>) -> Html<String> {
    Html(portal::dashboard(
        &state.csrf,
        state.hits.load(Ordering::Relaxed),
        &human_duration(state.started.elapsed()),
    ))
}

async fn users(State(state): State<AppState>) -> Html<String> {
    Html(portal::users_page(&state.csrf))
}

async fn settings(State(state): State<AppState>) -> Html<String> {
    Html(portal::settings_page(&state.csrf))
}

async fn audit(State(state): State<AppState>) -> Html<String> {
    Html(portal::audit_page(&state.csrf))
}

async fn backups(State(state): State<AppState>) -> Html<String> {
    Html(portal::backups_page(&state.csrf))
}

async fn integrations(State(state): State<AppState>) -> Html<String> {
    Html(portal::integrations_page(&state.csrf))
}

async fn stylesheet() -> Response {
    (
        [(header::CONTENT_TYPE, "text/css; charset=utf-8")],
        portal::stylesheet(),
    )
        .into_response()
}

// ---------------------------------------------------------------------------
// Operational endpoints
// ---------------------------------------------------------------------------

const REPORT_HEADERS: [(&str, &str); 3] = [
    ("content-type", "text/plain; charset=utf-8"),
    ("cache-control", "no-store"),
    ("x-robots-tag", "noindex, nofollow"),
];

async fn report(State(state): State<AppState>) -> Response {
    match state.store.read().await {
        Ok(contents) => (StatusCode::OK, REPORT_HEADERS, contents).into_response(),
        Err(err) => {
            tracing::error!(error = %err, "failed to read ip report");
            (StatusCode::INTERNAL_SERVER_ERROR, portal::server_error()).into_response()
        }
    }
}

async fn healthz() -> (StatusCode, &'static str) {
    (StatusCode::OK, "ok\n")
}

async fn robots() -> ([(header::HeaderName, &'static str); 1], String) {
    (
        [(header::CONTENT_TYPE, "text/plain; charset=utf-8")],
        portal::robots_txt(),
    )
}

async fn security() -> ([(header::HeaderName, &'static str); 1], String) {
    (
        [(header::CONTENT_TYPE, "text/plain; charset=utf-8")],
        portal::security_txt(),
    )
}

async fn favicon() -> StatusCode {
    // Browsers will ask for this; an empty response is less suspicious than 404.
    StatusCode::NO_CONTENT
}

// ---------------------------------------------------------------------------
// Decoy fallback
// ---------------------------------------------------------------------------

async fn fallback(State(state): State<AppState>, uri: Uri) -> Response {
    let path = uri.path();

    if let Some(decoy) = state.decoys.exact(path) {
        return decoy.clone().into_response();
    }

    if state.config.decoy_fallback
        && let Some(decoy) = state.decoys.fallback(path)
    {
        return decoy.into_response();
    }

    (StatusCode::NOT_FOUND, Html(portal::not_found())).into_response()
}

// ---------------------------------------------------------------------------
// Periodic compaction
// ---------------------------------------------------------------------------

async fn compact_loop(store: Arc<IpStore>, interval: Duration) {
    let mut ticker = tokio::time::interval(interval);
    ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
    ticker.tick().await;

    loop {
        ticker.tick().await;
        match store.compact().await {
            Ok(report) => tracing::info!(
                before = report.lines_before,
                unique = report.lines_after,
                duplicates = report.duplicates_removed,
                invalid = report.invalid_removed,
                "compacted ip report"
            ),
            Err(err) => tracing::error!(error = %err, "failed to compact ip report"),
        }
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn random_token(length: usize) -> String {
    rand::thread_rng()
        .sample_iter(&Alphanumeric)
        .take(length)
        .map(char::from)
        .collect()
}

fn human_duration(duration: Duration) -> String {
    let seconds = duration.as_secs();
    let days = seconds / 86_400;
    let hours = (seconds % 86_400) / 3_600;
    let minutes = (seconds % 3_600) / 60;

    if days > 0 {
        format!("{days}d {hours}h {minutes}m")
    } else if hours > 0 {
        format!("{hours}h {minutes}m")
    } else {
        format!("{minutes}m {}s", seconds % 60)
    }
}

async fn shutdown_signal() {
    let ctrl_c = async {
        let _ = tokio::signal::ctrl_c().await;
    };

    #[cfg(unix)]
    let terminate = async {
        match tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate()) {
            Ok(mut signal) => {
                signal.recv().await;
            }
            Err(_) => std::future::pending::<()>().await,
        }
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {}
        _ = terminate => {}
    }

    tracing::info!("shutting down");
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request as HttpRequest;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[test]
    fn durations_are_human_readable() {
        assert_eq!(human_duration(Duration::from_secs(45)), "0m 45s");
        assert_eq!(human_duration(Duration::from_secs(3_725)), "1h 2m");
        assert_eq!(human_duration(Duration::from_secs(90_061)), "1d 1h 1m");
    }

    #[test]
    fn control_characters_are_removed_from_logs() {
        assert_eq!(sanitize("a\nb\tc"), "a?b?c");
    }

    async fn test_app(dir: &tempfile::TempDir) -> (Router, Arc<IpStore>) {
        let config = Config {
            bind: "127.0.0.1:0".parse().unwrap(),
            ip_log_file: dir.path().join("ips.txt"),
            compact_interval: Duration::from_secs(600),
            trust_proxy_headers: true,
            decoy_fallback: true,
        };
        let store = Arc::new(IpStore::new(config.ip_log_file.clone()));
        store.prepare().await.unwrap();
        let state = AppState {
            config: Arc::new(config),
            store: Arc::clone(&store),
            decoys: Arc::new(DecoySet::build()),
            hits: Arc::new(AtomicU64::new(0)),
            csrf: Arc::new("test-token".to_string()),
            started: Instant::now(),
        };
        (router(state), store)
    }

    fn request(path: &str, forwarded_for: &str) -> HttpRequest<Body> {
        HttpRequest::builder()
            .uri(path)
            .header("x-forwarded-for", forwarded_for)
            .extension(ConnectInfo("10.0.0.2:5555".parse::<SocketAddr>().unwrap()))
            .body(Body::empty())
            .unwrap()
    }

    #[tokio::test]
    async fn hostile_requests_are_recorded() {
        let dir = tempfile::tempdir().unwrap();
        let (app, store) = test_app(&dir).await;

        let response = app
            .oneshot(request("/backup.sql", "8.8.8.8"))
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(store.read().await.unwrap(), "8.8.8.8\n");
    }

    #[tokio::test]
    async fn report_and_health_requests_are_not_recorded() {
        let dir = tempfile::tempdir().unwrap();
        let (app, store) = test_app(&dir).await;
        store.record("9.9.9.9".parse().unwrap()).await.unwrap();

        // Public and internal clients can both read the report, and neither
        // request is recorded.
        for (path, forwarded_for) in [
            ("/healthz", "8.8.8.8"),
            ("/report.txt", "8.8.8.8"),
            ("/report.txt", "10.0.0.9"),
        ] {
            let response = app
                .clone()
                .oneshot(request(path, forwarded_for))
                .await
                .unwrap();
            assert_eq!(
                response.status(),
                StatusCode::OK,
                "{path} from {forwarded_for}"
            );
        }

        let response = app
            .clone()
            .oneshot(request("/report.txt", "8.8.8.8"))
            .await
            .unwrap();
        let body = response.into_body().collect().await.unwrap().to_bytes();
        assert_eq!(&body[..], b"9.9.9.9\n");

        assert_eq!(store.read().await.unwrap(), "9.9.9.9\n");
    }

    #[tokio::test]
    async fn internal_peers_are_not_recorded() {
        let dir = tempfile::tempdir().unwrap();
        let (app, store) = test_app(&dir).await;

        let response = app.oneshot(request("/.env", "10.0.0.9")).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(store.read().await.unwrap(), "");
    }
}
