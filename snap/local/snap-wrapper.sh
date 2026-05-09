#!/bin/sh
# OpenClaw Snap Wrapper
# This script sets up the environment for the OpenClaw services and CLI.

# Ensure we use the Node.js bundled with the snap
export PATH="$SNAP/bin:$SNAP/usr/bin:$PATH"

# Set production environment
export NODE_ENV=production

# Allow running as root in the snap appliance environment
export OPENCLAW_ALLOW_ROOT=1


# Preload snap runtime overrides before the OpenClaw entrypoint reads config.
SNAP_PRELOAD_MODULE="$SNAP/bin/snap-preload.mjs"
if [ -n "$NODE_OPTIONS" ]; then
  export NODE_OPTIONS="--import=$SNAP_PRELOAD_MODULE $NODE_OPTIONS"
else
  export NODE_OPTIONS="--import=$SNAP_PRELOAD_MODULE"
fi

# Define the state and config paths within the snap's shared common directory
# This allows both the daemon (root) and the CLI (user) to share the same config.
export OPENCLAW_STATE_DIR="$SNAP_COMMON/.openclaw"
export OPENCLAW_CONFIG_PATH="$SNAP_COMMON/.openclaw/openclaw.json"

# Support for dynamic port configuration via 'snap set all-dev-openclaw port=...'
PORT=$(snapctl get port)
if [ -z "$PORT" ]; then
  PORT=3000
fi
export OPENCLAW_GATEWAY_PORT="$PORT"
export OPENCLAW_GATEWAY_URL="ws://127.0.0.1:$PORT"


# Support for network binding via 'snap set all-dev-openclaw bind=...' (loopback, lan, tailnet, auto)
BIND=$(snapctl get bind)
if [ -n "$BIND" ]; then
  case "$(printf '%s' "$BIND" | tr '[:upper:]' '[:lower:]')" in
    loopback|lan|tailnet|auto)
      export OPENCLAW_SNAP_BIND_OVERRIDE="$BIND"
      ;;
    *)
      echo "Ignoring unsupported snap bind setting: $BIND" >&2
      ;;
  esac
fi

# Direct remote http://<lan-ip>:<port>/ Control UI access needs Host-header origin
# fallback plus the device-auth bypass that OpenClaw normally reserves for
# break-glass setups. Keep this snap-specific and tied to explicit non-loopback
# appliance exposure.
REMOTE_HTTP_UI=$(snapctl get remote-http-ui)
if [ -n "$REMOTE_HTTP_UI" ]; then
  case "$(printf '%s' "$REMOTE_HTTP_UI" | tr '[:upper:]' '[:lower:]')" in
    1|true|on|enabled)
      export OPENCLAW_SNAP_REMOTE_HTTP_UI=1
      ;;
    0|false|off|disabled)
      export OPENCLAW_SNAP_REMOTE_HTTP_UI=0
      ;;
    *)
      echo "Ignoring unsupported snap remote-http-ui setting: $REMOTE_HTTP_UI" >&2
      ;;
  esac
fi

# Log the configuration for debugging
REMOTE_HTTP_UI_STATUS=${OPENCLAW_SNAP_REMOTE_HTTP_UI:-auto}
echo "Starting OpenClaw with: BIND=${OPENCLAW_SNAP_BIND_OVERRIDE:-loopback}, PORT=${OPENCLAW_GATEWAY_PORT:-18789}, REMOTE_HTTP_UI=${REMOTE_HTTP_UI_STATUS}" >&2

# Ensure standard umask for file creation (drwxr-xr-x / -rw-r--r--)
umask 0022

# Ensure the state directory exists before starting the application
if [ ! -d "$OPENCLAW_STATE_DIR" ]; then
  mkdir -p "$OPENCLAW_STATE_DIR"
fi

# Fix permissions if needed
if [ -d "$OPENCLAW_STATE_DIR" ]; then
  chmod u+rwX -R "$OPENCLAW_STATE_DIR" 2>/dev/null || true
  if [ ! -w "$OPENCLAW_STATE_DIR" ]; then
    echo "==========================================================================" >&2
    echo "🚨 ERROR: Permission denied writing to $OPENCLAW_STATE_DIR." >&2
    echo "Please fix this by running the following command:" >&2
    echo "  sudo chmod -R 777 $OPENCLAW_STATE_DIR" >&2
    echo "==========================================================================" >&2
  fi
fi

# Handle special commands
if [ "$1" = "get-token" ]; then
  TOKEN_FILE="$OPENCLAW_STATE_DIR/gateway.token"
  
  if [ -f "$TOKEN_FILE" ]; then
    echo "=========================================================================="
    echo "🔑 OpenClaw Gateway Token:"
    cat "$TOKEN_FILE"
    echo ""
    echo "Paste this token into the Dashboard at http://localhost:3000"
    echo "=========================================================================="
  elif [ -f "$OPENCLAW_CONFIG_PATH" ]; then
    # Fallback: Try to extract the token from openclaw.json if it exists
    TOKEN=$(grep -o '"token": *"[^"]*"' "$OPENCLAW_CONFIG_PATH" | head -n 1 | cut -d'"' -f4)
    if [ -n "$TOKEN" ]; then
      echo "=========================================================================="
      echo "🔑 OpenClaw Gateway Token (extracted from config):"
      echo "$TOKEN"
      echo ""
      echo "Paste this token into the Dashboard at http://localhost:3000"
      echo "=========================================================================="
    else
      echo "❌ Token not found in $OPENCLAW_CONFIG_PATH."
      echo "Is the gateway configured? Try starting it first."
    fi
  else
    echo "❌ Token file not found."
    echo "Is the gateway running? Try starting it first."
  fi
  exit 0
fi


# Intercept 'node run' to pass the correct gateway port directly
if [ "$1" = "node" ] && [ "$2" = "run" ]; then
  shift 2
  exec "$SNAP/bin/node" "$SNAP/openclaw.mjs" node run --port "$OPENCLAW_GATEWAY_PORT" "$@"
fi

exec "$SNAP/bin/node" "$SNAP/openclaw.mjs" "$@"


