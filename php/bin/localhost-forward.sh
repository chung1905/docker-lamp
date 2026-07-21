#!/bin/sh
# Forward this container's loopback :80/:443 to an upstream web server (the
# shared httpd container by default).
#
# Why: libcurl hardcodes RFC 6761, so any *.localhost host is resolved to
# 127.0.0.1 internally, bypassing DNS and /etc/hosts. That means a PHP app in
# one container calling another project at e.g. http://pub.streamconnect81.localhost/
# never leaves the container. socat catches that loopback connection and pipes
# it (raw TCP, so the Host header and TLS/SNI are preserved) to httpd, which
# routes it to the right php-fpm backend via the existing wildcard vhost. Works
# for every *.localhost project with no per-project config.
#
# Enabled per-scheme via LOCALHOST_HTTP_FORWARD / LOCALHOST_HTTPS_FORWARD
# (each a <host:port> upstream). Binding low ports as a non-root user is allowed
# via the net.ipv4.ip_unprivileged_port_start=0 sysctl (see compose).
set -e

# forward <local-listen-port> <upstream-host:port>
forward() {
    socat TCP4-LISTEN:"$1",fork,reuseaddr            "TCP:$2" &
    # ::1 too — curl often tries IPv6 loopback first for *.localhost.
    socat TCP6-LISTEN:"$1",fork,reuseaddr,ipv6only=1 "TCP:$2" 2>/dev/null &
}

[ -n "${LOCALHOST_HTTP_FORWARD:-}" ]  && forward 80  "$LOCALHOST_HTTP_FORWARD"
[ -n "${LOCALHOST_HTTPS_FORWARD:-}" ] && forward 443 "$LOCALHOST_HTTPS_FORWARD"

exec docker-php-entrypoint "$@"
