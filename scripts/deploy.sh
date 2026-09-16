#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$repo_dir/bin"
cp "$repo_dir/apps/desktop/src-tauri/target/release/deck-desktop" "$repo_dir/bin/deck-desktop"

if [[ "$(uname -s)" != Darwin ]]; then
    echo "Desktop executable deployed; LaunchAgent installation is macOS-only."
    exit 0
fi

# Resolve the actual runtime, not a version-manager shim requiring a login shell.
node_path="$(node -p 'process.execPath')"
label="com.kenbanks.doska"
agent_dir="$HOME/Library/LaunchAgents"
log_dir="$HOME/Library/Logs/doska"
plist="$agent_dir/$label.plist"
domain="gui/$(id -u)"

mkdir -p "$agent_dir" "$log_dir"
staged_plist="$(mktemp "$agent_dir/.$label.XXXXXX")"
trap 'rm -f "$staged_plist"' EXIT
cp "$repo_dir/$label.plist" "$staged_plist"
/usr/bin/plutil -replace ProgramArguments.0 -string "$node_path" "$staged_plist"
/usr/bin/plutil -replace WorkingDirectory -string "$repo_dir/apps/server" "$staged_plist"
/usr/bin/plutil -replace StandardOutPath -string "$log_dir/server.log" "$staged_plist"
/usr/bin/plutil -replace StandardErrorPath -string "$log_dir/server.error.log" "$staged_plist"
/usr/bin/plutil -lint "$staged_plist"
chmod 644 "$staged_plist"

# Unload the old job before loading the updated paths and configuration.
if /bin/launchctl print "$domain/$label" >/dev/null 2>&1; then
    /bin/launchctl bootout "$domain/$label"
fi
mv "$staged_plist" "$plist"
/bin/launchctl enable "$domain/$label"
/bin/launchctl bootstrap "$domain" "$plist"

echo "Deployed desktop executable and started $label."
echo "Server logs: $log_dir"
