# Best Practices for cc-copilot-bridge

**Reading time**: 20 minutes | **Skill level**: Intermediate | **Last updated**: 2026-01-22

Comprehensive guide for optimizing cost, performance, and security across multi-provider AI development workflows.

---

## Table of Contents

- [Strategic Model Selection](#strategic-model-selection)
- [Daily Development Workflows](#daily-development-workflows)
- [Team Best Practices](#team-best-practices)
- [Performance Optimization](#performance-optimization)
- [Security & Privacy Patterns](#security--privacy-patterns)
- [Cost Management](#cost-management)
- [Common Anti-Patterns](#common-anti-patterns)

---

## Strategic Model Selection

### Decision Framework

Choose your provider and model based on three dimensions: cost, quality, and privacy requirements.

#### Provider Selection Matrix

| Scenario | Recommended Provider | Reason |
|----------|---------------------|---------|
| Daily feature development | `ccc` (Copilot) | Uses quota (1x), fast, balanced quality |
| Code review / critical analysis | `ccd` (Anthropic) or `ccc-opus` | Best quality for security-critical decisions |
| Proprietary/sensitive code | `cco` (Ollama) | 100% local, no data leaves machine |
| Rapid prototyping | `ccc-gpt` (Copilot) | 0x multiplier = doesn't consume quota |
| Learning/experimentation | `ccc` (Copilot) | Uses quota, good for exploration |
| Production deployment review | `ccd --model opus` (Anthropic) | Official API, no ToS risk |
| Offline/air-gapped development | `cco` (Ollama) | Only option without internet |

#### Model Selection Within Copilot

When using GitHub Copilot (`ccc`), choose models based on task complexity:

| Task Type | Model | Command | Quality | Speed | Use Case |
|-----------|-------|---------|---------|-------|----------|
| Quick questions | Haiku 4.5 | `ccc-haiku` | ⭐⭐⭐ | ⚡⚡⚡ | "What does this function do?" |
| Feature implementation | Sonnet 4.5 | `ccc` or `ccc-sonnet` | ⭐⭐⭐⭐ | ⚡⚡ | Daily development (default) |
| Complex architecture | Opus 4.5 | `ccc-opus` | ⭐⭐⭐⭐⭐ | ⚡ | System design, critical code paths |
| Alternative perspective | GPT-4.1 | `ccc-gpt` | ⭐⭐⭐⭐ | ⚡⚡ | When Claude approach isn't working |

**All free with Copilot Pro+ subscription ($10/month).**

### Cost Optimization Strategies

#### 1. Copilot-First Approach (Recommended)

Use Copilot for 80-90% of work, reserve Anthropic Direct for critical 10-20%.

```bash
# Morning: Feature development (free)
ccc
> Implement JWT authentication middleware

# Afternoon: Continue development (free)
ccc
> Add rate limiting to API endpoints

# Before commit: Final review (paid, high quality)
ccd --model opus
> Security audit this authentication implementation
```

**Cost savings**: $40-80/month vs Anthropic-only workflow.

#### 2. Progressive Quality Escalation

Start with faster/cheaper models, escalate only when needed.

```bash
# Level 1: Quick prototype (Haiku)
ccc-haiku
> Sketch out user profile component structure

# Level 2: Full implementation (Sonnet)
ccc-sonnet
> Implement complete user profile with validation

# Level 3: Critical review (Opus)
ccc-opus
> Review for security vulnerabilities and edge cases
```

**Cost savings**: Avoid using Opus for tasks Haiku can handle.

#### 3. Multi-Model Validation

For critical decisions, validate across models before using expensive Anthropic.

```bash
# Free validation round
ccc-sonnet    # Claude perspective
> Evaluate this caching strategy

ccc-gpt       # GPT perspective
> Evaluate this caching strategy

# Only if disagreement warrants it:
ccd --model opus
> Final arbitration on caching approach
```

**Cost savings**: Often free models converge on the right answer, eliminating need for paid validation.

### Quality vs Speed Trade-offs

#### When to Prioritize Speed

Use faster models (`ccc-haiku`, `ccc-sonnet`) when:
- Exploring unfamiliar codebase
- Rapid prototyping / spike solutions
- Refactoring with clear specifications
- Answering straightforward questions
- Iterating on feedback quickly

**Do:**
```bash
ccc-haiku
> What files handle user authentication?
```

**Don't:**
```bash
ccc-opus  # Overkill for simple questions
> What files handle user authentication?
```

#### When to Prioritize Quality

Use best models (`ccc-opus`, `ccd --model opus`) when:
- Security-critical code paths
- Production deployment reviews
- Complex architectural decisions
- Debugging subtle race conditions
- Compliance-sensitive implementations

**Do:**
```bash
ccd --model opus
> Analyze this payment processing flow for security vulnerabilities
```

**Don't:**
```bash
ccc-haiku  # Insufficient for security analysis
> Analyze this payment processing flow for security vulnerabilities
```

---

## Daily Development Workflows

### Morning Pattern: Exploration & Planning

**Goal**: Understand codebase, plan features, quick wins.

**Recommended**: Copilot Haiku or Sonnet (fast, free)

```bash
# Start session
ccc-haiku

# Typical morning tasks
> Explore project structure and identify auth components
> Generate test cases for new feature
> Refactor duplicated validation logic
> Answer team's code review questions
```

**Why this works**: Morning tasks are exploratory with rapid iterations. Haiku's speed keeps flow state intact.

### Afternoon Pattern: Implementation & Testing

**Goal**: Build features, write tests, integrate components.

**Recommended**: Copilot Sonnet (balanced)

```bash
# Continue or new session
ccc-sonnet

# Typical afternoon tasks
> Implement user profile API endpoints with validation
> Write integration tests for authentication flow
> Debug failing test cases
> Optimize database queries
```

**Why this works**: Sonnet balances quality and speed for heads-down implementation work.

### Evening Pattern: Review & Refinement

**Goal**: Code review, security checks, documentation.

**Recommended**: Copilot Opus or Anthropic Direct (quality focus)

```bash
# High-quality review session
ccc-opus

# Typical evening tasks
> Review today's code for security issues
> Analyze edge cases in error handling
> Generate comprehensive API documentation
> Architectural review of new microservice
```

**Why this works**: End-of-day reviews benefit from highest quality model, worth the slower speed.

### Task-Based Selection Examples

#### Debugging Session

```bash
# Start with Sonnet
ccc-sonnet
> Debug why authentication fails for federated users

# If stuck after 15 minutes, escalate
ccc-opus
> Deep analysis: authentication flow for federated vs local users

# If still stuck, alternative perspective
ccc-gpt
> Review authentication logic from different angle
```

#### Feature Development Session

```bash
# Planning phase
ccc-sonnet
> Design user notification system architecture

# Implementation phase (continue same session)
> Implement notification service with queue integration
> Add rate limiting and retry logic
> Write unit and integration tests

# Review phase (switch to Opus)
/exit
ccc-opus
> Security and performance review of notification system
```

#### Refactoring Session

```bash
# Fast model sufficient for clear refactoring
ccc-haiku

> Extract payment processing into separate module
> Rename ambiguous variables in auth service
> Remove deprecated API endpoints
> Update function signatures for TypeScript strict mode
```

### Multi-Provider Workflows

#### Parallel Investigation

Run multiple terminals with different providers for complex problems:

```bash
# Terminal 1: Primary investigation (free)
ccc-sonnet
> Analyze performance bottleneck in API response times

# Terminal 2: Alternative approach (free)
ccc-gpt
> Suggest database query optimizations

# Terminal 3: Private code analysis (offline)
cco
> Review proprietary algorithm performance characteristics
```

#### Staged Quality Gates

Pass code through quality gates with increasing rigor:

```bash
# Gate 1: Implementation (Copilot Sonnet)
ccc-sonnet
> Implement feature X

# Gate 2: Self-review (Copilot Opus)
ccc-opus
> Review implementation for correctness

# Gate 3: Security audit (Anthropic Direct)
ccd --model opus
> Security analysis before production deployment
```

**Cost optimization**: Most code fails Gate 1 or 2, avoiding expensive Gate 3 review.

---

## Team Best Practices

### Onboarding New Team Members

#### Setup Checklist

Standardized onboarding reduces configuration variability:

**Day 1: Installation**
```bash
# 1. Verify prerequisites
which claude
which jq
which nc

# 2. Install cc-copilot-bridge
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash
source ~/.zshrc

# 3. Verify installation
ccs  # Check all provider status
```

**Day 2: Provider configuration**
```bash
# Configure Anthropic (optional but recommended for critical work)
export ANTHROPIC_API_KEY="<YOUR_API_KEY>"

# Configure Copilot (primary provider)
npm install -g copilot-api
copilot-api start
# Follow authentication flow

# Verify both work
ccd  # Test Anthropic
ccc  # Test Copilot
```

**Day 3: Optional Ollama setup**
```bash
# For sensitive code work
brew install ollama
ollama serve &
ollama pull qwen2.5-coder:7b  # Start with small model

cco  # Test Ollama
```

#### Team Aliases Configuration

Standardize aliases across team in shared `.bash_aliases.team`:

```bash
# === cc-copilot-bridge Team Standards ===

# Primary providers
alias ccd='claude-switch direct'
alias ccc='claude-switch copilot'
alias cco='claude-switch ollama'
alias ccs='claude-switch status'

# Copilot models (team conventions)
alias cc='ccc-sonnet'                # Default for daily work
alias cc-review='ccc-opus'           # Code reviews
alias cc-fast='ccc-haiku'            # Quick questions
alias cc-alt='ccc-gpt'               # Alternative perspective

# Production quality gate (Anthropic)
alias cc-prod='ccd --model opus'     # Production reviews only

# Ollama for sensitive work
alias cc-private='cco'               # Proprietary code
```

**Team convention**: Everyone uses `cc` for daily work, escalates to `cc-review` or `cc-prod` as needed.

### Standardizing Usage Patterns

#### Code Review Guidelines

Establish when to use each model tier:

**Level 1: Peer Review (Sonnet)**
- Standard pull requests
- Non-critical bug fixes
- Documentation changes
- Test additions

**Level 2: Senior Review (Opus via Copilot)**
- Security-sensitive changes
- API contract modifications
- Database schema migrations
- Critical bug fixes

**Level 3: Production Gate (Anthropic Direct)**
- Production hotfixes
- Infrastructure changes
- Security patches
- Compliance-critical code

**Implementation**:
```bash
# In .github/pull_request_template.md
## AI Review Checklist

- [ ] Level 1 review completed (`cc-review`)
- [ ] Level 2 review for security-sensitive changes (`cc-review`)
- [ ] Level 3 review for production deployments (`cc-prod`)
```

#### Session Logging for Audits

Enable team-wide session tracking:

```bash
# Shared team function in .bash_aliases.team
cc-log-summary() {
  echo "=== Your AI Usage Summary ==="
  echo ""
  echo "Copilot sessions:"
  grep "mode=copilot" ~/.claude/claude-switch.log | wc -l
  echo ""
  echo "Anthropic sessions:"
  grep "mode=direct" ~/.claude/claude-switch.log | wc -l
  echo ""
  echo "Model breakdown:"
  grep "mode=copilot:" ~/.claude/claude-switch.log | cut -d':' -f4 | sort | uniq -c
}

# Weekly review
cc-log-summary
```

**Team lead review**: Monthly analysis to optimize model selection patterns.

### Cost Management Strategies

#### Team Budget Allocation

Recommended budget split for 5-person team:

| Provider | Monthly Budget | Usage Pattern |
|----------|---------------|---------------|
| GitHub Copilot | $50 (5 × $10) | 80-90% of all AI interactions |
| Anthropic Direct | $100-200 total | Critical reviews, production gates |
| Ollama | $0 (infrastructure only) | Sensitive code, offline work |

**Total**: $150-250/month vs $500-1000+ for Anthropic-only team.

#### Cost Tracking Template

Share monthly cost analysis:

```bash
#!/bin/bash
# monthly-ai-report.sh

echo "=== Monthly AI Cost Report ==="
echo "Period: $(date +'%B %Y')"
echo ""

# Copilot usage
total_sessions=$(grep "mode=copilot" ~/.claude/claude-switch.log | wc -l)
echo "Copilot Sessions: ${total_sessions}"
echo "  Cost: $10.00 (flat rate)"
echo ""

# Anthropic usage (estimate from logs)
anthropic_sessions=$(grep "mode=direct" ~/.claude/claude-switch.log | wc -l)
echo "Anthropic Sessions: ${anthropic_sessions}"
echo "  Estimated cost: Check billing dashboard"
echo ""

# Model distribution
echo "Model usage breakdown:"
grep "mode=copilot:" ~/.claude/claude-switch.log | cut -d':' -f4 | sort | uniq -c | sort -rn
```

**Team lead action**: If Anthropic costs exceed $50/person/month, review escalation patterns.

#### Escalation Training

Train team to recognize when escalation is worth the cost:

**Escalate to Opus/Anthropic when:**
- Security vulnerability analysis
- Production incident post-mortems
- Architectural design decisions
- Compliance code review

**Don't escalate for:**
- Syntax questions
- Simple refactoring
- Test writing
- Documentation generation
- Code exploration

**Example training exercise:**
```bash
# Good escalation
ccc-sonnet
> Initial implementation of OAuth flow

ccd --model opus  # Escalate for security
> Security audit of OAuth implementation

# Bad escalation (waste of money)
ccd --model opus  # Unnecessary
> What does this forEach loop do?
```

### Shared Configuration Management

#### Team MCP Profiles

Standardize MCP server configurations:

```bash
# Shared team repo: .claude-config/
├── mcp-profiles/
│   ├── excludes.yaml           # Team-agreed exclusions
│   ├── generate.sh             # Profile generator
│   └── prompts/
│       ├── gpt-4.1-team.txt    # Team conventions for GPT
│       └── gemini-team.txt     # Team conventions for Gemini
```

**Setup script** for new members:
```bash
#!/bin/bash
# setup-team-mcp.sh

# Copy team MCP config
cp -r .claude-config/mcp-profiles ~/.claude/

# Generate profiles
~/.claude/mcp-profiles/generate.sh

echo "Team MCP configuration installed"
```

#### Alias Synchronization

Keep team aliases in sync with version control:

```bash
# In team repo: config/bash_aliases.team
# Team members source this in their ~/.zshrc

if [ -f ~/workspace/team-repo/config/bash_aliases.team ]; then
  source ~/workspace/team-repo/config/bash_aliases.team
fi
```

**Benefits:**
- Consistent commands across team
- Easy updates via git pull
- Onboarding documentation matches reality

---

## Performance Optimization

### General Principles

1. **Match tool to task**: Don't use Opus for tasks Haiku can handle
2. **Minimize context switching**: Stay in one session for related tasks
3. **Batch similar operations**: Group file operations, code reviews, etc.
4. **Monitor response times**: If consistently slow, investigate provider health

### Anthropic Direct Optimization

#### Response Time Optimization

```bash
# Check API latency
time ccd --model haiku << EOF
> Calculate 1+1
> /exit
EOF

# Expected: 1-3 seconds for Haiku
```

**If slow (>5 seconds):**
1. Check internet connection: `ping api.anthropic.com`
2. Verify API key validity: `echo $ANTHROPIC_API_KEY`
3. Review Anthropic status: https://status.anthropic.com

#### Token Usage Optimization

Anthropic charges per token (input + output):

**Minimize input tokens:**
```bash
# Bad: Verbose context
ccd
> I have this really long file with lots of code and I want you to analyze
  every single line and tell me everything about it in great detail...

# Good: Concise requests
ccd
> Security review: auth.js lines 45-67
```

**Minimize output tokens:**
```bash
# Bad: Open-ended responses
ccd
> Explain everything about React hooks

# Good: Specific questions
ccd
> When should I use useEffect vs useLayoutEffect?
```

**Monitor usage:**
```bash
# Check Anthropic dashboard monthly
# Target: <$20/month for individual developer
```

### GitHub Copilot Optimization

#### copilot-api Health Checks

Copilot performance depends on copilot-api being healthy:

```bash
# Check if running
nc -zv localhost 4141

# Check logs for errors
copilot-api logs

# Restart if unhealthy
copilot-api restart
```

**Auto-restart on Mac** (recommended):
```bash
# Create ~/Library/LaunchAgents/com.copilot-api.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.copilot-api</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/copilot-api</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
```

**Load:**
```bash
launchctl load ~/Library/LaunchAgents/com.copilot-api.plist
```

#### Model Selection for Speed

Response time comparison (typical):

| Model | Latency | Use When |
|-------|---------|----------|
| Haiku 4.5 | 0.5-1s | Need immediate feedback |
| Sonnet 4.5 | 1-2s | Balanced work |
| Opus 4.5 | 3-5s | Quality over speed |
| GPT-4.1 | 1-2s | Alternative perspective |
| GPT-5 | 2-4s | Advanced reasoning |

**Speed optimization workflow:**
```bash
# Quick iteration loop (Haiku)
ccc-haiku
> Try approach A
> Try approach B
> Try approach C

# Once approach settled, switch to Sonnet for quality
/exit
ccc-sonnet
> Implement chosen approach with production quality
```

#### MCP Server Impact

MCP servers add latency to each request:

```bash
# Minimal MCP profile for speed
# ~/.claude/mcp-profiles/generated/minimal.json
{
  "mcpServers": {
    "bash": { ... },      # Essential
    "filesystem": { ... } # Essential
    # Disable: grepai, playwright, context7, etc.
  }
}

# Use for speed-critical sessions
COPILOT_MODEL=claude-haiku-4.5 claude --mcp-config ~/.claude/mcp-profiles/generated/minimal.json
```

**Latency per MCP server**: ~50-200ms per server initialization.

### Ollama Performance Optimization

#### Context Length Configuration

**Problem**: Claude Code sends ~60K context, Ollama defaults to 8K → 87% truncation → constant reprocessing.

**Solution**: Increase context length:

```bash
# Set 32K context (recommended for Claude Code)
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
brew services restart ollama

# Verify
echo $OLLAMA_CONTEXT_LENGTH
```

**Trade-off**: Higher context = slower inference but correct behavior.

#### Apple Silicon Optimization

Full optimization guide: [OPTIMISATION-M4-PRO.md](OPTIMISATION-M4-PRO.md)

**Quick wins:**
```bash
# Enable flash attention (2-4x speed boost)
launchctl setenv OLLAMA_FLASH_ATTENTION 1

# Increase parallel processing
launchctl setenv OLLAMA_NUM_PARALLEL 4

# Restart Ollama
brew services restart ollama
```

**Expected performance** (M4 Pro 48GB, qwen2.5-coder:32b):
- Without optimization: 8-12 tok/s
- With optimization: 26-39 tok/s
- Improvement: 3-4x faster

#### Model Selection for Hardware

Match model size to available RAM:

| Hardware | Recommended Model | RAM Usage | Performance |
|----------|------------------|-----------|-------------|
| M1 16GB | qwen2.5-coder:7b | 6-8 GB | 15-25 tok/s |
| M2/M3 24GB | qwen2.5-coder:14b | 12-14 GB | 20-30 tok/s |
| M4 Pro 48GB | qwen2.5-coder:32b | 26 GB | 26-39 tok/s |

**Don't:**
```bash
# M1 16GB trying to run 32B model
OLLAMA_MODEL=qwen2.5-coder:32b cco  # Will crash or swap heavily
```

**Do:**
```bash
# M1 16GB with appropriate model
OLLAMA_MODEL=qwen2.5-coder:7b cco   # Smooth performance
```

#### Quantization Trade-offs

Model quantization affects quality and speed:

| Quantization | Size | Quality | Speed | Use Case |
|--------------|------|---------|-------|----------|
| q4_k_m | Smallest | ⭐⭐⭐ | Fastest | Simple refactoring |
| q5_k_m | Medium | ⭐⭐⭐⭐ | Balanced | Daily work (recommended) |
| q8_0 | Largest | ⭐⭐⭐⭐⭐ | Slowest | Critical code |

**Example:**
```bash
# Fast, good enough
ollama pull qwen2.5-coder:7b-instruct-q4_k_m
OLLAMA_MODEL=qwen2.5-coder:7b-instruct-q4_k_m cco

# Best quality
ollama pull qwen2.5-coder:7b-instruct-q8_0
OLLAMA_MODEL=qwen2.5-coder:7b-instruct-q8_0 cco
```

### Avoiding Common Pitfalls

#### Don't: Use Ollama for Large Projects Without Configuration

```bash
# This will be painfully slow (2-6 minute responses)
cco  # Default 8K context with 60K Claude Code context
```

**Fix:**
```bash
# Configure context length first
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
brew services restart ollama
cco  # Now usable
```

#### Don't: Use Opus for Simple Questions

```bash
# Waste of time and money
ccd --model opus
> What does map() do in JavaScript?
```

**Fix:**
```bash
# Use fast free model
ccc-haiku
> What does map() do in JavaScript?
```

#### Don't: Keep copilot-api Running Without Monitoring

```bash
# copilot-api crashes silently, you get confusing errors
ccc
# ERROR: Connection refused
```

**Fix:**
```bash
# Check status before starting session
ccs  # Shows copilot-api health

# Or add to shell prompt
PS1='[$(nc -z localhost 4141 && echo "✓" || echo "✗")] $ '
```

#### Don't: Run Multiple Ollama Models Simultaneously

```bash
# Terminal 1
OLLAMA_MODEL=qwen2.5-coder:32b cco  # Uses 26GB RAM

# Terminal 2
OLLAMA_MODEL=qwen2.5-coder:32b cco  # Tries to use another 26GB
# System crashes or swaps heavily
```

**Fix:**
```bash
# Use cloud providers for parallel sessions
ccc-sonnet  # Terminal 1
ccc-gpt     # Terminal 2
# Ollama only in Terminal 3 if needed
```

---

## Security & Privacy Patterns

### Data Sensitivity Classification

Classify your code by sensitivity level:

#### Level 1: Public/Open-Source
**Sensitivity**: None
**Allowed providers**: All (`ccc`, `ccd`, `cco`)
**Examples**: Open-source contributions, learning projects, public tools

```bash
# Any provider is fine
ccc
> Refactor this open-source React component
```

#### Level 2: Internal/Business Logic
**Sensitivity**: Medium
**Allowed providers**: Copilot, Anthropic (check company policy), Ollama
**Examples**: Internal tools, standard business features, non-confidential APIs

```bash
# Copilot generally acceptable (verify company policy)
ccc
> Implement user profile management feature
```

#### Level 3: Confidential/Proprietary
**Sensitivity**: High
**Allowed providers**: Ollama ONLY
**Examples**: Proprietary algorithms, trade secrets, client confidential code, NDA work

```bash
# Use local-only provider
cco
> Optimize proprietary recommendation algorithm
```

#### Level 4: Regulated/Compliance
**Sensitivity**: Critical
**Allowed providers**: Ollama ONLY + manual audit
**Examples**: Healthcare (HIPAA), Finance (PCI-DSS), Government (FedRAMP)

```bash
# Local only + human review mandatory
cco
> Review payment card processing implementation

# Then: Manual security audit by qualified personnel
```

### Provider Selection by Sensitivity

| Code Type | Use | Don't Use | Why |
|-----------|-----|-----------|-----|
| Open-source | `ccc`, `ccd`, `cco` | N/A | Public anyway |
| Standard features | `ccc`, `ccd` | N/A | Acceptable per most policies |
| Trade secrets | `cco` | `ccc`, `ccd` | Must stay local |
| Regulated data | `cco` + audit | `ccc`, `ccd` | Compliance requirement |
| Client NDA code | `cco` | `ccc`, `ccd` | Contractual obligation |

### Data Flow by Provider

Understanding where your code goes:

#### Anthropic Direct (`ccd`)
```
Your machine → HTTPS → api.anthropic.com (AWS US) → Anthropic servers
                                                    ↓
                                        Retained 30 days for abuse detection
```

**Privacy considerations:**
- Anthropic retains data for 30 days
- Used for abuse/safety monitoring
- Not used for model training (per Anthropic policy)
- Subject to Anthropic Terms of Service

**Acceptable for**: Standard business code, non-confidential work
**Not acceptable for**: Trade secrets, NDA code, regulated data

#### GitHub Copilot (`ccc`)
```
Your machine → HTTPS → copilot-api (localhost:4141) → GitHub Copilot API
                                                       ↓
                                        Retention per GitHub policy
```

**Privacy considerations:**
- Managed by GitHub/Microsoft
- Retention policy varies by subscription type
- May be used for service improvement (check current policy)
- Subject to GitHub Copilot Terms

**Acceptable for**: Standard business code (check company policy)
**Not acceptable for**: Highly confidential or regulated code

#### Ollama Local (`cco`)
```
Your machine → localhost:11434 (Ollama) → STAYS LOCAL
                                          ↓
                                    No external network calls
```

**Privacy guarantees:**
- 100% local processing
- No data leaves your machine
- No telemetry or cloud calls
- You control data retention

**Acceptable for**: Everything, including most sensitive code
**Required for**: Trade secrets, NDA work, regulated data

### Verifying Ollama Privacy

Confirm Ollama doesn't phone home:

```bash
# Monitor network connections during Ollama use
sudo tcpdump -i any -n 'host not localhost' | grep ollama &
TCPDUMP_PID=$!

# Use Ollama
cco
> Analyze this sensitive code

# Stop monitoring
kill $TCPDUMP_PID

# Should see: No external connections
```

**Alternative verification:**
```bash
# Check Ollama process network connections
lsof -i -P | grep ollama

# Should only show: localhost:11434 (no external IPs)
```

### Company Policy Compliance

#### Pre-Use Checklist

Before adopting cc-copilot-bridge, verify:

1. **AI Tool Policy**: Does your company allow AI coding assistants?
2. **Cloud Provider Restrictions**: Are GitHub/Anthropic approved vendors?
3. **Data Residency**: Any geographic restrictions on data processing?
4. **Audit Requirements**: Need logging/traceability of AI usage?
5. **Code Review**: Must AI-generated code be reviewed by humans?

#### Policy Template for Managers

Recommend this classification to your manager:

```
Company AI Coding Policy - cc-copilot-bridge

Allowed Use Cases:
- GitHub Copilot (ccc): Standard feature development, testing, documentation
- Anthropic Direct (ccd): Code review, architecture analysis, learning
- Ollama Local (cco): Sensitive/confidential code, regulated data

Prohibited:
- Sending customer data to AI models (any provider)
- Using cloud AI (ccc/ccd) for code under NDA
- Bypassing code review for AI-generated code

Required:
- Human review of all AI-generated code before commit
- Use of local Ollama (cco) for Level 3+ sensitive code
- Monthly audit of AI usage logs
```

### Audit Trail Management

#### Session Logging

All sessions are logged to `~/.claude/claude-switch.log`:

```bash
[2026-01-22 09:42:33] [INFO] Provider: GitHub Copilot - Model: claude-sonnet-4.5
[2026-01-22 09:42:33] [INFO] Session started: mode=copilot:claude-sonnet-4.5 pid=12345
[2026-01-22 10:15:20] [INFO] Session ended: duration=32m47s exit=0
```

**Audit queries:**
```bash
# How many times did I use each provider this month?
grep "Session started" ~/.claude/claude-switch.log | \
  grep "$(date +%Y-%m)" | \
  cut -d: -f4 | cut -d' ' -f1 | sort | uniq -c

# Did I use Copilot for sensitive project? (Audit violation check)
grep "mode=copilot" ~/.claude/claude-switch.log | grep -C 3 "$(date +%Y-%m-%d)"
# Cross-reference with git commits in sensitive repos
```

**For compliance:** Retain logs for duration required by policy (typically 1-3 years).

#### Scrubbing Sensitive Data

If you accidentally used wrong provider for sensitive code:

```bash
# Immediate action: Document incident
echo "[$(date)] INCIDENT: Used ccc for project X (should be cco)" >> ~/ai-audit.log

# Inform security team if required by policy
# Document: What code was exposed, when, to which provider

# Prevention: Add pre-commit hook
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached | grep -q "SENSITIVE"; then
  echo "WARNING: Committing sensitive code. Verify you used Ollama (cco)."
  echo "Last AI session: $(tail -1 ~/.claude/claude-switch.log)"
  read -p "Continue? (y/n) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi
```

### Client Work & NDA Considerations

When working on client code under NDA:

**Strict approach:**
```bash
# ONLY use Ollama for any client work
alias cc-client='cco'

# Add to shell prompt to remind you
PS1='[CLIENT-NDA] $ '

# Disable other providers during client work
alias ccc='echo "ERROR: Use cc-client for NDA work" && false'
alias ccd='echo "ERROR: Use cc-client for NDA work" && false'
```

**Moderate approach** (if policy allows):
```bash
# Non-confidential scaffolding: Copilot OK
ccc
> Generate boilerplate Express.js server

# Client-specific logic: Ollama only
cco
> Implement client's proprietary pricing algorithm
```

**Document your usage:**
```bash
# Log which provider used for which parts
echo "[$(date)] Project ClientX - used ccc for boilerplate only" >> ~/client-ai-log.txt
echo "[$(date)] Project ClientX - used cco for pricing algorithm" >> ~/client-ai-log.txt
```

---

## Cost Management

### Individual Developer Budget

Recommended monthly budget allocation:

| Scenario | Copilot | Anthropic | Ollama | Total |
|----------|---------|-----------|--------|-------|
| **Cost-conscious** | $10 | $0-5 | $0 | $10-15 |
| **Balanced** | $10 | $10-20 | $0 | $20-30 |
| **Quality-focused** | $10 | $30-50 | $0 | $40-60 |
| **Privacy-focused** | $0 | $0 | $0 | $0* |

*Ollama hardware costs not included (one-time)

**Target**: Stay under $30/month for most developers.

### Tracking Actual Costs

#### Copilot Tracking

**Fixed cost**: $10/month (GitHub Copilot Pro+ subscription)

**Usage tracking:**
```bash
# Count Copilot sessions this month
grep "mode=copilot" ~/.claude/claude-switch.log | \
  grep "$(date +%Y-%m)" | wc -l

# Average session duration
grep "mode=copilot.*duration=" ~/.claude/claude-switch.log | \
  grep "$(date +%Y-%m)" | \
  sed 's/.*duration=\([0-9]*\)m.*/\1/' | \
  awk '{sum+=$1; count++} END {print sum/count " minutes"}'
```

**Value metrics:**
- Sessions per day: Target 3-5 for daily usage
- Monthly quota: Pro = 300 requests, Pro+ = 1,500 requests
- Different models consume different quota (see multipliers)

#### Anthropic Tracking

**Variable cost**: Per-token usage

**Check dashboard:**
- Login: https://console.anthropic.com
- Navigate: Usage → Current month
- Monitor: Input tokens, output tokens, cost

**Cost estimation from logs:**
```bash
# Count Anthropic sessions
grep "mode=direct" ~/.claude/claude-switch.log | grep "$(date +%Y-%m)" | wc -l

# Rough estimate (actual cost varies by model and tokens)
# Haiku: ~$0.50/session
# Sonnet: ~$2/session
# Opus: ~$5/session
```

**Budget alerts:**
Set up in Anthropic Console:
- Navigate: Settings → Billing → Usage alerts
- Set alert: $20, $40, $60 thresholds

#### Ollama Tracking

**Operational cost**: $0 (electricity negligible)

**Infrastructure cost:**
- Apple Silicon Mac: One-time purchase ($1500-3500)
- Amortized over 3-4 years: ~$35-90/month
- Benefit: Usable for all work, not just AI

**Usage tracking:**
```bash
# Ollama sessions
grep "mode=ollama" ~/.claude/claude-switch.log | grep "$(date +%Y-%m)" | wc -l

# Disk usage (models)
du -sh ~/.ollama/models
```

### Cost Optimization Tactics

#### Tactic 1: Default to Free

Set Copilot as your default:

```bash
# In ~/.zshrc
alias cc='ccc-sonnet'  # Default to free Copilot

# Only use paid explicitly
alias cc-paid='ccd'
```

**Result**: Requires conscious decision to spend money.

#### Tactic 2: Model Selection Discipline

Build habits for right model selection:

```bash
# Cheap/free by default
cc-haiku    # Quick questions
cc-sonnet   # Implementation

# Expensive only when justified
cc-paid     # Critical security review
```

**Mental model**: "Is this question worth $2-5?" If no, use Copilot.

#### Tactic 3: Batch Reviews

Instead of multiple expensive reviews, batch them:

```bash
# Bad: Multiple Opus sessions
ccd --model opus
> Review function A
/exit

ccd --model opus
> Review function B
/exit

# Cost: 2 sessions × $5 = $10

# Good: Single batched session
ccd --model opus
> Review functions A, B, C, and D
/exit

# Cost: 1 session × $5 = $5
```

**Savings**: 50% on review costs.

#### Tactic 4: Progressive Disclosure

Start vague, add detail only if needed:

```bash
# First try: Free Copilot with vague question
ccc-sonnet
> This authentication isn't working

# If response insufficient, add detail
> Here's the code: [paste code]

# Only if still stuck, escalate
/exit
ccd --model opus
> Deep debugging: [paste code + context]
```

**Savings**: Often Copilot solves it, avoiding Anthropic cost.

#### Tactic 5: Ollama for Iteration

Use Ollama for rapid iteration (free), Anthropic for final review:

```bash
# Iterate with Ollama (free)
cco
> Try caching strategy A
> Try caching strategy B
> Try caching strategy C

# Once settled, validate with paid model
ccd --model opus
> Final review of caching strategy C
```

**Cost strategy**: Iterate with Copilot (uses quota), finalize with Anthropic Direct (official API).

### Team Cost Sharing

For teams using shared Anthropic account:

#### Fair Allocation Model

Track individual usage:

```bash
# Add to ~/.zshrc for each team member
alias ccd='echo "[$(date)] USER=$(whoami)" >> ~/.claude/claude-switch.log && claude-switch direct'

# Monthly team report
grep "USER=" ~/.claude/claude-switch.log | \
  cut -d= -f2 | sort | uniq -c
```

**Cost allocation:**
```
Total monthly bill: $150
User A sessions: 60 (40%)
User B sessions: 45 (30%)
User C sessions: 45 (30%)

User A pays: $60
User B pays: $45
User C pays: $45
```

#### Budget Pooling

Alternative: Team pool with agreed limits:

```
Team: 5 developers
Anthropic budget: $200/month pooled
Limit per dev: $40/month

Weekly check-in:
- Review: Who used what models
- Flag: Anyone approaching $40 limit
- Adjust: Encourage Copilot for that developer
```

---

## Common Anti-Patterns

### Anti-Pattern 1: Always Using Opus

**Symptom:** High Anthropic bills for routine work.

**Example:**
```bash
# Every day, for everything
ccd --model opus
> Write unit test
> Refactor variable names
> Explain this function
> Fix typo in comment

# Monthly cost: $200+
```

**Fix:**
```bash
# Use free Copilot for routine work
ccc-haiku
> Write unit test
> Refactor variable names

# Reserve Opus for critical decisions
ccd --model opus
> Architecture review for new microservice

# Monthly cost: $20
```

**Rule:** If Haiku could do it, Opus is waste.

### Anti-Pattern 2: Ignoring Provider Health

**Symptom:** Intermittent failures, confusion about what's broken.

**Example:**
```bash
# Just try commands until something works
ccc  # ERROR: Connection refused
ccd  # ERROR: API key invalid
cco  # ERROR: Model not found

# Frustration: Nothing works!
```

**Fix:**
```bash
# Check status FIRST
ccs

# Output shows exactly what's broken
# Anthropic API:  ✓ Reachable
# copilot-api:    ✗ Not running  ← Fix this
# Ollama:         ✗ Not running  ← And this

# Fix identified issues
copilot-api start
ollama serve &

# Now try again
ccc  # Works!
```

**Rule:** `ccs` before debugging.

### Anti-Pattern 3: Wrong Provider for Sensitivity

**Symptom:** Compliance violations, NDA breaches.

**Example:**
```bash
# Using cloud AI for trade secret
ccc
> Optimize our proprietary recommendation algorithm
# PROBLEM: Sent to GitHub Copilot servers
```

**Fix:**
```bash
# Use local-only provider for sensitive code
cco
> Optimize our proprietary recommendation algorithm
# Safe: Stays on your machine
```

**Rule:** If under NDA or trade secret, use `cco` only.

### Anti-Pattern 4: Not Configuring Ollama Context

**Symptom:** Ollama unbearably slow (2-6 minute responses).

**Example:**
```bash
# Using Ollama with default 8K context
cco  # Takes forever, responses incoherent
```

**Fix:**
```bash
# Configure 32K context ONCE
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
brew services restart ollama

# Now Ollama works properly
cco  # Reasonable speed, coherent responses
```

**Rule:** Configure Ollama before complaining it's slow.

### Anti-Pattern 5: No Model Selection Strategy

**Symptom:** Random model choice, inconsistent results, waste.

**Example:**
```bash
# No strategy, just random
ccc-opus     # Overkill for simple question
ccc-haiku    # Insufficient for security review
ccc-gpt      # When Claude would work fine
```

**Fix:**
```bash
# Clear decision tree
# Quick question? → Haiku
ccc-haiku
> What's the syntax for async/await?

# Implementation? → Sonnet
ccc-sonnet
> Implement user authentication

# Critical review? → Opus or Anthropic
ccc-opus
> Security review before production
```

**Rule:** Match model to task complexity.

### Anti-Pattern 6: Parallel Ollama Models

**Symptom:** System crashes, extreme swap usage.

**Example:**
```bash
# Terminal 1
OLLAMA_MODEL=qwen2.5-coder:32b cco  # 26GB RAM

# Terminal 2
OLLAMA_MODEL=qwen2.5-coder:32b cco  # Another 26GB
# Total: 52GB on 48GB machine → crash
```

**Fix:**
```bash
# Use cloud for parallel, Ollama for one
# Terminal 1
ccc-sonnet  # Cloud-based, no RAM issue

# Terminal 2
ccc-gpt     # Cloud-based, no RAM issue

# Terminal 3 (only if needed)
cco         # Local, uses RAM
```

**Rule:** Only one Ollama session at a time.

### Anti-Pattern 7: Forgetting copilot-api Auto-Start

**Symptom:** `ccc` fails randomly after reboots.

**Example:**
```bash
# After reboot
ccc
# ERROR: copilot-api not running on :4141

# Have to remember to start manually every time
copilot-api start
```

**Fix:**
```bash
# Set up auto-start ONCE (macOS)
# Create ~/Library/LaunchAgents/com.copilot-api.plist
# (see Performance Optimization section for full plist)

launchctl load ~/Library/LaunchAgents/com.copilot-api.plist

# Now copilot-api starts automatically
```

**Rule:** Automate what you use daily.

### Anti-Pattern 8: No Cost Tracking

**Symptom:** Surprise bills, no visibility into spending.

**Example:**
```bash
# Just use whatever, whenever
ccd --model opus  # Multiple times daily
# End of month: $300 bill, surprise!
```

**Fix:**
```bash
# Weekly cost check
cc-cost-check() {
  echo "This week:"
  echo "  Copilot: $(grep mode=copilot ~/.claude/claude-switch.log | grep "$(date +%Y-%m)" | wc -l) sessions"
  echo "  Anthropic: $(grep mode=direct ~/.claude/claude-switch.log | grep "$(date +%Y-%m)" | wc -l) sessions"
  echo "Check Anthropic dashboard for $$ amount"
}

# Run every Monday
cc-cost-check
```

**Rule:** Track spending, don't discover it.

---

## Quick Reference Card

### Daily Commands

```bash
ccs           # Check provider status (start here)
ccc           # Daily work (Copilot Sonnet, free)
ccc-haiku     # Quick questions (fastest, free)
ccc-opus      # Code reviews (best quality, free)
ccd           # Critical analysis (Anthropic, paid)
cco           # Sensitive code (local, free)
```

### Model Selection Decision Tree

```
Task type?
├─ Quick question → ccc-haiku
├─ Feature implementation → ccc-sonnet (or just ccc)
├─ Code review → ccc-opus
├─ Security-critical → ccd --model opus
└─ Trade secret → cco
```

### Cost Optimization Rules

1. Default to Copilot (free)
2. Use Haiku for speed, Sonnet for balance
3. Reserve Opus/Anthropic for critical work only
4. Batch expensive reviews
5. Check `ccs` before debugging
6. Track costs weekly

### Security Decision Tree

```
Code sensitivity?
├─ Public/open-source → ccc, ccd, cco (any)
├─ Internal business logic → ccc, ccd (check policy)
├─ Trade secret/NDA → cco (local only)
└─ Regulated (HIPAA, PCI) → cco + manual audit
```

### Performance Checklist

- [ ] copilot-api running (for `ccc`): `nc -zv localhost 4141`
- [ ] Ollama context configured (for `cco`): `echo $OLLAMA_CONTEXT_LENGTH` should show `32768`
- [ ] Using appropriate model size for hardware
- [ ] Not running multiple Ollama sessions
- [ ] MCP profiles generated for GPT models

---

## Conclusion

Effective use of cc-copilot-bridge requires:

1. **Strategic thinking**: Match provider and model to task requirements
2. **Cost discipline**: Default to free, escalate consciously
3. **Security awareness**: Classify code sensitivity, choose provider accordingly
4. **Performance optimization**: Configure tools properly, monitor health
5. **Team coordination**: Standardize practices, share configurations

**Remember**: The most expensive model isn't always the best choice. Use the right tool for each task, and you'll maximize value while minimizing costs.

---

## Related Documentation

- [Quick Start Guide](../QUICKSTART.md) - Get started in 2 minutes
- [Model Switching Guide](MODEL-SWITCHING.md) - Dynamic model selection
- [Decision Trees](DECISION-TREES.md) - Task-to-command mapping
- [FAQ](FAQ.md) - Common questions answered
- [Troubleshooting](TROUBLESHOOTING.md) - Problem resolution
- [MCP Profiles](MCP-PROFILES.md) - Advanced MCP configuration
- [Ollama Optimization](OPTIMISATION-M4-PRO.md) - Apple Silicon tuning

**Back to**: [Documentation Index](README.md) | [Main README](../README.md)
