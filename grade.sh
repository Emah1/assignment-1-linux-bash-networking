#!/usr/bin/env bash

FAIL=0

pass() {
    echo "PASS: $1"
}

fail() {
    echo "FAIL: $1"
    FAIL=1
}

echo "======================================"
echo " Assignment 1 Grader"
echo "======================================"

echo
echo "[1] Checking required files..."

required_files=(
    "README.md"
    "system-info.sh"
    "disk-check.sh"
    "network-check.sh"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        pass "$file exists"
    else
        fail "$file is missing"
    fi
done

echo
echo "[2] Checking logs directory..."

mkdir -p logs

if [[ -d "logs" ]]; then
    pass "logs directory exists"
else
    fail "logs directory is missing"
fi

echo
echo "[3] Checking Bash syntax..."

for file in system-info.sh disk-check.sh network-check.sh; do
    if bash -n "$file"; then
        pass "$file syntax is valid"
    else
        fail "$file has syntax errors"
    fi
done

echo
echo "[4] Checking executable permissions..."

for file in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if [[ -x "$file" ]]; then
        pass "$file is executable"
    else
        fail "$file is not executable"
    fi
done

echo
echo "[5] Testing system-info.sh..."

system_output=$(./system-info.sh 2>&1)
system_rc=$?

if [[ $system_rc -eq 0 ]]; then
    pass "system-info.sh exits successfully"
else
    fail "system-info.sh exited with code $system_rc"
fi

for keyword in "Hostname" "Current User" "Kernel" "Uptime"; do
    if echo "$system_output" | grep -qi "$keyword"; then
        pass "system-info.sh contains $keyword"
    else
        fail "system-info.sh is missing $keyword"
    fi
done

echo
echo "[6] Testing disk-check.sh..."

if ./disk-check.sh 0 >/dev/null 2>&1; then
    fail "disk-check.sh accepted threshold 0"
else
    disk_rc=$?
    if [[ $disk_rc -eq 2 ]]; then
        pass "threshold 0 correctly rejected"
    else
        fail "threshold 0 returned code $disk_rc instead of 2"
    fi
fi

if ./disk-check.sh 101 >/dev/null 2>&1; then
    fail "disk-check.sh accepted threshold 101"
else
    disk_rc=$?
    if [[ $disk_rc -eq 2 ]]; then
        pass "threshold 101 correctly rejected"
    else
        fail "threshold 101 returned code $disk_rc instead of 2"
    fi
fi

if ./disk-check.sh abc >/dev/null 2>&1; then
    fail "disk-check.sh accepted non-numeric threshold"
else
    disk_rc=$?
    if [[ $disk_rc -eq 2 ]]; then
        pass "non-numeric threshold correctly rejected"
    else
        fail "non-numeric threshold returned code $disk_rc instead of 2"
    fi
fi

./disk-check.sh 100 / >/dev/null 2>&1
disk_rc=$?

if [[ $disk_rc -eq 0 || $disk_rc -eq 1 ]]; then
    pass "valid disk-check command works"
else
    fail "valid disk-check returned unexpected code $disk_rc"
fi

echo
echo "[7] Testing network-check.sh..."

./network-check.sh >/dev/null 2>&1
network_rc=$?

if [[ $network_rc -ne 0 ]]; then
    pass "missing hostname correctly rejected"
else
    fail "network-check accepted missing hostname"
fi

./network-check.sh localhost >/dev/null 2>&1
network_rc=$?

if [[ $network_rc -eq 0 || $network_rc -eq 1 ]]; then
    pass "localhost network check completed"
else
    fail "localhost network check returned unexpected code $network_rc"
fi

for port in 0 65536 abc; do
    ./network-check.sh localhost "$port" >/dev/null 2>&1
    network_rc=$?

    if [[ $network_rc -eq 2 ]]; then
        pass "invalid port '$port' correctly rejected"
    else
        fail "invalid port '$port' returned code $network_rc instead of 2"
    fi
done

echo
echo "[8] Checking logging..."

log_count=$(find logs -type f ! -name ".gitkeep" | wc -l)

if [[ "$log_count" -gt 0 ]]; then
    pass "log files were created"
else
    fail "no log files were created"
fi

echo
echo "[9] Checking Git history..."

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commit_count=$(git rev-list --count HEAD 2>/dev/null || echo 0)

    if [[ "$commit_count" -ge 5 ]]; then
        pass "at least 5 Git commits found"
    else
        fail "only $commit_count Git commits found; at least 5 required"
    fi

    branch_count=$(git for-each-ref --format='%(refname:short)' refs/heads/ \
        | grep -v '^main$' \
        | grep -v '^master$' \
        | wc -l)

    if [[ "$branch_count" -ge 1 ]]; then
        pass "feature branch detected"
    else
        fail "no feature branch detected"
    fi
else
    fail "not a Git repository"
fi

echo
echo "======================================"

if [[ $FAIL -eq 0 ]]; then
    echo "RESULT: ALL CHECKS PASSED"
    echo "======================================"
    exit 0
else
    echo "RESULT: SOME CHECKS FAILED"
    echo "======================================"
    exit 1
fi
