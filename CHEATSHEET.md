# cc-copilot-bridge Quick Reference

**Version**: v1.2.0 | **Print**: Fits on 1 page | **Updated**: 2026-01-22

---

## 🎯 Core Commands (Memorize These)

| Command | Provider | Model | Cost | Use For |
|---------|----------|-------|------|---------|
| `ccd` | Anthropic Direct | Sonnet 4 | Pay-per-use | Production, critical work |
| `ccc` | GitHub Copilot | Sonnet 4.5 | $10/mo flat | Daily development (FREE!) |
| `cco` | Ollama Local | Qwen 32B | Free | Private/offline work |
| `ccs` | Status Check | - | - | Verify all providers |

---

## 🔄 Model Shortcuts (Copilot)

```bash
ccc-opus    # Claude Opus 4.5 (best quality, slower)
ccc-sonnet  # Claude Sonnet 4.5 (balanced, DEFAULT)
ccc-haiku   # Claude Haiku 4.5 (fastest)
ccc-gpt     # GPT-4.1 (alternative perspective)
```

**Dynamic selection**:
```bash
COPILOT_MODEL=claude-opus-4.5 ccc
COPILOT_MODEL=gpt-4.1 ccc
COPILOT_MODEL=gemini-3-pro-preview ccc
```

---

## 🚀 Quick Start

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash

# Reload shell
source ~/.zshrc  # or ~/.bashrc

# Test
ccs              # Check status
ccc              # Start session
```

---

## 🎯 Which Command? (Decision Tree)

```
Need offline? → Yes → cco (Ollama)
       ↓ No
Have Copilot Pro+? → Yes → ccc (FREE!)
       ↓ No             ↓
      ccd          Task type?
  (Anthropic)    ├─ Quick → ccc-haiku
                 ├─ Daily → ccc-sonnet
                 ├─ Review → ccc-opus
                 └─ Alt → ccc-gpt
```

---

## 📊 Cost Comparison

| Provider | Monthly Cost | Usage Limit | Best For |
|----------|--------------|-------------|----------|
| Anthropic Direct | $15-20* | Per-token | Production |
| **Copilot Bridge** | **$10** | **UNLIMITED** | **Daily dev** |
| Ollama Local | Free | Unlimited | Privacy |

*Typical software development usage

---

## 🆘 Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| `copilot-api not running` | `copilot-api start` |
| Ollama extremely slow | Use `ccc` instead or increase context to 32K |
| MCP errors with GPT-4.1 | Use `ccc-sonnet` (Claude models work better) |
| Model not found | `ollama pull qwen2.5-coder:32b` |
| Aliases not working | `source ~/.zshrc` |
| API key prompt every time | Already fixed in v1.2.0 |

**Full guide**: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 🔍 Verify Installation

```bash
which claude-switch     # Should show: ~/bin/claude-switch
alias | grep ccc        # Should show all aliases
ccs                     # Check provider status
```

---

## 📝 Session Management

```bash
# View logs
tail ~/.claude/claude-switch.log

# Recent sessions
tail -20 ~/.claude/claude-switch.log

# Filter by provider
grep "mode=copilot" ~/.claude/claude-switch.log
```

---

## 🎓 Strategic Model Selection

| Task Type | Recommended | Reasoning |
|-----------|-------------|-----------|
| Quick question | `ccc-haiku` | Fast, cheap |
| Daily dev | `ccc-sonnet` | Balanced |
| Code review | `ccc-opus` | Best quality |
| Architecture | `ccc-opus` | Deep reasoning |
| Proprietary code | `cco` | 100% private |
| Experimentation | `ccc-haiku` | Fast iteration |

---

## ⚙️ Environment Variables

```bash
# Copilot model override
export COPILOT_MODEL="claude-opus-4.5"

# Ollama model override
export OLLAMA_MODEL="qwen2.5-coder:7b"

# Check current settings
echo $COPILOT_MODEL
echo $OLLAMA_MODEL
```

---

## 🔗 MCP Compatibility

| Model Family | MCP Compatibility | Notes |
|--------------|-------------------|-------|
| Claude | ✅ 100% | Permissive validation |
| GPT-4.1, GPT-5 | ⚠️ ~80% | Strict validation, auto-profiles |
| Gemini | ⚠️ ~80% | Strict validation, auto-profiles |
| **GPT Codex** | ❌ **Incompatible** | Requires `/responses` endpoint |

**Use Claude models for best MCP compatibility**

---

## 🚨 Known Issues

1. **Ollama default context (8K) too small**
   - Fix: Increase to 32K for large projects
   - Better: Use `ccc` for large projects

2. **GPT Codex models unavailable**
   - Cause: copilot-api doesn't support `/responses` endpoint
   - Fix: Use `gpt-4.1`, `gpt-5`, or Claude models

---

## 📚 Essential Documentation

| Doc | What It's For |
|-----|---------------|
| [QUICKSTART.md](QUICKSTART.md) | 5-min installation guide |
| [docs/COMMANDS.md](docs/COMMANDS.md) | All commands explained |
| [docs/FAQ.md](docs/FAQ.md) | 30+ common questions |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Problem solving |
| [docs/](docs/README.md) | Full documentation index |

---

## 🔄 Aliases Reference

```bash
# Provider shortcuts
ccd='claude-switch direct'
ccc='claude-switch copilot'
cco='claude-switch ollama'
ccs='claude-switch status'

# Model shortcuts (Copilot)
ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
ccc-sonnet='COPILOT_MODEL=claude-sonnet-4.5 claude-switch copilot'
ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
```

---

## 🎯 Daily Workflow Example

```bash
# Morning: Quick exploration
ccc-haiku
> Help me understand this React codebase

# Afternoon: Feature implementation
ccc-sonnet
> Implement user authentication with JWT

# Before commit: Code review
ccc-opus
> Review this PR for security issues

# Private code analysis
cco
> Analyze this proprietary algorithm
```

---

## 🔧 Prerequisites

- ✅ Claude Code CLI installed
- ✅ Bash shell (macOS/Linux)
- ✅ For Copilot: GitHub Copilot Pro+ subscription + copilot-api
- ✅ For Ollama: Ollama installed + model pulled
- ✅ For Anthropic: ANTHROPIC_API_KEY set

---

## 📖 Quick Links

- **Repo**: [github.com/FlorianBruniaux/cc-copilot-bridge](https://github.com/FlorianBruniaux/cc-copilot-bridge)
- **Issues**: [Report bugs](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)
- **Docs**: [Full documentation](docs/README.md)

---

**Print this page and keep it next to your keyboard!**

[Back to README](README.md) | [Full Documentation](docs/README.md)
