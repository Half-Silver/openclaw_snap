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

# Ensure the state directory exists before starting the application
if [ ! -d "$OPENCLAW_STATE_DIR" ]; then
  mkdir -p "$OPENCLAW_STATE_DIR"
fi

# Execute the main entrypoint with the provided arguments
exec "$SNAP/bin/node" "$SNAP/openclaw.mjs" "$@"
