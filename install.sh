#!/usr/bin/env bash
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
fail() { printf 'Installation error: %s\n' "$1" >&2; exit 1; }

command -v bash >/dev/null 2>&1 || fail 'Bash is required.'
[[ "$(uname -s 2>/dev/null || printf unknown)" == Linux ]] || fail 'UniMonitor supports Ubuntu/Linux; run this installer from Linux or WSL.'
[[ -f "$ROOT/main.sh" && -d "$ROOT/modules" && -d "$ROOT/utils" ]] || fail 'Run install.sh from the UniMonitor project directory.'

required=(awk grep sed ps df mkdir date sleep head wc mv mktemp tr dirname rm chmod)
missing=()
for utility in "${required[@]}"; do command -v "$utility" >/dev/null 2>&1 || missing+=("$utility"); done
if ((${#missing[@]})); then printf 'Required utilities missing: %s\n' "${missing[*]}"; printf 'Install them with your distribution package manager, then rerun install.sh.\n'; exit 1; fi

mkdir -p -- "$ROOT/reports" "$ROOT/logs" "$ROOT/config" || fail 'Could not create project directories.'
if [[ ! -f "$ROOT/config/settings.conf" ]]; then
  cat > "$ROOT/config/settings.conf" <<'CONFIG'
CPU_WARNING=70
CPU_CRITICAL=90
MEMORY_WARNING=75
MEMORY_CRITICAL=90
DISK_WARNING=80
DISK_CRITICAL=95
SWAP_WARNING=70
SWAP_CRITICAL=90
REPORT_DIR=reports
LOG_DIR=logs
CONFIG
fi
chmod 755 "$ROOT/main.sh" "$ROOT/install.sh" "$ROOT/uninstall.sh" || fail 'Could not set executable permissions.'
project_modules=(system_info.sh cpu_monitor.sh memory_monitor.sh disk_monitor.sh process_manager.sh network_diagnostics.sh system_health.sh report_manager.sh settings.sh)
project_utils=(common.sh colors.sh logger.sh validation.sh)
for script in "${project_modules[@]}"; do chmod 644 "$ROOT/modules/$script" || fail "Could not set permissions on modules/$script."; done
for script in "${project_utils[@]}"; do chmod 644 "$ROOT/utils/$script" || fail "Could not set permissions on utils/$script."; done

printf 'UniMonitor 1.0 installed in %s\n' "$ROOT"
printf 'Optional utilities: '
optional=(uname hostname uptime free lsblk ip ping ss getent journalctl)
available=()
for utility in "${optional[@]}"; do command -v "$utility" >/dev/null 2>&1 && available+=("$utility"); done
printf '%s\n' "${available[*]:-none detected}"
printf 'Run: ./main.sh\n'
