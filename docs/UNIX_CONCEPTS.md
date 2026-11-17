# Unix and Bash Concepts Used in UniMonitor

Examples below refer to the project source. Run commands from the project directory.

## 1. Shell variables

**Definition:** A shell variable stores text or a value for use by later commands. **Syntax:** `name=value`; read with `$name`. **Example:** `CPU_WARNING=70` in `utils/common.sh`. **Why:** Thresholds and paths are shared by health checks, settings, and the dashboard.

## 2. Environment variables

**Definition:** Variables exported by a process are inherited by child processes. **Syntax:** `export NAME=value`; inspect with `$NAME`. **Example:** `NO_COLOR` controls color output and `UNIMONITOR_CONFIG` selects an alternate settings file. **Why:** Users can adjust behavior without changing source files.

## 3. Positional parameters and command-line arguments

**Definition:** `$1`, `$2`, and `$@` represent arguments supplied to a script or function. **Syntax:** `script.sh argument`. **Example:** `case "${1:-}" in --report) ...` in `main.sh`. **Why:** UniMonitor supports non-interactive report creation, help, and version output.

## 4. Conditional statements

**Definition:** `if` and `test` choose behavior from a condition or command exit status. **Syntax:** `if command; then ...; else ...; fi`. **Example:** `if [[ ! -f "$CONFIG_FILE" ]]` is used by installation/configuration handling. **Why:** Optional commands and unavailable data need explicit fallbacks.

## 5. `case` statements

**Definition:** `case` matches one value against patterns. **Syntax:** `case "$x" in pattern) commands;; esac`. **Example:** Menu dispatch in `main.sh` and the allowlist in `load_config`. **Why:** It keeps menu and config key handling readable while restricting accepted inputs.

## 6. `for` loops

**Definition:** A `for` loop repeats commands over a list. **Syntax:** `for item in list; do ...; done`. **Example:** `for cmd in awk grep sed ps df` in `health_analyze`. **Why:** It checks several required utilities with one reusable block.

## 7. `while` loops

**Definition:** A `while` loop repeats while its condition succeeds. **Syntax:** `while true; do ...; done`. **Example:** The application and submenus remain open until the user selects Return or Exit. **Why:** Navigation can continue without restarting the program.

## 8. Functions

**Definition:** A function groups commands under a reusable name. **Syntax:** `name() { commands; }`. **Example:** `cpu_usage_sample` and `memory_values` in `utils/common.sh`. **Why:** Modules share one implementation of measurement logic.

## 9. Arrays

**Definition:** Bash arrays store multiple values under one variable name. **Syntax:** `items=(one two)` and `${items[@]}`. **Example:** `HEALTH_RECOMMENDATIONS+=("...")` in `system_health.sh`. **Why:** Recommendations are collected from actual findings and printed as a list.

## 10. File handling

**Definition:** Shell tools create, read, append, move, and remove files. **Syntax:** redirection (`>`, `>>`) or utilities such as `cat`, `mv`, and `rm`. **Example:** `log_event` appends to `unimonitor.log`; `report_generate` writes a temporary report then saves it. **Why:** Results persist across program runs.

## 11. File permissions

**Definition:** Unix permissions control read, write, and execute access for owner, group, and others. **Syntax:** `chmod 755 main.sh`; `rwx` bits are commonly shown in octal. **Example:** `install.sh` sets entry points executable and settings are saved with mode `600`. **Why:** Scripts can be launched directly and configuration edits are private to the owner by default.

## 12. Pipes

**Definition:** A pipe connects one command's standard output to another command's standard input. **Syntax:** `command1 | command2`. **Example:** `ps ... | head -n 11` and `df ... | awk ...`. **Why:** UniMonitor filters and formats command output without intermediate files.

## 13. Input/output redirection

**Definition:** Redirection sends output or errors to files or other destinations. **Syntax:** `> file`, `>> file`, `2>/dev/null`, `2>&1`. **Example:** `printf ... >> "$log_file"` in `logger.sh`. **Why:** Logs/reports are saved, while expected optional-command errors can be handled cleanly.

## 14. Exit status

**Definition:** A command returns an integer status; `0` usually means success and nonzero means failure. **Syntax:** `if command; then ...; fi`; `$?` is the last status. **Example:** `ping` is tested in `network_test_ping`; `report_generate` returns failure when writing is unavailable. **Why:** Features can distinguish a successful operation from a fallback condition.

## 15. Command substitution

**Definition:** `$(...)` runs a command and inserts its output as text. **Syntax:** `value=$(command)`. **Example:** `cpu=$(cpu_usage_sample 1 ...)` in `main.sh`. **Why:** Dynamic system readings are assigned to variables and displayed.

## 16. Process management and signals

**Definition:** Processes have PIDs; signals request actions such as termination. **Syntax:** `kill -TERM PID`. **Example:** `process_terminate` validates, confirms, logs, and then sends `SIGTERM`. **Why:** The feature demonstrates process control while avoiding forceful default termination.

## 17. Text processing with `grep`

**Definition:** `grep` selects lines matching a pattern. **Syntax:** `grep pattern file`. **Example:** `cpu_monitor_print` uses `grep -m1` to select the first CPU model line from `/proc/cpuinfo`, then `sed` removes the label. **Why:** Text filters are standard tools for inspecting Unix output.

## 18. Text processing with `awk`

**Definition:** `awk` processes records and fields and can perform arithmetic. **Syntax:** `awk 'condition { action }' file`. **Example:** CPU counters are read and memory percentages calculated in `utils/common.sh` and module scripts. **Why:** It extracts kernel counters and produces accurate ratios.

## 19. Text processing with `sed`

**Definition:** `sed` transforms text streams. **Syntax:** `sed 's/old/new/'`. **Example:** `process_terminate` trims spaces around the command name with `sed`. **Why:** It normalizes command output before safety comparisons.

## 20. Command lookup and exit behavior

**Definition:** `command -v` locates a command in `PATH`; `set` changes shell options. **Syntax:** `command -v tool`; `set -o pipefail`. **Example:** `command_exists` in `common.sh`; `main.sh` enables `nounset` and `pipefail`. **Why:** Missing dependencies are handled, unset variable mistakes are surfaced, and pipeline failures are less likely to be hidden.

## 21. Quoting and input validation

**Definition:** Quoting preserves a value as one argument and prevents word splitting or glob expansion. **Syntax:** `command -- "$value"`. **Example:** `du -sh -- "$path"` and `kill -TERM "$pid"`. **Why:** User input is treated as data. Validators constrain paths, hostnames, thresholds, and PIDs.

## 22. Arrays and filename expansion

**Definition:** Filename expansion turns patterns into matching pathnames. **Syntax:** `files=(dir/*.txt)`. **Example:** `report_history_menu` uses a quoted array and temporarily enables `nullglob`. **Why:** Each report remains a distinct argument, including if the directory is empty.

## 23. Environment and shell context

**Definition:** The process environment and shell context provide defaults for child commands. **Syntax:** `${VAR:-default}`. **Example:** `NO_COLOR`, `SHELL`, `COLUMNS`, and the `UNIMONITOR_CONFIG` override. **Why:** The app adapts to the terminal and calling environment.

## 24. Background processes

**Definition:** Appending `&` starts a command asynchronously. **Syntax:** `command &`. **Example:** UniMonitor does not launch monitor loops in the background. **Why:** The application is an on-demand snapshot tool; keeping sampling in the foreground makes completion, error reporting, and process cleanup straightforward. No background worker is needed.

## 25. Cron automation

**Definition:** Cron runs commands at scheduled times using a user's crontab. **Syntax:** `minute hour day month weekday command`. **Example:** Cron is not installed or modified by this version; users can schedule `./main.sh --report` themselves. **Why:** Scheduling is optional in the project brief, and automatically editing a user's crontab would require a separate explicit setup flow.

## 26. Standard streams

**Definition:** Standard input, standard output, and standard error are file descriptors 0, 1, and 2. **Syntax:** `2>&1`. **Example:** Report collection redirects both module output streams into the report. **Why:** Diagnostics and errors remain available in the saved snapshot.
