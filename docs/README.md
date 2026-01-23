# cc-copilot-bridge Documentation

Complete documentation index for cc-copilot-bridge - Bridge GitHub Copilot to Claude Code CLI.

---

## 🚀 Getting Started (Essential Reading)

**New to cc-copilot-bridge? Start here:**

| Document | Reading Time | Skill Level | Description |
|----------|--------------|-------------|-------------|
| [Installation & Setup](../QUICKSTART.md) | 5 min | Beginner | Get cc-copilot-bridge running in 2 minutes |
| [First Commands](COMMANDS.md) | 10 min | Beginner | Learn essential commands for daily use |
| [Quick Reference](CHEATSHEET.md) | 2 min | All levels | One-page printable command reference |

**Next steps after installation:**
1. Check provider status: `ccs`
2. Try your first session: `ccc`
3. Review [Decision Trees](DECISION-TREES.md) to choose the right command

---

## 📖 Core Concepts

**Understand how cc-copilot-bridge works:**

| Document | Reading Time | Skill Level | Description |
|----------|--------------|-------------|-------------|
| [Model Switching](MODEL-SWITCHING.md) | 15 min | Intermediate | Dynamic model selection strategies (25+ models) |
| [MCP Profiles System](MCP-PROFILES.md) | 20 min | Advanced | Compatibility system for strict validation models |
| [Architecture Overview](../README.md#architecture-overview) | 5 min | All levels | How the bridge connects providers |

**Key concepts:**
- **Provider**: Backend service (Anthropic Direct, Copilot, Ollama)
- **Model**: AI model within provider (Opus, Sonnet, Haiku, GPT-4.1, etc.)
- **MCP Profile**: Configuration for model compatibility
- **Session**: Single Claude Code CLI execution

---

## 🎯 By Use Case

**Find documentation for your specific scenario:**

### Daily Development
- [Commands Reference](COMMANDS.md) - All available commands
- [Best Practices](BEST-PRACTICES.md) - Strategic model selection
- [Workflows](workflows/) - Common development patterns

### Features & Roadmap
- [Features Showcase](FEATURES.md) - Complete feature demonstration
- [Roadmap](ROADMAP.md) - Future plans and ideas

### Cost Optimization
- [Cost Comparison](../README.md#cost-comparison) - Provider pricing analysis
- [Strategic Selection](BEST-PRACTICES.md#strategic-model-selection) - When to use which provider

### Performance & Optimization
- [Apple Silicon Optimization](OPTIMISATION-M4-PRO.md) - M1/M2/M3/M4 tuning
- [Ollama Performance](TROUBLESHOOTING.md#ollama-extremely-slow) - Context size optimization

### Troubleshooting
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues & solutions
- [FAQ](FAQ.md) - Frequently asked questions

### Team & Enterprise
- [Team Adoption](workflows/TEAM-ADOPTION.md) - Onboarding guide
- [Security & Privacy](SECURITY.md) - Data flow and privacy implications
- [CI/CD Integration](workflows/CI-CD.md) - Automated workflows

---

## 🔧 Advanced Topics

**Deep dives for power users:**

| Document | Reading Time | Skill Level | Description |
|----------|--------------|-------------|-------------|
| [Architecture Deep Dive](ARCHITECTURE.md) | 20 min | Advanced | How cc-copilot-bridge works internally |
| [MCP Profiles](MCP-PROFILES.md) | 20 min | Advanced | Custom profile generation |
| [Performance Tuning](OPTIMISATION-M4-PRO.md) | 15 min | Advanced | Apple Silicon optimization |
| [Security](SECURITY.md) | 15 min | Intermediate | Privacy and data flow analysis |

**Advanced techniques:**
- Custom MCP profile creation
- Multi-provider workflows
- Performance benchmarking
- Network monitoring

---

## 📋 Reference Materials

**Quick lookups and comparisons:**

| Document | Type | Description |
|----------|------|-------------|
| [Cheatsheet](CHEATSHEET.md) | Quick Reference | One-page printable command reference |
| [Commands](COMMANDS.md) | Reference | Complete command documentation |
| [FAQ](FAQ.md) | Q&A | 30+ common questions answered |
| [Decision Trees](DECISION-TREES.md) | Visual Guide | Choose the right command/model |
| [Comparison](COMPARISON.md) | Analysis | cc-copilot-bridge vs alternatives |

---

## 🎓 Learning Path

**Progressive learning from beginner to expert:**

### 1️⃣ Beginner (Week 1)
**Goal**: Get comfortable with basic usage

- ✅ Complete [QUICKSTART.md](../QUICKSTART.md)
- ✅ Memorize 4 core commands (`ccd`, `ccc`, `cco`, `ccs`)
- ✅ Read [COMMANDS.md](COMMANDS.md)
- ✅ Bookmark [CHEATSHEET.md](CHEATSHEET.md)

**Practice**: Use `ccc` for 1 week of daily development

### 2️⃣ Intermediate (Week 2-3)
**Goal**: Master model selection and optimization

- ✅ Read [MODEL-SWITCHING.md](MODEL-SWITCHING.md)
- ✅ Understand [Decision Trees](DECISION-TREES.md)
- ✅ Learn [Best Practices](BEST-PRACTICES.md)
- ✅ Review [Cost Optimization](BEST-PRACTICES.md#cost-optimization)

**Practice**: Use different models for different tasks (opus for reviews, haiku for quick questions)

### 3️⃣ Advanced (Week 4+)
**Goal**: Optimize performance and customize setup

- ✅ Read [ARCHITECTURE.md](ARCHITECTURE.md)
- ✅ Study [MCP-PROFILES.md](MCP-PROFILES.md)
- ✅ Optimize with [OPTIMISATION-M4-PRO.md](OPTIMISATION-M4-PRO.md)
- ✅ Create custom workflows

**Practice**: Create team documentation and custom configurations

---

## 🆘 Help & Support

**When you need assistance:**

1. **Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - 10+ common issues with solutions
2. **Search [FAQ.md](FAQ.md)** - 30+ frequently asked questions
3. **Use [Decision Trees](DECISION-TREES.md)** - Visual problem-solving guides
4. **Open [GitHub Issue](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)** - Report bugs or request features

**Debug checklist:**
```bash
# 1. Check status
ccs

# 2. Verify installation
which claude-switch

# 3. Check logs
tail ~/.claude/claude-switch.log

# 4. Test providers individually
ccd  # Anthropic
ccc  # Copilot
cco  # Ollama
```

---

## 📚 Additional Resources

### Research & Analysis
- [Competitive Analysis](research/COMPETITIVE-ANALYSIS.md) - Comparison with similar tools
- [Technical Analysis](research/ANALYSIS.md) - Architecture decisions
- [AgentAPI vs copilot-api](research/AGENTAPI-VS-COPILOT-API.md) - Complementary tools comparison

### Contributing
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community guidelines

### Legal & Compliance
- [LICENSE](../LICENSE) - MIT License
- [Security Policy](SECURITY.md) - Data privacy and security

---

## 🗺️ Documentation Map

Visual overview of documentation structure:

```
cc-copilot-bridge/
├── README.md ················ Main repository overview
├── QUICKSTART.md ············ 5-minute setup guide
├── CHANGELOG.md ············· Version history
├── CLAUDE.md ················ AI assistant context
└── docs/
    ├── README.md ············ THIS FILE - Documentation index
    │
    ├── Getting Started
    │   ├── CHEATSHEET.md ···· One-page reference
    │   ├── COMMANDS.md ······ Command reference
    │   ├── DECISION-TREES.md  Visual decision guides
    │   └── FAQ.md ··········· Frequently asked questions
    │
    ├── Core Concepts
    │   ├── MODEL-SWITCHING.md Model selection guide
    │   ├── MCP-PROFILES.md ·· Compatibility system
    │   ├── BEST-PRACTICES.md  Strategic usage
    │   └── FEATURES.md ······ Complete feature showcase
    │
    ├── Advanced
    │   ├── ARCHITECTURE.md ·· Internal workings
    │   ├── OPTIMISATION-M4-PRO.md Apple Silicon tuning
    │   ├── SECURITY.md ······ Privacy & data flow
    │   ├── COMPARISON.md ···· vs alternatives
    │   └── ROADMAP.md ······· Future plans and ideas
    │
    ├── Community
    │   ├── CONTRIBUTING.md ·· How to contribute
    │   └── CODE_OF_CONDUCT.md Community guidelines
    │
    ├── Troubleshooting
    │   └── TROUBLESHOOTING.md Common issues
    │
    ├── Workflows
    │   ├── DAILY-DEV.md ····· Daily development
    │   ├── TEAM-ADOPTION.md · Team onboarding
    │   └── CI-CD.md ········· Automation
    │
    └── Research
        ├── COMPETITIVE-ANALYSIS.md
        ├── ANALYSIS.md
        └── AGENTAPI-VS-COPILOT-API.md
```

---

## 📝 Documentation Standards

All documentation follows these standards:

- **Reading time** - Estimated time to read document
- **Skill level** - Beginner/Intermediate/Advanced
- **Prerequisites** - What you need to know first
- **Related docs** - Cross-references to related content
- **Next steps** - Where to go after this document

---

## 🔄 Recently Updated

- **2026-01-22**: Documentation index created
- **2026-01-22**: v1.2.0 release (MCP Profiles + System Prompts)
- **2026-01-21**: Initial release

[View full changelog →](../CHANGELOG.md)

---

**Back to**: [Main README](../README.md) | [Quick Start](../QUICKSTART.md) | [GitHub Repository](https://github.com/FlorianBruniaux/cc-copilot-bridge)
