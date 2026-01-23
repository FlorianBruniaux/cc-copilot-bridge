#!/usr/bin/env bash
set -euo pipefail

# test-gemini.sh - Automated Gemini agentic mode testing
# Purpose: Debug Gemini tool calling and file creation capabilities with copilot-api

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEBUG_DIR="/Users/florianbruniaux/Sites/perso/cc-copilot-bridge/debug-gemini"
TEST_DIR="/tmp/gemini-test-$$"
COPILOT_API_PORT=4141

# Functions
log() {
    local level=$1
    shift
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
}

check_copilot_api() {
    log "INFO" "Checking copilot-api on port $COPILOT_API_PORT..."
    if ! nc -z localhost $COPILOT_API_PORT 2>/dev/null; then
        log "ERROR" "copilot-api not running on :$COPILOT_API_PORT"
        log "INFO" "Start it with: copilot-api start -v"
        exit 1
    fi
    log "SUCCESS" "copilot-api is running"
}

setup_environment() {
    log "INFO" "Setting up test environment..."
    mkdir -p "$DEBUG_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    log "SUCCESS" "Test directory: $TEST_DIR"
}

cleanup() {
    log "INFO" "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
}

run_test() {
    local test_num=$1
    local test_name=$2
    local model=$3
    local prompt=$4
    local extra_env=$5
    local log_file="$DEBUG_DIR/test${test_num}-${test_name}.log"

    log "INFO" "Test $test_num: $test_name (model: $model)"

    # Build command
    local cmd="cd $TEST_DIR && COPILOT_MODEL=$model"
    if [[ -n "$extra_env" ]]; then
        cmd="$cmd $extra_env"
    fi
    cmd="$cmd claude-switch copilot -p \"$prompt\""

    # Execute
    if eval "$cmd" > "$log_file" 2>&1; then
        log "SUCCESS" "Test $test_num passed"
        return 0
    else
        log "WARNING" "Test $test_num failed (exit code: $?)"
        return 1
    fi
}

analyze_logs() {
    log "INFO" "Analyzing logs..."

    local summary_file="$DEBUG_DIR/summary.txt"
    {
        echo "==================================="
        echo "Gemini Agentic Mode Test Summary"
        echo "Date: $(date)"
        echo "==================================="
        echo ""

        for i in {1..5}; do
            local log_file=$(ls "$DEBUG_DIR"/test${i}-*.log 2>/dev/null | head -1)
            if [[ -f "$log_file" ]]; then
                echo "Test $i: $(basename "$log_file" .log)"

                # Check for errors
                if grep -qi "error\|failed\|invalid" "$log_file"; then
                    echo "  Status: FAILED"
                    echo "  Errors:"
                    grep -i "error\|failed\|invalid" "$log_file" | head -5 | sed 's/^/    /'
                else
                    echo "  Status: PASSED"
                fi

                # Check for file creation
                if grep -q "Created\|Written" "$log_file"; then
                    echo "  File operations: YES"
                else
                    echo "  File operations: NO"
                fi

                echo ""
            fi
        done

        echo "==================================="
        echo "Files created in test directory:"
        ls -la "$TEST_DIR" 2>/dev/null || echo "  None"
        echo ""

    } > "$summary_file"

    cat "$summary_file"
}

generate_report() {
    log "INFO" "Generating diagnostic report..."

    local report_file="$DEBUG_DIR/diagnostic-report.md"
    {
        echo "# Gemini Agentic Mode Diagnostic Report"
        echo ""
        echo "**Date**: $(date)"
        echo "**Test Directory**: $TEST_DIR"
        echo ""

        echo "## Test Results"
        echo ""

        echo "| Test | Model | Status | File Creation | Notes |"
        echo "|------|-------|--------|---------------|-------|"

        for i in {1..5}; do
            local log_file=$(ls "$DEBUG_DIR"/test${i}-*.log 2>/dev/null | head -1)
            if [[ -f "$log_file" ]]; then
                local test_name=$(basename "$log_file" .log | cut -d'-' -f2-)
                local model="?"
                local status="✅"
                local files="❌"

                # Extract model
                if grep -q "gemini-3-pro" "$log_file"; then
                    model="gemini-3-pro-preview"
                elif grep -q "gemini-2.5" "$log_file"; then
                    model="gemini-2.5-pro"
                fi

                # Check status
                if grep -qi "error\|failed\|invalid" "$log_file"; then
                    status="❌"
                fi

                # Check files
                if grep -q "Created\|Written" "$log_file" || [[ -f "$TEST_DIR/hello"* ]]; then
                    files="✅"
                fi

                echo "| Test $i | $model | $status | $files | $test_name |"
            fi
        done

        echo ""
        echo "## Key Findings"
        echo ""

        # Analyze patterns
        if grep -rq "model_not_supported" "$DEBUG_DIR"/*.log 2>/dev/null; then
            echo "- ⚠️ **Model Not Supported Error** detected"
        fi

        if grep -rq "invalid_request_body" "$DEBUG_DIR"/*.log 2>/dev/null; then
            echo "- ⚠️ **Invalid Request Body Error** detected"
        fi

        if grep -rq "tool" "$DEBUG_DIR"/*.log 2>/dev/null; then
            echo "- ✅ Tool calling syntax present in logs"
        else
            echo "- ❌ No tool calling syntax found"
        fi

        echo ""
        echo "## Recommendations"
        echo ""

        # Generate recommendations based on results
        local test2_status=$(grep -l "error\|failed" "$DEBUG_DIR"/test2-*.log 2>/dev/null)
        local test4_status=$(grep -L "error\|failed" "$DEBUG_DIR"/test4-*.log 2>/dev/null)

        if [[ -n "$test2_status" ]] && [[ -n "$test4_status" ]]; then
            echo "1. **Use Subagent Workaround**: Gemini 3 preview fails in agentic mode without subagent override"
            echo "   - Set: \`CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini\`"
            echo ""
        fi

        echo "2. **Prefer Stable Models**: Use \`gemini-2.5-pro\` over preview versions for production"
        echo ""
        echo "3. **MCP Compatibility**: Check if MCP servers need exclusion (see test3 results)"
        echo ""

        echo "## Log Files"
        echo ""
        ls -1 "$DEBUG_DIR"/*.log 2>/dev/null | while read -r log; do
            echo "- \`$(basename "$log")\`"
        done

    } > "$report_file"

    log "SUCCESS" "Report generated: $report_file"
}

# Main execution
main() {
    log "INFO" "Starting Gemini agentic mode diagnostic"

    check_copilot_api
    setup_environment

    # Test 1: Baseline simple (non-agentic)
    run_test 1 "simple" "gemini-3-pro-preview" "Calculate 1+1 and explain" "" || true
    sleep 2

    # Test 2: File creation (agentic)
    run_test 2 "file" "gemini-3-pro-preview" "Create a file called hello.txt containing 'test from gemini'" "" || true
    sleep 2

    # Test 3: MCP tool usage
    run_test 3 "mcp" "gemini-3-pro-preview" "Use grep tool to search for 'test' in current directory" "" || true
    sleep 2

    # Test 4: Workaround with subagent
    run_test 4 "subagent" "gemini-3-pro-preview" "Create a file called hello2.txt with 'test subagent'" "CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini" || true
    sleep 2

    # Test 5: Gemini 2.5 stable
    run_test 5 "gemini25" "gemini-2.5-pro" "Create a file called hello3.txt with 'test gemini 2.5'" "" || true

    analyze_logs
    generate_report

    log "SUCCESS" "Diagnostic complete. Check $DEBUG_DIR for results"
    log "INFO" "Summary: $DEBUG_DIR/summary.txt"
    log "INFO" "Report: $DEBUG_DIR/diagnostic-report.md"

    # Cleanup
    trap cleanup EXIT
}

# Run
main "$@"
