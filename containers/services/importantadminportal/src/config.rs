use std::env;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::time::Duration;

/// Runtime configuration, read from the environment.
#[derive(Clone, Debug)]
pub struct Config {
    /// Address the HTTP server listens on (`BIND_ADDR`, default `0.0.0.0:8080`).
    pub bind: SocketAddr,
    /// File that receives one line per hostile request (`IP_LOG_FILE`).
    pub ip_log_file: PathBuf,
    /// How often the IP log is deduplicated (`COMPACT_INTERVAL_SECS`, default 600).
    pub compact_interval: Duration,
    /// Trust `X-Forwarded-For` / `X-Real-IP` when the direct peer is internal
    /// (`TRUST_PROXY_HEADERS`, default true).
    pub trust_proxy_headers: bool,
    /// Serve a plausible decoy for unknown file-like paths (`DECOY_FALLBACK`, default true).
    pub decoy_fallback: bool,
}

impl Config {
    pub fn from_env() -> Result<Self, String> {
        let bind = env_string("BIND_ADDR", "0.0.0.0:8080")
            .parse()
            .map_err(|err| format!("invalid BIND_ADDR: {err}"))?;

        let data_dir = PathBuf::from(env_string("DATA_DIR", "./data"));
        let ip_log_file = env::var_os("IP_LOG_FILE")
            .map(PathBuf::from)
            .unwrap_or_else(|| data_dir.join("ips.txt"));

        let compact_secs = env_string("COMPACT_INTERVAL_SECS", "600")
            .parse::<u64>()
            .map_err(|err| format!("invalid COMPACT_INTERVAL_SECS: {err}"))?
            .max(10);

        Ok(Self {
            bind,
            ip_log_file,
            compact_interval: Duration::from_secs(compact_secs),
            trust_proxy_headers: env_bool("TRUST_PROXY_HEADERS", true),
            decoy_fallback: env_bool("DECOY_FALLBACK", true),
        })
    }
}

fn env_string(name: &str, default: &str) -> String {
    match env::var(name) {
        Ok(value) if !value.trim().is_empty() => value,
        _ => default.to_string(),
    }
}

fn env_bool(name: &str, default: bool) -> bool {
    match env::var(name) {
        Ok(value) => match value.trim().to_ascii_lowercase().as_str() {
            "1" | "true" | "yes" | "on" => true,
            "0" | "false" | "no" | "off" => false,
            _ => default,
        },
        Err(_) => default,
    }
}
