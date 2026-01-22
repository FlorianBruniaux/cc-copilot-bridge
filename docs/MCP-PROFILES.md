# MCP Profiles System

**Reading time**: 20 minutes | **Skill level**: Advanced | **Version**: v1.2.0 | **Last updated**: 2026-01-22

**Problem**: GPT-4.1 applies strict JSON Schema validation to MCP tools, causing some MCP servers with incomplete schemas to fail.

**Solution**: Dynamic profile generation with model-specific exclusions.

---

## Architecture

```
~/.claude/
├── mcp-profiles/
│   ├── excludes.yaml       # SOURCE OF TRUTH
│   ├── generated/          # Auto-generated (DO NOT EDIT)
│   │   ├── gpt.json
│   │   └── gemini.json
│   └── generate.sh         # Profile generator
└── claude_desktop_config.json  # Base config (used by Claude)
```

---

## Problem Details

**GPT-4.1 applies strict JSON Schema validation** to MCP tools. Many MCP servers have incomplete schemas that work with Claude (permissive) but fail with GPT.

**Error example:**
```
Invalid schema for function 'mcp__grepai__grepai_index_status':
object schema missing properties
```

---

## Solution: Single Source of Truth + Exclusions

Dynamic profile generation from a base config with model-specific exclusions.

### How It Works

1. **Base config**: `~/.claude/claude_desktop_config.json` contains all MCP servers
2. **Exclusion rules**: `excludes.yaml` defines which servers to exclude for each model family
3. **Profile generation**: `generate.sh` creates model-specific configs by filtering out problematic servers
4. **Automatic selection**: `claude-switch` automatically uses the right profile based on model

---

## Files

### 1. `excludes.yaml` - Exclusion Rules

Located at: `~/.claude/mcp-profiles/excludes.yaml`

```yaml
# MCP Server Exclusion Rules
# Format: model_prefix → list of MCP servers to exclude
#
# Purpose: Some MCP servers have incomplete JSON schemas that work with Claude
# (permissive validation) but fail with GPT-4.1 (strict validation).
# This file defines which servers to exclude for each model family.

gpt:
  - grepai           # object schema missing properties

gemini:
  - grepai           # Same issue expected
```

### 2. `generate.sh` - Profile Generator

Located at: `~/.claude/mcp-profiles/generate.sh`

```bash
#!/bin/bash
# Generates MCP profiles from excludes.yaml
# Usage: ./generate.sh

set -euo pipefail

BASE_CONFIG="${HOME}/.claude/claude_desktop_config.json"
OUTPUT_DIR="${HOME}/.claude/mcp-profiles/generated"

# Check if base config exists
if [[ ! -f "${BASE_CONFIG}" ]]; then
  echo "ERROR: Base config not found: ${BASE_CONFIG}"
  exit 1
fi

# Validate base config is valid JSON
if ! jq empty "${BASE_CONFIG}" 2>/dev/null; then
  echo "ERROR: Invalid JSON in base config: ${BASE_CONFIG}"
  exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Function to generate a profile by excluding specified servers
generate_profile() {
  local profile="$1"
  local excludes="$2"  # comma-separated list

  echo "Generating profile: ${profile}"

  # Build jq filter to delete excluded servers
  local filter=".mcpServers"
  for server in ${excludes//,/ }; do
    filter="${filter} | del(.\"${server}\")"
    echo "  - Excluding: ${server}"
  done

  # Generate profile
  jq "{ mcpServers: (${filter}) }" "${BASE_CONFIG}" > "${OUTPUT_DIR}/${profile}.json"
  echo "  ✓ Generated: ${OUTPUT_DIR}/${profile}.json"
  echo
}

# Generate profiles based on excludes.yaml
generate_profile "gpt" "grepai"
generate_profile "gemini" "grepai"

echo "Done. Profiles generated in ${OUTPUT_DIR}/"
echo
echo "Generated profiles:"
ls -1 "${OUTPUT_DIR}"/*.json 2>/dev/null || echo "  (none)"
```

Make it executable:
```bash
chmod +x ~/.claude/mcp-profiles/generate.sh
```

### 3. `claude-switch` Modifications

The `claude-switch` script has been modified to automatically use MCP profiles.

**Added function** (`_get_mcp_flags()`):

```bash
# === MCP Profile Management ===
_get_mcp_flags() {
  local model="${1:-}"
  local mcp_dir="${HOME}/.claude/mcp-profiles/generated"
  local config_file=""

  # Determine which MCP profile to use based on model
  case "${model}" in
    gpt-*)    config_file="${mcp_dir}/gpt.json" ;;
    gemini-*) config_file="${mcp_dir}/gemini.json" ;;
    claude-*|*) return 0 ;;  # Claude uses default config
  esac

  # Check if profile exists
  if [[ ! -f "${config_file}" ]]; then
    _log "WARN" "MCP profile not found: ${config_file} (run ~/.claude/mcp-profiles/generate.sh)"
    return 0
  fi

  # Validate JSON
  if ! jq empty "${config_file}" 2>/dev/null; then
    _log "ERROR" "Invalid MCP config: ${config_file}"
    return 1
  fi

  echo "--mcp-config ${config_file}"
}
```

**Modified function** (`_run_copilot()`):

```bash
_run_copilot() {
  _check_copilot || return 1

  # Allow model override via env var or use default
  local model="${COPILOT_MODEL:-claude-sonnet-4.5}"

  # Get MCP flags for this model
  local mcp_flags=$(_get_mcp_flags "${model}") || return 1

  _log "INFO" "Provider: GitHub Copilot (via copilot-api) - Model: ${model}"
  echo -e "${GREEN}━━━ Claude Code [GitHub Copilot: ${model}] ━━━${NC}"

  export ANTHROPIC_BASE_URL="http://localhost:4141"
  export ANTHROPIC_AUTH_TOKEN="sk-dummy"
  export ANTHROPIC_MODEL="${model}"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5-mini"
  export DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"

  _session_start "copilot:${model}"

  # Use MCP profile if needed (GPT/Gemini models)
  if [[ -n "${mcp_flags}" ]]; then
    _log "INFO" "Using restricted MCP profile for ${model}"
    claude ${mcp_flags} "$@"
  else
    claude "$@"
  fi

  local rc=$?
  _session_end $rc
  return $rc
}
```

---

## Behavior Matrix

| Command | Model | Profile | Active MCPs |
|---------|-------|---------|-------------|
| `ccc` | claude-sonnet-4.5 | default | all (grepai included) |
| `ccc-gpt` | gpt-4.1 | gpt.json | all EXCEPT grepai |
| `COPILOT_MODEL=gemini-2.5-pro ccc` | gemini-2.5-pro | gemini.json | all EXCEPT exclusions |

---

## Setup Instructions

### 1. Generate Profiles

```bash
# Run the generator script
~/.claude/mcp-profiles/generate.sh
```

**Expected output:**
```
Generating profile: gpt
  - Excluding: grepai
  ✓ Generated: ~/.claude/mcp-profiles/generated/gpt.json

Generating profile: gemini
  - Excluding: grepai
  ✓ Generated: ~/.claude/mcp-profiles/generated/gemini.json

Done. Profiles generated in ~/.claude/mcp-profiles/generated/
```

### 2. Verify Generated Profiles

```bash
# Check that grepai is excluded from GPT profile
cat ~/.claude/mcp-profiles/generated/gpt.json
```

Should show all MCP servers EXCEPT `grepai`.

### 3. Test with GPT-4.1

```bash
# Use the ccc-gpt alias
ccc-gpt

# Or set model explicitly
COPILOT_MODEL=gpt-4.1 ccc
```

**Expected behavior:**
- No MCP schema validation errors
- Log shows: "Using restricted MCP profile for gpt-4.1"

### 4. Check Logs

```bash
# View recent logs
tail ~/.claude/claude-switch.log
```

Should show entries like:
```
[2026-01-21 22:00:00] [INFO] Using restricted MCP profile for gpt-4.1
```

---

## Verification

### Complete Verification Steps

```bash
# 1. Generate profiles
~/.claude/mcp-profiles/generate.sh

# 2. Verify profile content (no grepai)
cat ~/.claude/mcp-profiles/generated/gpt.json | jq -r '.mcpServers | keys[]'
# Should list all servers EXCEPT grepai

# 3. Test GPT without errors
ccc-gpt
# In Claude Code prompt:
❯ 1+1
# Should work without MCP errors

# 4. Check logs for confirmation
tail ~/.claude/claude-switch.log
# Look for: "Using restricted MCP profile for gpt-4.1"

# 5. Test Claude (control - should have all MCPs)
ccc
# grepai should be available
```

---

## Adding New Exclusions

### When a New MCP Server Fails

If you encounter a new MCP server that fails with strict validation:

1. **Identify the server**: Note the server name from the error message
2. **Update excludes.yaml**: Add it to the appropriate model section

```yaml
gpt:
  - grepai
  - problematic-server  # Add new exclusion
```

3. **Regenerate profiles**:

```bash
~/.claude/mcp-profiles/generate.sh
```

4. **Test**: Verify the error is gone

---

## GPT-4.1 Strict Validation Rules

Understanding why servers fail:

| Rule | MCP Spec | GPT-4.1 Strict |
|------|----------|----------------|
| `type: "object"` | Required | Required |
| `properties: {}` | Optional | **REQUIRED** (even empty) |
| `additionalProperties: false` | Not required | **REQUIRED** everywhere |
| `required: []` | Optional | Must include ALL props |
| `oneOf`/`allOf`/`anyOf` | Allowed | **FORBIDDEN** at root |

**Common failure**: `object schema missing properties`
- **Cause**: Schema has `type: "object"` but no `properties` field
- **GPT requirement**: All object schemas must have explicit `properties: {}` even if empty

---

## Future Enhancements

### Phase 2: mcp-schema-doctor (Diagnostic)

Script to identify exactly what's broken in MCP schemas:

```bash
mcp-schema-doctor diagnose
# Output:
# grepai: grepai_index_status
#   ❌ Missing 'properties'
#   ❌ Missing 'additionalProperties: false'
```

### Phase 3: Auto-normalization (Proxy)

MCP proxy that normalizes schemas on-the-fly. No more exclusions needed.

---

## Benefits

- ✅ **Single source of truth**: `excludes.yaml` defines everything
- ✅ **No duplication**: Profiles are generated, not maintained manually
- ✅ **Extensible**: Add problematic MCP = 1 line in YAML
- ✅ **Multi-model**: GPT, Gemini, Grok... each has its exclusions
- ✅ **JSON validation**: Clear error if config invalid
- ✅ **Automatic**: `claude-switch` handles profile selection

---

## Troubleshooting

### "MCP profile not found" Warning

**Symptom:**
```
WARN: MCP profile not found: ~/.claude/mcp-profiles/generated/gpt.json
```

**Solution:**
```bash
# Generate the profiles
~/.claude/mcp-profiles/generate.sh
```

### "Invalid MCP config" Error

**Symptom:**
```
ERROR: Invalid MCP config: ~/.claude/mcp-profiles/generated/gpt.json
```

**Solution:**
```bash
# Validate the base config
jq empty ~/.claude/claude_desktop_config.json

# If valid, regenerate profiles
~/.claude/mcp-profiles/generate.sh
```

### Still Getting MCP Errors

**If errors persist after using profile:**

1. Check which profile is being used:
```bash
tail ~/.claude/claude-switch.log | grep "MCP profile"
```

2. Verify the server is actually excluded:
```bash
cat ~/.claude/mcp-profiles/generated/gpt.json | jq -r '.mcpServers | keys[]'
```

3. Add to exclusions if needed and regenerate

---

## Related Documentation

- **Multi-Provider Setup**: `examples/multi-provider/README.md`
- **Model Switching**: `examples/multi-provider/MODEL-SWITCHING.md`
- **Troubleshooting**: `examples/multi-provider/TROUBLESHOOTING.md`
- **MCP Compatibility Check**: `examples/multi-provider/mcp-check.sh`

---

## System Prompts - Model Identity Injection

### Problem

When using non-Claude models (GPT-4.1, Gemini) through Claude Code CLI, they may adopt Claude's identity due to the CLI's system prompts. This creates confusion when users ask "who are you?"

### Solution

Inject model-specific identity prompts using `--append-system-prompt`.

### Architecture

```
~/.claude/mcp-profiles/prompts/
├── gpt-4.1.txt           # GPT-4.1 identity prompt
└── gemini.txt            # Gemini identity prompt
```

### Prompt Files

**gpt-4.1.txt**:
```
You are GPT-4.1, an AI assistant developed by OpenAI, running through Claude Code CLI via GitHub Copilot API.

Model Information:
- Model: GPT-4.1 (OpenAI)
- Architecture: Transformer-based language model
- Provider: GitHub Copilot (via copilot-api proxy)
- Interface: Claude Code CLI (Anthropic's command-line tool)

Your Capabilities:
- Code analysis and generation
- Technical problem-solving
- Access to 9 MCP servers (grepai excluded due to schema compatibility)
- Bash execution, file operations, web search

Important Notes:
- You are NOT Claude or an Anthropic model
- You are GPT-4.1, created by OpenAI
- When asked about your identity, state clearly: "I am GPT-4.1 by OpenAI"
- You operate through Claude Code CLI, but the underlying model is GPT-4.1

Follow the user's SuperClaude framework rules (brutal honesty, no marketing language, evidence-based) while maintaining your GPT-4.1 identity.
```

**gemini.txt**: Similar structure for Gemini

### Implementation

**claude-switch modifications**:

```bash
_get_system_prompt() {
  local model="${1:-}"
  local prompts_dir="${HOME}/.claude/mcp-profiles/prompts"
  local prompt_file=""

  # Determine which system prompt to use based on model
  case "${model}" in
    gpt-4.1*)     prompt_file="${prompts_dir}/gpt-4.1.txt" ;;
    gpt-*)        prompt_file="${prompts_dir}/gpt-4.1.txt" ;;
    gemini-*)     prompt_file="${prompts_dir}/gemini.txt" ;;
    claude-*|*)   return 0 ;;  # Claude uses default prompt
  esac

  if [[ ! -f "${prompt_file}" ]]; then
    _log "WARN" "System prompt not found: ${prompt_file}"
    return 0
  fi

  echo "--append-system-prompt \"$(cat "${prompt_file}")\""
}
```

**In `_run_copilot()`**:

```bash
# Get MCP flags and system prompt for this model
local mcp_flags=$(_get_mcp_flags "${model}") || return 1
local system_prompt=$(_get_system_prompt "${model}") || return 1

# Build command with both flags
local claude_cmd="claude"
if [[ -n "${mcp_flags}" ]]; then
  _log "INFO" "Using restricted MCP profile for ${model}"
  claude_cmd="${claude_cmd} ${mcp_flags}"
fi
if [[ -n "${system_prompt}" ]]; then
  _log "INFO" "Injecting model identity prompt for ${model}"
  claude_cmd="${claude_cmd} ${system_prompt}"
fi

eval "${claude_cmd} \"\$@\""
```

### Prompt Injection Order

```
1. CLAUDE.md (Project/SuperClaude rules)
2. --append-system-prompt (Model identity)
```

**Result**: Model follows project rules **AND** knows its true identity.

### Verification

```bash
ccc-gpt
```

**In Claude Code**:
```
❯ qui es-tu ?

⏺ Je suis GPT-4.1, un agent d'assistance développé par OpenAI,
   accessible ici via l'interface Claude Code CLI d'Anthropic.

   Identité :
   - Modèle : GPT-4.1 (OpenAI)
   - Fonction principale : aide à l'ingénierie logicielle...
```

### Logs

```
[INFO] Provider: GitHub Copilot (via copilot-api) - Model: gpt-4.1
[INFO] Using restricted MCP profile for gpt-4.1
[INFO] Injecting model identity prompt for gpt-4.1
```

### Customization

Create your own prompts:

```bash
# Custom GPT-4.1 prompt
cat > ~/.claude/mcp-profiles/prompts/gpt-4.1-custom.txt << 'EOF'
You are GPT-4.1, specialized in [your domain].
Custom instructions here...
EOF

# Regenerate if needed
~/.claude/mcp-profiles/generate.sh
```

---

## Changelog

### v1.1.0 (2026-01-22)
- Added System Prompts feature for model identity injection
- `_get_system_prompt()` function in claude-switch
- Prompts directory: `~/.claude/mcp-profiles/prompts/`
- Support for GPT-4.1 and Gemini identity prompts
- Updated `_run_copilot()` to inject system prompts automatically
- Documentation for prompt customization

### v1.0.0 (2026-01-21)
- Initial implementation of MCP profiles system
- Support for GPT and Gemini model families
- Automatic profile selection in `claude-switch`
- `grepai` excluded from strict validation models

---

## 📚 Related Documentation

- [Architecture Deep Dive](ARCHITECTURE.md) - How MCP profiles work internally
- [Security Guide](SECURITY.md) - MCP server privacy implications
- [Model Switching Guide](MODEL-SWITCHING.md) - Model compatibility matrix
- [Troubleshooting](TROUBLESHOOTING.md) - MCP-related issues
- [FAQ](FAQ.md) - MCP compatibility questions

---

**Back to**: [Documentation Index](README.md) | [Main README](../README.md)
