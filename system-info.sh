#!/usr/bin/env bash

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/system-info.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "System information check started"

echo "======================================"
echo "        SYSTEM INFORMATION"
echo "======================================"

echo "Hostname          : $(hostname)"
echo "Current User      : $(whoami)"
echo "Date/Time         : $(date)"
echo "Operating System  : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Kernel Version    : $(uname -r)"
echo "Uptime            : $(uptime -p)"
echo "CPU Information   : $(lscpu | grep -m1 'Model name:' | sed 's/^[^:]*:[[:space:]]*//')"
echo "Memory Information:"
free -h
echo "Current Directory : $(pwd)"

echo "======================================"

log "System information check completed"

exit 0
