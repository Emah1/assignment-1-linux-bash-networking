# Assignment 1: Linux, Bash & Networking Diagnostic Toolkit

A Linux diagnostic toolkit built with Bash. The toolkit collects system information, checks disk usage, performs basic network diagnostics, and maintains timestamped operation logs.

## Project Overview

This project demonstrates practical Linux administration, Bash scripting, networking, error handling, logging, and Git workflow skills.

The toolkit contains three main scripts:

* `system-info.sh` — Displays system information.
* `disk-check.sh` — Checks disk usage against a specified threshold.
* `network-check.sh` — Resolves hosts, tests connectivity, displays network interfaces, and optionally checks TCP ports.

## Requirements

The scripts are designed to run in a Linux environment.

Required tools include:

* Bash
* Git
* Core Linux utilities
* `ip`
* `ping`
* `getent`
* `df`
* `lscpu`
* `free`
* `timeout`

The project was developed and tested using Ubuntu on Windows Subsystem for Linux (WSL).

## Project Structure

```text
assignment-1-linux-bash-networking/
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
    └── .gitkeep
```

Runtime log files are created inside the `logs/` directory when the scripts are executed.

## Installation

Clone the repository:

```bash
git clone <repository-url>
cd assignment-1-linux-bash-networking
```

Make the scripts executable:

```bash
chmod +x *.sh
```

## Usage

### System Information

Run:

```bash
./system-info.sh
```

The script displays:

* Hostname
* Current user
* Date and time
* Operating system
* Kernel version
* System uptime
* CPU information
* Memory information
* Current working directory

Example:

```text
======================================
        SYSTEM INFORMATION
======================================
Hostname          : my-computer
Current User      : user
Date/Time         : Mon Oct 06 23:00:00 WAT 2026
Operating System  : Ubuntu
Kernel Version    : 6.x.x
Uptime            : up 1 hour
CPU Information   : ...
Memory Information:
...
Current Directory : /home/user/assignment-1-linux-bash-networking
======================================
```

### Disk Check

Usage:

```bash
./disk-check.sh <threshold> [path]
```

The path defaults to `/` when it is not supplied.

Example:

```bash
./disk-check.sh 80
```

Or:

```bash
./disk-check.sh 80 /home
```

Exit codes:

| Code | Meaning                                          |
| ---- | ------------------------------------------------ |
| `0`  | Disk usage is below the threshold                |
| `1`  | Disk usage has reached or exceeded the threshold |
| `2`  | Invalid input                                    |

The threshold must be an integer between `1` and `100`.

Examples:

```bash
./disk-check.sh 80 /
./disk-check.sh 90 /home
```

Invalid examples:

```bash
./disk-check.sh 0
./disk-check.sh 101
./disk-check.sh abc
```

### Network Check

Usage:

```bash
./network-check.sh <hostname-or-ip> [port]
```

Example:

```bash
./network-check.sh localhost
```

With a TCP port:

```bash
./network-check.sh localhost 80
```

The script:

1. Validates the supplied host.
2. Resolves the host.
3. Displays the resolved address.
4. Performs a basic connectivity check.
5. Displays network interface information.
6. Checks TCP connectivity when a port is supplied.

Valid ports are between `1` and `65535`.

Invalid examples:

```bash
./network-check.sh localhost 0
./network-check.sh localhost 65536
./network-check.sh localhost abc
```

Invalid input returns exit code `2`.

## Logging

The scripts create useful operational logs under:

```text
logs/
```

Log entries include a timestamp and a description of the operation performed.

Examples include:

```text
2026-10-06 23:00:00 - System information check started
2026-10-06 23:00:01 - System information check completed
2026-10-06 23:00:05 - Disk check performed on /: 45% usage, threshold 80%
2026-10-06 23:00:10 - Host resolved: localhost -> 127.0.0.1
```

Runtime logs are intentionally not committed to the repository.

## Testing

Bash syntax can be checked with:

```bash
bash -n system-info.sh
bash -n disk-check.sh
bash -n network-check.sh
```

The supplied local grader can be executed with:

```bash
chmod +x grade.sh *.sh
./grade.sh
```

The grader checks:

* Required files
* Bash syntax
* Executable permissions
* System information output
* Disk argument validation
* Network argument validation
* Logging
* Git history

## Git Workflow

The project uses Git for version control.

The assignment requires:

* At least five meaningful commits.
* At least one non-main feature branch.
* The feature branch to be merged into `main`.
* Clear commit messages.

Example workflow:

```bash
git checkout -b feature/network-improvements
git add .
git commit -m "Add network diagnostic functionality"

git checkout main
git merge feature/network-improvements
```

## Assumptions

* The toolkit is intended for Linux environments.
* The scripts use standard Linux command-line utilities.
* Network connectivity tests depend on the local network environment.
* Some external hosts may block ICMP traffic; therefore, a failed ping does not necessarily mean the host is unavailable.
* No cloud deployment is required for this assignment.
* No passwords, API tokens, private keys, or other secrets are required.

## Author

*Emmanuel Okoro*

DevOps Practical Assignment 1

Technologies:

* Linux
* Bash
* Networking
* Git
* WSL
