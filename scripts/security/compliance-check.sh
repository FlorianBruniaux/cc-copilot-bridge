#!/bin/bash
# Compliance verification script for Claude Code
# Usage: ./compliance-check.sh

set -euo pipefail

LOG_FILE="${HOME}/.claude/claude-switch.log"
CONFIG_FILE="${HOME}/.claude/claude_desktop_config.json"

echo "=== Claude Code Compliance Check ==="
echo "Date: $(date)"
echo ""

# 1. Check provider usage
echo "Provider Usage History:"
if [[ -f "${LOG_FILE}" ]]; then
    ANTHROPIC_COUNT=$(grep -c "Provider: Anthropic Direct" "${LOG_FILE}" 2>/dev/null || echo "0")
    COPILOT_COUNT=$(grep -c "Provider: GitHub Copilot" "${LOG_FILE}" 2>/dev/null || echo "0")
    OLLAMA_COUNT=$(grep -c "Provider: Ollama Local" "${LOG_FILE}" 2>/dev/null || echo "0")

    echo "  - Anthropic Direct: ${ANTHROPIC_COUNT} sessions"
    echo "  - GitHub Copilot:   ${COPILOT_COUNT} sessions"
    echo "  - Ollama Local:     ${OLLAMA_COUNT} sessions"
else
    echo "  (log file not found)"
    ANTHROPIC_COUNT=0
    COPILOT_COUNT=0
    OLLAMA_COUNT=0
fi
echo ""

# 2. Check for .claudeignore
echo ".claudeignore Configuration:"
CLAUDEIGNORE_SCORE=0
if [[ -f .claudeignore ]]; then
    echo "  ✓ Project .claudeignore exists"
    CLAUDEIGNORE_SCORE=10

    # Check for essential patterns
    if grep -q "\.env" .claudeignore; then
        echo "  ✓ Excludes .env files"
    else
        echo "  ⚠ Missing: .env exclusion"
    fi

    if grep -qE '\*\.(key|pem)' .claudeignore; then
        echo "  ✓ Excludes key files"
    else
        echo "  ⚠ Missing: key file exclusion"
    fi

    if grep -q "secret" .claudeignore; then
        echo "  ✓ Excludes secrets"
    else
        echo "  ⚠ Missing: secrets exclusion"
    fi
elif [[ -f "${HOME}/.claudeignore" ]]; then
    echo "  ✓ Global .claudeignore exists"
    CLAUDEIGNORE_SCORE=5
else
    echo "  ✗ No .claudeignore found (project or global)"
    echo "    Create one with: cat > .claudeignore << 'EOF'"
    echo "    .env"
    echo "    .env.*"
    echo "    *.key"
    echo "    *.pem"
    echo "    secrets.json"
    echo "    EOF"
fi
echo ""

# 3. Check for secrets in logs
echo "Secrets Detection in Logs:"
SECRETS_SCORE=20
if [[ -f "${LOG_FILE}" ]]; then
    if grep -iE '(password|secret|api_key|token|credential)' "${LOG_FILE}" >/dev/null 2>&1; then
        echo "  ✗ Potential secrets found in logs"
        echo "    RECOMMENDATION: Review log file and rotate any exposed credentials"
        SECRETS_SCORE=0
    else
        echo "  ✓ No obvious secrets detected"
    fi
else
    echo "  (log file not found)"
fi
echo ""

# 4. Check MCP server configuration
echo "MCP Server Configuration:"
MCP_SCORE=10
if [[ -f "${CONFIG_FILE}" ]]; then
    if command -v jq &> /dev/null; then
        SERVER_COUNT=$(jq -r '.mcpServers | keys | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")
        echo "  Active MCP servers: ${SERVER_COUNT}"

        # List servers with risk assessment
        jq -r '.mcpServers | keys[]' "${CONFIG_FILE}" 2>/dev/null | while read server; do
            case "${server}" in
                filesystem|bash|sequential-thinking|memory)
                    echo "    - ${server} (low risk)"
                    ;;
                web-search|browser|context7)
                    echo "    - ${server} (medium risk - external network)"
                    ;;
                *)
                    echo "    - ${server} (verify manually)"
                    ;;
            esac
        done
    else
        echo "  (jq not available for detailed analysis)"
    fi
else
    echo "  (config not found)"
    MCP_SCORE=0
fi
echo ""

# 5. Check network access
echo "Network Configuration:"
if [[ -n "${HTTPS_PROXY:-}" ]]; then
    echo "  - HTTPS Proxy: ${HTTPS_PROXY}"
else
    echo "  - Direct internet access (no proxy)"
fi

if [[ -n "${NO_PROXY:-}" ]]; then
    echo "  - NO_PROXY: ${NO_PROXY}"
fi
echo ""

# 6. Privacy-preserving usage
echo "Privacy-Preserving Usage:"
PRIVACY_SCORE=0
TOTAL_SESSIONS=$((ANTHROPIC_COUNT + COPILOT_COUNT + OLLAMA_COUNT))

if [[ ${TOTAL_SESSIONS} -gt 0 ]]; then
    OLLAMA_PERCENTAGE=$((OLLAMA_COUNT * 100 / TOTAL_SESSIONS))

    if [[ ${OLLAMA_PERCENTAGE} -ge 50 ]]; then
        echo "  ✓ High Ollama usage (${OLLAMA_PERCENTAGE}% - excellent privacy)"
        PRIVACY_SCORE=20
    elif [[ ${OLLAMA_PERCENTAGE} -ge 20 ]]; then
        echo "  ✓ Moderate Ollama usage (${OLLAMA_PERCENTAGE}% - good privacy)"
        PRIVACY_SCORE=15
    elif [[ ${OLLAMA_COUNT} -gt 0 ]]; then
        echo "  ⚠ Low Ollama usage (${OLLAMA_PERCENTAGE}% - consider using for sensitive code)"
        PRIVACY_SCORE=10
    else
        echo "  ⚠ No Ollama usage detected"
        echo "    RECOMMENDATION: Use Ollama for sensitive/proprietary code"
        PRIVACY_SCORE=0
    fi
else
    echo "  (insufficient data)"
    PRIVACY_SCORE=10
fi
echo ""

# 7. Data retention
echo "Data Retention:"
RETENTION_SCORE=10
if [[ -f "${LOG_FILE}" ]]; then
    LOG_AGE_DAYS=$(( ($(date +%s) - $(stat -f %m "${LOG_FILE}" 2>/dev/null || stat -c %Y "${LOG_FILE}" 2>/dev/null || echo $(date +%s))) / 86400 ))
    echo "  Log file age: ${LOG_AGE_DAYS} days"

    if [[ ${LOG_AGE_DAYS} -gt 90 ]]; then
        echo "  ⚠ Log file older than 90 days - consider rotation"
        RETENTION_SCORE=5
    fi
fi

if [[ -d "${HOME}/.claude/.session" ]]; then
    SESSION_COUNT=$(find "${HOME}/.claude/.session" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  Active sessions: ${SESSION_COUNT}"

    if [[ ${SESSION_COUNT} -gt 10 ]]; then
        echo "  ⚠ High session count - consider cleanup"
    fi
fi
echo ""

# 8. Calculate compliance score
COMPLIANCE_SCORE=$((CLAUDEIGNORE_SCORE + SECRETS_SCORE + MCP_SCORE + PRIVACY_SCORE + RETENTION_SCORE))
MAX_SCORE=70

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Compliance Score: ${COMPLIANCE_SCORE}/${MAX_SCORE} ($((COMPLIANCE_SCORE * 100 / MAX_SCORE))%)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ ${COMPLIANCE_SCORE} -ge 60 ]]; then
    echo "✓ PASS: Good compliance posture"
elif [[ ${COMPLIANCE_SCORE} -ge 40 ]]; then
    echo "⚠ FAIR: Compliance issues detected - review recommendations"
else
    echo "✗ FAIL: Significant compliance issues - immediate action required"
fi
echo ""

# 9. Recommendations
echo "Recommendations:"
RECS=0

if [[ ${CLAUDEIGNORE_SCORE} -lt 10 ]]; then
    echo "  ${RECS}. Create .claudeignore to exclude secrets and sensitive files"
    RECS=$((RECS + 1))
fi

if [[ ${SECRETS_SCORE} -eq 0 ]]; then
    echo "  ${RECS}. Review and clean logs - potential secrets detected"
    RECS=$((RECS + 1))
fi

if [[ ${PRIVACY_SCORE} -lt 15 ]]; then
    echo "  ${RECS}. Increase Ollama usage for sensitive/proprietary code"
    RECS=$((RECS + 1))
fi

if [[ ${RETENTION_SCORE} -lt 10 ]]; then
    echo "  ${RECS}. Rotate logs and clean old sessions"
    RECS=$((RECS + 1))
fi

if [[ -f "${LOG_FILE}" ]] && [[ $(du -k "${LOG_FILE}" | cut -f1) -gt 10240 ]]; then
    echo "  ${RECS}. Log file exceeds 10MB - rotate with: tail -1000 ~/.claude/claude-switch.log > ~/.claude/claude-switch.log.tmp && mv ~/.claude/claude-switch.log.tmp ~/.claude/claude-switch.log"
    RECS=$((RECS + 1))
fi

if [[ ${RECS} -eq 0 ]]; then
    echo "  ✓ No immediate recommendations"
fi
echo ""

echo "=== Compliance Check Complete ==="
