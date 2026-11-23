use std::collections::HashMap;
use std::sync::Mutex;

use axum::http::{HeaderName, HeaderValue, StatusCode, header};
use axum::response::{IntoResponse, Response};
use rand::distributions::Alphanumeric;
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};

/// A fake file returned to scanners.
#[derive(Clone)]
pub struct Decoy {
    pub status: StatusCode,
    pub content_type: &'static str,
    pub body: Vec<u8>,
    pub extra_headers: Vec<(&'static str, String)>,
}

impl Decoy {
    fn new(status: StatusCode, content_type: &'static str, body: impl Into<Vec<u8>>) -> Self {
        Self {
            status,
            content_type,
            body: body.into(),
            extra_headers: Vec::new(),
        }
    }

    fn html(body: impl Into<Vec<u8>>) -> Self {
        Self::new(StatusCode::OK, "text/html; charset=utf-8", body)
    }

    fn text(body: impl Into<Vec<u8>>) -> Self {
        Self::new(StatusCode::OK, "text/plain; charset=utf-8", body)
    }

    fn json(body: impl Into<Vec<u8>>) -> Self {
        Self::new(StatusCode::OK, "application/json", body)
    }

    fn with_header(mut self, name: &'static str, value: impl Into<String>) -> Self {
        self.extra_headers.push((name, value.into()));
        self
    }
}

impl IntoResponse for Decoy {
    fn into_response(self) -> Response {
        let mut response = (self.status, self.body).into_response();
        let headers = response.headers_mut();
        if let Ok(value) = HeaderValue::from_str(self.content_type) {
            headers.insert(header::CONTENT_TYPE, value);
        }
        for (name, value) in self.extra_headers {
            if let (Ok(name), Ok(value)) = (
                HeaderName::from_bytes(name.as_bytes()),
                HeaderValue::from_str(&value),
            ) {
                headers.insert(name, value);
            }
        }
        response
    }
}

/// A collection of generated decoy files.
///
/// Contents are generated once at startup with random credentials, so the
/// portal keeps returning the same "leaked" files while still looking unique
/// to each deployment.
pub struct DecoySet {
    exact: HashMap<&'static str, Decoy>,
    rng: Mutex<StdRng>,
}

impl DecoySet {
    pub fn build() -> Self {
        let mut rng = StdRng::from_entropy();
        let mut exact = HashMap::new();

        macro_rules! add {
            ($path:expr, $value:expr) => {
                exact.insert($path, $value);
            };
        }

        add!("/.env", env_file(&mut rng));
        add!("/.env.bak", env_file(&mut rng));
        add!("/.env.local", env_file(&mut rng));
        add!("/.env.production", env_file(&mut rng));
        add!("/.env.dev", env_file(&mut rng));
        add!("/.env.old", env_file(&mut rng));
        add!("/config.php", php_config(&mut rng));
        add!("/config.php.bak", php_config(&mut rng));
        add!("/configuration.php", php_config(&mut rng));
        add!("/wp-config.php", wp_config(&mut rng));
        add!("/wp-config.php.bak", wp_config(&mut rng));
        add!("/.git/config", git_config(&mut rng));
        add!("/.git/HEAD", Decoy::text("ref: refs/heads/main\n"));
        add!("/.git/logs/HEAD", git_log(&mut rng));
        add!("/.aws/credentials", aws_credentials(&mut rng));
        add!("/.aws/config", aws_config(&mut rng));
        add!("/.ssh/id_rsa", private_key(&mut rng));
        add!("/.ssh/id_rsa.pub", public_key(&mut rng));
        add!("/id_rsa", private_key(&mut rng));
        add!("/id_rsa.pub", public_key(&mut rng));
        add!("/backup.sql", sql_dump(&mut rng));
        add!("/db.sql", sql_dump(&mut rng));
        add!("/dump.sql", sql_dump(&mut rng));
        add!("/database.sql", sql_dump(&mut rng));
        add!("/backup/db.sql", sql_dump(&mut rng));
        add!("/logs/error.log", error_log(&mut rng));
        add!("/error.log", error_log(&mut rng));
        add!("/debug.log", error_log(&mut rng));
        add!("/logs/debug.log", error_log(&mut rng));
        add!("/server-status", server_status(&mut rng));
        add!("/actuator/env", actuator_env(&mut rng));
        add!(
            "/actuator/health",
            Decoy::json(r#"{"status":"UP","groups":["liveness","readiness"]}"#,)
        );
        add!("/phpinfo.php", phpinfo(&mut rng));
        add!("/info.php", phpinfo(&mut rng));
        add!("/test.php", phpinfo(&mut rng));
        add!("/phpmyadmin/", phpmyadmin_login(&mut rng));
        add!("/phpmyadmin/index.php", phpmyadmin_login(&mut rng));
        add!("/pma/", phpmyadmin_login(&mut rng));
        add!("/mysql/", phpmyadmin_login(&mut rng));
        add!("/adminer.php", adminer_login(&mut rng));
        add!("/wp-login.php", wp_login(&mut rng));
        add!("/xmlrpc.php", xmlrpc(&mut rng));
        add!("/administrator/", joomla_login(&mut rng));
        add!("/composer.json", composer_json(&mut rng));
        add!("/composer.lock", composer_lock(&mut rng));
        add!("/package.json", package_json(&mut rng));
        add!("/Dockerfile", dockerfile(&mut rng));
        add!("/docker-compose.yml", docker_compose(&mut rng));
        add!("/docker-compose.yaml", docker_compose(&mut rng));
        add!("/terraform.tfstate", terraform_state(&mut rng));
        add!("/.svn/entries", svn_entries());
        add!("/web.config", web_config(&mut rng));
        add!("/sftp-config.json", sftp_config(&mut rng));
        add!("/.ftpconfig", ftp_config(&mut rng));
        add!("/credentials.txt", credentials_txt(&mut rng));
        add!("/passwords.txt", passwords_txt(&mut rng));
        add!("/.htpasswd", htpasswd(&mut rng));
        add!("/crossdomain.xml", crossdomain());
        add!("/owa/auth/logon.aspx", owa_login(&mut rng));
        add!("/remote/login", fortinet_login(&mut rng));
        add!(
            "/dana-na/auth/url_default/welcome.cgi",
            pulse_login(&mut rng)
        );
        add!("/console/", weblogic_login(&mut rng));
        add!("/console/login/LoginForm.jsp", weblogic_login(&mut rng));
        add!(
            "/manager/html",
            tomcat_manager(&mut rng).with_header(
                "www-authenticate",
                "Basic realm=\"Tomcat Manager Application\""
            )
        );
        add!(
            "/vendor/phpunit/phpunit/src/Util/PHP/eval-stdin.php",
            Decoy::text("")
        );
        add!("/.DS_Store", ds_store(&mut rng));
        add!("/backup.zip", backup_zip(&mut rng));
        add!("/old.zip", backup_zip(&mut rng));

        Self {
            exact,
            rng: Mutex::new(rng),
        }
    }

    pub fn exact(&self, path: &str) -> Option<&Decoy> {
        self.exact.get(path)
    }

    /// Generate a plausible file for an unknown path that looks like a file.
    pub fn fallback(&self, path: &str) -> Option<Decoy> {
        let extension = file_extension(path)?;
        let mut rng = self
            .rng
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());

        let decoy = match extension.as_str() {
            "env" => env_file(&mut rng),
            "sql" => sql_dump(&mut rng),
            "php" | "phtml" | "phar" => php_config(&mut rng),
            "json" => sftp_config(&mut rng),
            "xml" => web_config(&mut rng),
            "yml" | "yaml" => docker_compose(&mut rng),
            "conf" | "config" | "ini" | "cnf" => generic_config(&mut rng),
            "log" => error_log(&mut rng),
            "txt" => credentials_txt(&mut rng),
            "csv" => csv_dump(&mut rng),
            "pem" | "key" | "crt" | "cer" => private_key(&mut rng),
            "bak" | "old" | "save" | "orig" | "swp" | "tmp" => generic_backup(&mut rng),
            "zip" | "tar" | "gz" | "tgz" | "rar" | "7z" => backup_zip(&mut rng),
            "sh" | "bash" => shell_script(&mut rng),
            "htpasswd" => htpasswd(&mut rng),
            "tfstate" => terraform_state(&mut rng),
            _ => generic_config(&mut rng),
        };

        Some(decoy)
    }
}

/// Return a short lower-case extension for file-like paths, or None for
/// things that look like pages and directories.
fn file_extension(path: &str) -> Option<String> {
    if path.ends_with('/') {
        return None;
    }

    let name = path.rsplit('/').next()?;
    if name.is_empty() {
        return None;
    }

    // Dotfiles such as /.env, /.gitignore
    if let Some(rest) = name.strip_prefix('.')
        && !rest.contains('.')
    {
        return Some(rest.to_ascii_lowercase());
    }

    let (stem, extension) = name.rsplit_once('.')?;
    if stem.is_empty() || extension.is_empty() || extension.len() > 12 {
        return None;
    }
    Some(extension.to_ascii_lowercase())
}

// ---------------------------------------------------------------------------
// Random helpers
// ---------------------------------------------------------------------------

fn alnum(rng: &mut StdRng, length: usize) -> String {
    (0..length)
        .map(|_| rng.sample(Alphanumeric) as char)
        .collect()
}

fn lower(rng: &mut StdRng, length: usize) -> String {
    (0..length)
        .map(|_| {
            let c = rng.sample(Alphanumeric).to_ascii_lowercase();
            c as char
        })
        .collect()
}

fn hex(rng: &mut StdRng, length: usize) -> String {
    const HEX: &[u8] = b"0123456789abcdef";
    (0..length)
        .map(|_| HEX[rng.gen_range(0..HEX.len())] as char)
        .collect()
}

fn number(rng: &mut StdRng, min: u64, max: u64) -> u64 {
    rng.gen_range(min..=max)
}

fn password(rng: &mut StdRng, length: usize) -> String {
    const SYMBOLS: &[u8] = b"!@#$%^&*-_=+";
    (0..length)
        .map(|_| {
            if rng.gen_bool(0.12) {
                SYMBOLS[rng.gen_range(0..SYMBOLS.len())] as char
            } else if rng.gen_bool(0.5) {
                rng.sample(Alphanumeric) as char
            } else {
                rng.sample(Alphanumeric).to_ascii_lowercase() as char
            }
        })
        .collect()
}

fn uuid(rng: &mut StdRng) -> String {
    format!(
        "{}-{}-4{}-a{}-{}",
        hex(rng, 8),
        hex(rng, 4),
        hex(rng, 3),
        hex(rng, 3),
        hex(rng, 12)
    )
}

fn bcrypt(rng: &mut StdRng) -> String {
    let mut hash = String::from("$2y$10$");
    hash.push_str(&alnum(rng, 53));
    hash
}

fn internal_ip(rng: &mut StdRng) -> String {
    format!("10.42.{}.{}", number(rng, 1, 32), number(rng, 2, 250))
}

fn public_ip(rng: &mut StdRng) -> String {
    format!(
        "{}.{}.{}.{}",
        number(rng, 1, 223),
        number(rng, 1, 254),
        number(rng, 1, 254),
        number(rng, 1, 254)
    )
}

fn timestamp(rng: &mut StdRng) -> String {
    format!(
        "2026-{:02}-{:02} {:02}:{:02}:{:02}",
        number(rng, 1, 11),
        number(rng, 1, 28),
        number(rng, 0, 23),
        number(rng, 0, 59),
        number(rng, 0, 59)
    )
}

fn expires(rng: &mut StdRng) -> String {
    format!("2026-{:02}-{:02}", number(rng, 2, 12), number(rng, 1, 28))
}

fn render(template: &str, values: &[(&str, &str)]) -> String {
    let mut output = template.to_string();
    for (key, value) in values {
        output = output.replace(key, value);
    }
    output
}

// ---------------------------------------------------------------------------
// Leaked configuration files
// ---------------------------------------------------------------------------

fn env_file(rng: &mut StdRng) -> Decoy {
    let app_key = format!("base64:{}", alnum(rng, 44));
    let db_password = password(rng, 18);
    let redis_password = password(rng, 20);
    let aws_key = format!("AKIA{}", alnum(rng, 16).to_ascii_uppercase());
    let aws_secret = alnum(rng, 40);
    let secret = hex(rng, 64);
    let ip = internal_ip(rng);
    let body = render(
        r#"APP_NAME="Important Admin Portal"
APP_ENV=production
APP_KEY=__APP_KEY__
APP_DEBUG=false
APP_URL=https://portal.acme.example
APP_TIMEZONE=UTC
LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=__IP__
DB_PORT=3306
DB_DATABASE=admin_portal
DB_USERNAME=portal_app
DB_PASSWORD=__DB_PASS__

CACHE_DRIVER=redis
REDIS_HOST=__IP__
REDIS_PORT=6379
REDIS_PASSWORD=__REDIS_PASS__

MAIL_MAILER=smtp
MAIL_HOST=mail.acme.example
MAIL_PORT=587
MAIL_USERNAME=alerts@acme.example
MAIL_PASSWORD=__MAIL_PASS__
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="alerts@acme.example"

AWS_ACCESS_KEY_ID=__AWS_KEY__
AWS_SECRET_ACCESS_KEY=__AWS_SECRET__
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=acme-portal-backups

JWT_SECRET=__SECRET__
SESSION_LIFETIME=480
"#,
        &[
            ("__APP_KEY__", &app_key),
            ("__IP__", &ip),
            ("__DB_PASS__", &db_password),
            ("__REDIS_PASS__", &redis_password),
            ("__MAIL_PASS__", &password(rng, 16)),
            ("__AWS_KEY__", &aws_key),
            ("__AWS_SECRET__", &aws_secret),
            ("__SECRET__", &secret),
        ],
    );
    Decoy::text(body)
}

fn php_config(rng: &mut StdRng) -> Decoy {
    let body = format!(
        r#"<?php
// Database configuration - generated by install.php
$db_host = '{ip}';
$db_name = 'admin_portal';
$db_user = 'portal_app';
$db_pass = '{pass}';
$db_charset = 'utf8mb4';

$mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($mysqli->connect_errno) {{
    error_log('DB connection failed: ' . $mysqli->connect_error);
}}

define('AUTH_SALT', '{salt}');
define('SECRET_KEY', '{secret}');
define('ADMIN_EMAIL', 'administrator@acme.example');
define('DEBUG_MODE', false);
"#,
        ip = internal_ip(rng),
        pass = password(rng, 18),
        salt = hex(rng, 32),
        secret = hex(rng, 48),
    );
    Decoy::text(body)
}

fn wp_config(rng: &mut StdRng) -> Decoy {
    let mut salts = String::new();
    for key in [
        "AUTH_KEY",
        "SECURE_AUTH_KEY",
        "LOGGED_IN_KEY",
        "NONCE_KEY",
        "AUTH_SALT",
        "SECURE_AUTH_SALT",
        "LOGGED_IN_SALT",
        "NONCE_SALT",
    ] {
        salts.push_str(&format!("define( '{key}', '{}' );\n", password(rng, 58)));
    }

    let body = format!(
        r#"<?php
/**
 * The base configuration for WordPress
 */

define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wp_admin' );
define( 'DB_PASSWORD', '{pass}' );
define( 'DB_HOST', '{ip}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

{salts}
$table_prefix = 'wp_';

define( 'WP_DEBUG', false );
define( 'WP_HOME', 'https://portal.acme.example' );
define( 'WP_SITEURL', 'https://portal.acme.example' );
define( 'DISALLOW_FILE_EDIT', true );

if ( ! defined( 'ABSPATH' ) ) {{
    define( 'ABSPATH', __DIR__ . '/' );
}}

require_once ABSPATH . 'wp-settings.php';
"#,
        pass = password(rng, 22),
        ip = internal_ip(rng),
        salts = salts,
    );
    Decoy::text(body)
}

fn git_config(rng: &mut StdRng) -> Decoy {
    let token = format!("ghp_{}", alnum(rng, 36));
    let body = format!(
        r#"[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = https://deploy:{token}@github.com/acme/important-admin-portal.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
[user]
	name = Deploy Bot
	email = deploy@acme.example
"#
    );
    Decoy::text(body)
}

fn git_log(rng: &mut StdRng) -> Decoy {
    let mut body = String::new();
    for _ in 0..8 {
        let hash = hex(rng, 40);
        body.push_str(&format!(
            "{hash} {hash} Deploy Bot <deploy@acme.example> {} +0000\tcommit: deploy portal v4.12.{}\n",
            number(rng, 1_750_000_000, 1_790_000_000),
            number(rng, 1, 9),
        ));
    }
    Decoy::text(body)
}

fn aws_credentials(rng: &mut StdRng) -> Decoy {
    let body = format!(
        "[default]\naws_access_key_id = AKIA{}\naws_secret_access_key = {}\nregion = us-east-1\n\n[backup]\naws_access_key_id = AKIA{}\naws_secret_access_key = {}\nregion = us-west-2\n",
        alnum(rng, 16).to_ascii_uppercase(),
        alnum(rng, 40),
        alnum(rng, 16).to_ascii_uppercase(),
        alnum(rng, 40),
    );
    Decoy::text(body)
}

fn aws_config(rng: &mut StdRng) -> Decoy {
    let body = format!(
        "[default]\nregion = us-east-1\noutput = json\n\n[profile deploy]\nregion = us-east-1\nrole_arn = arn:aws:iam::{}:role/portal-deploy\nsource_profile = default\n",
        number(rng, 100_000_000_000, 999_999_999_999),
    );
    Decoy::text(body)
}

fn private_key(rng: &mut StdRng) -> Decoy {
    let mut body = String::from("-----BEGIN OPENSSH PRIVATE KEY-----\n");
    for _ in 0..24 {
        body.push_str(&alnum(rng, 64));
        body.push('\n');
    }
    body.push_str("-----END OPENSSH PRIVATE KEY-----\n");
    Decoy::text(body)
}

fn public_key(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI{} deploy@build01\n",
        alnum(rng, 43)
    ))
}

fn sql_dump(rng: &mut StdRng) -> Decoy {
    let mut body = String::from(
        "-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)\n--\n-- Host: db01.internal    Database: admin_portal\n-- ------------------------------------------------------\n-- Server version\t8.0.36-0ubuntu0.22.04.1\n\n/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;\n/*!40101 SET NAMES utf8mb4 */;\n\nDROP TABLE IF EXISTS `users`;\nCREATE TABLE `users` (\n  `id` int NOT NULL AUTO_INCREMENT,\n  `username` varchar(64) NOT NULL,\n  `email` varchar(190) NOT NULL,\n  `password` varchar(255) NOT NULL,\n  `role` varchar(32) NOT NULL DEFAULT 'user',\n  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `users_username_unique` (`username`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n",
    );

    let names = [
        "administrator",
        "j.smith",
        "m.garcia",
        "ops",
        "deploy",
        "r.johnson",
        "k.williams",
        "backup",
        "support",
        "a.chen",
    ];
    for (index, name) in names.iter().enumerate() {
        body.push_str(&format!(
            "INSERT INTO `users` VALUES ({},'{}','{}@acme.example','{}','{}','{} 09:{}:00');\n",
            index + 1,
            name,
            name.replace('.', ""),
            bcrypt(rng),
            if *name == "administrator" {
                "admin"
            } else {
                "user"
            },
            number(rng, 1, 12),
            number(rng, 1, 28),
        ));
    }

    body.push_str("\nDROP TABLE IF EXISTS `api_tokens`;\nCREATE TABLE `api_tokens` (\n  `id` int NOT NULL AUTO_INCREMENT,\n  `user_id` int NOT NULL,\n  `token` varchar(128) NOT NULL,\n  `expires_at` datetime NOT NULL,\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\n\n");
    for index in 0..5 {
        body.push_str(&format!(
            "INSERT INTO `api_tokens` VALUES ({}, {}, '{}', '{} 00:00:00');\n",
            index + 1,
            number(rng, 1, 10),
            hex(rng, 64),
            expires(rng),
        ));
    }

    body.push_str("\n/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;\n");
    Decoy::text(body)
}

fn csv_dump(rng: &mut StdRng) -> Decoy {
    let mut body = String::from("id,username,email,password_hash,created_at\n");
    for index in 0..25 {
        body.push_str(&format!(
            "{},user{},user{}@acme.example,{},{}\n",
            index + 1,
            number(rng, 100, 999),
            number(rng, 10, 99),
            bcrypt(rng),
            timestamp(rng),
        ));
    }
    Decoy::text(body)
}

fn generic_config(rng: &mut StdRng) -> Decoy {
    let body = format!(
        "# application configuration\n[database]\nhost = {}\nport = 5432\nname = admin_portal\nuser = postgres\npassword = {}\n\n[server]\nbind = 0.0.0.0:8080\nadmin_token = {}\nsecret = {}\n\n[mail]\nsmtp_host = mail.acme.example\nsmtp_user = alerts@acme.example\nsmtp_password = {}\n",
        internal_ip(rng),
        password(rng, 18),
        hex(rng, 32),
        hex(rng, 48),
        password(rng, 16),
    );
    Decoy::text(body)
}

fn generic_backup(rng: &mut StdRng) -> Decoy {
    let body = format!(
        "<?php\n// Backup generated {} - do not commit\n$config = [\n    'host' => '{}',\n    'database' => 'admin_portal',\n    'username' => 'portal_app',\n    'password' => '{}',\n    'api_key' => '{}',\n];\n",
        timestamp(rng),
        internal_ip(rng),
        password(rng, 18),
        hex(rng, 40),
    );
    Decoy::text(body)
}

fn shell_script(rng: &mut StdRng) -> Decoy {
    let body = format!(
        "#!/bin/bash\nset -e\n\nDB_HOST={}\nDB_USER=portal_app\nDB_PASS='{}'\n\nmysqldump -h \"$DB_HOST\" -u \"$DB_USER\" -p\"$DB_PASS\" admin_portal > /var/backups/admin_portal.sql\ntar czf /var/backups/config-$(date +%F).tar.gz /var/www/portal/.env\n",
        internal_ip(rng),
        password(rng, 18),
    );
    Decoy::text(body)
}

fn htpasswd(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        "administrator:$apr1${}${}\nbackup:$apr1${}${}\n",
        alnum(rng, 8),
        alnum(rng, 22),
        alnum(rng, 8),
        alnum(rng, 22),
    ))
}

fn credentials_txt(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        "VPN / jump host\nuser: vpnadmin\npassword: {}\n\nDatabase (db01.internal)\nuser: portal_app\npassword: {}\n\nAWS console\nuser: deploy@acme.example\npassword: {}\nMFA: disabled temporarily\n",
        password(rng, 14),
        password(rng, 18),
        password(rng, 16),
    ))
}

fn passwords_txt(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        "admin: {}\nroot: {}\npostgres: {}\nportal_app: {}\nredis: {}\n",
        password(rng, 14),
        password(rng, 14),
        password(rng, 16),
        password(rng, 18),
        password(rng, 20),
    ))
}

fn sftp_config(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
    "type": "sftp",
    "save_before_upload": true,
    "upload_on_save": true,
    "sync_down_on_open": false,
    "host": "{ip}",
    "user": "deploy",
    "port": "22",
    "remote_path": "/var/www/portal",
    "password": "{pass}",
    "connect_timeout": 10,
    "sftp_flags": ["-o", "StrictHostKeyChecking=no"]
}}"#,
        ip = internal_ip(rng),
        pass = password(rng, 18),
    ))
}

fn ftp_config(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
    "protocol": "sftp",
    "host": "{}",
    "port": 22,
    "user": "deploy",
    "pass": "{}",
    "remotePath": "/var/www/portal",
    "uploadOnSave": true
}}"#,
        internal_ip(rng),
        password(rng, 18),
    ))
}

fn composer_json(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
    "name": "acme/important-admin-portal",
    "description": "Internal administration portal",
    "type": "project",
    "license": "proprietary",
    "repositories": [
        {{
            "type": "composer",
            "url": "https://repo.acme.example",
            "options": {{
                "http": {{
                    "header": "Authorization: Bearer {}"
                }}
            }}
        }}
    ],
    "require": {{
        "php": "^8.2",
        "laravel/framework": "^10.48",
        "guzzlehttp/guzzle": "^7.8",
        "doctrine/dbal": "^3.8"
    }},
    "config": {{
        "optimize-autoloader": true,
        "preferred-install": "dist"
    }}
}}"#,
        hex(rng, 40),
    ))
}

fn composer_lock(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
    "_readme": ["This file locks the dependencies of your project to a known state"],
    "content-hash": "{}",
    "packages": [
        {{
            "name": "laravel/framework",
            "version": "v10.48.12",
            "source": {{
                "type": "git",
                "url": "https://github.com/laravel/framework.git",
                "reference": "{}"
            }}
        }}
    ],
    "packages-dev": [],
    "aliases": [],
    "minimum-stability": "stable",
    "stability-flags": [],
    "prefer-stable": true,
    "prefer-lowest": false,
    "platform": {{"php": "^8.2"}},
    "plugin-api-version": "2.6.0"
}}"#,
        hex(rng, 32),
        hex(rng, 40),
    ))
}

fn package_json(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
  "name": "important-admin-portal",
  "version": "4.12.3",
  "private": true,
  "scripts": {{
    "dev": "vite",
    "build": "vite build",
    "deploy": "rsync -az dist/ deploy@{ip}:/var/www/portal/public/"
  }},
  "dependencies": {{
    "axios": "^1.7.2",
    "vue": "^3.4.31"
  }},
  "publishConfig": {{
    "registry": "https://npm.acme.example",
    "_authToken": "npm_{pass}"
  }}
}}"#,
        ip = internal_ip(rng),
        pass = alnum(rng, 36),
    ))
}

fn dockerfile(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        "FROM php:8.2-apache\n\nRUN docker-php-ext-install pdo_mysql mysqli\n\nENV APP_ENV=production \\\n    APP_DEBUG=false \\\n    DB_HOST={} \\\n    DB_PASSWORD={}\n\nCOPY . /var/www/html/\nRUN chown -R www-data:www-data /var/www/html/storage\n\nEXPOSE 80\n",
        internal_ip(rng),
        password(rng, 18),
    ))
}

fn docker_compose(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        r#"version: "3.9"

services:
  portal:
    image: registry.acme.example/important-admin-portal:4.12.3
    restart: always
    environment:
      APP_ENV: production
      DB_HOST: db
      DB_DATABASE: admin_portal
      DB_USERNAME: portal_app
      DB_PASSWORD: {db_pass}
      REDIS_PASSWORD: {redis_pass}
    ports:
      - "8080:80"
    volumes:
      - portal-data:/var/www/html/storage

  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: {root_pass}
      MYSQL_DATABASE: admin_portal
      MYSQL_USER: portal_app
      MYSQL_PASSWORD: {db_pass}
    volumes:
      - db-data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass {redis_pass}

volumes:
  portal-data:
  db-data:
"#,
        db_pass = password(rng, 18),
        root_pass = password(rng, 20),
        redis_pass = password(rng, 20),
    ))
}

fn web_config(rng: &mut StdRng) -> Decoy {
    Decoy::text(format!(
        r#"<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <directoryBrowse enabled="false" />
    <defaultDocument>
      <files>
        <add value="index.php" />
      </files>
    </defaultDocument>
  </system.webServer>
  <connectionStrings>
    <add name="PortalDb" connectionString="Server={};Database=admin_portal;User Id=portal_app;Password={};" providerName="MySql.Data.MySqlClient" />
  </connectionStrings>
  <appSettings>
    <add key="ApiKey" value="{}" />
    <add key="SmtpPassword" value="{}" />
  </appSettings>
</configuration>
"#,
        internal_ip(rng),
        password(rng, 18),
        hex(rng, 32),
        password(rng, 16),
    ))
}

fn terraform_state(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{
  "version": 4,
  "terraform_version": "1.8.5",
  "serial": {},
  "lineage": "{}",
  "outputs": {{
    "database_password": {{
      "value": "{}",
      "type": "string"
    }},
    "admin_bucket": {{
      "value": "acme-portal-backups-prod",
      "type": "string"
    }}
  }},
  "resources": [
    {{
      "mode": "managed",
      "type": "aws_iam_access_key",
      "name": "deploy",
      "provider": "provider[\\"registry.terraform.io/hashicorp/aws\\"]",
      "instances": [
        {{
          "attributes": {{
            "id": "AKIA{}",
            "secret": "{}",
            "user": "portal-deploy"
          }}
        }}
      ]
    }}
  ]
}}"#,
        number(rng, 20, 90),
        uuid(rng),
        password(rng, 20),
        alnum(rng, 16).to_ascii_uppercase(),
        alnum(rng, 40),
    ))
}

fn svn_entries() -> Decoy {
    Decoy::text(
        "12\ndir\n864\nhttps://svn.acme.example/repos/portal\nhttps://svn.acme.example/repos/portal\n2025-11-03T18:22:41.000000Z\n",
    )
}

fn crossdomain() -> Decoy {
    Decoy::text(
        r#"<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" />
  <allow-http-request-headers-from domain="*" headers="*"/>
</cross-domain-policy>
"#,
    )
}

fn backup_zip(rng: &mut StdRng) -> Decoy {
    let mut body = b"PK\x03\x04\x14\x00\x00\x00\x08\x00".to_vec();
    body.extend_from_slice(&[
        rng.r#gen::<u8>(),
        rng.r#gen::<u8>(),
        rng.r#gen::<u8>(),
        rng.r#gen::<u8>(),
    ]);
    for _ in 0..512 {
        body.push(rng.r#gen::<u8>());
    }
    Decoy::new(StatusCode::OK, "application/zip", body)
        .with_header("content-disposition", "attachment; filename=\"backup.zip\"")
}

fn ds_store(rng: &mut StdRng) -> Decoy {
    let mut body = vec![0u8, 0, 0, 0, 1, 0x42, 0x75, 0x64, 0x31];
    for _ in 0..384 {
        body.push(rng.r#gen::<u8>());
    }
    Decoy::new(StatusCode::OK, "application/octet-stream", body)
}

// ---------------------------------------------------------------------------
// Logs and status endpoints
// ---------------------------------------------------------------------------

fn error_log(rng: &mut StdRng) -> Decoy {
    let mut body = String::new();
    for _ in 0..25 {
        let level = ["error", "warning", "notice", "error"][number(rng, 0, 3) as usize];
        body.push_str(&format!(
            "[{}] [php:{}] [client {}] PHP {}: mysqli::real_connect(): (HY000/2002): Connection refused in /var/www/portal/includes/db.php on line {}\n",
            timestamp(rng),
            level,
            public_ip(rng),
            level,
            number(rng, 20, 400),
        ));
    }
    Decoy::text(body)
}

fn server_status(rng: &mut StdRng) -> Decoy {
    let mut rows = String::new();
    for _ in 0..14 {
        rows.push_str(&format!(
            "<tr><td><b>{}</b></td><td>{}:{}&nbsp;</td><td>0&nbsp;</td><td>GET /admin/dashboard HTTP/1.1&nbsp;</td><td>portal.acme.example</td><td>{}&nbsp;</td><td>0&nbsp;</td><td>{}&nbsp;</td><td>1.2&nbsp;</td><td>{}&nbsp;</td><td>0&nbsp;</td></tr>\n",
            number(rng, 1000, 9000),
            internal_ip(rng),
            number(rng, 30000, 65000),
            number(rng, 1000, 90000),
            number(rng, 1, 900),
            public_ip(rng),
        ));
    }
    Decoy::html(format!(
        "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\n<html><head><title>Apache Server Status for portal.acme.example</title></head><body>\n<h1>Apache Server Status for portal.acme.example</h1>\n<dl><dt>Server Version: Apache/2.4.52 (Ubuntu) OpenSSL/3.0.2</dt><dt>Server MPM: event</dt><dt>Server Built: 2025-10-02T13:11:22</dt></dl>\n<p>Current Time: {}<br />Restart Time: {}<br />Parent Server Config. Generation: 3<br />Parent Server MPM Generation: 1<br />Server uptime: 27 days 4 hours 11 minutes 9 seconds<br />Total accesses: 1842911 - Total Traffic: 12.4 GB</p>\n<table border=\"1\"><tr><th>Srv</th><th>PID</th><th>Acc</th><th>M</th><th>CPU</th><th>SS</th><th>Req</th><th>Conn</th><th>Child</th><th>Slot</th><th>Client</th><th>VHost</th><th>Request</th></tr>\n{}</table>\n</body></html>\n",
        timestamp(rng),
        timestamp(rng),
        rows,
    ))
}

fn actuator_env(rng: &mut StdRng) -> Decoy {
    Decoy::json(format!(
        r#"{{"activeProfiles":["prod"],"propertySources":[{{"name":"systemEnvironment","properties":{{"spring.datasource.url":{{"value":"jdbc:mysql://{}:3306/admin_portal"}},"spring.datasource.username":{{"value":"portal_app"}},"spring.datasource.password":{{"value":"{}"}},"spring.security.user.password":{{"value":"{}"}},"aws.accessKeyId":{{"value":"AKIA{}"}},"aws.secretKey":{{"value":"{}"}}}}}}]}}"#,
        internal_ip(rng),
        password(rng, 18),
        password(rng, 18),
        alnum(rng, 16).to_ascii_uppercase(),
        alnum(rng, 40),
    ))
}

// ---------------------------------------------------------------------------
// Login pages for well-known admin software
// ---------------------------------------------------------------------------

const LOGIN_CSS: &str = r#"body{font-family:Arial,Helvetica,sans-serif;background:#eef1f5;margin:0;display:flex;align-items:center;justify-content:center;min-height:100vh}.box{background:#fff;border:1px solid #c8d0da;border-radius:6px;padding:32px 36px;width:340px;box-shadow:0 2px 10px rgba(0,0,0,.08)}h1{font-size:19px;margin:0 0 6px;color:#243447}p.sub{color:#6b7a8c;font-size:12px;margin:0 0 20px}label{display:block;font-size:12px;color:#41566b;margin:12px 0 4px}input[type=text],input[type=password]{width:100%;box-sizing:border-box;padding:8px;border:1px solid #b8c4d0;border-radius:3px}button{margin-top:18px;width:100%;padding:9px;background:#2563a8;border:0;border-radius:3px;color:#fff;font-size:14px;cursor:pointer}.err{background:#fdecea;border:1px solid #f5c6c2;color:#9b2c22;font-size:12px;padding:8px;margin-bottom:14px;border-radius:3px}.foot{margin-top:22px;font-size:11px;color:#8a98a8;text-align:center}"#;

fn phpmyadmin_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>phpMyAdmin</title><style>{css}</style></head>
<body><div class="box"><h1>phpMyAdmin 5.2.1</h1><p class="sub">MySQL administration &mdash; portal.acme.example</p>
<form method="post" action="/phpmyadmin/index.php">
<input type="hidden" name="token" value="{token}">
<input type="hidden" name="set_session" value="{session}">
<label for="user">Username</label><input id="user" name="pma_username" type="text" autocomplete="username">
<label for="pass">Password</label><input id="pass" name="pma_password" type="password" autocomplete="current-password">
<button type="submit">Log in</button></form>
<div class="foot">Server: db01.internal &middot; Language: English</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = alnum(rng, 32),
        session = lower(rng, 26),
    ))
}

fn adminer_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>Adminer 4.8.1</title><style>{css}</style></head>
<body><div class="box"><h1>Adminer</h1><p class="sub">Database administration</p>
<form method="post" action="/adminer.php">
<label>System</label><input type="text" name="auth[driver]" value="server" readonly>
<label>Server</label><input type="text" name="auth[server]" value="db01.internal">
<label>Username</label><input type="text" name="auth[username]" value="portal_app">
<label>Password</label><input type="password" name="auth[password]">
<label>Database</label><input type="text" name="auth[db]" value="admin_portal">
<input type="hidden" name="token" value="{token}">
<button type="submit">Login</button></form>
<div class="foot">Adminer 4.8.1 &middot; MySQL</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = hex(rng, 20),
    ))
}

fn wp_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>Log In &lsaquo; Important Admin Portal &#8212; WordPress</title><style>{css}</style></head>
<body><div class="box"><h1>Important Admin Portal</h1><p class="sub">Powered by WordPress</p>
<form method="post" action="/wp-login.php">
<label for="user">Username or Email Address</label><input id="user" name="log" type="text">
<label for="pass">Password</label><input id="pass" name="pwd" type="password">
<input type="hidden" name="wp-submit" value="Log In">
<input type="hidden" name="redirect_to" value="https://portal.acme.example/wp-admin/">
<input type="hidden" name="testcookie" value="{token}">
<button type="submit">Log In</button></form>
<div class="foot"><a href="/wp-login.php?action=lostpassword">Lost your password?</a></div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = lower(rng, 12),
    ))
}

fn xmlrpc(rng: &mut StdRng) -> Decoy {
    Decoy::new(
        StatusCode::OK,
        "text/xml; charset=utf-8",
        format!(
            r#"<?xml version="1.0" encoding="UTF-8"?>
<methodResponse><fault><value><struct>
<member><name>faultCode</name><value><int>403</int></value></member>
<member><name>faultString</name><value><string>XML-RPC services are disabled on this site. ({})</string></value></member>
</struct></value></fault></methodResponse>
"#,
            hex(rng, 12),
        ),
    )
}

fn joomla_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>Joomla! Administration</title><style>{css}</style></head>
<body><div class="box"><h1>Joomla! Administration</h1><p class="sub">portal.acme.example &middot; Joomla 4.4.5</p>
<form method="post" action="/administrator/index.php">
<label for="user">Username</label><input id="user" name="username" type="text">
<label for="pass">Password</label><input id="pass" name="passwd" type="password">
<input type="hidden" name="option" value="com_login">
<input type="hidden" name="task" value="login">
<input type="hidden" name="return" value="{return_url}">
<button type="submit">Log in</button></form>
<div class="foot">Joomla! is free software released under the GNU General Public License.</div></div></body></html>
"#,
        css = LOGIN_CSS,
        return_url = alnum(rng, 32),
    ))
}

fn owa_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Outlook Web App</title><style>{css}</style></head>
<body><div class="box"><h1>Outlook Web App</h1><p class="sub">mail.acme.example</p>
<form method="post" action="/owa/auth.owa">
<label>Domain\user name</label><input type="text" name="username" autocomplete="username">
<label>Password</label><input type="password" name="password" autocomplete="current-password">
<input type="hidden" name="destination" value="https://mail.acme.example/owa/">
<button type="submit">Sign in</button></form>
<div class="foot">Exchange Server 2019 &middot; cookies required &middot; {token}</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = hex(rng, 12),
    ))
}

fn fortinet_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>SSL VPN</title><style>{css}</style></head>
<body><div class="box"><h1>FortiGate SSL VPN</h1><p class="sub">vpn.acme.example</p>
<form method="post" action="/remote/logincheck">
<label>User Name</label><input type="text" name="username" autocomplete="username">
<label>Password</label><input type="password" name="credential" autocomplete="current-password">
<input type="hidden" name="realm" value="">
<button type="submit">Login</button></form>
<div class="foot">FortiOS v7.0.12 &middot; {token}</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = hex(rng, 16),
    ))
}

fn pulse_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Pulse Secure</title><style>{css}</style></head>
<body><div class="box"><h1>Pulse Secure</h1><p class="sub">Connect to vpn.acme.example</p>
<form method="post" action="/dana-na/auth/url_default/login.cgi">
<label>Username</label><input type="text" name="username" autocomplete="username">
<label>Password</label><input type="password" name="password" autocomplete="current-password">
<label>Realm</label><input type="text" name="realm" value="Users">
<button type="submit">Sign In</button></form>
<div class="foot">Pulse Connect Secure 9.1R18 &middot; {token}</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = alnum(rng, 24),
    ))
}

fn weblogic_login(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Oracle WebLogic Server Administration Console</title><style>{css}</style></head>
<body><div class="box"><h1>Oracle WebLogic Server</h1><p class="sub">Administration Console 12.2.1.4</p>
<form method="post" action="/console/j_security_check">
<label>Username</label><input type="text" name="j_username" autocomplete="username">
<label>Password</label><input type="password" name="j_password" autocomplete="current-password">
<input type="hidden" name="j_character_encoding" value="UTF-8">
<button type="submit">Log In</button></form>
<div class="foot">Domain: acme_prod &middot; {token}</div></div></body></html>
"#,
        css = LOGIN_CSS,
        token = hex(rng, 16),
    ))
}

fn tomcat_manager(rng: &mut StdRng) -> Decoy {
    Decoy::new(
        StatusCode::UNAUTHORIZED,
        "text/html; charset=utf-8",
        format!(
            "<!DOCTYPE html>\n<html><head><title>Apache Tomcat/9.0.89 - Error report</title></head><body><h1>HTTP Status 401 &ndash; Unauthorized</h1><p><b>Message</b> {}</p><p><b>Description</b> The server requested authentication.</p></body></html>",
            alnum(rng, 24),
        ),
    )
}

// ---------------------------------------------------------------------------
// phpinfo
// ---------------------------------------------------------------------------

fn phpinfo(rng: &mut StdRng) -> Decoy {
    Decoy::html(format!(
        r#"<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>phpinfo()</title><style>body{{font-family:sans-serif;font-size:13px}}table{{border-collapse:collapse;margin-bottom:14px}}td,th{{border:1px solid #ccc;padding:3px 8px;text-align:left}}th{{background:#eee}}h1{{font-size:20px}}h2{{font-size:16px;background:#ddd;padding:4px}}</style></head>
<body><h1>PHP Version 8.2.12</h1>
<table><tr><td>System</td><td>Linux portal-01 5.15.0-105-generic #115-Ubuntu SMP x86_64</td></tr>
<tr><td>Build Date</td><td>Oct 24 2025 11:02:14</td></tr>
<tr><td>Server API</td><td>Apache 2.0 Handler</td></tr>
<tr><td>Loaded Configuration File</td><td>/etc/php/8.2/apache2/php.ini</td></tr>
<tr><td>DOCUMENT_ROOT</td><td>/var/www/portal/public</td></tr>
<tr><td>SERVER_ADDR</td><td>{ip}</td></tr>
<tr><td>SERVER_NAME</td><td>portal.acme.example</td></tr>
<tr><td>REMOTE_ADDR</td><td>{client}</td></tr>
<tr><td>_SERVER["DB_PASSWORD"]</td><td>{db_pass}</td></tr>
</table>
<h2>Environment</h2>
<table><tr><th>Variable</th><th>Value</th></tr>
<tr><td>APP_ENV</td><td>production</td></tr>
<tr><td>APP_KEY</td><td>base64:{app_key}</td></tr>
<tr><td>DB_HOST</td><td>{ip}</td></tr>
<tr><td>DB_PASSWORD</td><td>{db_pass}</td></tr>
<tr><td>AWS_SECRET_ACCESS_KEY</td><td>{aws_secret}</td></tr>
</table>
<div style="text-align:center;color:#777">PHP Credits &middot; {token}</div>
</body></html>
"#,
        ip = internal_ip(rng),
        client = public_ip(rng),
        db_pass = password(rng, 18),
        app_key = alnum(rng, 44),
        aws_secret = alnum(rng, 40),
        token = hex(rng, 12),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn exact_decoys_are_populated() {
        let set = DecoySet::build();
        for path in ["/.env", "/wp-config.php", "/backup.sql", "/.git/config"] {
            let decoy = set.exact(path).unwrap_or_else(|| panic!("{path} missing"));
            assert!(!decoy.body.is_empty());
        }
    }

    #[test]
    fn fallback_matches_file_extensions() {
        let set = DecoySet::build();
        assert!(set.fallback("/uploads/backup.env").is_some());
        assert!(set.fallback("/some/thing.sql").is_some());
        assert!(set.fallback("/.env.staging").is_some());
        assert!(set.fallback("/admin/").is_none());
        assert!(set.fallback("/dashboard").is_none());
    }

    #[test]
    fn decoy_secrets_look_generated() {
        let set = DecoySet::build();
        let env = set.exact("/.env").unwrap();
        let body = String::from_utf8_lossy(&env.body);
        assert!(body.contains("DB_PASSWORD="));
        assert!(body.contains("AWS_SECRET_ACCESS_KEY="));
    }
}
