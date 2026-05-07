# OpenClaw Snap Configuration Guide

This guide lists all the configuration keys available for the **all-dev-openclaw** snap. You can set these using the `sudo snap set all-dev-openclaw <key>=<value>` command.

## 🚀 Quick Setup
After installing the snap, retrieve your security token to unlock the dashboard:
```bash
all-dev-openclaw.get-token
```

## 🛠️ Services
| Key | Default | Description |
|-----|---------|-------------|
| `gateway-service` | `enabled` | Enable/Disable the Gateway daemon (`enabled`, `disabled`) |
| `node-service` | `enabled` | Enable/Disable the Node (engine) daemon (`enabled`, `disabled`) |

## 🌐 Network & UI
| Key | Default | Description |
|-----|---------|-------------|
| `port` | `3000` | Port for the Web UI and Gateway |
| `bind` | `lan` | Network binding (`loopback`, `lan`, `auto`) |
| `remote-http-ui` | `true` | Allow access to UI from other devices on the network |

## 🧠 Core
| Key | Default | Description |
|-----|---------|-------------|
| `model` | `openrouter/auto` | Primary AI model to use for chat |

## 🤖 AI Providers (LLMs)

| Key | Env Var | Description |
|-----|---------|-------------|
| `openai-api-key` | `OPENAI_API_KEY` | OpenAI API Key |
| `openrouter-api-key` | `OPENROUTER_API_KEY` | OpenRouter API Key |
| `anthropic-api-key` | `ANTHROPIC_API_KEY` | Anthropic API Key |
| `gemini-api-key` | `GEMINI_API_KEY` | Google Gemini API Key |

## 💬 Messaging Channels
| Key | Env Var | Description |
|-----|---------|-------------|
| `telegram-bot-token` | `TELEGRAM_BOT_TOKEN` | Telegram Bot Token |
| `discord-bot-token` | `DISCORD_BOT_TOKEN` | Discord Bot Token |
| `slack-bot-token` | `SLACK_BOT_TOKEN` | Slack Bot Token (Bot User OAuth Token) |
| `slack-app-token` | `SLACK_APP_TOKEN` | Slack App Token (Socket Mode) |

## 🔍 Search & Tools
| Key | Env Var | Description |
|-----|---------|-------------|
| `brave-api-key` | `BRAVE_API_KEY` | Brave Search API Key |
| `perplexity-api-key` | `PERPLEXITY_API_KEY` | Perplexity API Key |
| `firecrawl-api-key` | `FIRECRAWL_API_KEY` | Firecrawl Search/Scrape API Key |

## 🔊 Voice
| Key | Env Var | Description |
|-----|---------|-------------|
| `elevenlabs-api-key` | `ELEVENLABS_API_KEY` | ElevenLabs API Key |

## ⚙️ System
| Key | Default | Description |
|-----|---------|-------------|
| `log-level` | `info` | Logging level (`debug`, `info`, `warn`, `error`) |

---

## 🛠️ Example Usage

### Set an API Key
```bash
sudo snap set all-dev-openclaw openrouter-api-key=sk-or-v1-...
```

### Change the Port
```bash
sudo snap set all-dev-openclaw port=8080
```

### Enable/Disable Remote UI
```bash
sudo snap set all-dev-openclaw remote-http-ui=false
```

### Check Current Config
```bash
snap get all-dev-openclaw
```
