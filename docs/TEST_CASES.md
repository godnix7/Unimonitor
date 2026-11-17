# UniMonitor Test Cases

Run these cases from an Ubuntu/Linux terminal in the project directory. They avoid destructive process operations. For the termination case, use a disposable process started by the tester and confirm only that PID.

## Test procedure and expected results

| ID | Feature | Procedure | Expected result |
|---|---|---|---|
| TC-01 | Startup | Run `./install.sh`, then `./main.sh`. | Installer reports success; dashboard displays host and live metrics; menu accepts input. |
| TC-02 | Invalid menu option | Run `printf 'x\n\n0\n' \| ./main.sh`. | Clear validation message; app continues; no command is executed from the input. |
| TC-03 | Missing optional command | Run the app with a controlled `PATH` that omits an optional tool such as `lsblk`, while retaining Bash and core tools. | Feature reports the tool unavailable and other modules remain usable. |
| TC-04 | CPU monitoring | Select CPU module twice, refresh once, then return. | Utilization is based on two `/proc/stat` samples; load and top processes are shown; refresh obtains another sample. |
| TC-05 | Memory monitoring | Select memory module. | Total, used, available, free and swap are shown; used equals total minus available (subject to rounding only in display). |
| TC-06 | Disk monitoring | Select disk module; inspect a readable directory. | Persistent filesystem rows and block devices appear when available; directory size comes from `du`. |
| TC-07 | Process search | Search for a known process such as `bash`. | Matching process rows show PID, owner, CPU, and memory values; search text is literal. |
| TC-08 | Process details | Enter a live PID from the list. | `ps` displays details for that PID. Invalid and nonexistent PIDs are rejected. |
| TC-09 | Termination confirmation | Start a disposable process with `sleep 120 &`; select it by PID; first answer `no`, then repeat and answer `yes`. | `no` cancels. `yes` sends SIGTERM only to the selected process. Never use PID 1 or a system process. |
| TC-10 | Protected PID | Attempt PID `1` in the termination menu. | Request is refused and logged without signaling. |
| TC-10a | Root-owned process | When available, select a root-owned process in the termination menu. | UniMonitor refuses to signal it and explains privilege requirements. |
| TC-11 | Network connectivity | Test a reachable IP and a deliberately invalid/unreachable target. | Tests finish within bounded time; gateway and target outcomes are distinguished. ICMP filtering is mentioned as a limitation. |
| TC-12 | DNS | Resolve a valid hostname, then an invalid hostname. | Valid result lists addresses; invalid input or failed lookup reports failure without shell interpretation. |
| TC-13 | Health thresholds | Set a test threshold below a currently measured value using settings, run health, then restore defaults. | The measured metric receives warning/critical based on the configured threshold; failed metrics show N/A. |
| TC-14 | Report generation | Run `./main.sh --report`; open the result in `reports/`. | Timestamped readable report contains system, CPU, memory, disk, process, network, and health sections. |
| TC-15 | Report history | In Reports, view a report and cancel deletion; repeat and type `yes` to delete. | The report is displayed; cancellation preserves it; confirmed deletion removes only the selected report. |
| TC-16 | Missing config | Temporarily move `config/settings.conf`, run the app, then restore it. | Built-in defaults remain active; app continues. Installer recreates missing default config when run. |
| TC-17 | Invalid config data | In a disposable config, put `CPU_WARNING=not-a-number` and `CPU_CRITICAL=20`. | Invalid values fall back to defaults; config text is never executed. |
| TC-18 | Permission error | Set a test report directory that is not writable for the current user and run report generation. | Clear write failure; no partial report is presented as successful. |
| TC-19 | Log rotation | In a disposable copy, lower `LOG_MAX_BYTES` or create a large log; log an event. | Current log rotates to `.1`; new events appear in the current log. |
| TC-20 | CLI | Run `./main.sh --help`, `--version`, and an unknown option. | Help/version exit successfully; unknown option prints help and exits with status 2. |

## Verification record

This repository was authored in a Windows workspace. The available `bash.exe` is the WSL launcher, and no Ubuntu distribution is installed (the only registered distribution is Docker Desktop); therefore `/proc`-based monitoring, Linux `df -T`, installer OS detection, and Linux permission behavior could not be truthfully marked as exercised in Ubuntu during this run. Git Bash is available for syntax validation and safe CLI checks. Re-run the full procedure on Ubuntu before submitting as a Linux-tested implementation.

Record actual results after running on Ubuntu:

| Check | Result | Environment / notes |
|---|---|---|
| Bash syntax (`bash -n`) | Passed | Git Bash; all project shell scripts |
| CLI help/version | Passed | Git Bash |
| Interactive invalid menu / graceful exit | Passed | Git Bash smoke run; live dashboard and input loop |
| Report generation and section presence | Passed | Git Bash smoke run; all requested report sections were written |
| Process termination confirmation | Passed | Disposable `sleep` fixture; `no` preserved it and `yes` sent SIGTERM |
| Configuration payload safety | Passed | Git Bash smoke test; command-shaped threshold value was not executed |
| Threshold boundaries and health engine | Passed | Threshold utility boundaries (including N/A) and a controlled critical health case |
| Unavailable metrics and log rotation | Passed | Health stayed UNKNOWN with all measurements stubbed unavailable; log rotated at test size |
| Root-owned process guard | Passed | Controlled process metadata returned root; no signal was sent |
| Installer platform guard | Passed | Git Bash refused installation outside Linux without modifying project files |
| Linux monitor modules and report | Pending | Ubuntu runtime unavailable; see limitation above |
| Linux installation and permissions | Pending | Requires Ubuntu; only the non-Linux refusal path was exercised |
| ShellCheck review | Not run | `shellcheck` is not installed in the authoring environment |
