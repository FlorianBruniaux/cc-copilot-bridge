#!/bin/bash
# Daily security audit for Claude Code usage
# Usage: ./audit-daily.sh

set -euo pipefail

LOG_FILE="${HOME}/.claude/claude-switch.log"
CONFIG_FILE="${HOME}/.claude/claude_desktop_config.json"

echo "=== Claude Code Security Audit ==="
echo "Date: $(date)"
echo ""

# 1. Check recent provider usage
echo "Recent Provider Usage (last 10 sessions):"
if [[ -f "${LOG_FILE}" ]]; then
    tail -10 "${LOG_FILE}" | grep "Provider:" || echo "  (no provider switches found)"
else
    echo "  (log file not found)"
fi
echo ""

# 2. Check for unexpected network connections
echo "Active Network Connections:"
if command -v lsof &> /dev/null; then
    if sudo lsof -i -P 2>/dev/null | grep claude; then
        echo "✓ Claude Code is running"
    else
        echo "✓ No active connections"
    fi
else
    echo "  (lsof not available)"
fi
echo ""

# 3. Check log file size
if [[ -f "${LOG_FILE}" ]]; then
    LOG_SIZE=$(du -h "${LOG_FILE}" | cut -f1)
    LOG_KB=$(du -k "${LOG_FILE}" | cut -f1)
    echo "Log file size: ${LOG_SIZE}"
    if [[ ${LOG_KB} -gt 10240 ]]; then
        echo "⚠ WARNING: Log file exceeds 10MB, consider rotating"
    fi
else
    echo "Log file not found"
fi
echo ""

# 4. Check for secrets in recent sessions
echo "Checking for potential secrets in logs:"
if [[ -f "${LOG_FILE}" ]]; then
    if grep -iE '(password|secret|api_key|token|credential)' "${LOG_FILE}" 2>/dev/null; then
        echo "⚠ WARNING: Potential secrets found in logs!"
    else
        echo "✓ No obvious secrets detected"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 5. Check MCP configuration
echo "Active MCP Servers:"
if [[ -f "${CONFIG_FILE}" ]]; then
    if command -v jq &> /dev/null; then
        jq -r '.mcpServers | keys[]' "${CONFIG_FILE}" 2>/dev/null || echo "  (unable to parse config)"
    else
        echo "  (jq not available)"
    fi
else
    echo "  (config not found)"
fi
echo ""

# 6. Disk usage
echo "Claude Code disk usage:"
if [[ -d "${HOME}/.claude" ]]; then
    du -sh "${HOME}/.claude"
else
    echo "  (directory not found)"
fi
echo ""

# 7. Session count
echo "Session Statistics (today):"
if [[ -f "${LOG_FILE}" ]]; then
    TODAY=$(date '+%Y-%m-%d')
    SESSION_COUNT=$(grep -c "${TODAY}" "${LOG_FILE}" 2>/dev/null || echo "0")
    echo "  Total log entries today: ${SESSION_COUNT}"
fi
echo ""

echo "=== Audit Complete ==="
