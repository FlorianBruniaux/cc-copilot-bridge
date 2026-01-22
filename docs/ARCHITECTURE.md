# Architecture Deep-Dive

**Reading time**: 25 minutes | **Skill level**: Advanced | **Last updated**: 2026-01-22

**Comprehensive technical documentation of cc-copilot-bridge internals**

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Provider Routing](#2-provider-routing)
3. [MCP Profiles System](#3-mcp-profiles-system)
4. [Session Management](#4-session-management)
5. [Technical Implementation](#5-technical-implementation)
6. [Data Flow Diagrams](#6-data-flow-diagrams)
7. [Extension Points](#7-extension-points)

---

## 1. System Overview

### 1.1 High-Level Architecture

cc-copilot-bridge is a **routing layer** that sits between Claude Code CLI and multiple AI providers, enabling seamless provider switching without configuration changes.

```
┌──────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE                          │
│                     (Terminal Commands)                          │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    Aliases (ccd, ccc, cco)
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│                       claude-switch                              │
│                   (Main Orchestrator)                            │
│                                                                  │
│  ┌──────────────┐  ┌───────────────┐  ┌────────────────────┐  │
│  │ Health Check │  │ MCP Profiles  │  │  Session Tracking  │  │
│  │   System     │  │    Manager    │  │      System        │  │
│  └──────────────┘  └───────────────┘  └────────────────────┘  │
└────────────────────────────┬─────────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
    ┌─────────▼────┐  ┌─────▼─────┐  ┌────▼─────┐
    │   Direct     │  │  Copilot  │  │  Ollama  │
    │   Provider   │  │  Provider │  │ Provider │
    └─────────┬────┘  └─────┬─────┘  └────┬─────┘
              │              │              │
    ┌─────────▼────┐  ┌─────▼─────┐  ┌────▼─────┐
    │  Anthropic   │  │ copilot-  │  │  Ollama  │
    │     API      │  │    api    │  │  Server  │
    └──────────────┘  └─────┬─────┘  └──────────┘
                            │
                     ┌──────▼───────┐
                     │GitHub Copilot│
                     │   Backend    │
                     └──────────────┘
```

### 1.2 Component Responsibilities

| Component | Responsibility | Key Functions |
|-----------|----------------|---------------|
| **claude-switch** | Main orchestrator, provider routing | `main()`, `_run_direct()`, `_run_copilot()`, `_run_ollama()` |
| **Health Check System** | Pre-flight validation | `_check_port()`, `_check_copilot()`, `_check_ollama()` |
| **MCP Profiles Manager** | Model-specific MCP configuration | `_get_mcp_flags()`, `_get_system_prompt()` |
| **Session Tracker** | Logging and audit trail | `_session_start()`, `_session_end()`, `_log()` |
| **copilot-api** | Anthropic API → GitHub Copilot bridge | External proxy service |
| **Ollama** | Local inference engine | External service |

### 1.3 Key Design Principles

1. **Fail-Fast Philosophy**: Validate provider availability before execution
2. **Zero Configuration Switching**: Change providers without editing files
3. **Transparency**: Full audit trail via session logging
4. **Model Compatibility**: Automatic MCP profile selection based on model capabilities
5. **Environment Variable Magic**: Dynamic configuration via exports

---

## 2. Provider Routing

### 2.1 How claude-switch Works

The `claude-switch` script is a **bash-based routing layer** that intercepts CLI invocation and modifies the execution environment based on the selected provider.

**Core Mechanism**:
```bash
main() {
  local mode="${1:-}"      # Extract provider mode
  shift 2>/dev/null || true  # Remove mode from args

  case "${mode}" in
    d|direct)  _run_direct "$@" ;;   # Route to Anthropic
    c|copilot) _run_copilot "$@" ;;  # Route to Copilot
    o|ollama)  _run_ollama "$@" ;;   # Route to Ollama
    s|status)  _show_status ;;       # Show health status
    *)         _show_usage ;;        # Help text
  esac
}
```

### 2.2 Provider Implementation: Direct

**Execution Flow**:
```
ccd [args] → _run_direct() → unset env vars → exec claude [args]
```

**Implementation**:
```bash
_run_direct() {
  _log "INFO" "Provider: Anthropic Direct"
  echo -e "${BLUE}━━━ Claude Code [Anthropic Direct] ━━━${NC}"

  # Clear any proxy configurations
  unset ANTHROPIC_BASE_URL
  unset DISABLE_NON_ESSENTIAL_MODEL_CALLS
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC

  _session_start "direct"
  claude "$@"  # Execute with original args
  local rc=$?
  _session_end $rc
  return $rc
}
```

**Key Behavior**:
- Removes proxy environment variables to force direct API connection
- Passes all arguments unchanged to `claude` CLI
- Uses `ANTHROPIC_API_KEY` from environment (must be pre-configured)

### 2.3 Provider Implementation: Copilot

**Execution Flow**:
```
ccc [args] → _check_copilot() → set env vars → get MCP profile →
get system prompt → exec claude --mcp-config [profile]
--append-system-prompt [prompt] [args]
```

**Implementation**:
```bash
_run_copilot() {
  _check_copilot || return 1  # Fail-fast health check

  # Model selection (default or from env var)
  local model="${COPILOT_MODEL:-claude-sonnet-4.5}"

  # Get model-specific configuration
  local mcp_flags=$(_get_mcp_flags "${model}") || return 1
  local system_prompt=$(_get_system_prompt "${model}") || return 1

  _log "INFO" "Provider: GitHub Copilot - Model: ${model}"
  echo -e "${GREEN}━━━ Claude Code [GitHub Copilot: ${model}] ━━━${NC}"

  # Configure proxy routing
  export ANTHROPIC_BASE_URL="http://localhost:4141"
  export ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # copilot-api ignores this
  export ANTHROPIC_MODEL="${model}"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5-mini"
  export DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"

  _session_start "copilot:${model}"

  # Build command with MCP profile and system prompt
  local claude_cmd="claude"
  [[ -n "${mcp_flags}" ]] && claude_cmd="${claude_cmd} ${mcp_flags}"
  [[ -n "${system_prompt}" ]] && claude_cmd="${claude_cmd} ${system_prompt}"

  eval "${claude_cmd} \"\$@\""
  local rc=$?
  _session_end $rc
  return $rc
}
```

**Environment Variable Magic**:

| Variable | Purpose | Value |
|----------|---------|-------|
| `ANTHROPIC_BASE_URL` | Redirect API calls to copilot-api | `http://localhost:4141` |
| `ANTHROPIC_AUTH_TOKEN` | Dummy auth (copilot-api handles real auth) | `<PLACEHOLDER>` |
| `ANTHROPIC_MODEL` | Tell copilot-api which model to use | `gpt-4.1`, `claude-opus-4.5`, etc. |
| `DISABLE_NON_ESSENTIAL_MODEL_CALLS` | Reduce API traffic | `1` |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Further traffic optimization | `1` |

### 2.4 Provider Implementation: Ollama

**Execution Flow**:
```
cco [args] → _check_ollama() → set env vars → exec claude
--model qwen2.5-coder:32b [args]
```

**Implementation**:
```bash
_run_ollama() {
  _check_ollama || return 1  # Verify Ollama service + model

  _log "INFO" "Provider: Ollama Local"
  echo -e "${ORANGE}━━━ Claude Code [Ollama Local] ━━━${NC}"

  # Configure Ollama endpoint
  export ANTHROPIC_BASE_URL="http://localhost:11434"
  export ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # Ollama ignores this
  export ANTHROPIC_API_KEY="ollama"

  _session_start "ollama"
  claude --model qwen2.5-coder:32b "$@"
  local rc=$?
  _session_end $rc
  return $rc
}
```

**Key Differences**:
- Uses Ollama's OpenAI-compatible endpoint (port 11434)
- Explicitly specifies model via `--model` flag
- Auth token is ignored by Ollama (no authentication required)

### 2.5 Port Forwarding Mechanism

**Health Check Implementation**:
```bash
_check_port() {
  local host="$1" port="$2" timeout="${3:-2}"
  nc -z -w"${timeout}" "${host}" "${port}" 2>/dev/null
}

_check_copilot() {
  if ! _check_port "localhost" "4141"; then
    _log "ERROR" "copilot-api not running on :4141"
    echo "  Start it with: copilot-api start"
    return 1
  fi
  _log "INFO" "copilot-api health: OK"
}

_check_ollama() {
  if ! _check_port "localhost" "11434"; then
    _log "ERROR" "Ollama not running on :11434"
    echo "  Start it with: ollama serve"
    return 1
  fi

  # Verify model availability
  if ! ollama list 2>/dev/null | grep -q "qwen2.5-coder"; then
    _log "ERROR" "Model qwen2.5-coder not found"
    echo "  Pull it with: ollama pull qwen2.5-coder:32b"
    return 1
  fi
  _log "INFO" "Ollama health: OK (qwen2.5-coder found)"
}
```

**Port Assignment Logic**:

| Service | Port | Protocol | Rationale |
|---------|------|----------|-----------|
| copilot-api | 4141 | HTTP | Default port from copilot-api project |
| Ollama | 11434 | HTTP | Ollama's standard OpenAI-compatible endpoint |
| Anthropic API | 443 | HTTPS | Standard HTTPS (api.anthropic.com) |

### 2.6 Sequence Diagram: Copilot Provider

```
User          claude-switch      copilot-api      GitHub Copilot
 │                │                   │                   │
 │─── ccc ───────>│                   │                   │
 │                │                   │                   │
 │                │─ _check_port ────>│                   │
 │                │<── 200 OK ────────│                   │
 │                │                   │                   │
 │                │─ set ANTHROPIC_   │                   │
 │                │  BASE_URL         │                   │
 │                │                   │                   │
 │                │─ exec claude ─────>│                   │
 │                │                   │─ API request ────>│
 │                │                   │<── response ──────│
 │                │<── stream ────────│                   │
 │<── output ─────│                   │                   │
 │                │                   │                   │
```

---

## 3. MCP Profiles System

### 3.1 Architecture Overview

The MCP Profiles System solves **model-specific compatibility issues** by generating custom MCP server configurations for models with strict JSON schema validation.

**Problem**: GPT-4.1 enforces strict JSON Schema validation, rejecting MCP servers with incomplete schemas (e.g., missing `properties` field in object schemas).

**Solution**: Generate model-specific MCP configurations that exclude incompatible servers.

### 3.2 Directory Structure

```
~/.claude/
├── claude_desktop_config.json        # Base config (all MCP servers)
│
└── mcp-profiles/
    ├── excludes.yaml                 # SOURCE OF TRUTH
    ├── generate.sh                   # Profile generator script
    │
    ├── generated/                    # Auto-generated (DO NOT EDIT)
    │   ├── gpt.json                 # GPT-compatible config
    │   └── gemini.json              # Gemini-compatible config
    │
    └── prompts/                      # Model identity injection
        ├── gpt-4.1.txt              # GPT identity prompt
        └── gemini.txt               # Gemini identity prompt
```

### 3.3 Auto-Detection Logic

**Model → Profile Mapping**:
```bash
_get_mcp_flags() {
  local model="${1:-}"
  local mcp_dir="${HOME}/.claude/mcp-profiles/generated"
  local config_file=""

  # Pattern matching on model name
  case "${model}" in
    gpt-*)    config_file="${mcp_dir}/gpt.json" ;;
    gemini-*) config_file="${mcp_dir}/gemini.json" ;;
    claude-*|*) return 0 ;;  # Claude uses default config
  esac

  # Validate profile exists and is valid JSON
  if [[ ! -f "${config_file}" ]]; then
    _log "WARN" "MCP profile not found: ${config_file}"
    return 0
  fi

  if ! jq empty "${config_file}" 2>/dev/null; then
    _log "ERROR" "Invalid MCP config: ${config_file}"
    return 1
  fi

  echo "--mcp-config ${config_file}"
}
```

**Behavior Matrix**:

| Model Input | Profile Selected | MCP Servers Loaded |
|-------------|------------------|--------------------|
| `claude-sonnet-4.5` | None (default) | All servers (10/10) |
| `claude-opus-4.5` | None (default) | All servers (10/10) |
| `gpt-4.1` | `gpt.json` | All except grepai (9/10) |
| `gpt-5.2-codex` | `gpt.json` | All except grepai (9/10) |
| `gemini-2.5-pro` | `gemini.json` | All except grepai (9/10) |

### 3.4 Profile Generation

**excludes.yaml Format**:
```yaml
# MCP Server Exclusion Rules
# Format: model_prefix → list of MCP servers to exclude

gpt:
  - grepai           # object schema missing properties

gemini:
  - grepai           # Same issue expected
```

**Generation Algorithm** (`generate.sh`):
```bash
generate_profile() {
  local profile="$1"      # e.g., "gpt"
  local excludes="$2"     # e.g., "grepai,other-server"

  # Build jq filter to delete excluded servers
  local filter=".mcpServers"
  for server in ${excludes//,/ }; do
    filter="${filter} | del(.\"${server}\")"
  done

  # Generate profile by filtering base config
  jq "{ mcpServers: (${filter}) }" \
    "${BASE_CONFIG}" > "${OUTPUT_DIR}/${profile}.json"
}
```

**Execution Flow**:
```
excludes.yaml → generate.sh → reads base config → filters servers
→ writes gpt.json/gemini.json
```

**Example Generated Profile** (`gpt.json`):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@sequentialread/mcp-server"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
    // ... other servers, but NOT grepai
  }
}
```

### 3.5 Schema Validation Differences

**Claude vs GPT-4.1 JSON Schema Handling**:

| Schema Feature | MCP Spec | Claude Behavior | GPT-4.1 Behavior |
|----------------|----------|-----------------|------------------|
| `type: "object"` | Required | Accepts | Accepts |
| `properties: {}` | Optional | **Accepts if missing** | **Rejects if missing** |
| `additionalProperties` | Not required | Accepts omission | **Requires explicit `false`** |
| `required: []` | Optional | Accepts partial | **Requires all properties** |
| `oneOf`/`anyOf`/`allOf` | Allowed | Accepts at root | **Forbidden at root level** |

**Common Failure Pattern**:
```json
// MCP server schema (works with Claude, fails with GPT)
{
  "name": "grepai_index_status",
  "inputSchema": {
    "type": "object"  // ❌ Missing "properties" field
  }
}

// GPT-4.1 Error:
// "Invalid schema for function 'mcp__grepai__grepai_index_status':
//  object schema missing properties"

// Fixed schema (GPT-compatible):
{
  "name": "grepai_index_status",
  "inputSchema": {
    "type": "object",
    "properties": {},              // ✅ Explicit empty properties
    "additionalProperties": false  // ✅ Explicit prohibition
  }
}
```

### 3.6 Model Identity Injection

**Problem**: Non-Claude models adopt Claude's identity when running through Claude Code CLI.

**Solution**: Inject model-specific system prompts using `--append-system-prompt`.

**System Prompt Retrieval**:
```bash
_get_system_prompt() {
  local model="${1:-}"
  local prompts_dir="${HOME}/.claude/mcp-profiles/prompts"
  local prompt_file=""

  # Map model to prompt file
  case "${model}" in
    gpt-4.1*)     prompt_file="${prompts_dir}/gpt-4.1.txt" ;;
    gpt-*)        prompt_file="${prompts_dir}/gpt-4.1.txt" ;;
    gemini-*)     prompt_file="${prompts_dir}/gemini.txt" ;;
    claude-*|*)   return 0 ;;  # Claude uses default
  esac

  [[ -f "${prompt_file}" ]] || return 0

  echo "--append-system-prompt \"$(cat "${prompt_file}")\""
}
```

**Example Prompt** (`gpt-4.1.txt`):
```
You are GPT-4.1, an AI assistant developed by OpenAI, running
through Claude Code CLI via GitHub Copilot API.

Model Information:
- Model: GPT-4.1 (OpenAI)
- Architecture: Transformer-based language model
- Provider: GitHub Copilot (via copilot-api proxy)
- Interface: Claude Code CLI (Anthropic's tool)

Your Capabilities:
- Code analysis and generation
- Technical problem-solving
- Access to 9 MCP servers (grepai excluded)
- Bash execution, file operations, web search

Important Notes:
- You are NOT Claude or an Anthropic model
- You are GPT-4.1, created by OpenAI
- When asked about your identity, clearly state: "I am GPT-4.1 by OpenAI"
- You operate through Claude Code CLI, but the underlying model is GPT-4.1

Follow the user's SuperClaude framework rules while maintaining
your GPT-4.1 identity.
```

**Prompt Injection Order**:
```
1. Base system prompt (Claude Code CLI default)
2. CLAUDE.md (project-specific rules)
3. --append-system-prompt (model identity)
```

---

## 4. Session Management

### 4.1 Logging System

**Log Structure**:
```
~/.claude/
├── claude-switch.log          # Main session log
└── mcp-profiles/
    └── generated/             # Profile generation logs
```

**Log Format**:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

**Example Log Entries**:
```
[2026-01-22 09:42:33] [INFO] Provider: GitHub Copilot - Model: gpt-4.1
[2026-01-22 09:42:33] [INFO] Using restricted MCP profile for gpt-4.1
[2026-01-22 09:42:33] [INFO] Injecting model identity prompt for gpt-4.1
[2026-01-22 09:42:33] [INFO] Session started: mode=copilot:gpt-4.1 pid=12345 pwd=/path/to/project
[2026-01-22 10:15:20] [INFO] Session ended: mode=copilot:gpt-4.1 duration=32m47s exit=0
```

**Logging Implementation**:
```bash
LOG_FILE="${HOME}/.claude/claude-switch.log"
LOG_DIR="${HOME}/.claude"

_log() {
  local level="$1" msg="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  # Ensure log directory exists
  mkdir -p "${LOG_DIR}"

  # Append to log file
  echo "[${timestamp}] [${level}] ${msg}" >> "${LOG_FILE}"

  # Color-coded terminal output
  case "${level}" in
    ERROR) echo -e "${RED}ERROR: ${msg}${NC}" >&2 ;;
    WARN)  echo -e "${ORANGE}WARN: ${msg}${NC}" >&2 ;;
    INFO)  echo -e "${GREEN}${msg}${NC}" ;;
  esac
}
```

### 4.2 Session Tracking

**Session Lifecycle**:
```
_session_start() → user interaction → _session_end()
```

**Implementation**:
```bash
_session_start() {
  local mode="$1"
  export CLAUDE_SESSION_START=$(date +%s)
  export CLAUDE_SESSION_MODE="${mode}"
  _log "INFO" "Session started: mode=${mode} pid=$$ pwd=${PWD}"
}

_session_end() {
  local exit_code="$1"
  local duration=$(($(date +%s) - ${CLAUDE_SESSION_START:-0}))
  local mins=$((duration / 60))
  local secs=$((duration % 60))
  _log "INFO" "Session ended: mode=${CLAUDE_SESSION_MODE} duration=${mins}m${secs}s exit=${exit_code}"
}
```

**Tracked Metrics**:
- Session start timestamp (Unix epoch)
- Provider mode (direct/copilot:model/ollama)
- Process ID (for debugging)
- Working directory (context)
- Session duration (calculated on exit)
- Exit code (success/failure)

### 4.3 Health Checks

**Pre-Flight Validation Pattern**:
```
User command → Health check → [PASS → Execute] / [FAIL → Error + Help]
```

**Health Check Matrix**:

| Provider | Port Check | Service Check | Model Check |
|----------|------------|---------------|-------------|
| Direct | None | `curl api.anthropic.com` | N/A |
| Copilot | `localhost:4141` | `nc -z` | N/A |
| Ollama | `localhost:11434` | `nc -z` | `ollama list` + grep model |

**Fail-Fast Example** (Copilot):
```bash
ccc
# Health check fails:
ERROR: copilot-api not running on :4141
  Start it with: copilot-api start
# Exit immediately (no wasted API calls)
```

### 4.4 Error Handling

**Error Categories**:

| Category | Severity | Action |
|----------|----------|--------|
| Port unreachable | ERROR | Abort, show start command |
| Model not found | ERROR | Abort, show pull command |
| Invalid MCP config | ERROR | Abort, show regeneration command |
| MCP profile missing | WARN | Continue with default config |
| System prompt missing | WARN | Continue without prompt |

**Error Propagation**:
```bash
_run_copilot() {
  _check_copilot || return 1  # Early exit on health check failure

  local mcp_flags=$(_get_mcp_flags "${model}") || return 1
  local system_prompt=$(_get_system_prompt "${model}") || return 1

  # ... execution

  local rc=$?
  _session_end $rc
  return $rc  # Propagate exit code to caller
}
```

---

## 5. Technical Implementation

### 5.1 Bash Script Architecture

**Script Structure**:
```bash
#!/bin/bash
set -euo pipefail  # Strict mode

# === Configuration ===
LOG_FILE="${HOME}/.claude/claude-switch.log"
LOG_DIR="${HOME}/.claude"

# === Colors ===
BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# === Helper Functions ===
_log() { ... }
_check_port() { ... }
_check_copilot() { ... }
_check_ollama() { ... }

# === Session Management ===
_session_start() { ... }
_session_end() { ... }

# === MCP Profile Management ===
_get_mcp_flags() { ... }
_get_system_prompt() { ... }

# === Provider Functions ===
_run_direct() { ... }
_run_copilot() { ... }
_run_ollama() { ... }
_show_status() { ... }
_show_usage() { ... }

# === Main Entry Point ===
main() { ... }

main "$@"
```

**Key Bash Features Used**:

| Feature | Purpose | Example |
|---------|---------|---------|
| `set -euo pipefail` | Strict error handling | Exit on error, unset vars, pipe failures |
| `local` variables | Function scope | `local model="${1:-}"` |
| `export` variables | Environment propagation | `export ANTHROPIC_BASE_URL="..."` |
| `case` statements | Pattern matching | Model → profile mapping |
| `eval` command | Dynamic command building | Build claude command with flags |
| Process substitution | Inline command output | `$(date +%s)` |
| `|| return 1` | Fail-fast pattern | Early exit on error |

### 5.2 copilot-api Proxy Mechanism

**copilot-api Architecture** (external project):
```
Claude Code CLI → HTTP request to :4141 → copilot-api
                                             │
                                             ├─ Extract ANTHROPIC_MODEL
                                             ├─ Authenticate with GitHub
                                             ├─ Map to Copilot backend model
                                             │
                                             └─> GitHub Copilot API
                                                  (claude-opus-4.5, gpt-4.1, etc.)
```

**API Request Flow**:
```bash
# Claude Code CLI makes request:
POST http://localhost:4141/v1/messages
Headers:
  anthropic-version: 2023-06-01
  x-api-key: <PLACEHOLDER>
  anthropic-model: gpt-4.1
Body:
  { "model": "gpt-4.1", "messages": [...] }

# copilot-api transforms to:
POST https://api.githubcopilot.com/chat/completions
Headers:
  Authorization: Bearer <github-token>
  Copilot-Integration-Id: vscode-chat
Body:
  { "model": "gpt-4.1", "messages": [...] }
```

**Model Name Mapping**:

| ANTHROPIC_MODEL | Copilot Backend | Notes |
|-----------------|-----------------|-------|
| `claude-opus-4.5` | `claude-opus-4.5` | Native Copilot model |
| `claude-sonnet-4.5` | `claude-sonnet-4.5` | Native Copilot model |
| `gpt-4.1` | `gpt-4.1-turbo` | OpenAI model via Copilot |
| `gpt-5.2-codex` | `gpt-5.2-codex` | OpenAI model via Copilot |
| `gemini-2.5-pro` | `gemini-2.5-pro` | Google model via Copilot |

**Authentication Flow**:
```
copilot-api start
  │
  ├─ Prompt user for GitHub authentication
  │   (opens browser: github.com/login/device)
  │
  ├─ User authenticates with GitHub
  │
  ├─ copilot-api receives OAuth token
  │
  └─ Token stored in ~/.copilot-api/config.json
```

**Why copilot-api Is Required**:
- GitHub Copilot API uses proprietary authentication (not standard API keys)
- Requires OAuth device flow with GitHub account
- copilot-api handles token management and refresh
- Provides OpenAI-compatible endpoint for Claude Code CLI

### 5.3 Ollama Integration

**Ollama API Compatibility**:

Ollama provides an **OpenAI-compatible HTTP API**, allowing Claude Code CLI to interact with it using the same protocol as Anthropic's API (with minimal differences).

**API Endpoint Structure**:
```
Anthropic: https://api.anthropic.com/v1/messages
Ollama:    http://localhost:11434/v1/chat/completions  (OpenAI-compatible)
```

**Request Transformation**:
```bash
# Claude Code CLI expects Anthropic format:
export ANTHROPIC_BASE_URL="http://localhost:11434"

# Ollama translates to OpenAI format internally:
POST /v1/chat/completions
{
  "model": "qwen2.5-coder:32b",
  "messages": [
    {"role": "user", "content": "Hello"}
  ]
}
```

**Model Selection**:
```bash
_run_ollama() {
  # Explicit model flag (overrides ANTHROPIC_MODEL)
  claude --model qwen2.5-coder:32b "$@"
}
```

**Why `--model` Flag Is Required**:
- Claude Code CLI defaults to Anthropic's model names (`claude-3-5-sonnet`)
- Ollama models use different naming (`qwen2.5-coder:32b`)
- `--model` flag overrides the default model selection

**Model Availability Check**:
```bash
_check_ollama() {
  # 1. Port check
  if ! _check_port "localhost" "11434"; then
    _log "ERROR" "Ollama not running"
    return 1
  fi

  # 2. Model availability
  if ! ollama list 2>/dev/null | grep -q "qwen2.5-coder"; then
    _log "ERROR" "Model qwen2.5-coder not found"
    echo "  Pull it with: ollama pull qwen2.5-coder:32b"
    return 1
  fi

  _log "INFO" "Ollama health: OK"
}
```

**Ollama Server Lifecycle**:
```bash
# Start Ollama server
ollama serve &

# Pull models (one-time setup)
ollama pull qwen2.5-coder:32b
ollama pull deepseek-coder:33b

# List available models
ollama list

# Use with cc-copilot-bridge
cco  # Automatically uses qwen2.5-coder:32b
```

---

## 6. Data Flow Diagrams

### 6.1 Complete Request Flow (Copilot Provider)

```
┌─────────────────────────────────────────────────────────────────┐
│ USER LAYER                                                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                   $ ccc-gpt [prompt]
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ ALIAS EXPANSION                                                 │
│ ccc-gpt → COPILOT_MODEL=gpt-4.1 claude-switch copilot          │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ CLAUDE-SWITCH ORCHESTRATOR                                      │
│                                                                 │
│ 1. Parse mode: "copilot"                                       │
│ 2. Extract model: COPILOT_MODEL="gpt-4.1"                     │
│ 3. Health check: _check_copilot()                              │
│    └─> nc -z localhost 4141 → [OK]                             │
│ 4. Get MCP flags: _get_mcp_flags("gpt-4.1")                   │
│    └─> --mcp-config ~/.claude/mcp-profiles/generated/gpt.json │
│ 5. Get system prompt: _get_system_prompt("gpt-4.1")           │
│    └─> --append-system-prompt "You are GPT-4.1..."            │
│ 6. Set environment:                                             │
│    └─> ANTHROPIC_BASE_URL="http://localhost:4141"             │
│    └─> ANTHROPIC_MODEL="gpt-4.1"                              │
│ 7. Build command:                                               │
│    └─> claude --mcp-config gpt.json \                         │
│        --append-system-prompt "..." [prompt]                   │
│ 8. Execute: eval "${claude_cmd}"                               │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ CLAUDE CODE CLI                                                 │
│                                                                 │
│ 1. Load MCP config: gpt.json                                    │
│ 2. Initialize MCP servers (9/10, grepai excluded)              │
│ 3. Inject system prompt                                         │
│ 4. Construct API request:                                       │
│    POST http://localhost:4141/v1/messages                       │
│    {                                                            │
│      "model": "gpt-4.1",                                        │
│      "messages": [                                              │
│        {"role": "user", "content": "[prompt]"}                  │
│      ]                                                          │
│    }                                                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ COPILOT-API PROXY                                               │
│                                                                 │
│ 1. Receive request on :4141                                     │
│ 2. Extract model: "gpt-4.1"                                     │
│ 3. Load GitHub token: ~/.copilot-api/config.json               │
│ 4. Transform request to Copilot API format:                     │
│    POST https://api.githubcopilot.com/chat/completions         │
│    Authorization: Bearer <github-token>                         │
│    { "model": "gpt-4.1-turbo", "messages": [...] }             │
│ 5. Stream response back to Claude Code CLI                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ GITHUB COPILOT BACKEND                                          │
│                                                                 │
│ 1. Validate GitHub Copilot subscription                         │
│ 2. Route to model backend: GPT-4.1 (OpenAI)                    │
│ 3. Generate response                                            │
│ 4. Stream tokens back                                           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                        [Response]
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│ USER TERMINAL                                                   │
│                                                                 │
│ [Streaming output from GPT-4.1]                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 MCP Profile Selection Flow

```
Model Input
    │
    ├─ "claude-sonnet-4.5" ──> [No profile needed]
    │                           └─> Use default config
    │                               All MCP servers loaded
    │
    ├─ "gpt-4.1" ──────────────> [GPT profile needed]
    │                           │
    │                           ├─ Check: ~/.claude/mcp-profiles/generated/gpt.json
    │                           │   └─> [EXISTS]
    │                           │       └─> Validate JSON
    │                           │           └─> [VALID]
    │                           │               └─> Return: --mcp-config gpt.json
    │                           │
    │                           └─> Load gpt.json
    │                               ├─ Exclude: grepai
    │                               └─ Load: 9/10 MCP servers
    │
    └─ "gemini-2.5-pro" ───────> [Gemini profile needed]
                                │
                                └─> Similar flow to GPT
                                    Return: --mcp-config gemini.json
```

### 6.3 Session Lifecycle

```
Terminal Command
    │
    ├─> claude-switch copilot
    │       │
    │       ├─> _check_copilot() ──> [PASS] ──┐
    │       │                                  │
    │       │                     [FAIL] ──> ERROR + Exit
    │       │                                  │
    │       ├─> _get_mcp_flags() <────────────┘
    │       │       │
    │       │       └─> Return: "--mcp-config gpt.json"
    │       │
    │       ├─> _get_system_prompt()
    │       │       │
    │       │       └─> Return: "--append-system-prompt '...'"
    │       │
    │       ├─> export ANTHROPIC_BASE_URL="..."
    │       ├─> export ANTHROPIC_MODEL="..."
    │       │
    │       ├─> _session_start("copilot:gpt-4.1")
    │       │       │
    │       │       ├─> CLAUDE_SESSION_START=$(date +%s)
    │       │       ├─> CLAUDE_SESSION_MODE="copilot:gpt-4.1"
    │       │       └─> _log "Session started: ..."
    │       │
    │       ├─> eval "claude --mcp-config ... --append-system-prompt ..."
    │       │       │
    │       │       └─> [USER INTERACTION]
    │       │               │
    │       │               └─> [EXIT with code]
    │       │
    │       └─> _session_end($exit_code)
    │               │
    │               ├─> Calculate duration
    │               └─> _log "Session ended: duration=... exit=..."
    │
    └─> Propagate exit code to shell
```

---

## 7. Extension Points

### 7.1 Adding New Providers

**Steps to add a new provider** (e.g., Vertex AI):

1. **Add health check function**:
```bash
_check_vertex() {
  if ! _check_port "localhost" "8080"; then
    _log "ERROR" "Vertex AI proxy not running on :8080"
    echo "  Start it with: vertex-proxy start"
    return 1
  fi
  _log "INFO" "Vertex AI health: OK"
}
```

2. **Add provider function**:
```bash
_run_vertex() {
  _check_vertex || return 1

  local model="${VERTEX_MODEL:-gemini-pro}"

  _log "INFO" "Provider: Vertex AI - Model: ${model}"
  echo -e "${PURPLE}━━━ Claude Code [Vertex AI: ${model}] ━━━${NC}"

  export ANTHROPIC_BASE_URL="http://localhost:8080"
  export ANTHROPIC_AUTH_TOKEN="vertex"
  export ANTHROPIC_MODEL="${model}"

  _session_start "vertex:${model}"
  claude "$@"
  local rc=$?
  _session_end $rc
  return $rc
}
```

3. **Add to main() routing**:
```bash
main() {
  case "${mode}" in
    d|direct)  _run_direct "$@" ;;
    c|copilot) _run_copilot "$@" ;;
    o|ollama)  _run_ollama "$@" ;;
    v|vertex)  _run_vertex "$@" ;;   # NEW
    s|status)  _show_status ;;
  esac
}
```

4. **Add alias to install.sh**:
```bash
alias ccv='claude-switch vertex'
alias ccv-gemini='VERTEX_MODEL=gemini-2.5-pro claude-switch vertex'
```

### 7.2 Adding MCP Exclusions

**To exclude a new MCP server for a model**:

1. **Update excludes.yaml**:
```yaml
gpt:
  - grepai
  - new-problematic-server  # Add here

gemini:
  - grepai
  - new-problematic-server
```

2. **Update generate.sh** (if needed):
```bash
# The script automatically reads excludes.yaml,
# but you can add a new profile:
generate_profile "grok" "grepai,new-server"
```

3. **Regenerate profiles**:
```bash
~/.claude/mcp-profiles/generate.sh
```

4. **Update _get_mcp_flags()** (if new model family):
```bash
_get_mcp_flags() {
  case "${model}" in
    gpt-*)    config_file="${mcp_dir}/gpt.json" ;;
    gemini-*) config_file="${mcp_dir}/gemini.json" ;;
    grok-*)   config_file="${mcp_dir}/grok.json" ;;  # NEW
    claude-*|*) return 0 ;;
  esac
}
```

### 7.3 Custom System Prompts

**To add a custom system prompt**:

1. **Create prompt file**:
```bash
cat > ~/.claude/mcp-profiles/prompts/custom-gpt.txt << 'EOF'
You are GPT-4.1, specialized in [domain].

Custom instructions:
- [Instruction 1]
- [Instruction 2]
EOF
```

2. **Override prompt in alias**:
```bash
alias ccc-custom='CUSTOM_PROMPT=~/.claude/mcp-profiles/prompts/custom-gpt.txt ccc-gpt'
```

3. **Or modify _get_system_prompt()**:
```bash
_get_system_prompt() {
  # Allow override via env var
  if [[ -n "${CUSTOM_PROMPT}" && -f "${CUSTOM_PROMPT}" ]]; then
    echo "--append-system-prompt \"$(cat "${CUSTOM_PROMPT}")\""
    return 0
  fi

  # ... existing logic
}
```

### 7.4 Logging Enhancements

**To add structured logging** (e.g., JSON format):

```bash
_log_json() {
  local level="$1" msg="$2"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq -n \
    --arg ts "${timestamp}" \
    --arg lvl "${level}" \
    --arg msg "${msg}" \
    --arg mode "${CLAUDE_SESSION_MODE:-unknown}" \
    --arg pid "$$" \
    '{timestamp: $ts, level: $lvl, message: $msg, mode: $mode, pid: $pid}' \
    >> "${LOG_FILE}.json"
}
```

**To add metrics collection**:

```bash
_session_end() {
  local exit_code="$1"
  local duration=$(($(date +%s) - ${CLAUDE_SESSION_START:-0}))

  # Existing logging
  _log "INFO" "Session ended: duration=${duration}s exit=${exit_code}"

  # Metrics export (optional)
  if command -v curl &> /dev/null && [[ -n "${METRICS_ENDPOINT}" ]]; then
    curl -s -X POST "${METRICS_ENDPOINT}/sessions" \
      -H "Content-Type: application/json" \
      -d "{\"mode\":\"${CLAUDE_SESSION_MODE}\",\"duration\":${duration},\"exit_code\":${exit_code}}" \
      &> /dev/null &
  fi
}
```

### 7.5 MCP Profile Diagnostics

**To add schema validation** (future enhancement):

```bash
_diagnose_mcp_schemas() {
  local base_config="${HOME}/.claude/claude_desktop_config.json"

  echo "Diagnosing MCP schemas for GPT-4.1 compatibility..."

  jq -r '.mcpServers | keys[]' "${base_config}" | while read -r server; do
    echo "Checking: ${server}"

    # Extract schema for each tool
    # (Would require MCP server introspection API)

    # Validate against GPT-4.1 rules:
    # - All object schemas have "properties"
    # - All schemas have "additionalProperties: false"
    # - No oneOf/anyOf/allOf at root
  done
}
```

---

## Appendix: Reference Tables

### A.1 Environment Variables

| Variable | Purpose | Set By | Used By |
|----------|---------|--------|---------|
| `ANTHROPIC_API_KEY` | Anthropic authentication | User | claude CLI (direct mode) |
| `ANTHROPIC_BASE_URL` | API endpoint override | claude-switch | claude CLI |
| `ANTHROPIC_AUTH_TOKEN` | Proxy authentication | claude-switch | claude CLI |
| `ANTHROPIC_MODEL` | Model selection | claude-switch | copilot-api |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Fallback model | claude-switch | claude CLI |
| `DISABLE_NON_ESSENTIAL_MODEL_CALLS` | Traffic optimization | claude-switch | claude CLI |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Further optimization | claude-switch | claude CLI |
| `COPILOT_MODEL` | Override default model | User/Alias | claude-switch |
| `OLLAMA_MODEL` | Override default Ollama model | User/Alias | claude-switch |
| `CLAUDE_SESSION_START` | Session start timestamp | claude-switch | claude-switch |
| `CLAUDE_SESSION_MODE` | Current provider mode | claude-switch | claude-switch |

### A.2 File Locations

| File | Purpose | Format | Generated |
|------|---------|--------|-----------|
| `~/bin/claude-switch` | Main script | Bash | No (installed) |
| `~/.claude/claude-switch.log` | Session logs | Text | Yes (runtime) |
| `~/.claude/claude_desktop_config.json` | Base MCP config | JSON | No (user-created) |
| `~/.claude/mcp-profiles/excludes.yaml` | Exclusion rules | YAML | No (user-configured) |
| `~/.claude/mcp-profiles/generate.sh` | Profile generator | Bash | No (installed) |
| `~/.claude/mcp-profiles/generated/gpt.json` | GPT MCP profile | JSON | Yes (generated) |
| `~/.claude/mcp-profiles/generated/gemini.json` | Gemini MCP profile | JSON | Yes (generated) |
| `~/.claude/mcp-profiles/prompts/gpt-4.1.txt` | GPT identity prompt | Text | No (user-configured) |
| `~/.claude/mcp-profiles/prompts/gemini.txt` | Gemini identity prompt | Text | No (user-configured) |

### A.3 Exit Codes

| Code | Meaning | Cause |
|------|---------|-------|
| 0 | Success | Normal completion |
| 1 | General error | Health check failure, invalid config, etc. |
| 2 | Usage error | Invalid command-line arguments |
| 126 | Command not executable | `claude` CLI not found or not executable |
| 127 | Command not found | Missing dependency (nc, jq, ollama, etc.) |
| 130 | Interrupted (Ctrl+C) | User termination |

### A.4 Command Reference

| Command | Alias | Provider | Default Model |
|---------|-------|----------|---------------|
| `claude-switch direct` | `ccd` | Anthropic | claude-sonnet-4.5 |
| `claude-switch copilot` | `ccc` | Copilot | claude-sonnet-4.5 |
| `claude-switch ollama` | `cco` | Ollama | qwen2.5-coder:32b |
| `claude-switch status` | `ccs` | N/A | N/A |
| N/A | `ccc-opus` | Copilot | claude-opus-4.5 |
| N/A | `ccc-sonnet` | Copilot | claude-sonnet-4.5 |
| N/A | `ccc-haiku` | Copilot | claude-haiku-4.5 |
| N/A | `ccc-gpt` | Copilot | gpt-5.2-codex |

---

## Conclusion

cc-copilot-bridge implements a **zero-configuration routing layer** that enables seamless switching between AI providers while maintaining full compatibility with Claude Code CLI's feature set.

**Key Architectural Patterns**:
- **Fail-fast validation**: Pre-flight health checks prevent wasted API calls
- **Environment variable manipulation**: Dynamic configuration without file editing
- **Model-specific profiles**: Automatic compatibility handling for strict validators
- **Transparent logging**: Full audit trail for debugging and analytics
- **Extension-friendly design**: Clear extension points for new providers/models

**Production Considerations**:
- Session logs rotate automatically (not implemented yet - future enhancement)
- MCP profiles regenerate on base config changes (manual currently)
- Health checks timeout appropriately (2s default, configurable)
- Error messages provide actionable remediation steps

**Future Architecture Enhancements**:
- MCP schema validation and auto-fixing proxy
- Metrics collection and dashboard
- Provider load balancing (round-robin, least-cost)
- Auto-regeneration of MCP profiles on base config changes
- Session replay for debugging

---

**Related Documentation**:
- [Quick Start Guide](../QUICKSTART.md) - Get started in 5 minutes
- [MCP Profiles System](MCP-PROFILES.md) - Deep-dive on model compatibility
- [Model Switching Guide](MODEL-SWITCHING.md) - Choosing the right model
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions
- [Command Reference](COMMANDS.md) - Complete command documentation

---

**Maintenance Notes**:
- This document reflects cc-copilot-bridge v1.2.0
- Architecture unchanged since v1.0.0 (MCP Profiles added in v1.1.0)
- Next major version (v2.0.0) will introduce automatic MCP schema fixing
