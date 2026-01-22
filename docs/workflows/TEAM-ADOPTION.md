# Team Adoption Guide

**Reading time**: 20 minutes | **Skill level**: Intermediate | **Last updated**: 2026-01-22

Complete guide for teams adopting cc-copilot-bridge across the organization.

---

## 📋 Table of Contents

- [Pre-Adoption Planning](#pre-adoption-planning)
- [Pilot Program](#pilot-program)
- [Team Rollout](#team-rollout)
- [Training & Onboarding](#training--onboarding)
- [Usage Guidelines](#usage-guidelines)
- [Cost Management](#cost-management)
- [Success Metrics](#success-metrics)

---

## Pre-Adoption Planning

### 1. Assess Team Readiness

**Questions to answer**:
- ✅ Do we have GitHub Copilot Pro+ for the team?
- ✅ Are developers comfortable with Claude Code CLI?
- ✅ What's our data sensitivity policy?
- ✅ Do we need offline capabilities?

**Team size considerations**:
| Team Size | Recommendation |
|-----------|----------------|
| 1-5 devs | Start immediately, informal adoption |
| 6-20 devs | Pilot with 3-5 devs first |
| 20+ devs | Formal pilot → phased rollout |

---

### 2. Calculate Costs

**Per-developer monthly cost**:

| Option | Cost/Dev/Month | What's Included |
|--------|----------------|-----------------|
| **Copilot Pro** | $10 | 300 premium requests/month |
| **Copilot Pro+** | $39 | 1,500 premium requests/month |
| **Anthropic Direct** | Per-token | Pay-per-token, official API |
| **Ollama** | $0 | Self-hosted, requires hardware |

**Important**: Copilot has quota limits with model multipliers. See [Pricing & Limits](../../README.md#-github-copilot-pricing--limits).

**Team of 10 developers** (example):
- Copilot Pro: $100/month (3,000 total requests)
- Copilot Pro+: $390/month (15,000 total requests)
- Anthropic Direct: Varies by usage

**Note**: Using copilot-api may violate GitHub ToS. See [Risk Disclosure](../../README.md#-risk-disclosure).

---

### 3. Define Usage Policy

**Create team guidelines**:

```markdown
# Team cc-copilot-bridge Usage Policy

## Default Provider
- **Daily development**: `ccc` (Copilot)
- **Code reviews**: `ccc-opus` (Copilot)
- **Critical/production**: `ccd` (Anthropic Direct)

## Data Sensitivity Rules
- Public repos: Any provider OK
- Internal tools: Copilot or Anthropic
- **Confidential code**: `cco` (Ollama) ONLY

## Model Selection
- Quick tasks: `ccc-haiku`
- Standard work: `ccc-sonnet` (default)
- Code reviews: `ccc-opus`
- Alternative view: `ccc-gpt`

## Prohibited
- ❌ Never use with customer data
- ❌ Never paste API keys or secrets
- ❌ Never use for NDA-protected code (use Ollama)
```

---

## Pilot Program

### Phase 1: Select Pilot Team (Week 1)

**Ideal pilot participants**:
- ✅ Early adopters comfortable with CLI tools
- ✅ Mix of junior/senior developers
- ✅ Active in code reviews
- ✅ Good communicators for feedback

**Pilot size**: 3-5 developers

---

### Phase 2: Pilot Setup (Week 1)

**Installation session** (1 hour):

```bash
# 1. Group installation session
# Share screen, walk through:
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash

# 2. Verify everyone's installation
ccs  # Check status together

# 3. First test together
ccc
❯ Hello! Can you help me with code?
```

**Distribute**:
- [Quick Start Guide](../QUICKSTART.md)
- [Cheatsheet](../CHEATSHEET.md) (print for each dev)
- [Decision Trees](../DECISION-TREES.md)

---

### Phase 3: Pilot Usage (Weeks 2-3)

**Daily check-ins** (15 min standup):
- What worked well?
- What was confusing?
- Any issues encountered?

**Track metrics**:
```bash
# Each pilot participant tracks:
- Sessions per day
- Provider usage (ccc vs ccd vs cco)
- Time saved (estimate)
- Issues encountered
```

**Mid-pilot survey** (Week 2):
```
1. How often do you use cc-copilot-bridge? (daily/weekly/rarely)
2. Which provider do you use most? (ccc/ccd/cco)
3. Has it improved your productivity? (scale 1-5)
4. Biggest pain point?
5. Would you recommend to team? (yes/no/maybe)
```

---

### Phase 4: Pilot Review (Week 4)

**Retrospective** (1 hour meeting):

**Discuss**:
- ✅ What worked?
- ❌ What didn't?
- 💡 Improvements needed?
- 📊 Productivity impact?
- 💰 Cost analysis?

**Decision checkpoint**:
- **Go**: Roll out to entire team
- **Iterate**: Another 2-week pilot with changes
- **No-go**: Not a fit for our team (rare)

---

## Team Rollout

### Week 1: Announce & Prepare

**Send team announcement**:

```markdown
Subject: New Tool: cc-copilot-bridge for AI-Powered Development

Team,

We're rolling out cc-copilot-bridge - a tool that connects GitHub Copilot to Claude Code CLI.

**What you get:**
- FREE access to 25+ AI models (with our Copilot Pro+ subscription)
- Faster code reviews and implementation
- Offline mode for sensitive code

**Next steps:**
1. Attend Friday's training session (2pm, 1 hour)
2. Read Quick Start Guide: [link]
3. Install before the session

**Training session:** Friday 2pm (required)
**Questions:** #ai-tools Slack channel

Looking forward to seeing the productivity gains!
```

---

### Week 1: Training Session (2 hours)

**Agenda**:

**Part 1: Installation (30 min)**
- Live walkthrough
- Troubleshoot issues
- Verify everyone working

**Part 2: Core Concepts (30 min)**
- Provider overview (ccd vs ccc vs cco)
- Model selection (opus vs sonnet vs haiku)
- Decision tree walkthrough

**Part 3: Hands-On Practice (45 min)**
- Everyone runs same prompts
- Compare results
- Q&A

**Part 4: Team Guidelines (15 min)**
- Usage policy review
- Data sensitivity rules
- Support channels

**Materials provided**:
- ✅ Printed cheatsheet for everyone
- ✅ Slack channel: #cc-copilot-bridge
- ✅ Internal wiki page
- ✅ Video recording of session

---

### Weeks 2-4: Supported Rollout

**Daily office hours** (30 min):
- Mon/Wed/Fri 10am
- Drop-in Q&A
- Troubleshooting help

**Weekly tips** (Slack):
```
Monday: "💡 Tip of the Week"
- Week 1: Use ccc-haiku for quick questions
- Week 2: Use ccc-opus for code reviews
- Week 3: Set up Ollama for private code
- Week 4: Create custom workflows
```

**Success stories** (Share in Slack):
```
"@john used cc-copilot-bridge to review 500 lines of legacy code
in 10 minutes. Caught 3 bugs before they hit production! 🎉"
```

---

## Training & Onboarding

### New Developer Onboarding Checklist

**Day 1: Installation**
```bash
# Onboarding buddy walks through:
□ Install cc-copilot-bridge
□ Verify with ccs
□ First successful session with ccc
□ Bookmark documentation
```

**Week 1: Basics**
```
□ Read Quick Start Guide
□ Memorize 4 core commands (ccd, ccc, cco, ccs)
□ Complete 5 real tasks with ccc
□ Print and review cheatsheet
```

**Week 2: Best Practices**
```
□ Read Best Practices guide
□ Try all 3 models (opus, sonnet, haiku)
□ Review code with ccc-opus
□ Learn decision tree
```

**Week 3: Advanced**
```
□ Set up Ollama for private code (if needed)
□ Learn model switching
□ Customize workflow
□ Share tip with team
```

---

### Training Resources

**Essential** (must-read):
1. [Quick Start Guide](../QUICKSTART.md) - 5 min
2. [Cheatsheet](../CHEATSHEET.md) - 2 min
3. [Decision Trees](../DECISION-TREES.md) - 5 min

**Recommended** (read within 2 weeks):
4. [Best Practices](../BEST-PRACTICES.md) - 20 min
5. [Daily Workflow](DAILY-DEV.md) - 10 min
6. [FAQ](../FAQ.md) - Browse as needed

**Advanced** (optional):
7. [Architecture](../ARCHITECTURE.md) - For curious devs
8. [MCP Profiles](../MCP-PROFILES.md) - Advanced users only

---

## Usage Guidelines

### Team Standards

**Command naming convention**:
```bash
# Use team-standard aliases
ccc          # Daily work (not: ccc-sonnet)
ccc-opus     # Code reviews
ccc-haiku    # Quick questions
cco          # Confidential code
```

**Provider selection by project**:

| Project Type | Allowed Providers | Reasoning |
|--------------|-------------------|-----------|
| Open source | `ccc`, `ccd`, `cco` | Any provider OK |
| Internal tools | `ccc`, `ccd` | Cloud OK |
| Client projects | Check contract | May require Ollama |
| Confidential | `cco` only | Must be 100% private |

---

### Code Review Standards

**Before PR**:
```bash
# Required: Review with Opus
ccc-opus
❯ Review all changes for:
  - Security vulnerabilities
  - Performance issues
  - Code quality
  - Test coverage
```

**Recommended workflow**:
1. Implement with `ccc-sonnet`
2. Self-review with `ccc-opus`
3. Fix issues found
4. Create PR

**PR description template**:
```markdown
## Changes
[Description]

## AI Review
- ✅ Security check (ccc-opus): No issues
- ✅ Performance review (ccc-opus): Optimized
- ✅ Code quality (ccc-opus): Approved

## Testing
[Test results]
```

---

## Cost Management

### Monthly Cost Tracking

**Team dashboard** (spreadsheet):

| Developer | Copilot Sessions | Anthropic Sessions | Est. Anthropic Cost |
|-----------|------------------|--------------------|---------------------|
| Alice | 45 | 5 | $8 |
| Bob | 52 | 12 | $15 |
| Carol | 38 | 0 | $0 |
| **Total** | **135** | **17** | **$23** |

**Track with script**:
```bash
# Monthly cost report
for dev in alice bob carol; do
  echo "$dev:"
  echo "  Copilot: $(grep "mode=copilot" ~/.claude/claude-switch-$dev.log | wc -l)"
  echo "  Anthropic: $(grep "mode=direct" ~/.claude/claude-switch-$dev.log | wc -l)"
done
```

---

### Cost Optimization Strategies

**1. Default to Copilot**
```bash
# Team default: Uses Copilot quota
ccc  # Not ccd
```

**2. Reserve Anthropic for Critical**
```bash
# Only use ccd for:
- Production deployments
- Security audits
- Critical architecture decisions
```

**3. Bulk Reviews with Opus**
```bash
# Instead of multiple Anthropic calls, use Copilot Opus:
ccc-opus  # Free, high quality
```

**Potential savings**: $500-2000/month for 10-developer team

---

## Success Metrics

### Track Team Impact

**Quantitative metrics**:
```
- Time to implement feature (before/after)
- Code review turnaround time
- Bugs caught pre-production
- Lines of code reviewed per week
- Developer satisfaction score
```

**Qualitative feedback**:
```
- Weekly pulse survey (1-5 rating)
- Monthly retrospectives
- Feature requests
- Pain points
```

---

### Monthly Team Review

**Report template**:

```markdown
# cc-copilot-bridge Monthly Report

## Usage Stats
- Total sessions: 450
- Developers active: 10/10 (100%)
- Copilot/Anthropic/Ollama: 85%/10%/5%

## Cost
- Copilot Pro+: $100 (team subscription)
- Anthropic usage: $45
- **Total: $145** (vs $350 Anthropic-only estimate)
- **Savings: $205/month**

## Impact
- ✅ 30% faster code reviews (estimate)
- ✅ 15 bugs caught pre-production
- ✅ 98% developer satisfaction

## Issues
- 2 developers had Ollama slow issues → switched to Copilot
- 1 MCP compatibility issue → using Claude models now

## Actions
- Schedule advanced training session
- Update team guidelines based on feedback
```

---

## Troubleshooting Team Issues

### Common Team Challenges

**"Some devs not using it"**
- **Solution**: Pair with power users, show real wins
- **Action**: Weekly "win sharing" in standup

**"Confusion about which command"**
- **Solution**: Print decision tree, post in office
- **Action**: Simplify to 2 commands: ccc (default), cco (private)

**"Costs higher than expected"**
- **Solution**: Audit Anthropic usage, push Copilot
- **Action**: Team training on provider selection

**"Quality concerns"**
- **Solution**: Emphasize model selection (opus for reviews)
- **Action**: Code review standards with Opus

---

## 📚 Resources for Team Leads

**Planning**:
- [Cost Comparison](../README.md#cost-comparison)
- [FAQ](../FAQ.md)

**Training**:
- [Quick Start](../QUICKSTART.md)
- [Cheatsheet](../CHEATSHEET.md)
- [Daily Workflow](DAILY-DEV.md)

**Ongoing**:
- [Best Practices](../BEST-PRACTICES.md)
- [Troubleshooting](../TROUBLESHOOTING.md)

---

**Related Documentation**:
- [Daily Development Workflow](DAILY-DEV.md)
- [Best Practices](../BEST-PRACTICES.md)
- [Security Guide](../SECURITY.md)

**Back to**: [Documentation Index](../README.md) | [Main README](../../README.md)
