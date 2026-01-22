#!/bin/bash
# Weekly security audit for Claude Code usage
# Usage: ./audit-weekly.sh

set -euo pipefail

LOG_FILE="${HOME}/.claude/claude-switch.log"
CONFIG_FILE="${HOME}/.claude/claude_desktop_config.json"

echo "=== Claude Code Weekly Security Audit ==="
echo "Week of: $(date)"
echo ""

# 1. Provider usage statistics
echo "Provider Usage Statistics (all time):"
if [[ -f "${LOG_FILE}" ]]; then
    ANTHROPIC_COUNT=$(grep -c "Provider: Anthropic Direct" "${LOG_FILE}" 2>/dev/null || echo "0")
    COPILOT_COUNT=$(grep -c "Provider: GitHub Copilot" "${LOG_FILE}" 2>/dev/null || echo "0")
    OLLAMA_COUNT=$(grep -c "Provider: Ollama Local" "${LOG_FILE}" 2>/dev/null || echo "0")

    echo "  Anthropic Direct: ${ANTHROPIC_COUNT} sessions"
    echo "  GitHub Copilot:   ${COPILOT_COUNT} sessions"
    echo "  Ollama Local:     ${OLLAMA_COUNT} sessions"

    TOTAL=$((ANTHROPIC_COUNT + COPILOT_COUNT + OLLAMA_COUNT))
    if [[ ${TOTAL} -gt 0 ]]; then
        echo ""
        echo "  Distribution:"
        echo "    Anthropic: $((ANTHROPIC_COUNT * 100 / TOTAL))%"
        echo "    Copilot:   $((COPILOT_COUNT * 100 / TOTAL))%"
        echo "    Ollama:    $((OLLAMA_COUNT * 100 / TOTAL))%"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 2. Session duration analysis
echo "Session Duration Analysis:"
if [[ -f "${LOG_FILE}" ]]; then
    if grep -q "Session ended" "${LOG_FILE}"; then
        AVG_DURATION=$(grep "Session ended" "${LOG_FILE}" | \
            grep -oE 'duration=[0-9]+m' | \
            cut -d'=' -f2 | cut -d'm' -f1 | \
            awk '{sum+=$1; count++} END {if(count>0) printf "%.1f", sum/count; else print "0"}')
        echo "  Average session duration: ${AVG_DURATION} minutes"

        TOTAL_SESSIONS=$(grep -c "Session ended" "${LOG_FILE}" 2>/dev/null || echo "0")
        echo "  Total sessions: ${TOTAL_SESSIONS}"
    else
        echo "  (no completed sessions found)"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 3. Error analysis
echo "Recent Errors (last 10):"
if [[ -f "${LOG_FILE}" ]]; then
    ERROR_COUNT=$(grep -c "\[ERROR\]" "${LOG_FILE}" 2>/dev/null || echo "0")
    echo "  Total errors: ${ERROR_COUNT}"
    if [[ ${ERROR_COUNT} -gt 0 ]]; then
        echo ""
        grep "\[ERROR\]" "${LOG_FILE}" | tail -10 | sed 's/^/    /'
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 4. MCP profile usage
echo "MCP Profile Usage:"
if [[ -f "${LOG_FILE}" ]]; then
    if grep -q "Using restricted MCP profile" "${LOG_FILE}"; then
        grep "Using restricted MCP profile" "${LOG_FILE}" | tail -5 | sed 's/^/  /'
    else
        echo "  (no restricted profiles used)"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 5. Model usage
echo "Model Usage (Copilot):"
if [[ -f "${LOG_FILE}" ]]; then
    if grep -q "Model:" "${LOG_FILE}"; then
        grep -oE 'Model: [a-z0-9\.\-]+' "${LOG_FILE}" | sort | uniq -c | sort -rn | sed 's/^/  /'
    else
        echo "  (no model information found)"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 6. Security recommendations
echo "Security Recommendations:"
RECOMMENDATIONS=0

if [[ -f "${LOG_FILE}" ]]; then
    LOG_KB=$(du -k "${LOG_FILE}" | cut -f1)
    if [[ ${LOG_KB} -gt 10240 ]]; then
        echo "  - Rotate log file (exceeds 10MB)"
        RECOMMENDATIONS=$((RECOMMENDATIONS + 1))
    fi

    if ! grep -q "Provider: Ollama" "${LOG_FILE}"; then
        echo "  - Consider using Ollama for sensitive projects"
        RECOMMENDATIONS=$((RECOMMENDATIONS + 1))
    fi

    if grep -iE '(password|secret|api_key)' "${LOG_FILE}" >/dev/null 2>&1; then
        echo "  - WARNING: Potential secrets detected in logs"
        RECOMMENDATIONS=$((RECOMMENDATIONS + 1))
    fi
fi

if [[ ! -f ".claudeignore" ]] && [[ ! -f "${HOME}/.claudeignore" ]]; then
    echo "  - Create .claudeignore to exclude secrets"
    RECOMMENDATIONS=$((RECOMMENDATIONS + 1))
fi

if [[ ${RECOMMENDATIONS} -eq 0 ]]; then
    echo "  ✓ No immediate recommendations"
fi
echo ""

# 7. Disk usage trend
echo "Disk Usage:"
if [[ -d "${HOME}/.claude" ]]; then
    echo "  ~/.claude: $(du -sh "${HOME}/.claude" | cut -f1)"
    echo "  Log file:  $(du -sh "${LOG_FILE}" 2>/dev/null | cut -f1 || echo "N/A")"
    echo "  Sessions:  $(du -sh "${HOME}/.claude/.session" 2>/dev/null | cut -f1 || echo "N/A")"
fi
echo ""

echo "=== Weekly Audit Complete ==="
