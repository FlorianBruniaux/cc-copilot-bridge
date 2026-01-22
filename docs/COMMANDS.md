# Claude Code Multi-Provider - Quick Command Reference

**Version**: 1.1.0

---

## 📋 All Available Commands

### Provider Switching

| Command | Provider | Description |
|---------|----------|-------------|
| `ccd` | Anthropic Direct | Best quality, production-ready |
| `ccc` | GitHub Copilot | Free with subscription |
| `cco` | Ollama Local | 100% private, offline |
| `ccs` | Status | Check all providers |

---

### Model Selection (Copilot)

| Command | Model | Speed | Use Case |
|---------|-------|-------|----------|
| `ccc-opus` | Claude Opus 4.5 | Slow | Best quality, code review |
| `ccc-sonnet` | Claude Sonnet 4.5 | Medium | Balanced (default) |
| `ccc-haiku` | Claude Haiku 4.5 | Fast | Quick questions |
| `ccc-gpt` | GPT-5.2 Codex | Medium | Alternative perspective |

---

### Dynamic Model Selection

**Copilot** (25+ models available):
```bash
COPILOT_MODEL=claude-opus-4.5 ccc
COPILOT_MODEL=claude-haiku-4.5 ccc
COPILOT_MODEL=gpt-5.2-codex ccc
COPILOT_MODEL=gemini-3-pro-preview ccc
```

**Ollama** (local models):
```bash
OLLAMA_MODEL=qwen2.5-coder:7b cco
OLLAMA_MODEL=qwen2.5-coder:14b cco
OLLAMA_MODEL=deepseek-coder:6.7b cco
```

---

### Help & Version

| Command | Output |
|---------|--------|
| `claude-switch --help` | Full usage guide |
| `claude-switch --version` | Version: v1.1.0 |
| `ollama-check.sh --help` | Diagnostic help |
| `ollama-check.sh --version` | Version: v1.1.0 |
| `ollama-optimize.sh --help` | Optimization help |
| `ollama-optimize.sh --version` | Version: v1.1.0 |

---

### Diagnostic & Optimization

| Command | Purpose |
|---------|---------|
| `ollama-check.sh` | 11-point installation diagnostic |
| `ollama-optimize.sh` | Apply Apple Silicon optimizations |
| `ccs` | Check all provider status |

---

### Session Logs

| Command | Description |
|---------|-------------|
| `cat ~/.claude/claude-switch.log` | View all sessions |
| `tail -20 ~/.claude/claude-switch.log` | Recent sessions |
| `grep "mode=copilot" ~/.claude/claude-switch.log` | Filter by provider |
| `grep "Session ended" ~/.claude/claude-switch.log` | View durations |

---

## 🚀 Quick Start Examples

### 1. Check Provider Status
```bash
ccs
```

### 2. Use Anthropic Direct
```bash
ccd
> Implement user authentication
```

### 3. Use Copilot (Free)
```bash
ccc
> Refactor this function for readability
```

### 4. Use Ollama (Private)
```bash
cco
> Analyze this proprietary algorithm
```

### 5. Quick Question with Haiku
```bash
ccc-haiku
> What's the difference between map and flatMap?
```

### 6. Code Review with Opus
```bash
ccc-opus
> Review this code for security vulnerabilities
```

### 7. Alternative with GPT
```bash
ccc-gpt
> Generate test cases for this function
```

---

## 🔧 Diagnostic Examples

### Full Installation Check
```bash
ollama-check.sh
```

**Expected output**:
```
═══════════════════════════════════════════════════════════
  RÉSUMÉ
═══════════════════════════════════════════════════════════

   Ollama actif:      ✅
   API accessible:    ✅
   Modèle 32B:        ✅
   claude-switch:     ✅
```

### Apply Optimizations
```bash
ollama-optimize.sh
```

**Result**: 26-39 tok/s on M4 Pro 48GB with Qwen2.5-Coder-32B

---

## 📊 Usage Patterns

### Cost Optimization Workflow
```bash
# Morning: Explore (free)
ccc-haiku
> Help me understand this React project

# Afternoon: Implement (free)
ccc
> Add JWT authentication

# Before commit: Review (paid, best quality)
ccd
> Final security review
```

### Privacy-First Workflow
```bash
# Public code: Use Copilot
ccc
> Implement standard REST API

# Proprietary code: Use Ollama
cco
> Optimize this trade secret algorithm
```

### Speed-Optimized Workflow
```bash
# Quick iteration: Haiku
ccc-haiku
> 10 different approaches

# Refinement: Sonnet
ccc-sonnet
> Implement approach #3

# Polish: Opus
ccc-opus
> Final quality check
```

---

## 🎯 Strategic Command Selection

| Scenario | Recommended Command | Reasoning |
|----------|---------------------|-----------|
| Production deployment | `ccd` or `ccc-opus` | Best quality |
| PR review | `ccd` or `ccc-opus` | Critical decisions |
| Learning new framework | `ccc` or `ccc-haiku` | Fast iteration, free |
| Prototyping MVP | `ccc` | Cost-effective |
| Proprietary code | `cco` | 100% private |
| Offline work | `cco` | No internet required |
| Quick questions | `ccc-haiku` | Fastest responses |
| Comparing approaches | `ccc` then `ccc-gpt` | Different perspectives |

---

## 📝 Session Management

### Start Session
```bash
ccc              # Starts new session
ccc -c           # Resume previous session
```

### View Session History
```bash
# Last 5 sessions
tail -5 ~/.claude/claude-switch.log

# Sessions with durations
grep "Session ended" ~/.claude/claude-switch.log

# Today's sessions
grep "$(date '+%Y-%m-%d')" ~/.claude/claude-switch.log
```

### Filter by Provider
```bash
grep "mode=direct" ~/.claude/claude-switch.log    # Anthropic
grep "mode=copilot" ~/.claude/claude-switch.log   # Copilot
grep "mode=ollama" ~/.claude/claude-switch.log    # Ollama
```

---

## 🔄 Switching Between Providers Mid-Work

**Not supported within same session**. Exit and restart:

```bash
# Terminal 1: Start with Copilot
ccc
> Start implementing feature
> /exit

# Switch to Anthropic for critical review
ccd
> Review the code I just wrote
```

**Alternative**: Use multiple terminals in parallel:
```bash
# Terminal 1
ccc              # Development

# Terminal 2
cco              # Local testing

# Terminal 3
ccd              # Final review
```

---

## 💡 Pro Tips

### 1. Model Experimentation
Test same prompt with different models:
```bash
echo "Write a binary search function" | ccc-haiku
echo "Write a binary search function" | ccc-sonnet
echo "Write a binary search function" | ccc-opus
echo "Write a binary search function" | ccc-gpt
```

### 2. Cost Tracking
Track Anthropic usage vs Copilot:
```bash
# Count Anthropic sessions
grep "mode=direct" ~/.claude/claude-switch.log | wc -l

# Count Copilot sessions (free)
grep "mode=copilot" ~/.claude/claude-switch.log | wc -l
```

### 3. Performance Monitoring
Track Ollama performance:
```bash
# During session, in another terminal
watch -n 2 'ps aux | grep ollama | grep -v grep | awk "{printf \"RAM: %.2f GB\n\", \$6/1024/1024}"'
```

### 4. Model Aliases in Scripts
```bash
# Add to project-specific .envrc or Makefile
export COPILOT_MODEL="claude-opus-4.5"
alias review="ccc"  # Now uses Opus for this project
```

---

## 🆘 Troubleshooting Commands

### Provider Not Working
```bash
ccs              # Check status first
```

### copilot-api Not Running
```bash
copilot-api start
```

### Ollama Issues
```bash
ollama-check.sh  # Full diagnostic
brew services restart ollama
```

### Clear Logs (if too large)
```bash
tail -1000 ~/.claude/claude-switch.log > ~/.claude/claude-switch.log.tmp
mv ~/.claude/claude-switch.log.tmp ~/.claude/claude-switch.log
```

---

## 📚 Documentation Commands

### Quick Reference
```bash
claude-switch --help          # Full help
```

### Detailed Guides
```bash
# Read documentation
cat examples/multi-provider/README.md
cat examples/multi-provider/QUICKSTART.md
cat examples/multi-provider/OPTIMISATION-M4-PRO.md
```

---

**All commands tested and working on macOS (M4 Pro 48GB) ✅**

For more information, see: `examples/multi-provider/README.md`
