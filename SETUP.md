# OpenClaw (ALL Edition) — Setup Guide

This guide will walk you through installing and configuring **all-dev-openclaw** on your device.

## 🚀 Full One-Line Setup
If you want to get everything running in one go:
```bash
sudo snap set all-dev-openclaw gateway-service=enabled && \
sudo snap set all-dev-openclaw node-service=enabled && \
sudo snap set all-dev-openclaw port=3000 && \
sudo snap set all-dev-openclaw bind=lan && \
sudo snap set all-dev-openclaw ct-callback-url=http://<ct-ip>:8080/callback && \
sudo snap set all-dev-openclaw ct-deployment-id=deploy-001 && \
sudo snap set all-dev-openclaw ct-node-id=node-001 && \
sudo snap set all-dev-openclaw ct-snap-name=all-dev-openclaw
```

---

## 1. Installation

Install the snap from your local build:
```bash
sudo snap install all-dev-openclaw_2026.5.7_amd64.snap --dangerous
```

## 2. Unlocking the Dashboard
OpenClaw generates a unique security token on its first run.
* **Get Token**: `all-dev-openclaw.get-token`
* **URL**: `http://<device-ip>:3000`
* **Check Port**: `ss -tulnp | grep 3000`

## 3. Service Management

### Enable/Disable Services
```bash
# Enable
sudo snap set all-dev-openclaw gateway-service=enabled node-service=enabled

# Disable
sudo snap set all-dev-openclaw gateway-service=disabled node-service=disabled
```

### Restart Services
```bash
# Restart Everything
sudo snap restart all-dev-openclaw

# Individual Services
sudo snap restart all-dev-openclaw.gateway
sudo snap restart all-dev-openclaw.node
sudo snap restart all-dev-openclaw.ct-engine
```

## 4. Configuration (API Keys & Model)

### AI Settings
```bash
# Set Model
sudo snap set all-dev-openclaw model=openrouter/auto

# Set API Keys
sudo snap set all-dev-openclaw openai-api-key=sk-...
sudo snap set all-dev-openclaw openrouter-api-key=sk-or-v1-...
```

### System Settings
```bash
sudo snap set all-dev-openclaw log-level=info
```

## 5. Monitoring & Debugging

### Follow Live Logs
```bash
# All Services
snap logs all-dev-openclaw -f

# Specific Service (Last 100 lines)
snap logs all-dev-openclaw.gateway -n 100 -f
```

### Check Interfaces
```bash
snap connections all-dev-openclaw
```

---

## 📂 File Locations

| Path Type | Location |
|-----------|----------|
| **Shared Data** | `/var/snap/all-dev-openclaw/common/.openclaw/` |
| **Secrets (.env)** | `/var/snap/all-dev-openclaw/common/.openclaw/.env` |
| **Config (JSON)** | `/var/snap/all-dev-openclaw/common/.openclaw/openclaw.json` |
| **User Settings** | `~/snap/all-dev-openclaw/` |
