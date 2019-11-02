// According to reqwest documentation,
// the port "0" will use the "conventional port for the given scheme"
// e.g. 80 for HTTP, 443 for HTTPS.
const FALLBACK_PORT: &'static str = "0";

pub(crate) trait SocketAddrDigester {
    /// Adds the `FALLBACK_PORT` to the end of the string if it doesn't have a port.
    fn digest_ip(self) -> String;
}

impl SocketAddrDigester for String {
    fn digest_ip(self) -> String {
        let has_dot = self.contains(".");

        if has_dot && !self.contains(":") {
            // IPv4 without port
            return format!("{self}:{FALLBACK_PORT}");
        }

        if !has_dot && !self.contains("[") {
            // IPv6 without port
            return format!("[{self}]:{FALLBACK_PORT}");
        }

        self
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_digest_ip() {
        assert_eq!("1.2.3.4:5678".to_string().digest_ip(), "1.2.3.4:5678");
        assert_eq!("1.2.3.4".to_string().digest_ip(), "1.2.3.4:0");
        assert_eq!("::1".to_string().digest_ip(), "[::1]:0");
        assert_eq!("[::1]:5678".to_string().digest_ip(), "[::1]:5678");
    }
}
