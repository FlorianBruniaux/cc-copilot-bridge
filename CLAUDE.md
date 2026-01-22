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
ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # copilot-api ignores this value
ANTHROPIC_MODEL="${COPILOT_MODEL:-claude-sonnet-4.5}"
DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"

# Ollama mode
ANTHROPIC_BASE_URL="http://localhost:11434"
ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # Ollama ignores this value
```

**Model Switching:**
- Default Copilot model: `claude-sonnet-4.5`
- Override via `COPILOT_MODEL` env var (25+ models supported)
- Default Ollama model: `devstral-small-2` (configurable via `OLLAMA_MODEL`)
- Backup Ollama model: `ibm/granite4:small-h` (long context, 70% less VRAM)

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
cco-devstral='OLLAMA_MODEL=devstral-small-2 claude-switch ollama'
cco-granite='OLLAMA_MODEL=ibm/granite4:small-h claude-switch ollama'
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
| Ollama | Native | devstral, granite4, qwen3-coder | 100% (permissive) |

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

**Critical Issue:** Claude Code sends ~18K tokens of system prompt + tools. Default Ollama context (4K) causes truncation, hallucinations, and slow responses.

**Solution: Create a 64K Modelfile (persistent):**
```bash
mkdir -p ~/.ollama
cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
FROM devstral-small-2
PARAMETER num_ctx 65536
PARAMETER temperature 0.15
EOF

ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k
```

**Verify effective context:** `ollama ps` (not `ollama show`)

**Memory footprint on M4 Pro 48GB with 64K context:**
- Devstral Q4_K_M: 15GB model + 8-12GB cache = **23-27GB total** → ~21GB libre
- Recommendation: 32K for comfort, 64K possible but tight

**Recommendations by Project Size:**
| Project Size | Files | Recommended Solution |
|--------------|-------|---------------------|
| Small | <500 | Ollama with Modelfile 64K ⚡ |
| Medium | 500-2K | Copilot ⚡ or Ollama 64K |
| Large | >2K | Copilot/Anthropic ⚡ |
| Privacy-critical | Any | Ollama 64K (private) 🔒 |

**Check context usage:** Run `/context` in Claude Code session

### Ollama Models (Updated January 2026)

| Model | Size | SWE-bench | Context | Use Case |
|-------|------|-----------|---------|----------|
| **devstral-small-2** (default) | 24B | 68% | 256K native | Best agentic coding |
| ibm/granite4:small-h | 32B (9B active) | ~62% | 1M | Long context, 70% less VRAM |
| qwen3-coder:30b | 30B | 85% | 256K | Highest accuracy, needs template work |

**Sources:**
- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/)
- [docs.ollama - Context](https://docs.ollama.com/context-length)
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/)

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
ollama pull devstral-small-2
# Create 64K Modelfile (see Performance Considerations section)
OLLAMA_MODEL=devstral-64k cco
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

# Ollama with different models (use 64K Modelfile versions)
OLLAMA_MODEL=devstral-64k cco          # Default (best agentic)
OLLAMA_MODEL=ibm/granite4:small-h cco  # Long context, 70% less VRAM
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

### Issue: Ollama Extremely Slow or Hallucinating
**Cause:** Default Ollama context (4K) is too low for Claude Code (~18K system prompt + tools)
**Solution:**
1. **Recommended:** Create a 64K Modelfile (persistent):
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
2. **Alternative:** Quick fix (global, less priority):
   ```bash
   launchctl setenv OLLAMA_CONTEXT_LENGTH 65536
   brew services restart ollama
   ```
3. **Verify:** `ollama ps` should show CONTEXT = 65536

### Issue: "copilot-api not running on :4141"
**Solution:**
```bash
copilot-api start
# Keep running in separate terminal
```

### Issue: Model not found
**Solution:**
```bash
# Pull recommended model
ollama pull devstral-small-2
# Or backup model for long context
ollama pull ibm/granite4:small-h
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
| Best agentic local | `cco-devstral` | Devstral-small-2 (68% SWE-bench) |
| Long context local | `cco-granite` | Granite4 (70% less VRAM) |

## Known Issues & Patches

### copilot-api Issue #174: Reserved Billing Header

**Status**: ⚠️ Patch appliqué localement (en attente de fix officiel)

**Problème**: Claude Code v2.1.15+ injecte `x-anthropic-billing-header` dans le system prompt, causant une erreur `invalid_request_body` avec copilot-api.

**Patch appliqué**: Filtre automatique du header réservé dans `translateAnthropicMessagesToOpenAI`

**Fichier modifié**:
```
~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js
```

**Vérification**:
```bash
# Vérifier que le patch est présent
grep -n "FIX #174" ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js

# Tester le fix
./scripts/test-billing-header-fix.sh
```

**Restauration** (si nécessaire):
```bash
cp ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js.backup \
   ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js
```

**⚠️ Important**: Le patch sera écrasé lors de `npm update -g copilot-api`. Après mise à jour, vérifier si le fix officiel est intégré ou ré-appliquer le patch.

**Documentation complète**: [docs/TROUBLESHOOTING.md - Patch communautaire](docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée)

**Suivi**: [ericc-ch/copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174)

---

## Version Information

- **claude-switch**: v1.4.0 (2026-01-22) - Updated Ollama: Devstral default, 64K context warning
- **copilot-api**: v0.7.0 + patch #174 (endpoint limitation: /chat/completions only)
- **Claude Code CLI**: v2.1.15 (@anthropic-ai/claude-code npm package)
- **Ollama**: Homebrew service, default model: devstral-small-2 (backup: ibm/granite4:small-h)

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
