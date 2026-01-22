# Ideas & Roadmap

> Research topics and future improvements for cc-copilot-bridge. Community-driven and prioritized.

---

## 🚀 In Progress

### v1.3.0 Planning

**Target**: February 2026

**Features under consideration**:
- [ ] Windows support (PowerShell port)
- [ ] Auto-update mechanism (`cc-copilot-bridge update`)
- [ ] Cost tracking dashboard (CLI-based)
- [ ] Model performance benchmarking

---

## 🔥 High Priority

### 1. Automated Testing Suite

**Why**: Ensure reliability across updates and platforms

**What to test**:
- Health checks for all 3 providers
- Model switching (25+ models)
- MCP profile generation
- Session logging
- Error handling

**Implementation**:
```bash
tests/
├── test-providers.sh       # Test ccd, ccc, cco
├── test-health-checks.sh   # Port availability, API keys
├── test-mcp-profiles.sh    # Profile generation
└── test-session-logs.sh    # Logging verification
```

**Effort**: 2-4 hours
**Impact**: High (prevents regressions)

---

### 2. GitHub Actions CI/CD

**Why**: Automate quality checks

**Workflows**:
- Shellcheck on all bash scripts
- Test on macOS and Linux
- Link validation in docs
- Release automation

**Implementation**:
```yaml
.github/workflows/
├── ci.yml              # Lint + test on push
├── docs-check.yml      # Validate documentation
└── release.yml         # Auto-release on tag
```

**Effort**: 3-5 hours
**Impact**: High (automated quality)

---

### 3. Homebrew Formula

**Why**: Standard installation for macOS users

**Implementation**:
```ruby
# Formula/cc-copilot-bridge.rb
class CcCopilotBridge < Formula
  desc "Bridge GitHub Copilot to Claude Code CLI"
  homepage "https://github.com/FlorianBruniaux/cc-copilot-bridge"
  url "https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/v1.2.0.tar.gz"
  sha256 "..."
  license "MIT"

  def install
    bin.install "claude-switch"
    # ...
  end
end
```

**Usage after**:
```bash
brew install FlorianBruniaux/tap/cc-copilot-bridge
```

**Effort**: 4-6 hours (includes tap setup)
**Impact**: Medium (easier installation)

---

## 💡 Medium Priority

### 4. VS Code Extension

**Why**: GUI for users who prefer visual interface

**Features**:
- Provider switcher in status bar
- Model selector dropdown
- Session history viewer
- Cost tracker dashboard

**Tech stack**: TypeScript + VS Code API

**Effort**: 20-40 hours
**Impact**: High (reaches non-CLI users)

---

### 5. Cost Tracking Dashboard

**Why**: Visualize spending across providers

**Features**:
```bash
cc-cost-dashboard
# Output:
┌─────────────────────────────────────┐
│   cc-copilot-bridge Cost Report    │
├─────────────────────────────────────┤
│ This Month:                         │
│   Copilot:    45 sessions  ($10)    │
│   Anthropic:  12 sessions  (~$24)   │
│   Ollama:     8 sessions   ($0)     │
│   Total:      $34                   │
├─────────────────────────────────────┤
│ Savings vs Anthropic-only: $31     │
└─────────────────────────────────────┘
```

**Implementation**: Bash script with session log analysis

**Effort**: 4-6 hours
**Impact**: Medium (helps cost optimization)

---

### 6. Docker Container

**Why**: Pre-configured environment for quick testing

**Features**:
- copilot-api pre-installed
- Ollama pre-installed
- cc-copilot-bridge configured
- All aliases ready

**Usage**:
```bash
docker run -it florianbruniaux/cc-copilot-bridge
# Container starts with all providers ready
ccs  # Shows all green
```

**Effort**: 6-8 hours
**Impact**: Medium (easier onboarding)

---

## 🌟 Lower Priority

### 7. Model Performance Benchmarking

**Why**: Help users choose optimal model for task

**Features**:
```bash
cc-benchmark
# Runs same prompt on all models, measures:
- Response time
- Quality score (LLM-as-judge)
- Token usage
- Cost per task
```

**Effort**: 10-15 hours
**Impact**: Low (nice-to-have)

---

### 8. Web Dashboard

**Why**: Real-time monitoring and analytics

**Features**:
- Live session monitoring
- Usage graphs (daily/weekly/monthly)
- Cost projections
- Provider health dashboard

**Tech stack**: Next.js + Tailwind + Recharts

**Effort**: 40-60 hours
**Impact**: Low (most users prefer CLI)

---

### 9. PowerShell Port (Windows)

**Why**: Reach Windows developers

**Implementation**:
```powershell
# claude-switch.ps1
param(
    [string]$Mode,
    [string[]]$Args
)

switch ($Mode) {
    "direct"  { Run-Direct $Args }
    "copilot" { Run-Copilot $Args }
    "ollama"  { Run-Ollama $Args }
}
```

**Effort**: 15-25 hours (full port + testing)
**Impact**: Medium (Windows user base)

---

## 🔮 Future / Watching

### 10. Multi-Model Consensus

**Idea**: Run same prompt on multiple models, compare responses

**Example**:
```bash
cc-consensus "Optimize this function"
# Runs on: Claude Sonnet, GPT-4.1, Gemini
# Shows: 3 different approaches
# LLM-as-judge picks best
```

**Status**: Waiting for demand (0 requests so far)

---

### 11. Team Analytics Platform

**Idea**: Central dashboard for team usage

**Features**:
- Team-wide cost tracking
- Developer productivity metrics
- Model usage patterns
- Compliance reporting

**Status**: Requires enterprise demand

---

### 12. OpenRouter Integration

**Idea**: Add OpenRouter as 4th provider

**Pros**:
- Access to 100+ models
- Pay-per-token pricing
- Good for experimentation

**Cons**:
- Not free like Copilot
- Adds complexity
- Overlaps with Anthropic Direct

**Status**: Waiting for 5+ community requests

---

## 🚫 Discarded Ideas

| Idea | Reason Discarded |
|------|------------------|
| Slack integration | Out of scope - CLI tool focus |
| Model fine-tuning | Users don't control models |
| Custom model hosting | Infrastructure complexity |
| Browser extension | Different use case than CLI |
| Mobile app | Not suitable for coding workflow |
| Plugin system | Over-engineering for bash script |
| GraphQL API | Unnecessary complexity |

---

## Contributing Ideas

**Have a feature idea?**

1. **Check this file** - Maybe already listed
2. **Search issues** - Someone may have suggested it
3. **Open discussion** - Get community feedback
4. **Create issue** - If validated by discussion

**Good idea format**:
```markdown
## Feature Name

**Why it matters**: [Problem it solves]

**How it works**: [Brief implementation idea]

**Effort estimate**: [Hours/days]

**Impact**: [High/Medium/Low]

**Alternatives considered**: [Other approaches]
```

---

## Prioritization Criteria

Ideas are prioritized by:

1. **User demand**: How many users requested it?
2. **Impact**: How many users benefit?
3. **Effort**: How hard to implement?
4. **Maintenance**: Ongoing cost to maintain?
5. **Scope**: Fits project focus?

**Formula**: Priority = (Demand × Impact) / (Effort × Maintenance Cost)

---

## Roadmap Transparency

**Why public roadmap?**
- Community knows what's coming
- Avoid duplicate work
- Encourage relevant contributions
- Set expectations

**How to influence roadmap?**
- 👍 React to issues/discussions (+1 for features you want)
- 💬 Comment with use cases
- 🔧 Submit PR to implement
- 💰 Sponsor development (GitHub Sponsors)

---

## Research Topics

### Needed Research

**1. copilot-api `/responses` endpoint support**
- **Goal**: Enable GPT Codex models
- **Status**: Monitoring upstream PR
- **Link**: https://github.com/ericc-ch/copilot-api/pull/117

**2. MCP schema auto-fixing**
- **Goal**: Auto-normalize problematic MCP servers
- **Approach**: Proxy that fixes schemas on-the-fly
- **Complexity**: High

**3. Multi-provider load balancing**
- **Goal**: Distribute requests across providers
- **Use case**: Avoid rate limits, optimize cost
- **Complexity**: Medium

---

## Community Wishlist

**Most requested features** (from issues/discussions):

1. ⭐⭐⭐⭐⭐ (0 requests) - No requests yet (new project!)
2. Add your request to influence roadmap

**Vote**: React with 👍 on issues for features you want

---

## Contributing

Found something interesting? Add it with:
1. **Topic name** and why it matters
2. **Implementation approach** (brief)
3. **Effort estimate**
4. **Impact assessment**

Submit via PR or discussion!

---

**Last Updated**: 2026-01-22
**Maintained By**: @FlorianBruniaux
