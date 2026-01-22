# Quick Start Guide

**Get up and running in 2 minutes**

## Installation (30 seconds)

### Option 1: Automatic (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/claude-switch/main/install.sh | bash
source ~/.zshrc  # or ~/.bashrc
```

### Option 2: Manual

```bash
# Download script
curl -o ~/bin/claude-switch https://raw.githubusercontent.com/FlorianBruniaux/claude-switch/main/claude-switch
chmod +x ~/bin/claude-switch

# Add aliases to ~/.zshrc (or ~/.bashrc)
cat >> ~/.zshrc << 'EOF'

# Claude Code Multi-Provider
export PATH="$HOME/bin:$PATH"
alias ccd='claude-switch direct'
alias ccc='claude-switch copilot'
alias cco='claude-switch ollama'
alias ccs='claude-switch status'

# Copilot Model Shortcuts
alias ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
alias ccc-sonnet='COPILOT_MODEL=claude-sonnet-4.5 claude-switch copilot'
alias ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
alias ccc-gpt='COPILOT_MODEL=gpt-5.2-codex claude-switch copilot'
EOF

source ~/.zshrc
```

---

## First Use (30 seconds)

### Check Status

```bash
ccs
```

**Expected output**:
```
=== Claude Code Provider Status ===

Anthropic API:  ✓ Reachable
copilot-api:    ✗ Not running
Ollama:         ✗ Not running

=== Recent Sessions ===
(no logs yet)
```

### Use Anthropic Direct (Immediate)

If you have `ANTHROPIC_API_KEY` set:

```bash
ccd
```

You're in! Start coding with Claude.

---

## Setup Additional Providers (Optional)

### GitHub Copilot (5 minutes)

**Requirements**: Active Copilot Pro+ subscription

```bash
# 1. Install copilot-api
npm install -g copilot-api

# 2. Start and authenticate
copilot-api start
# Follow the GitHub authentication flow

# 3. Test
ccc
```

**Keep copilot-api running** in a terminal or set up auto-start (see [README.md](README.md#advanced-usage)).

### Ollama Local (10 minutes + download time)

**Requirements**: 10-20GB disk space for models

```bash
# 1. Install Ollama
brew install ollama  # macOS
# or download from https://ollama.ai

# 2. Start server
ollama serve &

# 3. Pull a coding model (choose one)
ollama pull qwen2.5-coder:32b   # Best quality, ~20GB
# or
ollama pull qwen2.5-coder:7b    # Faster, ~4.7GB

# 4. Test
cco
```

---

## Daily Usage

### Switch Providers

```bash
ccd      # Anthropic (best quality)
ccc      # Copilot (free)
cco      # Ollama (private)
ccs      # Check status
```

### Use Different Models (Copilot)

```bash
ccc-opus     # Claude Opus 4.5 (slowest, best)
ccc-sonnet   # Claude Sonnet 4.5 (default)
ccc-haiku    # Claude Haiku 4.5 (fastest)
ccc-gpt      # GPT-5.2 Codex
```

### Pass Arguments

```bash
ccc -c              # Resume session
ccd --model opus    # Use Opus with Anthropic
```

---

## Example Workflow

```bash
# Morning: Explore codebase (fast, free)
ccc-haiku
> Help me understand this React project structure

# Afternoon: Implement feature (balanced)
ccc-sonnet
> Add user authentication with JWT

# Before commit: Review with best quality
ccc-opus
> Review this code for security issues

# Private code: Use local model
cco
> Analyze this proprietary algorithm
```

---

## Troubleshooting

### "claude: command not found"

```bash
npm install -g @anthropic-ai/claude-code
```

### "copilot-api not running"

```bash
copilot-api start
```

Keep it running in a separate terminal.

### "Ollama model not found"

```bash
ollama pull qwen2.5-coder:32b
```

### Verify Installation

```bash
# Check script is installed
which claude-switch
# Should output: /Users/yourname/bin/claude-switch

# Check aliases are loaded
alias ccs
# Should output: alias ccs='claude-switch status'
```

---

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [MODEL-SWITCHING.md](MODEL-SWITCHING.md) for model selection strategies
- See [REPO-STRUCTURE.md](REPO-STRUCTURE.md) for advanced setup

---

## Cheat Sheet

| Command | Provider | Model | Use Case |
|---------|----------|-------|----------|
| `ccd` | Anthropic | Sonnet | Production, critical |
| `ccc` | Copilot | Sonnet 4.5 | Daily development |
| `ccc-opus` | Copilot | Opus 4.5 | Code review, best quality |
| `ccc-haiku` | Copilot | Haiku 4.5 | Quick questions |
| `ccc-gpt` | Copilot | GPT Codex | Alternative perspective |
| `cco` | Ollama | qwen2.5-coder | Privacy, offline |
| `ccs` | - | - | Check all providers |

---

**That's it!** You're ready to use claude-switch.

Questions? Open an issue on [GitHub](https://github.com/FlorianBruniaux/claude-switch).
