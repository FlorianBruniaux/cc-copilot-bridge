# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**claude-switch** is a multi-provider wrapper for Claude Code CLI that enables seamless switching between:
- **Anthropic Direct**: Official API, best quality
- **GitHub Copilot**: Free with Copilot Pro+ via copilot-api proxy
- **Ollama Local**: 100% private, offline capable

The project consists of 3 main bash scripts and extensive documentation for optimal usage.

## Core Scripts

### 1. claude-switch (Main Script)
Location: `~/bin/claude-switch` (installed via `install.sh`)

**Key Functions:**
- `_run_direct()`: Anthropic API direct connection
- `_run_copilot()`: GitHub Copilot via copilot-api proxy (localhost:4141)
- `_run_ollama()`: Local Ollama models via localhost:11434
- `_check_port()`: Health checks before launching providers
- `_get_mcp_flags()`: Dynamic MCP profile selection based on model
- `_session_start()`/`_session_end()`: Session logging with durations

**Environment Variables Set:**
```bash
# Copilot mode
ANTHROPIC_BASE_URL="http://localhost:4141"
ANTHROPIC_AUTH_TOKEN="sk-dummy"
ANTHROPIC_MODEL="${COPILOT_MODEL:-claude-sonnet-4.5}"
DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"

# Ollama mode
ANTHROPIC_BASE_URL="http://localhost:11434"
ANTHROPIC_AUTH_TOKEN="ollama"
```

**Model Switching:**
- Default Copilot model: `claude-sonnet-4.5`
- Override via `COPILOT_MODEL` env var (25+ models supported)
- Ollama model: `qwen2.5-coder:32b` (configurable via `OLLAMA_MODEL`)

### 2. install.sh (Installation)
Auto-installer that:
1. Creates `~/bin/` directory if needed
2. Downloads `claude-switch` script
3. Adds shell aliases to `~/.zshrc` or `~/.bashrc`
4. Creates `~/.claude/` directory for logs

**Aliases Created:**
```bash
ccd='claude-switch direct'
ccc='claude-switch copilot'
cco='claude-switch ollama'
ccs='claude-switch status'
ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
ccc-sonnet='COPILOT_MODEL=claude-sonnet-4.5 claude-switch copilot'
ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
```

### 3. mcp-check.sh (MCP Diagnostics)
Identifies MCP servers with schema validation issues that fail with GPT-4.1 strict validation.

**Known Issues:**
- `grepai`: object schema missing properties (incompatible with GPT-4.1)

**Usage:**
```bash
mcp-check.sh                # Check configured MCP servers
mcp-check.sh --parse-logs   # Scan recent logs for errors
```

## Architecture

### Session Logging
All sessions logged to `~/.claude/claude-switch.log`:
```
[TIMESTAMP] [LEVEL] message
```

**Log Format:**
- Session start: `mode=<provider> pid=<PID> pwd=<directory>`
- Session end: `mode=<provider> duration=<time> exit=<code>`
- Provider info: `Provider: <name> - Model: <model>`

### Provider Health Checks
Before launching, `claude-switch` verifies:
- **Copilot**: Port 4141 responds (via `nc -z`)
- **Ollama**: Port 11434 responds + model exists (`ollama list`)
- **Anthropic**: Uses existing `ANTHROPIC_API_KEY` from environment

### Model Compatibility Matrix

| Provider | Endpoint | Models | MCP Compatibility |
|----------|----------|--------|-------------------|
| Anthropic | Native | Opus/Sonnet/Haiku | 100% (permissive) |
| Copilot-Claude | /chat/completions | claude-*-4.5 | 100% (permissive) |
| Copilot-GPT | /chat/completions | gpt-4.1, gpt-5, gpt-5-mini | ~80% (strict validation) |
| Copilot-Codex | /responses | gpt-*-codex | ❌ Incompatible (copilot-api v0.7.0) |
| Ollama | Native | qwen2.5-coder | 100% (permissive) |

**Critical Note:** ALL GPT Codex models (`gpt-5.2-codex`, `gpt-5.1-codex`, etc.) require OpenAI's `/responses` endpoint (launched Oct 2025), which copilot-api doesn't support. Use `gpt-4.1`, `gpt-5`, or `gpt-5-mini` instead.

### MCP Profiles System (Advanced)

**Purpose:** GPT-4.1 applies strict JSON Schema validation that rejects some MCP servers with incomplete schemas. System uses dynamic profile generation to exclude problematic servers.

**Directory Structure:**
```
~/.claude/mcp-profiles/
├── excludes.yaml           # SOURCE OF TRUTH
├── generated/              # Auto-generated
│   ├── gpt.json           # GPT models config
│   └── gemini.json        # Gemini models config
└── generate.sh            # Profile generator
```

**Behavior:**
- Claude models → Use default `~/.claude/claude_desktop_config.json` (all MCPs)
- GPT models → Use `generated/gpt.json` (excludes grepai)
- Gemini models → Use `generated/gemini.json` (excludes grepai)

**Regenerate after config changes:**
```bash
~/.claude/mcp-profiles/generate.sh
```

## Performance Considerations

### Ollama Context Size vs Claude Code Requirements

**Critical Issue:** Claude Code sends ~60K tokens of context (Memory files + MCP tools + System prompt), but default Ollama optimization uses 8K context.

**Consequences:**
- 8K context: ⚡ 26-39 tok/s, but ❌ truncates 87% of context → 2-6 min responses
- 16K context: 🐢 15-25 tok/s, works for medium projects
- 32K context: 🐌 8-15 tok/s, works for large projects

**Recommendations by Project Size:**
| Project Size | Files | Recommended Solution |
|--------------|-------|---------------------|
| Small | <500 | Ollama 8K ⚡ |
| Medium | 500-2K | Copilot ⚡ |
| Large | >2K | Copilot/Anthropic ⚡ |
| Privacy-critical | Any | Ollama 32K 🐌 |

**Check context usage:** Run `/context` in Claude Code session

## Commands for Development

### Testing Providers
```bash
# Check all provider status
ccs

# Test Anthropic Direct
ccd
# Expects: ANTHROPIC_API_KEY set in environment

# Test GitHub Copilot (requires copilot-api running)
copilot-api start  # In separate terminal
ccc

# Test Ollama (requires ollama serve + model pulled)
brew services restart ollama
ollama pull qwen2.5-coder:32b
cco
```

### Debugging Session Issues
```bash
# View recent logs
tail -20 ~/.claude/claude-switch.log

# Check provider health
nc -z localhost 4141  # Copilot
nc -z localhost 11434 # Ollama
curl -s https://api.anthropic.com/v1/messages # Anthropic

# View session durations
grep "Session ended" ~/.claude/claude-switch.log

# Filter by provider
grep "mode=copilot" ~/.claude/claude-switch.log
grep "mode=ollama" ~/.claude/claude-switch.log
```

### Model Switching Commands
```bash
# Copilot with different models
COPILOT_MODEL=claude-opus-4.5 ccc      # Best quality
COPILOT_MODEL=claude-haiku-4.5 ccc     # Fastest
COPILOT_MODEL=gpt-4.1 ccc              # GPT alternative

# Ollama with different models
OLLAMA_MODEL=qwen2.5-coder:7b cco      # Smaller model
OLLAMA_MODEL=qwen2.5-coder:14b cco     # Medium model
```

### MCP Troubleshooting
```bash
# Check MCP compatibility
mcp-check.sh

# Scan logs for MCP errors
mcp-check.sh --parse-logs

# Regenerate MCP profiles after config changes
~/.claude/mcp-profiles/generate.sh

# Verify profile content
cat ~/.claude/mcp-profiles/generated/gpt.json | jq -r '.mcpServers | keys[]'
```

## Common Issues & Solutions

### Issue: Ollama Extremely Slow (2-6 minutes per response)
**Cause:** Context mismatch (Claude Code sends 60K tokens, Ollama expects 8K)
**Solution:**
1. **Preferred:** Switch to Copilot (`ccc`) or Anthropic (`ccd`) for large projects
2. **Alternative:** Increase Ollama context (slower but functional):
   ```bash
   launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
   brew services restart ollama
   ```
3. **Alternative:** Create `.claudeignore` to reduce project context

### Issue: "copilot-api not running on :4141"
**Solution:**
```bash
copilot-api start
# Keep running in separate terminal
```

### Issue: "Model qwen2.5-coder not found"
**Solution:**
```bash
ollama pull qwen2.5-coder:32b-instruct-q4_k_m
# Or override: OLLAMA_MODEL=qwen2.5-coder:7b cco
```

### Issue: MCP Schema Validation Error (GPT-4.1)
**Example:** `Invalid schema for function 'mcp__grepai__grepai_index_status'`
**Solution:**
1. **Preferred:** Use Claude models (`ccc-sonnet`, `ccc-opus`) - 100% MCP compatible
2. **Alternative:** Disable problematic MCP server in `~/.claude/claude_desktop_config.json`
3. **Alternative:** Use MCP profiles system (automatically excludes grepai for GPT)

### Issue: "model gpt-5.2-codex is not accessible via /chat/completions endpoint"
**Cause:** ALL GPT Codex models require `/responses` endpoint (copilot-api v0.7.0 doesn't support it)
**Solution:** Use compatible models:
- `gpt-4.1` (0x premium, recommended)
- `gpt-5` (1x premium)
- `gpt-5-mini` (0x premium, fastest)

## File Organization Rules

### DO NOT modify these files directly:
- `~/.claude/mcp-profiles/generated/*.json` - Auto-generated by `generate.sh`

### Modify these when needed:
- `~/.claude/mcp-profiles/excludes.yaml` - Add problematic MCP servers
- `~/.claude/claude_desktop_config.json` - Base MCP configuration
- `~/bin/claude-switch` - Script modifications

### Documentation structure:
- `README.md` - Complete documentation
- `QUICKSTART.md` - 2-minute setup guide
- `COMMANDS.md` - Command reference
- `TROUBLESHOOTING.md` - Common issues & solutions
- `MODEL-SWITCHING.md` - Dynamic model selection guide
- `MCP-PROFILES.md` - MCP compatibility system
- `OPTIMISATION-M4-PRO.md` - Performance optimization (Apple Silicon)

## Strategic Provider Selection

| Scenario | Command | Reasoning |
|----------|---------|-----------|
| Production code | `ccd` or `ccc-opus` | Best quality, critical decisions |
| Daily development | `ccc` | Free, fast, Claude Sonnet |
| Quick questions | `ccc-haiku` | Fastest responses |
| Code review | `ccc-opus` | Maximum quality |
| Learning/prototyping | `ccc` | Cost-effective iteration |
| Proprietary code | `cco` | 100% private, no data leaves machine |
| Offline work | `cco` | No internet required |
| Small scripts | `cco` (8K) | Fast local inference |

## Version Information

- **claude-switch**: v1.1.0 (2026-01-21)
- **copilot-api**: v0.7.0 (endpoint limitation: /chat/completions only)
- **Claude Code CLI**: @anthropic-ai/claude-code (npm package)
- **Ollama**: Homebrew service, default models: qwen2.5-coder family

## Testing Changes

When modifying `claude-switch`:
1. Test with all 3 providers (`ccd`, `ccc`, `cco`)
2. Check session logs: `tail ~/.claude/claude-switch.log`
3. Verify health checks: `ccs`
4. Test model switching: `COPILOT_MODEL=<model> ccc`
5. Test error handling: Stop provider and try launching

## Notes for AI Assistants

- All bash scripts use `set -euo pipefail` for safety
- Port conflicts: Copilot (4141), Ollama (11434)
- Session tracking via log file enables usage analytics
- MCP profiles prevent runtime errors with strict validation models
- Default models chosen for best quality/speed balance
- Logs are append-only, consider rotation for long-term use
