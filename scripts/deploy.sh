#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$repo_dir/bin"
cp "$repo_dir/apps/desktop/src-tauri/target/release/deck-desktop" "$repo_dir/bin/deck-desktop"

if [[ "$(uname -s)" != Darwin ]]; then
    echo "Desktop executable deployed; LaunchAgent installation is macOS-only."
    exit 0
fi

# The desktop build also builds apps/client/dist via beforeBuildCommand.
if [[ ! -f "$repo_dir/apps/client/dist/index.html" || ! -f "$repo_dir/apps/client/node_modules/vite/bin/vite.js" ]]; then
    echo "Missing web client build or dependencies. Install dependencies and run mise deploy." >&2
    exit 1
fi

# Resolve the actual runtime, not a version-manager shim requiring a login shell.
node_path="$(node -p 'process.execPath')"
agent_dir="$HOME/Library/LaunchAgents"
log_dir="$HOME/Library/Logs/doska"
domain="gui/$(id -u)"

mkdir -p "$agent_dir" "$log_dir"
staged_plist=""
trap '[[ -z "$staged_plist" ]] || rm -f "$staged_plist"' EXIT

install_agent() {
    local label="$1" app="$2" log_name="$3"
    shift 3
    local plist="$agent_dir/$label.plist" program_arguments
    staged_plist="$(mktemp "$agent_dir/.$label.XXXXXX")"
    cp "$repo_dir/com.kenbanks.doska.plist" "$staged_plist"
    # Replace the whole array: plutil's indexed replacement can insert an element.
    program_arguments="$("$node_path" -e 'console.log(JSON.stringify([process.execPath, ...process.argv.slice(1)]))' -- "$@")"
    /usr/bin/plutil -replace Label -string "$label" "$staged_plist"
    /usr/bin/plutil -replace ProgramArguments -json "$program_arguments" "$staged_plist"
    /usr/bin/plutil -replace WorkingDirectory -string "$repo_dir/apps/$app" "$staged_plist"
    /usr/bin/plutil -replace StandardOutPath -string "$log_dir/$log_name.log" "$staged_plist"
    /usr/bin/plutil -replace StandardErrorPath -string "$log_dir/$log_name.error.log" "$staged_plist"
    if [[ "$app" == client ]]; then
        # Match the backend's IPv4 loopback binding, regardless of localhost DNS order.
        /usr/bin/plutil -insert EnvironmentVariables -json '{"RPC_TARGET":"http://127.0.0.1:3000"}' "$staged_plist"
    fi
    /usr/bin/plutil -lint "$staged_plist"
    chmod 644 "$staged_plist"

    # Unload the old job before loading the updated paths and configuration.
    if /bin/launchctl print "$domain/$label" >/dev/null 2>&1; then
        /bin/launchctl bootout "$domain/$label"
    fi
    mv "$staged_plist" "$plist"
    /bin/launchctl enable "$domain/$label"
    # bootout can return before launchd finishes tearing down the previous job.
    local attempt bootstrap_error
    for attempt in {1..10}; do
        if bootstrap_error="$(/bin/launchctl bootstrap "$domain" "$plist" 2>&1)"; then
            return 0
        fi
        sleep 1
    done
    echo "Could not start $label: $bootstrap_error" >&2
    return 1
}

install_agent com.kenbanks.doska server server --env-file-if-exists=.env --import tsx src/index.ts
# Local-only serving of the built SPA, with the existing preview API proxy.
install_agent com.kenbanks.doska.web client web node_modules/vite/bin/vite.js preview --host localhost --port 5173 --strictPort

# Don't report success merely because launchd accepted the jobs.
for attempt in {1..30}; do
    if /usr/bin/curl --noproxy '*' -fsS --max-time 2 -o /dev/null 'http://localhost:5173/sign-in?desktop=' 2>/dev/null &&
       /usr/bin/curl --noproxy '*' -fsS --max-time 2 -o /dev/null 'http://localhost:5173/api/auth/get-session' 2>/dev/null; then
        echo "Deployed desktop executable, backend, and web client."
        echo "Sign in: http://localhost:5173/sign-in?desktop="
        echo "Logs: $log_dir"
        exit 0
    fi
    sleep 1
done

echo "Deployment failed its web/auth readiness checks. Inspect logs in $log_dir." >&2
exit 1
