# Claude Switch Aliases Reference

Complete documentation of all available shell aliases for `claude-switch`.

## Installation

Aliases are automatically configured during installation via `install.sh` or by running:

```bash
eval "$(claude-switch --shell-config)"
```

## Core Provider Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ccd` | `claude-switch direct` | Anthropic Direct API (requires `ANTHROPIC_API_KEY`) |
| `ccc` | `claude-switch copilot` | GitHub Copilot via copilot-api (default: claude-sonnet-4.5) |
| `cco` | `claude-switch ollama` | Local Ollama models (default: devstral-small-2) |
| `ccs` | `claude-switch status` | Show status of all providers |

## Claude Models via Copilot

| Alias | Model | Billing | Use Case |
|-------|-------|---------|----------|
| `ccc-opus` | `claude-opus-4.5` | 0x (free) | Best quality, production code, critical decisions |
| `ccc-sonnet` | `claude-sonnet-4.5` | 0x (free) | Daily development, balanced quality/speed |
| `ccc-haiku` | `claude-haiku-4.5` | 0x (free) | Fastest responses, quick questions |

**Example:**
```bash
ccc-opus -p "Review this security-critical authentication code"
ccc-sonnet -p "Add validation to login form"
ccc-haiku -p "Explain what this function does"
```

## GPT Models via Copilot

| Alias | Model | Billing | Use Case |
|-------|-------|---------|----------|
| `ccc-gpt41` / `ccc-gpt` | `gpt-4.1` | 0x (free) | Alternative perspective, second opinion |
| `ccc-gpt5` | `gpt-5` | 1x (premium) | Latest GPT, enhanced reasoning |
| `ccc-gpt5-mini` | `gpt-5-mini` | 0x (free) | Fast GPT alternative |

**Note:** GPT models have ~80% MCP compatibility due to strict JSON Schema validation. Some MCP servers (e.g., grepai) may fail. Use Claude models for 100% compatibility.

**Example:**
```bash
ccc-gpt41 -p "Different perspective on this architecture"
ccc-gpt5-mini -p "Quick code explanation"
```

## GPT Codex Models via Unified Fork

**⚠️ Requires unified fork:** Run `ccunified` in separate terminal first.

| Alias | Model | Billing | Use Case | Status |
|-------|-------|---------|----------|--------|
| `ccc-codex` | `gpt-5.2-codex` | 0x (free) | Best code generation | ✅ Tested |
| `ccc-codex-std` | `gpt-5.1-codex` | 0x (free) | Standard code generation | ✅ Tested |
| `ccc-codex-mini` | `gpt-5.1-codex-mini` | 0x (free) | Fast code generation | ✅ Tested |
| `ccc-codex-max` | `gpt-5.1-codex-max` | 1x (premium) | Max quality code generation | ✅ Tested |

**Setup:**
```bash
# Terminal 1: Launch unified fork (keep running)
ccunified

# Terminal 2: Use Codex models
ccc-codex -p "Generate REST API with authentication"
ccc-codex-mini -p "Quick utility function"
```

**Why separate terminal?**
- Official copilot-api v0.7.0 doesn't support `/responses` endpoint (required for Codex)
- Unified fork adds support via PR #170
- Fork must run on port 4141 instead of official copilot-api

**Example:**
```bash
ccc-codex -p "Create a complete Express API with JWT auth"
ccc-codex-mini -p "Write a binary search function in TypeScript"
```

## Gemini Models via Copilot

| Alias | Model | Billing | Use Case | Status |
|-------|-------|---------|----------|--------|
| `ccc-gemini` | `gemini-2.5-pro` | 0x (free) | Fast iteration, simple prompts | Deprecating 2/17/26 |
| `ccc-gemini3` | `gemini-3-flash-preview` | 0x (free) | Latest Gemini, experimental | ⚠️ Agentic UNTESTED |
| `ccc-gemini3-pro` | `gemini-3-pro-preview` | 1x (premium) | Latest Gemini Pro, experimental | ⚠️ Agentic UNTESTED |

**⚠️ Known Limitations:**
- ✅ Simple prompts work well
- ⚠️ Agentic mode (file creation, tool calling, MCP) has compatibility issues
- ⚠️ Gemini 3 models require unified fork but agentic support is **UNTESTED**
- **Recommendation:** Use Claude models (`ccc-sonnet`, `ccc-opus`) for 100% reliability

**Example (safe usage):**
```bash
ccc-gemini -p "Explain this algorithm"  # ✅ Works
ccc-gemini -p "Create file.txt"        # ⚠️ May fail
ccc-sonnet -p "Create file.txt"        # ✅ Use Claude instead
```

**See:** `docs/TROUBLESHOOTING.md` for Gemini agentic mode workarounds.

## Ollama Local Models

| Alias | Model | Params | Use Case | SWE-bench |
|-------|-------|--------|----------|-----------|
| `cco-devstral` / `cco` | `devstral-small-2` | 24B | Best agentic (default) | 68.0% |
| `cco-granite` | `ibm/granite4:small-h` | 32B (9B active) | Long context, 70% less VRAM | ~62% |

**Requirements:**
- 32GB RAM minimum for 24B models
- 48GB RAM recommended for 32B + 64K context
- 64K context Modelfile required (see Performance Considerations in CLAUDE.md)

**Example:**
```bash
cco-devstral -p "Analyze this codebase"  # Best agentic performance
cco-granite -p "Review this 50K LOC project"  # Long context
```

## Semantic Aliases (Shortcuts)

User-friendly aliases that map to specific use cases:

| Alias | Resolves To | Use Case |
|-------|-------------|----------|
| `ccc-prod` | `ccc-opus` | Production code, critical decisions |
| `ccc-dev` | `ccc-sonnet` | Daily development |
| `ccc-quick` | `ccc-haiku` | Quick questions, explanations |
| `ccc-code` | `ccc-codex` | Code generation (requires ccunified) |
| `ccc-alt` | `ccc-gpt41` | Alternative perspective |
| `ccc-private` | `cco-devstral` | Private/offline work |

**Example workflow:**
```bash
ccc-dev        # Start daily work session
ccc-quick      # Ask quick questions during coding
ccc-prod       # Final review before deployment
ccc-private    # Work on proprietary code
```

## Utility Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ccunified` | `~/Sites/perso/cc-copilot-bridge/scripts/launch-unified-fork.sh` | Launch unified fork for Codex/Gemini3 |

## Billing Quick Reference

| Tier | Models | Cost |
|------|--------|------|
| **0x (Free)** | Claude Opus/Sonnet/Haiku, GPT-4.1, GPT-5-mini, All Codex, Gemini 2.5/3-flash | Included in Copilot Pro+ subscription |
| **1x (Premium)** | GPT-5, Codex-Max, Gemini-3-Pro | Consumes completions quota faster |

**Note:** All models are effectively "free" with Copilot Pro+ subscription, but 1x models consume your quota faster.

## Decision Tree

```
Need best quality? → ccc-prod (opus)
Daily development? → ccc-dev (sonnet)
Quick question? → ccc-quick (haiku)
Code generation? → ccc-code (codex) + ccunified
Alternative view? → ccc-alt (gpt-4.1)
Private/offline? → ccc-private (ollama devstral)
Long context (>32K)? → cco-granite
Maximum agentic? → cco-devstral
```

## Advanced Usage

### Dynamic Model Override

All aliases support runtime model override via environment variables:

```bash
# Override Copilot model
COPILOT_MODEL=gpt-5 ccc -p "test"

# Override Ollama model
OLLAMA_MODEL=qwen3-coder:30b cco -p "test"
```

### Chaining with Other Tools

```bash
# Use with git
ccc-dev -p "Review git diff and suggest improvements" <<< "$(git diff)"

# Pipe output
echo "function add(a, b) { return a + b }" | ccc-quick -p "Explain this"

# Integration with scripts
ccc-prod -p "Review $(cat security-critical.ts)"
```

### Session Logging

All sessions are logged to `~/.claude/claude-switch.log`:

```bash
# View recent sessions
tail -20 ~/.claude/claude-switch.log

# Filter by provider
grep "mode=copilot" ~/.claude/claude-switch.log
grep "model=gpt-5.2-codex" ~/.claude/claude-switch.log

# Session duration analysis
grep "Session ended" ~/.claude/claude-switch.log
```

## Compatibility Matrix

| Alias Family | MCP Support | Tool Calling | File Creation | Recommended For |
|--------------|-------------|--------------|---------------|-----------------|
| Claude (`ccc-*`) | 100% | ✅ Perfect | ✅ Perfect | Everything |
| GPT (`ccc-gpt*`) | ~80% | ✅ Good | ✅ Good | Second opinion |
| Codex (`ccc-codex*`) | ~80% | ✅ Excellent | ✅ Excellent | Code generation |
| Gemini (`ccc-gemini*`) | ⚠️ Limited | ⚠️ Issues | ⚠️ Issues | Simple prompts only |
| Ollama (`cco-*`) | 100% | ✅ Good | ✅ Good | Private/offline |

## Troubleshooting

### "copilot-api not running on :4141"
```bash
# For standard models
copilot-api start

# For Codex models
ccunified
```

### "model not found" (Ollama)
```bash
ollama pull devstral-small-2
ollama pull ibm/granite4:small-h
```

### Slow Ollama responses
Create 64K context Modelfile (see `CLAUDE.md` Performance Considerations section).

### MCP errors with GPT models
Some MCP servers have schema issues with GPT strict validation. Use Claude models for 100% compatibility:
```bash
ccc-gpt41 -p "..."  # ⚠️ May have MCP issues
ccc-sonnet -p "..." # ✅ Always works
```

## Further Reading

- **CLAUDE.md**: Complete technical documentation
- **QUICKSTART.md**: 2-minute setup guide
- **MODEL-SWITCHING.md**: Dynamic model selection strategies
- **TROUBLESHOOTING.md**: Common issues and solutions
- **MCP-PROFILES.md**: MCP compatibility system

## Version

Aliases documented for:
- **claude-switch**: v1.5.3
- **copilot-api**: v0.7.0 (official) + unified fork
- **Claude Code CLI**: v2.1.15