#!/usr/bin/env bash
# Unified copilot-api fork launcher (EXPERIMENTAL)
# Combines PR #167 (Gemini 3 thinking) + PR #170 (Codex responses)
# Source: caozhiyuan/copilot-api branch 'all'
#
# ⚠️  EXPERIMENTAL STATUS:
# - Codex models (/responses): ✅ Tested, working
# - Gemini 3 thinking: ⚠️  UNTESTED - may or may not improve agentic mode
#
# What PR #167 adds:
# - Support for Gemini 3 "thinking" response fields (thought_signature, reasoning_text)
# - This is NOT the same as fixing tool calling format translation
# - The core issue (Claude → OpenAI → Gemini format) may still exist
#
# Models that SHOULD work:
# - Codex: gpt-5.2-codex, gpt-5.1-codex, gpt-5.1-codex-mini, gpt-5.1-codex-max
# - Standard: All Claude, GPT-4.1, GPT-5, Gemini 2.5, etc.
#
# Models to TEST (uncertain):
# - Gemini 3: gemini-3-flash-preview, gemini-3-pro-preview
#
# Usage:
#   ./launch-unified-fork.sh          # Start the fork
#   ./launch-unified-fork.sh --update # Force update before starting

set -euo pipefail

FORK_DIR="${HOME}/copilot-api-unified"
FORK_REPO="https://github.com/caozhiyuan/copilot-api.git"
FORK_BRANCH="all"
PORT=4141

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

FORCE_UPDATE="${1:-}"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ${GREEN}Unified copilot-api Fork${CYAN}  ${YELLOW}[EXPERIMENTAL]${CYAN}                    ║${NC}"
echo -e "${CYAN}║  PR #167 (Gemini 3 thinking) + PR #170 (Codex /responses)    ║${NC}"
echo -e "${CYAN}║  Source: caozhiyuan/copilot-api branch 'all'                 ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  Gemini 3 agentic mode: UNTESTED - PR #167 adds thinking support,${NC}"
echo -e "${YELLOW}   but may not fix tool calling issues. Test before relying on it.${NC}"
echo ""

# Step 0: Check PRs merge status (informational)
echo -e "${YELLOW}[0/5] Checking PRs status (informational)...${NC}"

check_pr_status() {
    local pr_num=$1
    local pr_name=$2
    local status
    status=$(curl -s "https://api.github.com/repos/ericc-ch/copilot-api/pulls/${pr_num}" 2>/dev/null | grep '"merged"' | head -1 | grep -o 'true\|false' || echo "unknown")

    if [ "$status" = "true" ]; then
        echo -e "  ${GREEN}PR #${pr_num} (${pr_name}): MERGED${NC} - Fork may no longer be needed for this feature"
    elif [ "$status" = "false" ]; then
        echo -e "  ${YELLOW}PR #${pr_num} (${pr_name}): Pending${NC} - Fork required"
    else
        echo -e "  ${YELLOW}PR #${pr_num} (${pr_name}): Unknown${NC} - Network issue or rate limit"
    fi
}

check_pr_status 167 "Gemini 3 thinking"
check_pr_status 170 "Codex /responses"
echo ""

# Step 1: Check for conflicting processes
echo -e "${YELLOW}[1/5] Checking for port conflicts...${NC}"
if lsof -i :${PORT} > /dev/null 2>&1; then
    echo -e "${RED}Port ${PORT} is already in use!${NC}"
    echo ""
    echo "Current process on port ${PORT}:"
    lsof -i :${PORT} | head -5
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  1. Stop existing process: pkill -f 'copilot-api'"
    echo "  2. Or use a different port (edit PORT in this script)"
    echo ""
    read -r -p "Stop existing process and continue? (y/N) " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        pkill -f 'copilot-api' || true
        sleep 2
        echo -e "${GREEN}Process stopped${NC}"
    else
        echo -e "${RED}Aborted${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Port ${PORT} is free${NC}"
fi

# Step 2: Clone or update fork
echo -e "\n${YELLOW}[2/5] Setting up fork repository...${NC}"
if [ ! -d "$FORK_DIR" ]; then
    echo "Cloning fork from ${FORK_REPO}..."
    git clone --branch "$FORK_BRANCH" "$FORK_REPO" "$FORK_DIR"
    echo -e "${GREEN}Fork cloned successfully${NC}"
else
    echo "Fork directory exists: ${FORK_DIR}"
    cd "$FORK_DIR"

    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    if [ "$CURRENT_BRANCH" != "$FORK_BRANCH" ]; then
        echo -e "${YELLOW}Switching to branch '${FORK_BRANCH}'...${NC}"
        git fetch origin
        git checkout "$FORK_BRANCH"
    fi

    # Update if requested or if last update was > 24h ago
    SHOULD_UPDATE=false
    if [ "$FORCE_UPDATE" = "--update" ]; then
        SHOULD_UPDATE=true
        echo "Force update requested"
    elif [ -f ".last_update" ]; then
        LAST_UPDATE=$(cat .last_update)
        NOW=$(date +%s)
        AGE=$(( NOW - LAST_UPDATE ))
        if [ $AGE -gt 86400 ]; then
            SHOULD_UPDATE=true
            echo "Last update was $(( AGE / 3600 )) hours ago, updating..."
        fi
    else
        SHOULD_UPDATE=true
    fi

    if [ "$SHOULD_UPDATE" = true ]; then
        echo "Pulling latest changes..."
        git fetch origin
        git reset --hard "origin/${FORK_BRANCH}"
        date +%s > .last_update
        echo -e "${GREEN}Fork updated${NC}"
    else
        echo -e "${GREEN}Fork is up to date${NC}"
    fi
fi

cd "$FORK_DIR"

# Step 3: Install dependencies
echo -e "\n${YELLOW}[3/5] Installing dependencies...${NC}"
if command -v bun &> /dev/null; then
    echo "Using bun..."
    bun install --frozen-lockfile 2>/dev/null || bun install
else
    echo "Using npm..."
    npm ci 2>/dev/null || npm install
fi
echo -e "${GREEN}Dependencies installed${NC}"

# Step 4: Build
echo -e "\n${YELLOW}[4/5] Building...${NC}"
if [ ! -f "dist/main.js" ] || [ "$FORCE_UPDATE" = "--update" ] || [ "${SHOULD_UPDATE:-false}" = true ]; then
    if command -v bun &> /dev/null; then
        bun run build 2>/dev/null || echo "Build step skipped (may not be needed)"
    else
        npm run build 2>/dev/null || echo "Build step skipped (may not be needed)"
    fi
    echo -e "${GREEN}Build complete${NC}"
else
    echo -e "${GREEN}Build exists, skipping${NC}"
fi

# Step 5: Start
echo -e "\n${YELLOW}[5/5] Starting copilot-api on port ${PORT}...${NC}"
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Unified Fork is starting...${NC}"
echo -e "${GREEN}  Port: ${PORT}${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Supported models:${NC}"
echo -e "  ${GREEN}GPT Codex (/responses endpoint):${NC} ✅ Tested"
echo "    - gpt-5.2-codex (latest)"
echo "    - gpt-5.1-codex, gpt-5.1-codex-mini, gpt-5.1-codex-max"
echo ""
echo -e "  ${YELLOW}Gemini 3 (with thinking):${NC} ⚠️  EXPERIMENTAL - Test required"
echo "    - gemini-3-flash-preview"
echo "    - gemini-3-pro-preview"
echo "    Note: PR #167 adds thinking support, but tool calling may still fail"
echo ""
echo -e "  ${GREEN}Standard models:${NC} ✅ Working"
echo "    - All Claude models (claude-sonnet-4.5, claude-opus-4.5, etc.)"
echo "    - All GPT models (gpt-4.1, gpt-5, gpt-5-mini, etc.)"
echo "    - gemini-2.5-pro"
echo ""
echo -e "${YELLOW}Test Gemini 3 agentic mode:${NC}"
echo "  1. ccc-gemini3 -p '1+1'              # Should work (baseline)"
echo "  2. ccc-gemini3 then 'Create test.txt' # May or may not work (agentic)"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Add bun to PATH if needed
export PATH="$HOME/.bun/bin:$PATH"

# Start with verbose logging
if command -v bun &> /dev/null; then
    exec bun run start start -v
else
    exec npm run start start -v
fi
