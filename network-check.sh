#!/usr/bin/env bash

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/network-check.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <hostname-or-ip> [port]"
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "ERROR: Hostname or IP address is required."
    usage
    log "Missing or invalid host argument"
    exit 2
fi

host="$1"

if [[ -z "$host" ]]; then
    echo "ERROR: Host cannot be empty."
    log "Empty host argument"
    exit 2
fi

if [[ $# -eq 2 ]]; then
    port="$2"

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Port must be numeric."
        log "Invalid non-numeric port: $port"
        exit 2
    fi

    if (( port < 1 || port > 65535 )); then
        echo "ERROR: Port must be between 1 and 65535."
        log "Port out of range: $port"
        exit 2
    fi
fi

echo "======================================"
echo "         NETWORK CHECK"
echo "======================================"
echo "Host: $host"

resolved_address=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')

if [[ -z "$resolved_address" ]]; then
    echo "ERROR: Unable to resolve host: $host"
    log "Host resolution failed: $host"
    exit 1
fi

echo "Resolved Address: $resolved_address"
log "Host resolved: $host -> $resolved_address"

if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
    echo "Connectivity: SUCCESS"
    log "Ping connectivity successful: $host"
else
    echo "Connectivity: FAILED"
    log "Ping connectivity failed: $host"
fi

echo
echo "Network Interfaces:"
ip -brief address 2>/dev/null || ifconfig 2>/dev/null || echo "Unable to display interfaces."

if [[ $# -eq 2 ]]; then
    echo
    echo "TCP Port Check: $host:$port"

    if timeout 5 bash -c "</dev/tcp/$host/$port" >/dev/null 2>&1; then
        echo "TCP Connectivity: SUCCESS"
        log "TCP connection successful: $host:$port"
    else
        echo "TCP Connectivity: FAILED"
        log "TCP connection failed: $host:$port"
    fi
fi

echo "======================================"

exit 0
