#!/usr/bin/env bash
set -o nounset
set -o pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
[[ -f "$ROOT/main.sh" && "$ROOT" != / ]] || { printf 'Refusing to remove files: project root check failed.\n' >&2; exit 1; }
printf 'This removes UniMonitor program files from %s.\n' "$ROOT"
printf 'Reports, logs and config/settings.conf are preserved by default.\n'
read -r -p 'Type yes to uninstall the program files: ' answer || answer=no
[[ "$answer" == yes ]] || { printf 'Uninstall cancelled.\n'; exit 0; }
project_files=(
  main.sh install.sh uninstall.sh README.md LICENSE
  modules/system_info.sh modules/cpu_monitor.sh modules/memory_monitor.sh
  modules/disk_monitor.sh modules/process_manager.sh modules/network_diagnostics.sh
  modules/system_health.sh modules/report_manager.sh modules/settings.sh
  utils/common.sh utils/colors.sh utils/logger.sh utils/validation.sh
  docs/PROJECT_DOCUMENTATION.md docs/UNIX_CONCEPTS.md docs/TEST_CASES.md docs/VIVA_QUESTIONS.md
)
for relative_path in "${project_files[@]}"; do
  if [[ -f "$ROOT/$relative_path" ]] && ! rm -f -- "$ROOT/$relative_path"; then
    printf 'Could not remove project file: %s\n' "$relative_path" >&2
    exit 1
  fi
done
rmdir -- "$ROOT/modules" "$ROOT/utils" "$ROOT/docs" 2>/dev/null || :
read -r -p 'Also permanently delete reports and logs? Type yes to confirm: ' data_answer || data_answer=no
if [[ "$data_answer" == yes ]]; then
  rm -rf -- "$ROOT/reports" "$ROOT/logs"
  printf 'Reports and logs deleted.\n'
else printf 'Reports and logs preserved.\n'; fi
printf 'UniMonitor program files removed. Configuration was preserved.\n'
