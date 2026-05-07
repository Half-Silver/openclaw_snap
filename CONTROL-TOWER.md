# Control Tower Integration — all-dev-openclaw

This document defines the input schema and configuration required for the **ALL Control Tower** to manage this snap.

## 📄 Snap Manifest (JSON)

Use this JSON when registering the snap in the Control Tower dashboard.

```json
{
  "name": "all-dev-openclaw",
  "version": "2026.5.7",
  "type": "sidecar",
  "config": {
    "port": 3000,
    "bind": "lan",
    "model": "openrouter/auto",
    "openrouter-api-key": "",
    "openai-api-key": "",
    "ct-callback-url": "http://<ct-ip>:8080/callback"
  },
  "output": {
    "mode": "logs",
    "interval": 0,
    "initial_event": "message_initial",
    "stop_event": "deployment_stop"
  }
}
```

## 🛠️ Input Schema (Configuration)

| Key | Type | Description |
|-----|------|-------------|
| `port` | `int` | Gateway port (Default: `3000`) |
| `bind` | `string` | Network binding (Default: `lan`) |
| `model` | `string` | Primary AI model (e.g., `openrouter/auto`) |
| `openrouter-api-key` | `string` | OpenRouter API Key |
| `openai-api-key` | `string` | OpenAI API Key |
| `ct-callback-url` | `string` | The Control Tower callback URL for status reporting |

## 📡 Status Reporting (Sidecar)

OpenClaw reports its status via periodic callbacks to the `ct-callback-url`.

### Automated Dashboard Login
Upon startup, OpenClaw sends a `message_initial` event containing a **tokenized dashboard link**:
- `http://<ip>:3000?token=xxxxxxx`

This allows you to open the dashboard directly from your Control Tower messages without manually retrieving the security token.

### Shutdown
Upon stopping, OpenClaw sends a `deployment_stop` event to notify the Control Tower of graceful closure.
