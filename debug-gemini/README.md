# Gemini Agentic Mode Debug Workspace

This directory contains tools and logs for investigating Gemini model behavior in agentic mode with copilot-api.

## Quick Start

### 1. Prerequisites

Ensure copilot-api is running in verbose mode:

```bash
# Terminal 1: Start copilot-api with verbose logging
pkill -f copilot-api || true
copilot-api start -v 2>&1 | tee copilot-api-verbose.log
```

### 2. Run Automated Tests

```bash
# Terminal 2: Execute test suite
../scripts/test-gemini.sh
```

This will:
- Run 5 test scenarios (simple, file creation, MCP tools, workarounds)
- Capture all logs in `debug-gemini/`
- Generate `summary.txt` and `diagnostic-report.md`

### 3. Analyze Results

```bash
# View summary
cat summary.txt

# View detailed report
cat diagnostic-report.md

# Analyze copilot-api logs (if captured)
../scripts/analyze-copilot-logs.sh copilot-api-verbose.log
```

## Test Scenarios

| Test | Model | Scenario | Purpose |
|------|-------|----------|---------|
| 1 | gemini-3-pro-preview | Simple calculation | Baseline non-agentic |
| 2 | gemini-3-pro-preview | File creation | Agentic tool use |
| 3 | gemini-3-pro-preview | MCP grep tool | MCP compatibility |
| 4 | gemini-3-pro-preview + gpt-5-mini subagent | File creation | Workaround validation |
| 5 | gemini-2.5-pro | File creation | Stable model comparison |

## Expected Findings

### Known Issues (from copilot-api #151)

- **Gemini 3 Preview**: May fail with `model_not_supported` or `invalid_request_body` in agentic mode
- **Tool Calling**: Gemini tool format differs from Claude; translation may be incomplete
- **Subagent Workaround**: Using `CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini` may route tool calls through GPT

### Decision Tree

```
Test 1 fails → Auth/config issue with copilot-api
Test 2 fails → Tool format incompatibility (Claude → Gemini)
Test 3 fails → MCP schema validation issue
Test 4 succeeds, Test 2 fails → Confirms subagent routing fixes issue
Test 5 succeeds, Test 2 fails → Gemini 3 preview limitation
```

## Manual Testing (Alternative)

If you prefer manual execution:

```bash
cd /tmp && mkdir -p gemini-test && cd gemini-test

# Test 1: Simple
COPILOT_MODEL=gemini-3-pro-preview ccc -p "1+1"

# Test 2: File creation
COPILOT_MODEL=gemini-3-pro-preview ccc -p "Create hello.txt with 'test'"

# Test 3: MCP tool
COPILOT_MODEL=gemini-3-pro-preview ccc -p "Use grep to search for 'TODO'"

# Test 4: Subagent workaround
COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini \
  ccc -p "Create hello2.txt with 'test'"

# Test 5: Stable model
COPILOT_MODEL=gemini-2.5-pro ccc -p "Create hello3.txt with 'test'"
```

## Output Files

After running tests, you'll find:

- `test1-simple.log` through `test5-gemini25.log` - Individual test logs
- `summary.txt` - Quick results overview
- `diagnostic-report.md` - Detailed findings and recommendations
- `copilot-api-verbose.log` - Raw copilot-api output (if captured)
- `log-analysis.md` - Copilot-API log analysis (if generated)

## Next Steps

Based on findings, implement workarounds:

1. **Update claude-switch** - Auto-detect Gemini and set subagent
2. **Update documentation** - Add Known Issues section
3. **Update MODEL-SWITCHING.md** - Document Gemini limitations
4. **Update TROUBLESHOOTING.md** - Add troubleshooting steps

## References

- [copilot-api Issue #151](https://github.com/ericc-ch/copilot-api/issues/151) - Gemini model compatibility
- [copilot-api Issue #174](https://github.com/ericc-ch/copilot-api/issues/174) - Billing header issue (separate)
