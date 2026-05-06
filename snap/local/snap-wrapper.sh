#!/bin/sh
# OpenClaw Snap Wrapper
# This script sets up the environment for the OpenClaw services and CLI.

# Ensure we use the Node.js bundled with the snap
export PATH="$SNAP/bin:$SNAP/usr/bin:$PATH"

# Set production environment
export NODE_ENV=production

# Define the state and config paths within the snap's writable user data directory
export OPENCLAW_STATE_DIR="$HOME/.openclaw"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw/openclaw.json"

# Support for dynamic port configuration via 'snap set openclaw port=...'
PORT=$(snapctl get port)
if [ -n "$PORT" ]; then
  export OPENCLAW_GATEWAY_PORT="$PORT"
fi

# Support for network binding via 'snap set openclaw bind=...' (loopback, lan)
BIND=$(snapctl get bind)
if [ -n "$BIND" ]; then
  export OPENCLAW_GATEWAY_BIND="$BIND"
fi

# Log the configuration for debugging
echo "Starting OpenClaw with: BIND=${OPENCLAW_GATEWAY_BIND:-loopback}, PORT=${OPENCLAW_GATEWAY_PORT:-18789}" >&2

# Ensure standard umask for file creation (drwxr-xr-x / -rw-r--r--)
umask 0022

# Ensure the state directory exists before starting the application
if [ ! -d "$OPENCLAW_STATE_DIR" ]; then
  mkdir -p "$OPENCLAW_STATE_DIR"
fi

# Fix permissions if needed (e.g., due to previous sudo usage or bad umask)
if [ -d "$OPENCLAW_STATE_DIR" ]; then
  chmod u+rwX -R "$OPENCLAW_STATE_DIR" 2>/dev/null || true
  if [ ! -w "$OPENCLAW_STATE_DIR" ]; then
    echo "==========================================================================" >&2
    echo "🚨 ERROR: Permission denied writing to $OPENCLAW_STATE_DIR." >&2
    echo "If you previously ran openclaw with sudo, your files may be owned by root." >&2
    echo "Please fix this by running the following command:" >&2
    echo "  sudo chown -R \$USER:\$(id -gn) $OPENCLAW_STATE_DIR" >&2
    echo "==========================================================================" >&2
  fi
fi

# Execute the main entrypoint with the provided arguments
# But first, automatically inject the gateway token if it exists so the CLI
# and the Node service can connect to the local gateway daemon without prompting.
TOKEN_FILE="$OPENCLAW_STATE_DIR/gateway.token"
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ] && [ -f "$TOKEN_FILE" ]; then
  export OPENCLAW_GATEWAY_TOKEN=$(cat "$TOKEN_FILE")
fi

exec "$SNAP/bin/node" "$SNAP/openclaw.mjs" "$@"
