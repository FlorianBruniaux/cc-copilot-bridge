#!/bin/bash
# Network monitoring script for Claude Code
# Usage: ./network-monitor.sh [duration_seconds]

set -euo pipefail

DURATION="${1:-60}"  # Default: 60 seconds
OUTPUT_FILE="claude-network-$(date +%Y%m%d-%H%M%S).txt"

echo "=== Claude Code Network Monitor ==="
echo "Duration: ${DURATION} seconds"
echo "Output: ${OUTPUT_FILE}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script requires root privileges for network monitoring"
    echo "Run with: sudo ./network-monitor.sh"
    exit 1
fi

# Check for required tools
if ! command -v lsof &> /dev/null; then
    echo "ERROR: lsof not found (required for network monitoring)"
    exit 1
fi

echo "Starting network monitoring..."
echo "Press Ctrl+C to stop early"
echo ""

# Create output file
cat > "${OUTPUT_FILE}" << EOF
Claude Code Network Monitoring Report
Generated: $(date)
Duration: ${DURATION} seconds
================================================================================

EOF

# Monitor function
monitor() {
    local iteration=0
    local end_time=$(($(date +%s) + DURATION))

    while [[ $(date +%s) -lt ${end_time} ]]; do
        iteration=$((iteration + 1))

        echo "Iteration ${iteration} - $(date)" >> "${OUTPUT_FILE}"
        echo "----------------------------------------" >> "${OUTPUT_FILE}"

        # Get Claude Code connections
        if lsof -i -P 2>/dev/null | grep -E "claude|copilot-api|ollama" >> "${OUTPUT_FILE}"; then
            echo "✓ Active connections detected" >> "${OUTPUT_FILE}"
        else
            echo "(no active connections)" >> "${OUTPUT_FILE}"
        fi

        echo "" >> "${OUTPUT_FILE}"

        # Show progress
        REMAINING=$((end_time - $(date +%s)))
        echo -ne "\rMonitoring... ${REMAINING} seconds remaining"

        sleep 5
    done

    echo ""
}

# Run monitoring
monitor

# Analyze results
echo "" >> "${OUTPUT_FILE}"
echo "=================================================================================" >> "${OUTPUT_FILE}"
echo "Analysis" >> "${OUTPUT_FILE}"
echo "=================================================================================" >> "${OUTPUT_FILE}"
echo "" >> "${OUTPUT_FILE}"

# Extract unique destinations
echo "Unique Destinations:" >> "${OUTPUT_FILE}"
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+|[a-z0-9\.\-]+:[0-9]+' "${OUTPUT_FILE}" | \
    grep -v "localhost:" | \
    sort | uniq >> "${OUTPUT_FILE}" 2>/dev/null || echo "(none detected)" >> "${OUTPUT_FILE}"

echo "" >> "${OUTPUT_FILE}"

# Summary
echo "Summary:" >> "${OUTPUT_FILE}"
ANTHROPIC_CONN=$(grep -c "api.anthropic.com" "${OUTPUT_FILE}" 2>/dev/null || echo "0")
COPILOT_CONN=$(grep -c "copilot-proxy\|github" "${OUTPUT_FILE}" 2>/dev/null || echo "0")
LOCALHOST_CONN=$(grep -c "localhost:4141\|localhost:11434" "${OUTPUT_FILE}" 2>/dev/null || echo "0")

echo "  - Anthropic API connections: ${ANTHROPIC_CONN}" >> "${OUTPUT_FILE}"
echo "  - GitHub Copilot connections: ${COPILOT_CONN}" >> "${OUTPUT_FILE}"
echo "  - Localhost connections: ${LOCALHOST_CONN}" >> "${OUTPUT_FILE}"

echo ""
echo "Monitoring complete!"
echo "Results saved to: ${OUTPUT_FILE}"
echo ""

# Show summary
echo "Quick Summary:"
echo "  - Anthropic API: ${ANTHROPIC_CONN} detections"
echo "  - GitHub Copilot: ${COPILOT_CONN} detections"
echo "  - Localhost only: ${LOCALHOST_CONN} detections"
echo ""

# Recommendations
echo "Recommendations:"
if [[ ${ANTHROPIC_CONN} -gt 0 ]]; then
    echo "  - Anthropic Direct API in use (data sent to api.anthropic.com)"
fi

if [[ ${COPILOT_CONN} -gt 0 ]]; then
    echo "  - GitHub Copilot in use (data sent via copilot-proxy.github.io)"
fi

if [[ ${LOCALHOST_CONN} -gt 0 ]] && [[ ${ANTHROPIC_CONN} -eq 0 ]] && [[ ${COPILOT_CONN} -eq 0 ]]; then
    echo "  ✓ Offline mode detected (Ollama) - no external network traffic"
fi

echo ""
echo "For detailed analysis, review: ${OUTPUT_FILE}"
