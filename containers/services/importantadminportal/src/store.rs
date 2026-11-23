use std::collections::HashSet;
use std::io::ErrorKind;
use std::net::IpAddr;
use std::path::{Path, PathBuf};

use tokio::fs;
use tokio::io::AsyncWriteExt;
use tokio::sync::Mutex;

use crate::ip;

/// Append-only log of hostile IP addresses.
///
/// Requests are appended as they arrive; `compact` rewrites the file with one
/// line per unique public address while preserving first-seen order.
#[derive(Debug)]
pub struct IpStore {
    path: PathBuf,
    lock: Mutex<()>,
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq)]
pub struct CompactReport {
    pub lines_before: usize,
    pub lines_after: usize,
    pub duplicates_removed: usize,
    pub invalid_removed: usize,
}

impl IpStore {
    pub fn new(path: PathBuf) -> Self {
        Self {
            path,
            lock: Mutex::new(()),
        }
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    pub async fn prepare(&self) -> std::io::Result<()> {
        if let Some(parent) = self.path.parent()
            && !parent.as_os_str().is_empty()
        {
            fs::create_dir_all(parent).await?;
        }
        fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.path)
            .await?;
        Ok(())
    }

    pub async fn record(&self, ip: IpAddr) -> std::io::Result<()> {
        let _guard = self.lock.lock().await;
        let mut file = fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.path)
            .await?;
        file.write_all(format!("{ip}\n").as_bytes()).await?;
        file.flush().await
    }

    /// Read the current report. A missing file is an empty report.
    pub async fn read(&self) -> std::io::Result<String> {
        match fs::read_to_string(&self.path).await {
            Ok(contents) => Ok(contents),
            Err(err) if err.kind() == ErrorKind::NotFound => Ok(String::new()),
            Err(err) => Err(err),
        }
    }

    /// Rewrite the file with unique, public IP addresses only.
    pub async fn compact(&self) -> std::io::Result<CompactReport> {
        let _guard = self.lock.lock().await;

        let contents = match fs::read_to_string(&self.path).await {
            Ok(contents) => contents,
            Err(err) if err.kind() == ErrorKind::NotFound => return Ok(CompactReport::default()),
            Err(err) => return Err(err),
        };

        let mut seen = HashSet::new();
        let mut unique = Vec::new();
        let mut lines_before = 0;
        let mut invalid_removed = 0;

        for line in contents.lines() {
            let line = line.trim();
            if line.is_empty() {
                continue;
            }
            lines_before += 1;

            match line.parse::<IpAddr>() {
                Ok(ip) if ip::is_public(ip) => {
                    if seen.insert(ip) {
                        unique.push(ip);
                    }
                }
                _ => invalid_removed += 1,
            }
        }

        let mut output = String::new();
        for ip in &unique {
            output.push_str(&ip.to_string());
            output.push('\n');
        }

        let temp = self.temp_path();
        fs::write(&temp, output.as_bytes()).await?;
        if let Err(err) = fs::rename(&temp, &self.path).await {
            let _ = fs::remove_file(&temp).await;
            return Err(err);
        }

        Ok(CompactReport {
            lines_before,
            lines_after: unique.len(),
            duplicates_removed: lines_before
                .saturating_sub(unique.len())
                .saturating_sub(invalid_removed),
            invalid_removed,
        })
    }

    fn temp_path(&self) -> PathBuf {
        let mut name = self
            .path
            .file_name()
            .map(|name| name.to_os_string())
            .unwrap_or_else(|| "ips.txt".into());
        name.push(format!(".tmp.{}", std::process::id()));
        self.path.with_file_name(name)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn records_then_compacts_unique_public_addresses() {
        let dir = tempfile::tempdir().unwrap();
        let store = IpStore::new(dir.path().join("ips.txt"));
        store.prepare().await.unwrap();

        for ip in [
            "8.8.8.8",
            "10.0.0.1",
            "8.8.8.8",
            "1.1.1.1",
            "2001:db8::1",
            "8.8.8.8",
            "9.9.9.9",
            "1.1.1.1",
        ] {
            store.record(ip.parse().unwrap()).await.unwrap();
        }

        let report = store.compact().await.unwrap();
        assert_eq!(report.lines_before, 8);
        assert_eq!(report.lines_after, 3);
        assert_eq!(report.duplicates_removed, 3);
        assert_eq!(report.invalid_removed, 2);
        assert_eq!(store.read().await.unwrap(), "8.8.8.8\n1.1.1.1\n9.9.9.9\n");
    }

    #[tokio::test]
    async fn compacting_a_missing_file_is_harmless() {
        let dir = tempfile::tempdir().unwrap();
        let store = IpStore::new(dir.path().join("missing.txt"));
        assert_eq!(store.compact().await.unwrap(), CompactReport::default());
        assert_eq!(store.read().await.unwrap(), "");
    }
}
