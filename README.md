# UniMonitor

UniMonitor is a modular Bash toolkit for checking Linux system information, CPU and memory use, mounted filesystems, processes, network configuration, and basic system health. It can also save timestamped text reports.

## Requirements

- Ubuntu/Linux with Bash 4 or newer
- Core command line tools: `awk`, `grep`, `sed`, `ps`, and `df`
- Optional utilities improve details: `nproc`, `free`, `lsblk`, `ip`, `ping`, `ss`, `getent`, `uptime`

Missing optional utilities are reported and their features degrade gracefully. The application normally runs without root privileges. Some process details and interface data may be restricted by the operating system.

## Install and run

```bash
chmod +x install.sh
./install.sh
./main.sh
```

Generate a report without opening the interactive menu:

```bash
./main.sh --report
```

Use `./main.sh --help` for command-line options. Set `NO_COLOR=1` to disable ANSI colors, or `UNIMONITOR_CONFIG=/path/to/settings.conf` to read a different configuration file.

## Configuration

Edit `config/settings.conf` or use **Application settings** in the menu. Thresholds are integer percentages. Warning must be lower than critical. Configuration is parsed as data; it is never executed as shell code. Relative report and log paths are resolved from the project directory.

## Reports and logs

Reports are saved under `reports/` by default as `unimonitor_report_YYYY-MM-DD_HHMMSS.txt`. Logs are written to `logs/unimonitor.log` and rotated to `.1` at approximately 1 MiB. Report history lets users view or delete an individual report after confirmation.

## Process safety

UniMonitor never terminates a process automatically. Process termination requires typing `yes`, sends `SIGTERM`, and does not use `sudo` or `SIGKILL`. PID 1, UniMonitor itself, its parent, root-owned processes, and selected critical system processes are protected. Permission failures explain when the operating system may require elevated privileges.

## Project layout

```text
main.sh                 Interactive dashboard and command-line entry point
install.sh              Linux dependency and permission checks
uninstall.sh            Confirmed removal of program files
modules/                System, CPU, memory, disk, process, network, health, reports, settings
utils/                  Shared display, config, validation, and logging functions
config/settings.conf    Default thresholds and paths
reports/                Generated reports
logs/                   Application log
docs/                   Academic and laboratory documentation
```

## Limitations

Measurements use Linux `/proc` interfaces and standard utilities; they are point-in-time diagnostics rather than a long-running metrics service. ICMP can be filtered, so a failed ping alone does not prove that a host or internet connection is unavailable. Load average is interpreted against the online CPU count. Health checks report `N/A` when a source cannot be measured instead of treating missing data as a critical value.

See [docs/PROJECT_DOCUMENTATION.md](docs/PROJECT_DOCUMENTATION.md), [docs/UNIX_CONCEPTS.md](docs/UNIX_CONCEPTS.md), [docs/TEST_CASES.md](docs/TEST_CASES.md), and [docs/VIVA_QUESTIONS.md](docs/VIVA_QUESTIONS.md).
