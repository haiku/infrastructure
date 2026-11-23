use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

use axum::http::HeaderMap;

/// Work out the address a request really came from.
///
/// Proxy headers are only honoured when the direct peer is itself internal.
/// That keeps a client connecting from the public internet from spoofing its
/// address with `X-Forwarded-For`, while still working behind an ingress.
pub fn client_ip(headers: &HeaderMap, peer: IpAddr, trust_proxy_headers: bool) -> IpAddr {
    if !trust_proxy_headers || is_public(peer) {
        return peer;
    }

    if let Some(value) = headers.get("x-forwarded-for")
        && let Some(ip) = value.to_str().ok().and_then(parse_forwarded_chain)
    {
        return ip;
    }

    if let Some(ip) = headers
        .get("x-real-ip")
        .and_then(|value| value.to_str().ok())
        .and_then(parse_ip)
    {
        return ip;
    }

    peer
}

fn parse_forwarded_chain(value: &str) -> Option<IpAddr> {
    value.split(',').find_map(parse_ip)
}

fn parse_ip(raw: &str) -> Option<IpAddr> {
    let raw = raw.trim().trim_matches('"');
    if raw.is_empty() {
        return None;
    }

    if let Some(inner) = raw.strip_prefix('[').and_then(|s| s.split(']').next())
        && let Ok(ip) = inner.parse()
    {
        return Some(ip);
    }

    if let Ok(ip) = raw.parse() {
        return Some(ip);
    }

    // Some proxies (and scanners) append a port: 203.0.113.7:4711
    if raw.matches(':').count() == 1
        && let Some((host, _port)) = raw.split_once(':')
        && let Ok(ip) = host.parse()
    {
        return Some(ip);
    }

    None
}

/// True only for addresses that are routable on the public internet.
///
/// Reserved, documentation, benchmark, carrier-grade NAT, multicast and
/// private ranges are all treated as internal.
pub fn is_public(ip: IpAddr) -> bool {
    match ip {
        IpAddr::V4(ip) => is_public_v4(ip),
        IpAddr::V6(ip) => is_public_v6(ip),
    }
}

fn is_public_v4(ip: Ipv4Addr) -> bool {
    let [a, b, c, _d] = ip.octets();

    !(a == 0
        || a == 10
        || a == 127
        || (a == 100 && (64..=127).contains(&b))
        || (a == 169 && b == 254)
        || (a == 172 && (16..=31).contains(&b))
        || (a == 192 && b == 0 && c == 0)
        || (a == 192 && b == 0 && c == 2)
        || (a == 192 && b == 88 && c == 99)
        || (a == 192 && b == 168)
        || (a == 198 && (b == 18 || b == 19))
        || (a == 198 && b == 51 && c == 100)
        || (a == 203 && b == 0 && c == 113)
        || a >= 224)
}

fn is_public_v6(ip: Ipv6Addr) -> bool {
    if let Some(mapped) = ip.to_ipv4_mapped() {
        return is_public_v4(mapped);
    }

    let segments = ip.segments();

    // ::/96 (IPv4-compatible, deprecated) and ::/128
    if segments[..6].iter().all(|segment| *segment == 0) {
        return false;
    }

    !(ip.is_loopback()
        || ip.is_unspecified()
        || ip.is_multicast()
        // fc00::/7 unique local
        || (segments[0] & 0xfe00) == 0xfc00
        // fe80::/10 link local
        || (segments[0] & 0xffc0) == 0xfe80
        // 100::/64 discard only
        || (segments[0] == 0x0100 && segments[1..4].iter().all(|s| *s == 0))
        // 2001:db8::/32 documentation
        || (segments[0] == 0x2001 && segments[1] == 0x0db8))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn public(input: &str) -> bool {
        is_public(input.parse().unwrap())
    }

    #[test]
    fn public_addresses_are_public() {
        for ip in [
            "8.8.8.8",
            "1.1.1.1",
            "203.0.114.5",
            "2606:4700:4700::1111",
            "::ffff:8.8.8.8",
        ] {
            assert!(public(ip), "{ip} should be public");
        }
    }

    #[test]
    fn internal_and_reserved_addresses_are_not_public() {
        for ip in [
            "127.0.0.1",
            "10.1.2.3",
            "172.20.0.4",
            "192.168.1.1",
            "169.254.169.254",
            "100.64.0.1",
            "192.0.2.10",
            "198.51.100.9",
            "203.0.113.9",
            "198.18.0.1",
            "0.0.0.0",
            "224.0.0.1",
            "255.255.255.255",
            "::1",
            "::",
            "fd00::1",
            "fe80::1",
            "2001:db8::1",
            "::ffff:10.0.0.1",
        ] {
            assert!(!public(ip), "{ip} should not be public");
        }
    }

    #[test]
    fn forwarded_for_is_only_used_for_internal_peers() {
        let mut headers = HeaderMap::new();
        headers.insert("x-forwarded-for", "203.0.113.9, 10.0.0.1".parse().unwrap());

        let internal_peer = "10.0.0.2".parse().unwrap();
        assert_eq!(
            client_ip(&headers, internal_peer, true),
            "203.0.113.9".parse::<IpAddr>().unwrap()
        );

        let public_peer = "8.8.8.8".parse().unwrap();
        assert_eq!(client_ip(&headers, public_peer, true), public_peer);

        assert_eq!(client_ip(&headers, internal_peer, false), internal_peer);
    }

    #[test]
    fn forwarded_address_with_port_is_parsed() {
        let mut headers = HeaderMap::new();
        headers.insert("x-real-ip", "203.0.113.9:5512".parse().unwrap());
        assert_eq!(
            client_ip(&headers, "10.0.0.2".parse().unwrap(), true),
            "203.0.113.9".parse::<IpAddr>().unwrap()
        );
    }
}
