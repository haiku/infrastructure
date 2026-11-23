//! The fake administration portal that the honeypot presents to visitors.

const CSS: &str = r#"
:root {
  --navy: #14263c;
  --navy-light: #1d3551;
  --ink: #22303f;
  --muted: #6c7a8a;
  --line: #d8e0e8;
  --accent: #2f6fb3;
  --danger: #b23a2e;
  --bg: #eef2f6;
}
* { box-sizing: border-box; }
body { margin: 0; font-family: -apple-system, "Segoe UI", Roboto, Arial, sans-serif; background: var(--bg); color: var(--ink); font-size: 14px; }
a { color: var(--accent); text-decoration: none; }
.login-wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #14263c 0%, #29465f 100%); }
.login-box { background: #fff; width: 380px; padding: 38px 40px 30px; border-radius: 6px; box-shadow: 0 12px 40px rgba(0,0,0,.35); }
.brand { display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
.brand-mark { width: 42px; height: 42px; border-radius: 8px; background: var(--navy); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px; letter-spacing: .5px; }
h1 { font-size: 20px; margin: 0; }
.sub { color: var(--muted); font-size: 12px; margin: 4px 0 24px; }
label { display: block; font-size: 12px; font-weight: 600; color: #41566b; margin: 14px 0 5px; }
input[type=text], input[type=password], select { width: 100%; padding: 9px 10px; border: 1px solid #b9c5d2; border-radius: 3px; font-size: 14px; background: #fbfcfd; }
button { margin-top: 22px; width: 100%; padding: 10px; border: 0; border-radius: 3px; background: var(--accent); color: #fff; font-size: 14px; font-weight: 600; cursor: pointer; }
button:hover { background: #275c94; }
.notice { background: #fff4d6; border: 1px solid #e8cf8b; color: #745400; padding: 9px 11px; border-radius: 3px; font-size: 12px; margin-bottom: 8px; }
.error { background: #fdecea; border: 1px solid #f0c4bf; color: #8f2c22; padding: 9px 11px; border-radius: 3px; font-size: 12px; margin-bottom: 8px; }
.login-foot { margin-top: 26px; padding-top: 14px; border-top: 1px solid var(--line); color: #8b98a6; font-size: 11px; text-align: center; line-height: 1.6; }
.shell { display: flex; min-height: 100vh; }
.side { width: 220px; background: var(--navy); color: #c6d4e2; flex-shrink: 0; }
.side .logo { padding: 20px 18px; border-bottom: 1px solid var(--navy-light); font-weight: 700; color: #fff; font-size: 15px; }
.side .logo span { display: block; font-weight: 400; font-size: 10px; color: #8fa7bd; margin-top: 3px; letter-spacing: .8px; text-transform: uppercase; }
.side nav { padding: 12px 0; }
.side nav a { display: block; padding: 10px 18px; color: #c6d4e2; font-size: 13px; border-left: 3px solid transparent; }
.side nav a:hover, .side nav a.active { background: var(--navy-light); color: #fff; border-left-color: #5d9bd6; }
.main { flex: 1; min-width: 0; }
.top { background: #fff; border-bottom: 1px solid var(--line); padding: 13px 26px; display: flex; align-items: center; justify-content: space-between; }
.top .crumb { color: var(--muted); font-size: 12px; }
.top .who { font-size: 12px; color: var(--muted); }
.top .who b { color: var(--ink); }
.content { padding: 24px 26px 40px; }
.page-title { font-size: 19px; margin: 0 0 4px; }
.page-sub { color: var(--muted); font-size: 12px; margin: 0 0 22px; }
.cards { display: grid; grid-template-columns: repeat(4, minmax(120px, 1fr)); gap: 14px; margin-bottom: 24px; }
.card { background: #fff; border: 1px solid var(--line); border-radius: 5px; padding: 15px 16px; }
.card .k { font-size: 11px; text-transform: uppercase; letter-spacing: .5px; color: var(--muted); }
.card .v { font-size: 24px; font-weight: 700; margin-top: 6px; }
.card .v.bad { color: var(--danger); }
.panel { background: #fff; border: 1px solid var(--line); border-radius: 5px; margin-bottom: 18px; }
.panel h2 { font-size: 14px; margin: 0; padding: 13px 16px; border-bottom: 1px solid var(--line); }
.panel .body { padding: 16px; }
table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; padding: 8px 10px; border-bottom: 1px solid #e9eef3; font-size: 12.5px; }
th { color: var(--muted); font-weight: 600; background: #f7f9fb; }
tr:last-child td { border-bottom: 0; }
.tag { display: inline-block; padding: 2px 7px; border-radius: 9px; font-size: 10.5px; font-weight: 600; }
.tag.ok { background: #e3f4e8; color: #22683a; }
.tag.fail { background: #fbe6e3; color: #99362b; }
.tag.warn { background: #fdf0d5; color: #7a5a05; }
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; }
.foot { color: #8b98a6; font-size: 11px; padding: 16px 26px; border-top: 1px solid var(--line); background: #fff; }
@media (max-width: 860px) { .side { display: none; } .cards { grid-template-columns: repeat(2, 1fr); } }
"#;

fn render(template: &str, values: &[(&str, &str)]) -> String {
    let mut output = template.to_string();
    for (key, value) in values {
        output = output.replace(key, value);
    }
    output
}

pub fn login_page(csrf: &str, error: Option<&str>) -> String {
    let alert = error.map_or_else(String::new, |message| {
        format!("<div class=\"error\" role=\"alert\">{message}</div>")
    });

    render(
        r#"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sign in &middot; Admin Portal</title>
<link rel="stylesheet" href="/assets/portal.css">
<style>__CSS__</style>
</head>
<body>
<div class="login-wrap">
  <div class="login-box">
    <div class="brand">
      <div class="brand-mark">HA</div>
      <div>
        <h1>Admin Portal</h1>
        <p class="sub">Haiku, Inc. &middot; Internal Operations</p>
      </div>
    </div>
    __ALERT__
    <div class="notice">This system is monitored. Unauthorized access is prohibited.</div>
    <form method="post" action="/admin/login" autocomplete="off">
      <input type="hidden" name="csrf_token" value="__CSRF__">
      <label for="username">Username</label>
      <input id="username" name="username" type="text" autocomplete="username" autofocus>
      <label for="password">Password</label>
      <input id="password" name="password" type="password" autocomplete="current-password">
      <label for="domain">Domain</label>
      <select id="domain" name="domain">
        <option value="HAIKU">HAIKU</option>
        <option value="HAIKU-ADMIN">HAIKU-ADMIN</option>
      </select>
      <button type="submit">Sign in</button>
    </form>
    <div class="login-foot">
      Admin Portal v4.12.3 &middot; build 20261103-2<br>
      Authorized personnel only. Sessions are logged and audited.
    </div>
  </div>
</div>
</body>
</html>
"#,
        &[("__CSS__", CSS), ("__ALERT__", &alert), ("__CSRF__", csrf)],
    )
}

pub fn dashboard(csrf: &str, hits: u64, uptime: &str) -> String {
    let body = format!(
        r#"<h1 class="page-title">Operations overview</h1>
<p class="page-sub">Environment: production &middot; cluster acme-prod-use1 &middot; last refresh just now</p>

<div class="cards">
  <div class="card"><div class="k">Active sessions</div><div class="v">37</div></div>
  <div class="card"><div class="k">Failed logins (24h)</div><div class="v bad">{failed}</div></div>
  <div class="card"><div class="k">Hostile requests</div><div class="v">{hits}</div></div>
  <div class="card"><div class="k">Uptime</div><div class="v" style="font-size:16px;padding-top:6px">{uptime}</div></div>
</div>

<div class="panel">
  <h2>Recent authentication attempts</h2>
  <div class="body" style="padding:0">
    <table>
      <tr><th>Time</th><th>Account</th><th>Source</th><th>Result</th></tr>
      <tr><td>2026-11-23 14:02:11</td><td>administrator</td><td class="mono">185.220.101.44</td><td><span class="tag fail">DENIED</span></td></tr>
      <tr><td>2026-11-23 13:58:47</td><td>administrator</td><td class="mono">185.220.101.44</td><td><span class="tag fail">DENIED</span></td></tr>
      <tr><td>2026-11-23 13:44:02</td><td>j.smith</td><td class="mono">10.42.7.19</td><td><span class="tag ok">OK</span></td></tr>
      <tr><td>2026-11-23 13:31:56</td><td>admin</td><td class="mono">45.155.205.233</td><td><span class="tag fail">DENIED</span></td></tr>
      <tr><td>2026-11-23 13:12:40</td><td>m.garcia</td><td class="mono">10.42.7.31</td><td><span class="tag ok">OK</span></td></tr>
      <tr><td>2026-11-23 12:55:18</td><td>root</td><td class="mono">91.240.118.172</td><td><span class="tag fail">DENIED</span></td></tr>
    </table>
  </div>
</div>

<div class="panel">
  <h2>System alerts</h2>
  <div class="body">
    <p style="margin:0 0 8px"><span class="tag warn">WARN</span> &nbsp;Backup verification job <span class="mono">portal-backup-20261122</span> reported 1 missing object in <span class="mono">s3://acme-portal-backups</span>.</p>
    <p style="margin:0 0 8px"><span class="tag warn">WARN</span> &nbsp;TLS certificate for <span class="mono">portal.acme.example</span> expires in 21 days.</p>
    <p style="margin:0"><span class="tag ok">OK</span> &nbsp;All 4 application nodes are responding to health checks.</p>
  </div>
</div>"#,
        failed = 1284 + hits / 3,
        hits = hits,
        uptime = uptime,
    );

    layout("dashboard", "Operations overview", csrf, &body)
}

pub fn users_page(csrf: &str) -> String {
    let body = r#"<h1 class="page-title">Users</h1>
<p class="page-sub">Directory synchronized from ACME-ADMIN every 15 minutes.</p>
<div class="panel">
  <h2>Administrative accounts</h2>
  <div class="body" style="padding:0">
    <table>
      <tr><th>Username</th><th>Display name</th><th>Role</th><th>MFA</th><th>Last login</th></tr>
      <tr><td class="mono">administrator</td><td>Portal Administrator</td><td>superuser</td><td><span class="tag ok">enabled</span></td><td>2026-11-23 09:14</td></tr>
      <tr><td class="mono">j.smith</td><td>Jordan Smith</td><td>operator</td><td><span class="tag ok">enabled</span></td><td>2026-11-23 13:44</td></tr>
      <tr><td class="mono">m.garcia</td><td>Maria Garcia</td><td>operator</td><td><span class="tag ok">enabled</span></td><td>2026-11-23 13:12</td></tr>
      <tr><td class="mono">deploy</td><td>Deployment service</td><td>automation</td><td><span class="tag warn">bypass</span></td><td>2026-11-23 11:02</td></tr>
      <tr><td class="mono">backup</td><td>Backup service</td><td>automation</td><td><span class="tag warn">bypass</span></td><td>2026-11-22 02:00</td></tr>
      <tr><td class="mono">support</td><td>Support desk</td><td>read-only</td><td><span class="tag ok">enabled</span></td><td>2026-11-21 16:37</td></tr>
    </table>
  </div>
</div>
<div class="panel">
  <h2>Pending invitations</h2>
  <div class="body">
    <p style="margin:0">No pending invitations. New accounts must be approved by the security team.</p>
  </div>
</div>"#;

    layout("users", "Users", csrf, body)
}

pub fn settings_page(csrf: &str) -> String {
    let body = r#"<h1 class="page-title">Settings</h1>
<p class="page-sub">Changes are applied immediately and recorded in the audit log.</p>
<div class="panel">
  <h2>Application</h2>
  <div class="body">
    <table>
      <tr><th>Setting</th><th>Value</th></tr>
      <tr><td>Environment</td><td class="mono">production</td></tr>
      <tr><td>Application version</td><td class="mono">4.12.3</td></tr>
      <tr><td>Database host</td><td class="mono">db01.internal:3306</td></tr>
      <tr><td>Redis host</td><td class="mono">redis01.internal:6379</td></tr>
      <tr><td>Backup bucket</td><td class="mono">s3://acme-portal-backups</td></tr>
      <tr><td>Session lifetime</td><td class="mono">480 minutes</td></tr>
      <tr><td>Debug mode</td><td><span class="tag ok">disabled</span></td></tr>
    </table>
  </div>
</div>
<div class="panel">
  <h2>Maintenance</h2>
  <div class="body">
    <p style="margin:0 0 12px">Scheduled maintenance window: Sunday 02:00&ndash;04:00 UTC.</p>
    <button type="button" style="width:auto;margin:0;padding:8px 16px">Run backup verification</button>
  </div>
</div>"#;

    layout("settings", "Settings", csrf, body)
}

pub fn audit_page(csrf: &str) -> String {
    let body = r#"<h1 class="page-title">Audit log</h1>
<p class="page-sub">Retained for 90 days. Export requests go through the security team.</p>
<div class="panel">
  <h2>Latest events</h2>
  <div class="body" style="padding:0">
    <table>
      <tr><th>Timestamp</th><th>Actor</th><th>Source</th><th>Event</th></tr>
      <tr><td class="mono">2026-11-23 14:02:11</td><td>anonymous</td><td class="mono">185.220.101.44</td><td>authentication.failed (2)</td></tr>
      <tr><td class="mono">2026-11-23 13:44:02</td><td class="mono">j.smith</td><td class="mono">10.42.7.19</td><td>session.created</td></tr>
      <tr><td class="mono">2026-11-23 13:31:56</td><td>anonymous</td><td class="mono">45.155.205.233</td><td>authentication.failed (1)</td></tr>
      <tr><td class="mono">2026-11-23 13:20:39</td><td class="mono">deploy</td><td class="mono">10.42.3.8</td><td>deployment.succeeded v4.12.3</td></tr>
      <tr><td class="mono">2026-11-23 12:55:18</td><td>anonymous</td><td class="mono">91.240.118.172</td><td>waf.blocked (path traversal)</td></tr>
      <tr><td class="mono">2026-11-23 11:02:00</td><td class="mono">backup</td><td class="mono">10.42.3.12</td><td>backup.completed 2.4 GB</td></tr>
      <tr><td class="mono">2026-11-23 09:14:33</td><td class="mono">administrator</td><td class="mono">10.42.0.5</td><td>session.created</td></tr>
    </table>
  </div>
</div>"#;

    layout("audit", "Audit log", csrf, body)
}

pub fn backups_page(csrf: &str) -> String {
    let body = r#"<h1 class="page-title">Backups</h1>
<p class="page-sub">Nightly logical database dumps, encrypted with the operations KMS key.</p>
<div class="panel">
  <h2>Recent snapshots</h2>
  <div class="body" style="padding:0">
    <table>
      <tr><th>Snapshot</th><th>Created</th><th>Size</th><th>Retention</th><th>Status</th></tr>
      <tr><td class="mono">portal-backup-20261123</td><td>2026-11-23 02:00</td><td>2.4 GB</td><td>90 days</td><td><span class="tag ok">verified</span></td></tr>
      <tr><td class="mono">portal-backup-20261122</td><td>2026-11-22 02:00</td><td>2.4 GB</td><td>90 days</td><td><span class="tag warn">1 missing object</span></td></tr>
      <tr><td class="mono">portal-backup-20261121</td><td>2026-11-21 02:00</td><td>2.3 GB</td><td>90 days</td><td><span class="tag ok">verified</span></td></tr>
      <tr><td class="mono">portal-backup-20261120</td><td>2026-11-20 02:00</td><td>2.3 GB</td><td>90 days</td><td><span class="tag ok">verified</span></td></tr>
    </table>
  </div>
</div>
<div class="panel">
  <h2>Restore</h2>
  <div class="body">
    <p style="margin:0 0 12px">Restores require a second approver and are limited to the maintenance window.</p>
    <button type="button" style="width:auto;margin:0;padding:8px 16px">Request restore</button>
  </div>
</div>"#;

    layout("backups", "Backups", csrf, body)
}

pub fn integrations_page(csrf: &str) -> String {
    let body = r#"<h1 class="page-title">Integrations</h1>
<p class="page-sub">Service credentials are stored in the ACME vault and rotate every 30 days.</p>
<div class="panel">
  <h2>Connected systems</h2>
  <div class="body" style="padding:0">
    <table>
      <tr><th>Service</th><th>Endpoint</th><th>Auth</th><th>Status</th></tr>
      <tr><td>Acme Directory</td><td class="mono">ldaps://dc01.acme.internal:636</td><td>bind account</td><td><span class="tag ok">connected</span></td></tr>
      <tr><td>Billing API</td><td class="mono">https://billing.acme.example/api/v2</td><td>bearer token</td><td><span class="tag ok">connected</span></td></tr>
      <tr><td>Object storage</td><td class="mono">s3://acme-portal-backups</td><td>IAM role</td><td><span class="tag ok">connected</span></td></tr>
      <tr><td>SMTP relay</td><td class="mono">mail.acme.example:587</td><td>STARTTLS</td><td><span class="tag ok">connected</span></td></tr>
      <tr><td>SIEM forwarder</td><td class="mono">syslog://siem.acme.internal:6514</td><td>mutual TLS</td><td><span class="tag ok">connected</span></td></tr>
    </table>
  </div>
</div>"#;

    layout("integrations", "Integrations", csrf, body)
}

pub fn stylesheet() -> &'static str {
    CSS
}

fn layout(active: &str, title: &str, csrf: &str, body: &str) -> String {
    let nav = [
        ("dashboard", "/admin", "Overview"),
        ("users", "/admin/users", "Users"),
        ("settings", "/admin/settings", "Settings"),
        ("audit", "/admin/audit", "Audit log"),
        ("backups", "/admin/backups", "Backups"),
        ("integrations", "/admin/integrations", "Integrations"),
    ];

    let mut links = String::new();
    for (key, href, label) in nav {
        let class = if key == active {
            " class=\"active\""
        } else {
            ""
        };
        links.push_str(&format!("<a href=\"{href}\"{class}>{label}</a>\n"));
    }

    render(
        r#"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>__TITLE__ &middot; Admin Portal</title>
<link rel="stylesheet" href="/assets/portal.css">
<style>__CSS__</style>
</head>
<body>
<div class="shell">
  <aside class="side">
    <div class="logo">Admin Portal<span>Haiku, Inc.</span></div>
    <nav>
      __NAV__
    </nav>
  </aside>
  <div class="main">
    <div class="top">
      <div class="crumb">Admin / __TITLE__</div>
      <div class="who">Signed in as <b>administrator</b> &middot; <a href="/admin/logout">Sign out</a></div>
    </div>
    <div class="content">
      __BODY__
    </div>
    <div class="foot">Admin Portal v4.12.3 &middot; &copy; 2026 Haiku, Inc. &middot; Authorized use only &middot; <span class="mono">__CSRF__</span></div>
  </div>
</div>
</body>
</html>
"#,
        &[
            ("__TITLE__", title),
            ("__CSS__", CSS),
            ("__NAV__", &links),
            ("__BODY__", body),
            ("__CSRF__", csrf),
        ],
    )
}

pub fn not_found() -> String {
    r#"<!DOCTYPE html>
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.24.0 (Ubuntu)</center>
</body>
</html>
"#
    .to_string()
}

pub fn server_error() -> String {
    r#"<!DOCTYPE html>
<html>
<head><title>500 Internal Server Error</title></head>
<body>
<center><h1>500 Internal Server Error</h1></center>
<hr><center>nginx/1.24.0 (Ubuntu)</center>
</body>
</html>
"#
    .to_string()
}

pub fn robots_txt() -> String {
    "User-agent: *\nDisallow: /admin/\nDisallow: /backup/\nDisallow: /reports/\nDisallow: /config/\nAllow: /\n\n# Internal crawlers must send X-Portal-Key.\n".to_string()
}

pub fn security_txt() -> String {
    "Contact: mailto:security@acme.example\nExpires: 2027-01-01T00:00:00.000Z\nPreferred-Languages: en\nCanonical: https://portal.acme.example/.well-known/security.txt\n".to_string()
}
