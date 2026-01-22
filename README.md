# cc-copilot-bridge

**Bridge GitHub Copilot to Claude Code CLI for free AI-powered coding**

Turn your $10/month GitHub Copilot Pro+ subscription into unlimited Claude Code access with 25+ models (GPT-4.1, Claude Opus/Sonnet/Haiku, Gemini, etc.).

---

## 🎯 What Is This?

A **Copilot bridge** for Claude Code CLI that enables **free** access to 25+ AI models (GPT-4.1, Claude Opus/Sonnet/Haiku, Gemini) using your existing GitHub Copilot Pro+ subscription.

**Core Value**: Turn your $10/month Copilot subscription into unlimited Claude Code access.

**Bonus**: Includes Ollama offline mode (architecturally independent) for private/air-gapped development.

### Architecture Overview

```
┌─────────────────────────────────────────────────┐
│           Claude Code CLI                       │
│         (Anthropic's CLI tool)                  │
└─────────────────┬───────────────────────────────┘
                  │
        ┌─────────▼──────────┐
        │  cc-copilot-bridge │  ◄─── This Tool
        └─────────┬──────────┘
                  │
        ┌─────────┴──────────────────────────────┐
        │                                        │
    ┌───▼────┐         ┌───────▼────────┐   ┌───▼────┐
    │ Direct │         │ Copilot Bridge │   │ Ollama │
    │  API   │         │  (copilot-api) │   │ Local  │
    └────────┘         └────────────────┘   └────────┘
    Anthropic           GitHub Copilot       Self-hosted
    $0.015/1M tokens    $10/month (flat)     Free (offline)
    (Haiku example)     UNLIMITED usage      Apple Silicon
```

---

## 🚀 Quick Start

### Installation

```bash
# Clone or download
curl -sSL https://raw.githubusercontent.com/YOU/cc-copilot-bridge/main/install.sh | bash

# Or manual install
cp claude-switch ~/bin/
chmod +x ~/bin/claude-switch
```

### Setup Aliases

```bash
# Add to ~/.bash_aliases or ~/.zshrc
alias ccd='claude-switch direct'      # Anthropic API (paid)
alias ccc='claude-switch copilot'     # GitHub Copilot (free*)
alias cco='claude-switch ollama'      # Ollama Local (offline)
alias ccs='claude-switch status'      # Check all providers

# Model shortcuts
alias ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
alias ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
```

### Usage

```bash
# Start with Copilot (free via your subscription)
ccc

# Switch models on-the-fly
COPILOT_MODEL=gpt-4.1 ccc
COPILOT_MODEL=claude-opus-4.5 ccc

# Check status
ccs
```

---

## 💰 Cost Comparison

| Scenario | Anthropic Direct | cc-copilot-bridge | Savings |
|----------|------------------|-------------------|---------|
| **100M tokens/month** | $1,500 (Haiku) | $10 (Copilot flat) | **99.3%** |
| **10 sessions/day** | ~$300/month | $10/month | **96.7%** |
| **Heavy usage** | Pay per token | Fixed $10/month | **~$290/month** |

**Requirements**: GitHub Copilot Pro+ subscription ($10/month)

---

## 🎨 Features

### 1. **Instant Provider Switching** (3 characters)

```bash
ccd     # Anthropic Direct API (production)
ccc     # GitHub Copilot Bridge (prototyping)
cco     # Ollama Local (offline/private)
```

No config changes, no restarts, no environment variable juggling.

### 2. **Dynamic Model Selection** (25+ models)

| Provider | Models | Cost |
|----------|--------|------|
| **Anthropic** | opus-4.5, sonnet-4.5, haiku-4.5 | Per token |
| **Copilot** | claude-*, gpt-4.1, gpt-5, gemini-* | Flat $10/month |
| **Ollama** | qwen2.5-coder, deepseek-coder, codellama | Free |

```bash
# Switch models mid-session
ccc                     # Default: claude-sonnet-4.5
ccc-opus                # Claude Opus 4.5
ccc-gpt                 # GPT-4.1
COPILOT_MODEL=gemini-2.5-pro ccc  # Gemini
```

### 3. **MCP Profiles System** (Auto-Compatibility)

**Problem**: GPT-4.1 has strict JSON schema validation → breaks some MCP servers

**Solution**: Auto-generated profiles exclude incompatible servers

```bash
~/.claude/mcp-profiles/
├── excludes.yaml       # Define problematic servers
├── generate.sh         # Auto-generate profiles
└── generated/
    ├── gpt.json       # GPT-compatible (9/10 servers)
    └── gemini.json    # Gemini-compatible
```

### 4. **Model Identity Injection**

**Problem**: GPT-4.1 thinks it's Claude when running through Claude Code CLI

**Solution**: System prompts injection

```bash
~/.claude/mcp-profiles/prompts/
├── gpt-4.1.txt        # "You are GPT-4.1 by OpenAI..."
└── gemini.txt         # "You are Gemini by Google..."
```

**Result**: Models correctly identify themselves

### 5. **Health Checks & Fail-Fast**

```bash
ccc
# → ERROR: copilot-api not running on :4141
#    Start it with: copilot-api start
```

### 6. **Session Logging**

```bash
tail ~/.claude/claude-switch.log

[2026-01-22 09:42:33] [INFO] Provider: GitHub Copilot - Model: gpt-4.1
[2026-01-22 09:42:33] [INFO] Using restricted MCP profile for gpt-4.1
[2026-01-22 09:42:33] [INFO] Injecting model identity prompt for gpt-4.1
[2026-01-22 10:15:20] [INFO] Session ended: duration=32m47s exit=0
```

---

## 🏗️ Provider Architecture

### 🎯 CORE: GitHub Copilot Bridge

**Use Case**: Daily coding, prototyping, exploration (FREE*)

```bash
ccc                               # Default: claude-sonnet-4.5
ccc-gpt                          # GPT-4.1
ccc-opus                         # Claude Opus 4.5
COPILOT_MODEL=gemini-2.5-pro ccc # Gemini
```

**How It Works**:
- Routes through [copilot-api](https://github.com/ericc-ch/copilot-api) proxy
- **Unlimited** usage for $10/month (Copilot Pro+ subscription)
- Access to 15+ models (Claude, GPT, Gemini families)
- Best for: Daily development, experimentation, learning

**Requirements**:
1. GitHub Copilot Pro+ subscription ($10/month)
2. copilot-api running locally (`copilot-api start`)

---

### 🎁 BONUS: Ollama Local (Offline Mode)

**Use Case**: Offline work, proprietary code, air-gapped environments

```bash
cco                                          # Default: qwen2.5-coder:32b
OLLAMA_MODEL=deepseek-coder:33b cco          # DeepSeek Coder
```

**How It Works**:
- Self-hosted inference (no internet required)
- Free, 100% private
- Apple Silicon optimized (M1/M2/M3/M4 - up to 4x faster)
- Best for: Sensitive code, airplane mode, privacy-first scenarios

**Important**: Ollama is **architecturally independent** from Copilot bridging. It's a separate provider for local inference, not related to copilot-api.

**Requirements**:
1. Ollama installed (`ollama.ai`)
2. Models downloaded (`ollama pull qwen2.5-coder:32b-instruct`)

---

### 🔄 FALLBACK: Anthropic Direct API

**Use Case**: Production, maximum quality, critical analysis

```bash
ccd
```

**How It Works**:
- Official Anthropic API
- Pay per token ($0.015-$75 per 1M tokens)
- Best for: Production code review, security audits, critical decisions

**Requirements**:
1. `ANTHROPIC_API_KEY` environment variable
2. Anthropic account with billing

---

## 📊 vs Claude Code Router

| Feature | cc-copilot-bridge | Claude Code Router |
|---------|-------------------|-------------------|
| **Architecture** | Copilot proxy (copilot-api) | Paid API routing |
| **Cost Model** | $10/month (flat) | Per-token ($0.14-$75/1M) |
| **Copilot Integration** | ✅ Primary feature | ❌ Not supported |
| **Target Audience** | Copilot subscribers | API users |
| **Offline Mode** | ✅ Ollama provider | ❌ Cloud only |
| **MCP Profiles** | ✅ Auto-generated | Manual |
| **Model Identity** | ✅ Injected prompts | N/A |

**We're not competing** - we serve different markets:
- **cc-copilot-bridge**: For Copilot subscribers wanting free Claude Code access
- **Claude Code Router**: For users routing to multiple paid APIs

---

## 🎬 Real-World Workflows

### Workflow 1: Cost-Optimized Development

```bash
# Morning: Prototype with free Copilot
ccc
❯ Build user authentication flow

# Afternoon: Review with Anthropic quality
ccd
❯ Security audit of auth implementation

# Evening: Refactor sensitive parts offline
cco
❯ Optimize password hashing module
```

**Savings**: ~70% cost reduction vs Anthropic-only

### Workflow 2: Multi-Model Validation

```bash
# Test algorithm with 3 different perspectives
ccc-opus      # Claude Opus analysis
ccc-gpt       # GPT-4.1 analysis
COPILOT_MODEL=gemini-2.5-pro ccc  # Gemini analysis

# Compare approaches, choose best
```

### Workflow 3: Offline Development

```bash
# Work on proprietary code (airplane mode)
cco
❯ Implement proprietary encryption algorithm
# ✅ No internet required
# ✅ Code never leaves machine
```

---

## 📦 What's Included

| Component | Description |
|-----------|-------------|
| **claude-switch** | Main script (provider switcher) |
| **install.sh** | Auto-installer |
| **mcp-check.sh** | MCP compatibility checker |
| **MCP Profiles** | Auto-generated configs for strict models |
| **System Prompts** | Model identity injection |
| **Health Checks** | Fail-fast validation |
| **Session Logging** | Full audit trail |

---

## 🔧 Requirements

- **Claude Code CLI** (Anthropic)
- **copilot-api** ([ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api)) for Copilot provider
- **Ollama** (optional, for local provider)
- **jq** (JSON processing)
- **nc** (netcat, for health checks)

---

## 📚 Documentation

- **QUICKSTART.md** - 2-minute setup
- **MODEL-SWITCHING.md** - Dynamic model selection guide
- **MCP-PROFILES.md** - MCP Profiles & System Prompts
- **OPTIMISATION-M4-PRO.md** - Apple Silicon optimization
- **TROUBLESHOOTING.md** - Problem resolution

---

## 🎯 Who Should Use This?

### Primary Audience (Copilot Bridge)
✅ **Copilot Pro+ subscribers** who want to extend their $10/month subscription to Claude Code CLI
✅ **Cost-conscious developers** who want unlimited AI coding for flat $10/month instead of per-token pricing
✅ **Multi-model users** who want to experiment with Claude + GPT + Gemini without multiple API keys

### Secondary Audience (Bonus Features)
✅ **Privacy-conscious developers** who need offline mode for proprietary code (Ollama)
✅ **Teams in air-gapped environments** who can't use cloud APIs (Ollama)
✅ **Apple Silicon users** (M1/M2/M3/M4) who want optimized local inference (Ollama)
✅ **Production users** who need Anthropic Direct for critical analysis (fallback)

---

## 🚀 Version

**Current**: v1.2.0

**Changelog**: See [CHANGELOG.md](CHANGELOG.md)

---

## 📖 Credits

- **copilot-api**: [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api) - The bridge that makes this possible
- **Claude Code**: [Anthropic](https://www.anthropic.com/) - The CLI tool we're enhancing
- **Ollama**: [ollama.ai](https://ollama.ai/) - Local AI inference

---

## 📄 License

MIT

---

## 🔗 Related

- **Claude Code Ultimate Guide**: Comprehensive guide to Claude Code CLI
- **Claude Code Router**: Multi-provider API router (different architecture)
- **awesome-claude-code**: Community tools and resources
