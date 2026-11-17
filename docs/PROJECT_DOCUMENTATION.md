# UniMonitor: Linux System Monitoring and Diagnostics Toolkit

## Abstract

UniMonitor is a modular command-line application written in Bash for observing common Linux system resources. It gathers operating-system details, samples CPU activity, reads memory counters, summarizes mounted filesystem capacity, inspects processes, displays network configuration, evaluates configurable health thresholds, and writes plain-text reports. The project demonstrates shell functions, variables, arrays, validation, text processing, permissions, process signals, pipelines, and file operations. It uses live operating-system interfaces and gracefully labels unavailable measurements.

## Introduction

Linux administrators and students often use separate commands to inspect system state. UniMonitor brings frequently used read-only checks into a consistent interactive menu while keeping each feature in a separate Bash module. The application is intended for demonstrations and basic diagnostics; it is not a replacement for a monitoring service that stores historical time series.

## Problem statement

Collecting a useful system snapshot requires familiarity with several commands and their output formats. A student may also confuse free memory with available memory, treat a failed measurement as a healthy value, or terminate a process without considering the signal and permissions involved. UniMonitor presents these values together, applies configurable thresholds, and requires an explicit confirmation before sending a termination signal.

## Objectives

- Display dynamic system identity and uptime information.
- Calculate CPU utilization from two readings of `/proc/stat`.
- Distinguish total, used, available, and free RAM; report swap separately.
- Summarize persistent mounted filesystems while excluding common temporary filesystems.
- Support process listing, text search, detail inspection, and cautious SIGTERM requests.
- Show interfaces, routes, listening sockets, and bounded connectivity/DNS diagnostics.
- Analyze measured values against validated thresholds and offer condition-based recommendations.
- Generate timestamped reports and maintain a simple application log.
- Demonstrate maintainable Bash programming concepts in an academic mini-project.

## Scope

UniMonitor targets Ubuntu and compatible Linux distributions, including Ubuntu under VirtualBox and WSL. Normal inspection does not need administrator privileges. It relies on Linux `/proc` files and command-line tools. Optional commands are detected before use. It performs no automatic process termination, package installation, network configuration changes, or persistent background monitoring. Cron scheduling is not included in this release.

## Hardware requirements

Any computer or virtual machine capable of running a supported Linux distribution. A network adapter is only needed for network diagnostics. No fixed processor, memory, or disk size is required by the application beyond the Linux system's own minimum requirements.

## Software requirements

- Ubuntu/Linux and Bash 4+
- Required utilities: `awk`, `grep`, `sed`, `ps`, and `df`
- Optional: `nproc`, `getconf`, `uptime`, `free`, `lsblk`, `ip`, `ping`, `ss`, `getent`, `hostname`, and `journalctl`
- ShellCheck is recommended for development review but is not a runtime dependency.

## System architecture

```text
main.sh
 ├── utils/colors.sh       ANSI palette and status colors
 ├── utils/validation.sh   Input, PID, host, threshold, and path validation
 ├── utils/logger.sh       Timestamped log and size-based rotation
 ├── utils/common.sh       Safe config parser, shared sampling, formatting
 └── modules/
      ├── system_info.sh
      ├── cpu_monitor.sh
      ├── memory_monitor.sh
      ├── disk_monitor.sh
      ├── process_manager.sh
      ├── network_diagnostics.sh
      ├── system_health.sh
      ├── report_manager.sh
      └── settings.sh
```

The entry point enables `nounset` and `pipefail`, loads shared functions, parses the configuration as data, initializes report and log directories, and dispatches menu selections. Modules expose functions and reuse common formatting, measurement, and logging logic. `main.sh --report` uses the same module functions without opening the menu.

## Module descriptions

### System information

Reads distribution metadata from `/etc/os-release`, kernel and architecture from `uname`, host and user names from standard commands, and uptime from `uptime` or `/proc/uptime`. Processor count uses `nproc`, `getconf`, or `/proc/cpuinfo` in that order.

### CPU monitoring

Reads aggregate counters from `/proc/stat`, waits one second, and reads them again. Usage is the non-idle counter delta divided by the total counter delta. It also shows load averages, processor information, and five processes sorted by CPU percentage. If a counter sample is missing or invalid, usage is reported as unavailable.

### Memory monitoring

Parses `/proc/meminfo`. Used memory is calculated as total minus available; `MemAvailable` is preferred because it estimates memory that can be used without swapping. If unavailable, a conservative estimate uses free, buffers, cache, reclaimable memory, and shared memory. Swap is measured and classified independently.

### Disk monitoring

Uses `df -P -T` and excludes `tmpfs`, `devtmpfs`, `squashfs`, `proc`, `sysfs`, and `overlay` from the filesystem summary. Device details come from `lsblk` when present. A user may request `du -sh` for an existing directory; permission errors remain visible.

### Process management

Lists processes using `ps`, searches output using literal case-insensitive substring matching, and displays details by validated numeric PID. A termination request is confirmed with the exact word `yes`; UniMonitor then sends `SIGTERM`. It blocks PID 1, its own PID, its parent PID, root-owned processes, and a set of critical process names. It does not elevate privileges or send `SIGKILL`; a permission message explains when the operating system may require privileges the current user lacks.

### Network diagnostics

Displays interfaces, addresses, the default route, local addresses, and listening sockets when the relevant tools exist. Ping uses a finite number of probes and timeout. When a default gateway exists, the gateway is checked separately from the requested target. DNS lookup uses `getent ahosts`; host input is validated before use.

### System health analysis

Compares CPU, memory, disk, and swap percentages against configuration. Load average is compared to the online core count (above one core-count is warning; at least twice the count is critical). The tool also checks the availability of `awk`, `grep`, `sed`, `ps`, and `df`. A failed measurement is `N/A` and does not by itself make the system critical. Recommendations are added only for measured threshold violations or unavailable data/utilities. If no metric can be evaluated, the overall result remains `UNKNOWN` rather than being labeled healthy.

### Reports and settings

Reports combine module output and include a generation timestamp. They use a temporary file and `tee` to write the final report. The history view permits reading a report and deleting an individual report after confirmation. Settings enforce integer ranges and warning/critical ordering. Config values are read by a `case` statement and never passed to `source` or `eval`.

## Implementation details

The application has no network API, database, or language runtime dependency beyond Bash and normal Linux utilities. Metrics are collected at the time of the request. Shell commands that may not exist are guarded with `command_exists`; optional failures produce a fallback message. Paths and process IDs are quoted. User-provided text is never interpreted as a shell command. Output redirection is used for logs and reports, while pipelines format command output.

Default thresholds are CPU 70/90%, memory 75/90%, disk 80/95%, and swap 70/90% (warning/critical). They are examples for a general workstation; administrators can adjust them for their systems.

## Unix commands used

`uname`, `hostname`, `uptime`, `whoami`, `date`, `nproc`, `getconf`, `df`, `du`, `lsblk`, `findmnt`, `ps aux`, `ps -eo`, `pgrep`, `top`, `ip`, `ping`, `ss`, `getent`, `awk`, `sed`, `grep`, `head`, `sort`, `wc`, `mkdir`, `mktemp`, `mv`, `rm`, `chmod`, `tee`, `kill`, `sleep`, and `tr` are used or checked. `free`, `lscpu`, and `journalctl` are optional, not required for core metrics. `/proc/stat`, `/proc/meminfo`, `/proc/loadavg`, and `/proc/uptime` provide kernel-exported counters.

## Expected outputs

The dashboard shows current host identity, CPU usage, memory and filesystem percentages, load average, and menu choices. Module views show the relevant live measurements or explicitly report `unavailable`. Health output gives an overall status and recommendations derived from the measurements. A report is saved as `reports/unimonitor_report_YYYY-MM-DD_HHMMSS.txt` by default. Values depend on the host at run time and are not fixed in this document.

## Advantages

- Modular Bash structure and a consistent terminal interface.
- No external service or database dependency.
- Live measurements instead of sample or randomized values.
- Configurable thresholds and a data-only configuration parser.
- Explicit confirmation before process signaling.
- Graceful handling of optional commands and missing metrics.
- Academic documentation connects code to Unix concepts.

## Limitations

- Snapshot sampling is not historical monitoring or alert delivery.
- Load average and filesystem interpretation vary by workload and system configuration.
- ICMP may be filtered; ping failure is not conclusive proof of an outage.
- Process visibility and signaling depend on user permissions and namespaces.
- Some Linux distributions format optional command output differently.
- Log rotation retains only the current log and one prior log.
- Cron-based scheduled reports are not implemented.

## Future enhancements

- Add optional cron installation and removal for scheduled report generation.
- Add configurable log retention and report export formats.
- Add tests that run in an Ubuntu CI container and controlled fixtures for parser edge cases.
- Add interface-specific packet counters and more detailed mount filtering.
- Add an opt-in historical CSV mode while keeping the default installation lightweight.

## Conclusion

UniMonitor packages common Linux system checks into a reusable Bash application. Its modular design demonstrates practical Unix programming while giving attention to measured data, input validation, process safety, and failure reporting. It is suitable for a laboratory demonstration and basic interactive diagnostics, with limitations that make clear where a dedicated monitoring platform would be needed.
