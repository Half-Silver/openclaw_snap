# Control Tower Integration — all-dev-openclaw

This snap uses the **ALL Universal Snap Engine (`ct-engine`)** for seamless Control Tower integration. All app-specific behavior is defined in the `plugin.yaml` manifest.

## 🏗️ Architecture

```text
all-dev-openclaw:
├── ct-engine          ← universal integration engine
├── plugin.yaml        ← OpenClaw-specific manifest
└── openclaw (mjs)     ← the actual gateway & node
```

## 📄 The Manifest (`plugin.yaml`)

This definition allows the `ct-engine` to manage OpenClaw's security tokens and dashboard access.

```yaml
app:
  name: "all-dev-openclaw"
  version: "2026.5.7"

config:
  port: { required: false, type: "int", default: 3000 }
  bind: { required: false, type: "string", default: "lan" }
  model: { required: false, type: "string", default: "openrouter/auto" }

sidecar:
  # Reports the dashboard link with the auto-generated security token
  status_command: |
    IP=$(hostname -I | awk '{print $1}')
    TOKEN=$(cat /var/snap/all-dev-openclaw/common/.openclaw/gateway.token)
    echo "dashboard: http://$IP:3000?token=$TOKEN"

output:
  mode: "logs"
  interval: 0
  initial_event: "message_initial"
```

## 📡 How it works

1. **Deployment**: Control Tower configures the snap via `snap set`.
2. **Token Generation**: OpenClaw starts and generates a `gateway.token`.
3. **Status Reporting**: The `ct-engine` runs the `sidecar.status_command`, reads the token, and sends the **authenticated login link** to the Control Tower.
4. **One-Click Access**: The user sees the link in their Control Tower UI and can log in immediately.

## 🛠️ Control Tower JSON Reference

```json
{
  "name": "all-dev-openclaw",
  "type": "sidecar",
  "config": {
    "port": 3000,
    "model": "openrouter/auto",
    "ct-callback-url": "http://<ct-ip>:8080/callback"
  }
}
```
