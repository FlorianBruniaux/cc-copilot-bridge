#!/usr/bin/env bash
set -euo pipefail

# analyze-copilot-logs.sh - Analyze copilot-api logs for Gemini issues
# Usage: ./analyze-copilot-logs.sh <log_file>

LOG_FILE="${1:-}"

if [[ -z "$LOG_FILE" ]] || [[ ! -f "$LOG_FILE" ]]; then
    echo "Usage: $0 <log_file>"
    echo "Example: $0 debug-gemini/copilot-api-verbose.log"
    exit 1
fi

OUTPUT_DIR="$(dirname "$LOG_FILE")"
ANALYSIS_FILE="$OUTPUT_DIR/log-analysis.md"

echo "Analyzing: $LOG_FILE"
echo "Output: $ANALYSIS_FILE"

{
    echo "# Copilot-API Log Analysis"
    echo ""
    echo "**Source**: \`$(basename "$LOG_FILE")\`"
    echo "**Date**: $(date)"
    echo ""

    # HTTP Errors
    echo "## HTTP Errors"
    echo ""
    if grep -E "(400|401|403|500)" "$LOG_FILE" > /dev/null 2>&1; then
        echo "\`\`\`"
        grep -E "(400|401|403|500)" "$LOG_FILE" | head -20
        echo "\`\`\`"
    else
        echo "✅ No HTTP errors found"
    fi
    echo ""

    # Gemini-specific errors
    echo "## Gemini-Specific Errors"
    echo ""
    if grep -iE "(model_not_supported|INVALID_ARGUMENT|RESOURCE_EXHAUSTED)" "$LOG_FILE" > /dev/null 2>&1; then
        echo "\`\`\`"
        grep -iE "(model_not_supported|INVALID_ARGUMENT|RESOURCE_EXHAUSTED)" "$LOG_FILE" | head -20
        echo "\`\`\`"
    else
        echo "✅ No Gemini-specific errors found"
    fi
    echo ""

    # Tool calling
    echo "## Tool Calling Activity"
    echo ""
    local tool_count=$(grep -c '"tools"' "$LOG_FILE" 2>/dev/null || echo "0")
    echo "- Tool definitions sent: **$tool_count** times"
    echo ""

    if [[ $tool_count -gt 0 ]]; then
        echo "### Sample Tool Definitions"
        echo "\`\`\`json"
        grep -A 10 '"tools"' "$LOG_FILE" | head -50
        echo "\`\`\`"
    fi
    echo ""

    # Request patterns
    echo "## Request Patterns"
    echo ""
    local anthropic_requests=$(grep -c "POST /v1/messages" "$LOG_FILE" 2>/dev/null || echo "0")
    local openai_requests=$(grep -c "POST /chat/completions" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "- Anthropic format requests: **$anthropic_requests**"
    echo "- OpenAI format requests: **$openai_requests**"
    echo ""

    # Model identifiers
    echo "## Models Used"
    echo ""
    echo "\`\`\`"
    grep -oE '"model":\s*"[^"]+"' "$LOG_FILE" | sort -u || echo "No model identifiers found"
    echo "\`\`\`"
    echo ""

    # Response errors
    echo "## Response Errors"
    echo ""
    if grep -i "error" "$LOG_FILE" > /dev/null 2>&1; then
        echo "### Error Messages"
        echo "\`\`\`"
        grep -i "error" "$LOG_FILE" | grep -v "no error" | head -30
        echo "\`\`\`"
    else
        echo "✅ No error messages found"
    fi
    echo ""

    # Timeouts
    echo "## Timeouts & Latency"
    echo ""
    if grep -iE "(timeout|timed out|DEADLINE_EXCEEDED)" "$LOG_FILE" > /dev/null 2>&1; then
        echo "⚠️ Timeout issues detected:"
        echo "\`\`\`"
        grep -iE "(timeout|timed out|DEADLINE_EXCEEDED)" "$LOG_FILE" | head -10
        echo "\`\`\`"
    else
        echo "✅ No timeout issues"
    fi
    echo ""

    # Summary statistics
    echo "## Summary Statistics"
    echo ""
    echo "| Metric | Count |"
    echo "|--------|-------|"
    echo "| Total lines | $(wc -l < "$LOG_FILE") |"
    echo "| HTTP 4xx errors | $(grep -c "40[0-9]" "$LOG_FILE" 2>/dev/null || echo "0") |"
    echo "| HTTP 5xx errors | $(grep -c "50[0-9]" "$LOG_FILE" 2>/dev/null || echo "0") |"
    echo "| Tool calls | $(grep -c '"tools"' "$LOG_FILE" 2>/dev/null || echo "0") |"
    echo "| Error keywords | $(grep -ci "error" "$LOG_FILE" 2>/dev/null || echo "0") |"
    echo ""

} > "$ANALYSIS_FILE"

echo "✅ Analysis complete: $ANALYSIS_FILE"
cat "$ANALYSIS_FILE"
