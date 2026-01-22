# cc-copilot-bridge

> **TL;DR**: Bash script that routes Claude Code CLI through multiple AI providers. Switch between Anthropic Direct API, GitHub Copilot (via copilot-api proxy), or Ollama local with simple aliases (`ccd`, `ccc`, `cco`).

> 📖 **New to Claude Code?** Check out the [Claude Code Ultimate Guide](https://florianbruniaux.github.io/claude-code-ultimate-guide-landing/) for comprehensive documentation, tips, and best practices.

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/tag/FlorianBruniaux/cc-copilot-bridge?label=version)](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

**Multi-provider routing for Claude Code CLI**

Use your existing GitHub Copilot subscription with Claude Code, or run 100% offline with Ollama. Access Claude, GPT, and Gemini models through a unified interface.

[Quick Start](#-quick-start) • [Pricing & Limits](#-github-copilot-pricing--limits) • [Features](#-features) • [Risk Disclosure](#-risk-disclosure)

</div>

---

## 🎯 What Is This?

A **multi-provider router** for Claude Code CLI that lets you switch between AI backends with simple aliases.

### Three Providers, One Interface

| Provider | Command | Use Case | Cost Model |
|----------|---------|----------|------------|
| **Anthropic Direct** | `ccd` | Production, maximum quality | Pay-per-token |
| **GitHub Copilot** | `ccc` | Daily development | Premium requests quota |
| **Ollama Local** | `cco` | Offline, proprietary code | Free (local compute) |

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
        ┌─────────┴────────────┌─────────────────┐
        │                      |                 │
    ┌───▼────┐         ┌───────▼────────┐   ┌───▼────┐
    │ Direct │         │ Copilot Bridge │   │ Ollama │
    │  API   │         │  (copilot-api) │   │ Local  │
    └────────┘         └────────────────┘   └────────┘
    Anthropic           GitHub Copilot       Self-hosted
    Pay-per-token       Premium requests     Free (offline)
                        quota system
```

---

## 🚀 Quick Start

### Installation

**Quick start** (automated, 30 seconds):
```bash
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash
source ~/.zshrc  # or ~/.bashrc
```

**Security-conscious?** See [Manual Installation Guide](QUICKSTART.md#option-2-manual-security-conscious---3-minutes)

**Full setup guide**: [QUICKSTART.md](QUICKSTART.md)

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

**Visual Examples**:

**Claude Sonnet 4.5 (Default)**:
![Claude Sonnet 4.5](assets/ccc-sonnet.png)

**Claude Opus 4.5 (Premium)**:
![Claude Opus 4.5](assets/ccc-opus.png)

**GPT-4.1 (OpenAI)**:
![GPT-4.1](assets/ccc-gpt.png)

**Ollama Offline (Private)**:
![Ollama Offline](assets/cco.png)

---

## 💰 GitHub Copilot Pricing & Limits

**Important**: Using Claude Code via Copilot consumes your **premium request quota**. Usage is NOT unlimited.

### Current Plans (January 2026)

| Plan | Monthly Cost | Premium Requests | Notes |
|------|--------------|------------------|-------|
| **Copilot Free** | $0 | 50 | Limited model access |
| **Copilot Pro** | $10 | 300 | Access to most models |
| **Copilot Pro+** | $39 | 1,500 | Full model access |
| **Copilot Business** | $19/user | 300 | Organization features |
| **Copilot Enterprise** | $39/user | 1,000 | Custom models, knowledge bases |

### Model Multipliers

Different models consume different amounts of premium requests per interaction:

| Model | Multiplier | Effective Quota (Pro, 300 req) | Effective Quota (Pro+, 1500 req) |
|-------|-----------|-------------------------------|----------------------------------|
| **GPT-4.1, GPT-4o, GPT-5-mini** | 0x | **Unlimited** | **Unlimited** |
| Claude Haiku 4.5 | 0.33x | ~900 interactions | ~4,500 interactions |
| Claude Sonnet 4.5 | 1x | 300 interactions | 1,500 interactions |
| Gemini 2.5 Pro | 1x | 300 interactions | 1,500 interactions |
| GPT-5.1/5.2 | 1x | 300 interactions | 1,500 interactions |
| **Claude Opus 4.5** | 3x | ~100 interactions | ~500 interactions |

**Key insight**: GPT-4.1 and GPT-4o are **free** (0x multiplier) on paid plans. Use them for routine tasks to preserve premium requests for Claude/Opus.

### Quota Behavior

- Quotas reset on the **1st of each month** (00:00 UTC)
- Unused requests **do not carry over**
- When quota is exhausted, system **falls back to free models** (GPT-4.1)
- Optional: Enable spending budgets for overflow at $0.04/request

**Source**: [GitHub Copilot Plans](https://docs.github.com/en/copilot/about-github-copilot/subscription-plans-for-github-copilot)

---

## 🎨 Features

### 1. **Instant Provider Switching** (3 characters)

```bash
ccd     # Anthropic Direct API (production)
ccc     # GitHub Copilot Bridge (prototyping)
cco     # Ollama Local (offline/private)
```

No config changes, no restarts, no environment variable juggling.

**Help Menu**:
![Claude Switch Help](assets/claude-switch-help.png)

**Available commands**:
- `ccs` / `claude-switch status` - Check all providers health
- `claude-switch --help` - Full command reference

### 2. **Dynamic Model Selection** (25+ models)

| Provider | Models | Cost Model |
|----------|--------|------------|
| **Anthropic** | opus-4.5, sonnet-4.5, haiku-4.5 | Per token |
| **Copilot** | claude-*, gpt-4.1, gpt-5, gemini-* | Premium requests quota |
| **Ollama** | devstral, granite4, qwen3-coder | Free (local) |

```bash
# Switch models mid-session
ccc                     # Default: claude-sonnet-4.5
ccc-opus                # Claude Opus 4.5
ccc-gpt                 # GPT-4.1
COPILOT_MODEL=gemini-2.5-pro ccc  # Gemini

# Ollama models
cco                     # Default: devstral-small-2
cco-devstral            # Explicit Devstral
cco-granite             # Granite4 (long context)
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

### 🎯 GitHub Copilot Bridge

**Use Case**: Daily coding, prototyping, exploration

```bash
ccc                               # Default: claude-sonnet-4.5
ccc-gpt                          # GPT-4.1 (0x multiplier = free)
ccc-opus                         # Claude Opus 4.5 (3x multiplier)
COPILOT_MODEL=gemini-2.5-pro ccc # Gemini
```

**How It Works**:
- Routes through [copilot-api](https://github.com/ericc-ch/copilot-api) proxy
- Uses your Copilot premium request quota (see [Pricing & Limits](#-github-copilot-pricing--limits))
- Access to 15+ models (Claude, GPT, Gemini families)
- Best for: Daily development, experimentation, learning

**copilot-api Running**:
![copilot-api start](assets/copilot-api.png)

*Screenshot: copilot-api proxy server logs showing active connections*

**Requirements**:
1. GitHub Copilot Pro ($10/mo) or Pro+ ($39/mo) subscription
2. copilot-api running locally (`copilot-api start`)

---

### 🎁 BONUS: Ollama Local (Offline Mode)

**Use Case**: Offline work, proprietary code, air-gapped environments

```bash
cco                                          # Default: devstral-small-2
OLLAMA_MODEL=devstral-64k cco               # With 64K context (recommended)
OLLAMA_MODEL=ibm/granite4:small-h cco       # Granite4 (long context, 70% less VRAM)
```

**How It Works**:
- Self-hosted inference (no internet required)
- Free, 100% private
- Apple Silicon optimized (M1/M2/M3/M4 - up to 4x faster)
- Best for: Sensitive code, airplane mode, privacy-first scenarios

**Important**: Ollama is **architecturally independent** from Copilot bridging. It's a separate provider for local inference, not related to copilot-api.

**⚠️ Critical: Context Configuration**

Claude Code sends ~18K tokens of system prompt + tools. Default Ollama context (4K) causes hallucinations and slow responses.

**Create a 64K Modelfile (recommended)**:
```bash
mkdir -p ~/.ollama
cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
FROM devstral-small-2
PARAMETER num_ctx 65536
PARAMETER temperature 0.15
EOF
ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k
OLLAMA_MODEL=devstral-64k cco
```

**Recommended Models (January 2026)**:
| Model | SWE-bench | Use Case |
|-------|-----------|----------|
| **devstral-small-2** | 68% | Best agentic coding (default) |
| ibm/granite4:small-h | ~62% | Long context, 70% less VRAM |
| qwen3-coder:30b | 85% | Highest accuracy (needs template work) |

**Requirements**:
1. Ollama installed (`ollama.ai`)
2. Models downloaded (`ollama pull devstral-small-2`)

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

## 📊 Competitive Landscape & Tool Comparison

The Claude Code ecosystem includes 30+ routing and provider management tools. Here's how **cc-copilot-bridge** positions itself:

### 🎯 Market Segmentation

| Category | Representative Tools | Target Use Case |
|----------|---------------------|-----------------|
| **Configuration Switchers** | jiang6641/claude-switch, foreveryh/claude-code-switch | Manual profile switching |
| **Multi-Provider Proxies** | @musistudio/claude-code-router (31.9k/week), fuergaosi233/claude-code-proxy | API routing & aggregation |
| **Copilot Bridges** | **cc-copilot-bridge** (this project) | Free access via Copilot Pro+ |
| **Orchestration Frameworks** | ruvnet/claude-flow, coder/anyclaude | Multi-agent systems |
| **Desktop Apps** | farion1231/cc-switch (Rust GUI) | Cross-platform GUI management |
| **Open-Source Alternatives** | OpenCode (48k stars) | Complete Claude Code replacement |

### 🥊 Head-to-Head Comparison (Top Tools)

| Feature | **cc-copilot-bridge** | @musistudio/router | fuergaosi233/proxy | OpenCode |
|---------|----------------------|-------------------|-------------------|----------|
| **Weekly Downloads** | N/A (new) | **31,917** 🏆 | Unknown | 48,000 stars |
| **Architecture** | Copilot proxy | Multi-provider API router | OpenAI-compatible proxy | Full IDE replacement |
| **Cost Model** | Premium requests quota | Per-token ($0.14-$75/1M) | Per-token | Free (self-hosted) |
| **Copilot Integration** | ✅ **Primary feature** | ❌ Not supported | ❌ Not supported | ❌ Not supported |
| **Providers Supported** | 3 (Direct, Copilot, Ollama) | 8+ native | OpenAI-compatible only | 75+ providers |
| **Offline Mode** | ✅ Ollama provider | ❌ Cloud only | ❌ Cloud only | ✅ Local models |
| **MCP Profiles** | ✅ Auto-generated | ✅ Manual config | ❌ None | N/A |
| **Model Identity** | ✅ Injected prompts | ❌ N/A | ❌ N/A | N/A |
| **Web UI** | ❌ CLI only | ✅ Full React UI | ❌ CLI only | ✅ Full IDE |
| **Setup Complexity** | ⚡ 1 command | 🔧 Medium (config.json) | ⚡ Simple (.env) | 🔧 Complex |
| **GitHub Actions** | ❌ Not supported | ✅ Native integration | ❌ Not supported | ✅ Workflows |
| **Target Audience** | **Copilot Pro+ subscribers** | API users, enterprises | OpenAI-centric teams | Open-source purists |
| **Best For** | Use Copilot quota with Claude Code | Production routing at scale | Simple OpenAI fallback | Full IDE replacement |

### 🎯 Unique Value Propositions

| Tool | Core USP | When to Choose |
|------|----------|----------------|
| **cc-copilot-bridge** | Route Copilot quota to Claude Code | You have Copilot subscription, want to use Claude Code |
| @musistudio/router | Market leader (31.9k/week), mature ecosystem | Production-grade multi-provider routing |
| fuergaosi233/proxy | Python-based, minimal setup | Python stack, OpenAI fallback only |
| 1rgs/proxy | LiteLLM integration (100+ providers) | Maximum provider coverage |
| horselock/proxy | OAuth PKCE (account-based auth) | No API key dependency |
| glidea/worker-proxy | Edge deployment (Cloudflare Workers) | Ultra-low latency, global distribution |
| ruvnet/claude-flow | 54 agents, neural learning, persistence | Enterprise orchestration, multi-agent |
| farion1231/cc-switch | Rust desktop GUI (macOS/Linux/Windows) | Non-technical users, visual config |
| OpenCode | 75+ providers, open-source | Complete open-source alternative |

### 💡 Why cc-copilot-bridge Exists

**Serving Copilot Pro+ subscribers specifically.**

For general multi-provider routing at scale, see [@musistudio/claude-code-router](https://www.npmjs.com/package/@musistudio/claude-code-router) (31.9k weekly downloads).

| Dimension | cc-copilot-bridge | Other Tools |
|-----------|-------------------|-------------|
| **Primary Value** | Use existing Copilot subscription with Claude Code | Route to multiple paid APIs |
| **Cost Structure** | Premium requests quota (plan-dependent) | Per-token billing |
| **Prerequisites** | GitHub Copilot Pro or Pro+ subscription | API keys from multiple providers |
| **Use Case** | Daily development, prototyping, learning | Production routing, cost optimization |
| **Philosophy** | "Use your Copilot quota with Claude Code CLI" | "Route to best API for each task" |

### 🏆 Market Insights

**Market Leaders by Adoption**:
1. **@musistudio/claude-code-router** - 31,917 weekly downloads (proxy category winner)
2. **OpenCode** - 48,000 GitHub stars (open-source category winner)
3. **fuergaosi233/claude-code-proxy** - 1,600 GitHub stars (Python category winner)

**Market Distribution**:
- **Configuration Switchers**: <5% adoption (legacy approach)
- **Multi-Provider Proxies**: 95%+ adoption (current standard)
- **Orchestration Frameworks**: <1% but fastest-growing (enterprise future)

**Technology Stack Preferences**:
- TypeScript/Node.js: 60% of tools (musistudio, 1rgs, etc.)
- Python: 25% of tools (fuergaosi233, ujisati)
- Rust: 10% (farion1231 desktop app)
- Go/Hybrid: 5% (jimmc414)

### 🚀 Differentiation Strategy

**cc-copilot-bridge differentiates through**:
1. **Copilot-First Architecture** - Only tool optimized for copilot-api proxy
2. **Quota-Based Model** - Uses your existing Copilot subscription (no additional API costs)
3. **MCP Compatibility System** - Auto-generated profiles for strict models (GPT-4.1)
4. **Model Identity Injection** - System prompts ensure models know who they are
5. **Hybrid Provider Strategy** - Copilot + Ollama (offline) + Anthropic (fallback)

**Complementary tools**:
- Use **cc-copilot-bridge** for daily dev (uses Copilot quota)
- Use **@musistudio/router** for production multi-provider routing
- Use **OpenCode** for complete open-source alternative

### 📈 Ecosystem Maturity

| Maturity Level | Tools | Status |
|----------------|-------|--------|
| **Production-Ready** | 24/30 (80%) | ✅ Battle-tested |
| **Pre-Release** | 3/30 (10%) | 🟡 Alpha/Beta |
| **Limited Maintenance** | 3/30 (10%) | ⚠️ Stale repos |

**Market positioning**: The Claude Code ecosystem is mature with established leaders. **cc-copilot-bridge** serves Copilot subscribers who want to use Claude Code CLI without additional API costs.

---

## 🎬 Real-World Workflows

### Workflow 1: Quota-Optimized Development

```bash
# Use GPT-4.1 for routine tasks (0x multiplier = doesn't consume quota)
ccc-gpt
❯ Build user authentication flow

# Use Claude Sonnet for complex logic (1x multiplier)
ccc
❯ Design database schema

# Use Anthropic Direct for production review (official API)
ccd
❯ Security audit of auth implementation
```

### Workflow 2: Multi-Model Validation

```bash
# Compare approaches across models
ccc-gpt       # GPT-4.1 analysis (free)
ccc           # Claude Sonnet analysis (1x)
ccc-opus      # Claude Opus analysis (3x - use sparingly)
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
  - ⚠️ **Note**: Community patch applied to fix [issue #174](https://github.com/ericc-ch/copilot-api/issues/174) (reserved billing header). See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée) for details.
- **Ollama** (optional, for local provider)
- **jq** (JSON processing)
- **nc** (netcat, for health checks)

---

## 📚 Documentation

### This Project
- **QUICKSTART.md** - 2-minute setup
- **MODEL-SWITCHING.md** - Dynamic model selection guide
- **MCP-PROFILES.md** - MCP Profiles & System Prompts
- **SECURITY.md** - Security, privacy, and compliance guide
- **OPTIMISATION-M4-PRO.md** - Apple Silicon optimization
- **TROUBLESHOOTING.md** - Problem resolution

### Claude Code Resources
- 📖 **[Claude Code Ultimate Guide](https://florianbruniaux.github.io/claude-code-ultimate-guide-landing/)** - Comprehensive guide to Claude Code CLI
- 🔗 **[Ultimate Guide Repository](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)** - Complete documentation, tips, and best practices

---

## 🎯 Who Should Use This?

### Primary Audience
- **Copilot subscribers** who want to use Claude Code CLI with their existing subscription
- **Multi-model users** who want to compare Claude, GPT, and Gemini responses
- **Developers** who want a unified interface across multiple AI providers

### Secondary Audience
- **Privacy-conscious developers** who need offline mode for proprietary code (Ollama)
- **Teams in air-gapped environments** who can't use cloud APIs (Ollama)
- **Production users** who need Anthropic Direct API for critical analysis

---

## 🚀 Version

**Current**: v1.4.0

**Changelog**: See [CHANGELOG.md](CHANGELOG.md)

---

## ⚠️ Risk Disclosure

### Terms of Service Considerations

This project uses [copilot-api](https://github.com/ericc-ch/copilot-api), a community tool that reverse-engineers GitHub Copilot's API.

**Important disclaimers:**

1. **Not officially supported**: copilot-api is not endorsed by GitHub, Microsoft, Anthropic, or any AI provider
2. **ToS risk**: Using third-party proxies to access Copilot may violate [GitHub Copilot Terms of Service](https://docs.github.com/en/site-policy/github-terms/github-copilot-product-specific-terms)
3. **Account suspension**: GitHub reserves the right to suspend accounts for ToS violations "at its sole discretion" without prior notice
4. **API changes**: This tool may stop working at any time if providers change their APIs
5. **No guarantees**: The authors provide no warranty and accept no liability for account suspension or service interruption

### Documented Risks

Community reports indicate that:
- Accounts using high volumes through third-party proxies have been suspended
- Suspensions may affect your entire GitHub account, not just Copilot access
- GitHub does not provide a public definition of "excessive usage" or "abuse"

### Recommendations

| Use Case | Recommended Provider |
|----------|---------------------|
| **Production code** | Anthropic Direct (`ccd`) - Official API, no ToS risk |
| **Sensitive/proprietary code** | Ollama Local (`cco`) - 100% offline, no cloud |
| **Daily development** | Copilot (`ccc`) - Understand the risks first |
| **Risk-averse users** | Avoid copilot-api entirely |

**Source**: [GitHub Terms of Service - API Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service#h-api-terms)

---

## 📖 Credits

- **copilot-api**: [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api) - The bridge that makes this possible
- **Claude Code**: [Anthropic](https://www.anthropic.com/) - The CLI tool we're enhancing
- **Ollama**: [ollama.ai](https://ollama.ai/) - Local AI inference

---

## 📄 License

MIT

---

## 🔗 Related Projects

### By the Same Author
- 📖 **[Claude Code Ultimate Guide](https://florianbruniaux.github.io/claude-code-ultimate-guide-landing/)** - Comprehensive guide to mastering Claude Code CLI
  - Complete documentation and best practices
  - Tips & tricks for productivity
  - MCP server integration guides
  - GitHub: [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)

### Community Tools
- **[copilot-api](https://github.com/ericc-ch/copilot-api)** - GitHub Copilot API proxy (core dependency)
- **[Ollama](https://ollama.ai/)** - Local AI inference platform
- **awesome-claude-code** - Curated list of Claude Code resources
