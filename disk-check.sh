#!/usr/bin/env bash

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/disk-check.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <threshold> [path]"
    echo "Threshold must be an integer from 1 to 100."
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "ERROR: Invalid number of arguments."
    usage
    log "Invalid argument count"
    exit 2
fi

threshold="$1"
path="${2:-/}"

if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Threshold must be an integer."
    log "Invalid threshold: $threshold"
    exit 2
fi

if (( threshold < 1 || threshold > 100 )); then
    echo "ERROR: Threshold must be between 1 and 100."
    log "Threshold out of range: $threshold"
    exit 2
fi

if [[ ! -e "$path" ]]; then
    echo "ERROR: Path does not exist: $path"
    log "Invalid path: $path"
    exit 2
fi

usage_percent=$(df -P "$path" | awk 'NR==2 {gsub("%","",$5); print $5}')

if [[ -z "$usage_percent" ]]; then
    echo "ERROR: Unable to determine disk usage."
    log "Unable to determine disk usage for $path"
    exit 1
fi

echo "Disk usage for $path: ${usage_percent}%"
echo "Threshold: ${threshold}%"

log "Disk check performed on $path: ${usage_percent}% usage, threshold ${threshold}%"

if (( usage_percent >= threshold )); then
    echo "WARNING: Disk usage has reached or exceeded the threshold."
    exit 1
else
    echo "OK: Disk usage is below the threshold."
    exit 0
fi
