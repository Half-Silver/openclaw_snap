# OpenClaw (ALL Edition) — Setup Guide

This guide will walk you through installing and configuring **all-dev-openclaw** on your device.

## 1. Installation

Install the snap from your local build:
```bash
sudo snap install all-dev-openclaw_2026.5.7_amd64.snap --dangerous
```

## 2. Unlocking the Dashboard

OpenClaw generates a unique security token on its first run. To access the dashboard, you need to retrieve this token:

```bash
all-dev-openclaw.get-token
```

1. Copy the token.
2. Open your browser to `http://<your-device-ip>:3000`.
3. Paste the token when prompted.

## 3. Control Tower Integration (Optional)

If you are using the ALL Control Tower, you can automate the configuration and status reporting:

```bash
# Set your CT Callback URL
sudo snap set all-dev-openclaw ct-callback-url=http://<ct-ip>:8080/callback

# (Optional) Set Deployment IDs
sudo snap set all-dev-openclaw ct-deployment-id=deploy-001
sudo snap set all-dev-openclaw ct-node-id=node-001
```

Once connected, OpenClaw will automatically post a **tokenized login link** to your Control Tower, so you won't need to manually copy the token again!

## 4. Configuration (API Keys)

You can configure your AI providers directly from the terminal. All changes are saved to a shared `.env` file in `$SNAP_COMMON/.openclaw/.env`.

### AI Providers
```bash
sudo snap set all-dev-openclaw openai-api-key=sk-...
sudo snap set all-dev-openclaw openrouter-api-key=sk-or-v1-...
sudo snap set all-dev-openclaw anthropic-api-key=sk-ant-...
sudo snap set all-dev-openclaw gemini-api-key=...
```

### Messaging Channels
```bash
sudo snap set all-dev-openclaw telegram-bot-token=...
sudo snap set all-dev-openclaw discord-bot-token=...
```

### Search & Tools
```bash
sudo snap set all-dev-openclaw brave-api-key=...
sudo snap set all-dev-openclaw perplexity-api-key=...
sudo snap set all-dev-openclaw firecrawl-api-key=...
```

## 5. Service Management

You can enable or disable parts of the system if needed:

```bash
# Disable the engine (node) but keep the dashboard (gateway)
sudo snap set all-dev-openclaw node-service=disabled

# Re-enable
sudo snap set all-dev-openclaw node-service=enabled
```

---

## Troubleshooting

### View Logs
```bash
sudo snap logs all-dev-openclaw -f
```

### Check Status
```bash
snap services all-dev-openclaw
```

### Reset Permissions
If you encounter permission issues in the state directory:
```bash
sudo chmod -R 777 /var/snap/all-dev-openclaw/common/.openclaw
```
