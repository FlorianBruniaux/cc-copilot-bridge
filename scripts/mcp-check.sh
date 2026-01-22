#!/bin/bash
# MCP Server Compatibility Checker
# Identifies MCP servers with schema issues that cause GPT-4.1 validation errors
#
# Usage: ./mcp-check.sh [--parse-logs]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config
CONFIG_FILE="${HOME}/.claude/claude_desktop_config.json"
LOG_PATTERN="Invalid schema for function"
PARSE_LOGS=false

# Function to get known issues for a server
get_known_issue() {
  local server="$1"
  case "${server}" in
    grepai)
      echo "grepai_index_status: object schema missing properties (confirmed 2026-01-21)"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Parse args
if [[ "${1:-}" == "--parse-logs" ]]; then
  PARSE_LOGS=true
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required but not installed${NC}"
  echo "Install with: brew install jq"
  exit 1
fi

# Check if config exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo -e "${RED}Error: Claude Desktop config not found${NC}"
  echo "Expected: ${CONFIG_FILE}"
  exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}MCP Server Compatibility Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Extract server names
SERVERS=$(jq -r '.mcpServers | keys[]' "${CONFIG_FILE}")
SERVER_COUNT=$(echo "$SERVERS" | wc -l | tr -d ' ')

echo "Found ${SERVER_COUNT} MCP server(s) configured:"
echo ""

ISSUES_FOUND=0
WARNINGS=0

# Check each server
while IFS= read -r server; do
  echo -e "${BLUE}━━━ ${server} ━━━${NC}"

  # Get command and args
  COMMAND=$(jq -r ".mcpServers.\"${server}\".command" "${CONFIG_FILE}")
  ARGS=$(jq -r ".mcpServers.\"${server}\".args // [] | join(\" \")" "${CONFIG_FILE}")

  echo "Command: ${COMMAND} ${ARGS}"

  # Check if command exists
  if ! command -v "${COMMAND}" &> /dev/null; then
    echo -e "${RED}✗ Command not found: ${COMMAND}${NC}"
    echo -e "${YELLOW}  Install it or remove from config${NC}"
    ((ISSUES_FOUND++))
    echo ""
    continue
  fi

  echo -e "${GREEN}✓ Command installed${NC}"

  # Check if server has known issues
  ISSUE=$(get_known_issue "${server}")
  if [[ -n "${ISSUE}" ]]; then
    echo -e "${RED}✗ Known compatibility issue:${NC}"
    echo -e "  ${YELLOW}${ISSUE}${NC}"
    echo -e "  ${CYAN}Impact: Fails with GPT-4.1 (strict validation)${NC}"
    ((ISSUES_FOUND++))
  else
    echo -e "${GREEN}✓ No known compatibility issues${NC}"
  fi

  echo ""

done <<< "${SERVERS}"

# Parse logs if requested
if $PARSE_LOGS; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Parsing Recent Logs${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # Find recent log files
  LOG_DIR="${HOME}/.claude/logs"
  if [[ -d "${LOG_DIR}" ]]; then
    # Find logs from last 24h with MCP errors
    RECENT_ERRORS=$(find "${LOG_DIR}" -name "*.log" -mtime -1 -exec grep -l "${LOG_PATTERN}" {} \; 2>/dev/null || true)

    if [[ -n "${RECENT_ERRORS}" ]]; then
      while IFS= read -r log_file; do
        echo "Found errors in: $(basename "${log_file}")"

        # Extract error details
        grep "${LOG_PATTERN}" "${log_file}" | while IFS= read -r error_line; do
          # Try to extract function name
          if [[ "${error_line}" =~ mcp__([^_]+)__([^\']+) ]]; then
            MCP_SERVER="${BASH_REMATCH[1]}"
            MCP_FUNCTION="${BASH_REMATCH[2]}"
            echo -e "  ${RED}✗ ${MCP_SERVER}: ${MCP_FUNCTION}${NC}"
            ((WARNINGS++))
          else
            echo -e "  ${YELLOW}${error_line}${NC}"
          fi
        done
      done <<< "${RECENT_ERRORS}"
    else
      echo -e "${GREEN}✓ No MCP errors in recent logs${NC}"
    fi
  else
    echo -e "${YELLOW}⚠ Log directory not found: ${LOG_DIR}${NC}"
  fi

  echo ""
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Servers checked: ${SERVER_COUNT}"
echo "Compatibility issues: ${ISSUES_FOUND}"
echo ""

if [[ ${ISSUES_FOUND} -eq 0 ]]; then
  echo -e "${GREEN}✓ All configured MCP servers appear compatible${NC}"
  echo ""
  echo -e "${CYAN}Note: This checks for known issues only.${NC}"
  echo -e "${CYAN}Run with --parse-logs to scan for recent errors.${NC}"
  exit 0
else
  echo -e "${RED}✗ ${ISSUES_FOUND} server(s) with known compatibility issues${NC}"
  echo ""
  echo -e "${YELLOW}═══ Recommendations ═══${NC}"
  echo ""
  echo -e "${CYAN}Option 1: Use Claude models (100% MCP compatible)${NC}"
  echo "  ccc-sonnet   # Claude Sonnet 4.5"
  echo "  ccc-opus     # Claude Opus 4.5"
  echo ""
  echo -e "${CYAN}Option 2: Disable problematic MCP servers${NC}"
  echo "  Edit: ${CONFIG_FILE}"
  echo "  Remove or comment out problematic servers"
  echo ""
  echo -e "${CYAN}Option 3: Report issue to MCP server maintainer${NC}"
  echo "  Example: https://github.com/grepAI/grepai/issues"
  echo ""
  exit 1
fi
