# UniMonitor Viva Questions and Answers

## 1. What is Unix?

Unix is a family of multiuser, multitasking operating systems. It provides a kernel, command-line tools, file abstractions, permissions, and interfaces used by programs.

## 2. What is Linux?

Linux is an open-source Unix-like operating system kernel. A Linux distribution combines the kernel with system libraries, utilities, package management, and applications.

## 3. What is the kernel's role?

The kernel manages CPU scheduling, memory, devices, filesystems, and system calls. UniMonitor reads some kernel-provided counters through `/proc`.

## 4. What is a shell?

A shell reads commands and runs programs. Bash is the shell used by UniMonitor scripts.

## 5. What is a Bash variable?

A variable stores a value for later use. Assignment has no spaces, such as `CPU_WARNING=70`; expansion uses `$CPU_WARNING`.

## 6. What is the difference between a shell variable and an environment variable?

A shell variable is local to the current shell unless exported. An environment variable is inherited by child processes. UniMonitor reads environment values such as `NO_COLOR` and `UNIMONITOR_CONFIG`.

## 7. What are positional parameters?

They are script or function arguments. `$1` is the first argument, `$2` the second, and `"$@"` represents all arguments. UniMonitor uses `$1` for `--report`, `--help`, and `--version`.

## 8. Why does a script use a shebang?

The shebang identifies the interpreter used to run the script directly. `#!/usr/bin/env bash` finds Bash through the current `PATH`.

## 9. What is an exit status?

It is an integer returned by a command. Zero conventionally indicates success; nonzero indicates a problem or a condition such as no match. Bash uses it in `if` and pipelines.

## 10. What does `set -o nounset` do?

It makes an expansion of an unset variable an error. UniMonitor uses defaults such as `${1:-}` where a value may legitimately be absent.

## 11. What does `set -o pipefail` do?

It makes a pipeline return a failure if any command in the pipeline fails, rather than only returning the status of the last command.

## 12. What is a function in Bash?

A function is a named group of commands. It avoids duplication and can be called from different modules; for example, `memory_values` is shared by the dashboard, monitor, and health check.

## 13. What is the purpose of `case`?

`case` selects a branch based on a string pattern. UniMonitor uses it for menu choices and to whitelist configuration keys.

## 14. What is the difference between `for` and `while` loops?

A `for` loop iterates over a list of values. A `while` loop repeats while a condition succeeds. UniMonitor loops over required utilities and repeats the menu until exit.

## 15. What is a Bash array?

An indexed array stores multiple values in one variable. Health recommendations are added to an array and printed individually.

## 16. What is a pipe?

A pipe (`|`) sends one command's standard output to another command's standard input. UniMonitor pipes `ps` output to `head` and `df` output to `awk`.

## 17. What is output redirection?

`>` writes output to a file and replaces its previous content; `>>` appends. Logs append to the log file and reports redirect module output into a temporary file.

## 18. What are standard input, output, and error?

They are file descriptors 0, 1, and 2. The app can redirect error output with `2>` or combine it with standard output using `2>&1`.

## 19. What does `awk` do?

`awk` processes text by records and fields and supports calculations. UniMonitor uses it to extract `/proc` fields, calculate percentages, and format output.

## 20. What does `grep` do?

`grep` selects text lines that match a pattern. It is a common Unix search utility and is checked as a required dependency by UniMonitor.

## 21. What does `sed` do?

`sed` performs stream transformations such as substitution. UniMonitor trims whitespace from process command names before comparing them with protected names.

## 22. How are file permissions represented?

Permissions assign read, write, and execute rights to owner, group, and others. For example, `755` grants the owner all rights and others read/execute; `600` grants the owner read/write only.

## 23. Why should shell variables be quoted?

Quoting prevents word splitting and wildcard expansion. `du -sh -- "$path"` treats a path as one argument and prevents a leading dash from being an option.

## 24. How does UniMonitor calculate CPU utilization?

It reads aggregate counters from `/proc/stat`, waits one second, reads them again, and calculates 100 times the non-idle tick delta divided by the total tick delta. A single counter reading cannot yield an interval utilization percentage.

## 25. What is load average?

Load average is the average number of runnable or uninterruptible tasks over 1, 5, and 15 minutes. It is not itself a CPU percentage. UniMonitor compares the 1-minute value with online CPU count as a rough signal.

## 26. Why is available memory different from free memory?

Linux uses otherwise idle RAM for caches. `MemAvailable` estimates how much memory can be allocated without swapping, while `MemFree` counts only currently unused pages.

## 27. What is swap space?

Swap is disk-backed space used to hold memory pages that are not currently resident in RAM. Heavy swap use can indicate memory pressure, but some swap use is normal.

## 28. What is a process ID?

A PID is a numeric identifier for a process. Commands such as `ps` display PIDs; `kill` addresses a signal to a PID.

## 29. What is SIGTERM?

SIGTERM is a request for a process to terminate. A process can handle it and clean up. UniMonitor asks for confirmation and sends SIGTERM rather than forcefully killing the process.

## 30. What is SIGKILL?

SIGKILL is an uncatchable signal that immediately ends a process. It prevents cleanup and is not used by UniMonitor.

## 31. Why can `kill` fail?

The process may have exited, the PID may be invalid, or the caller may lack permission. A process in another user's account may need administrator action; UniMonitor does not invoke `sudo`.

## 32. What does `df` show?

`df` reports filesystem capacity and usage for mounted filesystems. UniMonitor excludes common temporary or pseudo filesystem types from its physical-storage summary.

## 33. What is the difference between `df` and `du`?

`df` reports filesystem-level space use; `du` estimates space consumed by files under a directory. Their values can differ because of deleted-but-open files, reserved blocks, and filesystem metadata.

## 34. What does `ss` show?

`ss` displays socket information. The `-tuln` options show TCP and UDP listening sockets numerically without resolving service names.

## 35. Why can ping fail while internet access works?

Firewalls and networks can filter ICMP echo packets even while HTTP, DNS, or other traffic works. Ping is a useful diagnostic signal but not definitive proof of connectivity.

## 36. What is DNS resolution?

DNS maps hostnames to IP addresses. `getent ahosts` uses the system's configured name-service mechanisms to return address records.

## 37. Why validate a hostname?

Validation rejects malformed or empty values before invoking a network utility. Quoting also keeps a value as a single argument and prevents it from becoming shell syntax.

## 38. Why not source a configuration file?

Sourcing runs the file as shell code. UniMonitor parses only known `KEY=value` names and validates the values, so a modified config cannot execute arbitrary commands.

## 39. What is command substitution?

`$(command)` runs a command and substitutes its standard output. UniMonitor uses it to assign live CPU samples and host details to variables.

## 40. What is cron?

Cron is a scheduler that runs commands at specified times for a user. UniMonitor does not edit a crontab, but users may schedule `main.sh --report` themselves.

## 41. Why check command availability?

Different minimal Linux installations may omit optional tools. Checking with `command -v` lets the app show a fallback instead of failing the whole session.

## 42. What is `/proc`?

`/proc` is a virtual filesystem exposing kernel and process information. Files such as `/proc/stat`, `/proc/meminfo`, and `/proc/loadavg` contain live counters, not ordinary stored files.

## 43. Why does UniMonitor use functions in separate modules?

Functions separate responsibilities and let the entry point control navigation. Shared utilities avoid duplicate measurement and validation logic.

## 44. What is log rotation?

Log rotation renames or archives a current log when it grows too large. UniMonitor rotates the current log to `.1` at approximately 1 MiB and starts a new log.

## 45. What is a race condition in process termination?

A process can exit after its PID is checked but before a signal is sent; the PID may then be reused. UniMonitor reduces risk through confirmation and protected PID checks, but shell-level PID checks cannot fully eliminate this operating-system race.
