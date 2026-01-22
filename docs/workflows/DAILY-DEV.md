# Daily Development Workflow

**Reading time**: 10 minutes | **Skill level**: Beginner | **Last updated**: 2026-01-22

Practical guide for using cc-copilot-bridge in your daily development routine.

---

## 🌅 Morning Routine (Exploration & Planning)

### Start Your Day Fast

**Goal**: Quickly understand what you need to work on

```bash
# Morning: Use Haiku for fast exploration
ccc-haiku
```

**Typical tasks**:
```
❯ Summarize the changes in the last 5 commits
❯ What files were modified yesterday?
❯ Show me the open GitHub issues for this project
❯ List all TODOs in the codebase
❯ Help me understand this module [paste code]
```

**Why Haiku?**
- ⚡ Fastest responses (1-2s)
- ✅ Good enough for exploration
- 💰 Free (Copilot Pro+ subscription)

**Time saved**: 15-30 minutes vs manual review

---

## 🏗️ Mid-Morning (Feature Implementation)

### Switch to Sonnet for Balanced Work

**Goal**: Implement features efficiently with good quality

```bash
# Implementation: Use Sonnet (balanced)
ccc-sonnet
# or just: ccc
```

**Typical tasks**:
```
❯ Implement user authentication with JWT
❯ Add validation to this form
❯ Fix bug: [describe bug with error message]
❯ Refactor this function for better readability
❯ Add tests for this component
❯ Generate API documentation from this code
```

**Why Sonnet?**
- ⚖️ Best balance quality/speed
- ✅ Reliable for production code
- 💰 1x quota multiplier (uses your Copilot quota)
- 🔧 100% MCP compatible

**Pro tip**: Use `ccc-gpt` for routine tasks (0x = doesn't consume quota)

---

## 🍕 Lunch Break (Let It Think)

### Long-Running Tasks

If you have complex analysis tasks, start them before lunch:

```bash
# Start long task
ccc-opus
❯ Analyze this entire codebase for security vulnerabilities
❯ Propose a refactoring plan for the auth module
```

**Why Opus?**
- 🧠 Best reasoning for complex tasks
- ⏰ Takes longer, but lunch break absorbs wait time
- 💰 Still free with Copilot

---

## ☀️ Afternoon (Focused Implementation)

### Power Through Feature Work

```bash
# Continue with Sonnet for implementation
ccc
```

**Workflow pattern**:

1. **Plan** (5 min):
   ```
   ❯ Help me plan implementing [feature]
   ❯ What edge cases should I consider?
   ```

2. **Implement** (60-90 min):
   ```
   ❯ Implement the login form with validation
   ❯ Add error handling for network failures
   ❯ Write tests for this new function
   ```

3. **Verify** (10 min):
   ```
   ❯ Review this code for potential bugs
   ❯ Are there any security issues?
   ```

4. **Document** (5 min):
   ```
   ❯ Generate JSDoc comments for this file
   ❯ Update README with new feature
   ```

---

## 🌆 Late Afternoon (Code Review)

### Switch to Opus for Quality

**Goal**: Ensure code quality before commit/PR

```bash
# Code review: Use Opus (best quality)
ccc-opus
```

**Pre-commit checklist**:
```
❯ Review all changes I made today for security issues
❯ Check for performance problems in this code
❯ Are there any edge cases I missed?
❯ Suggest improvements for code readability
❯ Check test coverage completeness
```

**Why Opus?**
- 🔍 Most thorough analysis
- 🛡️ Best security detection
- ✅ Catches subtle issues
- 💰 Free (Copilot)

**Time investment**: 10-15 minutes
**Value**: Catches bugs before review

---

## 🌙 End of Day (Cleanup & Documentation)

### Document Your Work

```bash
# Quick tasks: Use Haiku
ccc-haiku
```

**Closing tasks**:
```
❯ Generate a commit message for my changes
❯ Write PR description summarizing today's work
❯ Update CHANGELOG with today's changes
❯ Create a summary of what I accomplished today
```

**Final check**:
```bash
# Check status of all providers (for tomorrow)
ccs

# View today's session logs
grep "$(date '+%Y-%m-%d')" ~/.claude/claude-switch.log
```

---

## 📊 Daily Workflow Summary

| Time | Phase | Command | Tasks |
|------|-------|---------|-------|
| **9:00 AM** | Exploration | `ccc-haiku` | Review commits, plan day |
| **9:30 AM** | Implementation | `ccc` | Feature development |
| **12:00 PM** | Complex analysis | `ccc-opus` | Security audits |
| **1:00 PM** | Implementation | `ccc` | Continue features |
| **4:00 PM** | Code review | `ccc-opus` | Pre-commit review |
| **5:00 PM** | Documentation | `ccc-haiku` | Commit messages, PR |

**Total cost**: $0 (included in Copilot Pro+ $10/month)

---

## 🎯 Task-Based Quick Reference

### Quick Questions
```bash
ccc-haiku
❯ What does this function do?
❯ How do I use this library?
```

### Feature Implementation
```bash
ccc
❯ Implement [feature]
❯ Add [functionality]
```

### Bug Fixes
```bash
ccc
❯ Fix bug: [error message]
❯ Debug why [behavior]
```

### Code Review
```bash
ccc-opus
❯ Review this code
❯ Security audit
```

### Refactoring
```bash
ccc
❯ Refactor this for readability
❯ Extract this into reusable function
```

### Documentation
```bash
ccc-haiku
❯ Generate docs
❯ Write README section
```

---

## 💡 Pro Tips

### 1. Keep Sessions Open

Don't exit Claude Code between tasks:
```bash
# Start in morning
ccc

# Use all day
❯ [task 1]
❯ [task 2]
❯ [task 3]

# Exit at end of day
/exit
```

### 2. Use Multiple Terminals

Run different models in parallel:
```bash
# Terminal 1: Main work
ccc

# Terminal 2: Quick questions
ccc-haiku

# Terminal 3: Background analysis
ccc-opus
```

### 3. Private Code Separate

Keep proprietary code in separate session:
```bash
# Terminal 1: Public/internal code
ccc

# Terminal 2: Confidential code
cco  # Ollama (100% local)
```

### 4. Cost Tracking

All Copilot commands are free, but track Anthropic usage:
```bash
# Count Anthropic sessions (paid)
grep "mode=direct" ~/.claude/claude-switch.log | wc -l

# Count Copilot sessions (free)
grep "mode=copilot" ~/.claude/claude-switch.log | wc -l
```

---

## 🚫 Common Mistakes to Avoid

### ❌ Don't: Use Opus for Everything
```bash
# Wasteful - slow for simple tasks
ccc-opus
❯ What is 2+2?
```

### ✅ Do: Match Model to Task
```bash
# Efficient - fast model for simple task
ccc-haiku
❯ What is 2+2?
```

---

### ❌ Don't: Exit Between Small Tasks
```bash
ccc
❯ Task 1
/exit

ccc  # Restart for task 2 (loses context)
❯ Task 2
```

### ✅ Do: Keep Session Open
```bash
ccc
❯ Task 1
❯ Task 2  # Maintains context
❯ Task 3
```

---

### ❌ Don't: Use Ollama for Large Projects
```bash
# Will be very slow (2-6 min responses)
cco  # Large project with 60K context
```

### ✅ Do: Use Cloud for Large Projects
```bash
# Fast (1-3s responses)
ccc  # Large project
```

---

## 📈 Measuring Your Efficiency

### Track Your Patterns

```bash
# Session durations
grep "Session ended" ~/.claude/claude-switch.log | \
  awk '{print $7}' | \
  sort | uniq -c

# Most used provider
grep "Session started" ~/.claude/claude-switch.log | \
  grep "$(date '+%Y-%m-%d')" | \
  awk '{print $5}' | \
  sort | uniq -c
```

### Optimize Based on Data

- **>50% Opus usage?** → Try using Sonnet more (faster)
- **>30% Haiku usage?** → Good efficiency!
- **Using Ollama on large project?** → Switch to Copilot

---

## 🎓 Weekly Optimization

### Friday Afternoon Review

```bash
# Review week's usage
tail -100 ~/.claude/claude-switch.log

# Questions to ask:
# - Am I using the right models?
# - Any patterns to optimize?
# - Should I adjust workflow?
```

### Adjust Next Week

Based on findings:
- Slow tasks → Try faster model
- Quality issues → Upgrade model
- Cost concerns → More Copilot, less Anthropic

---

## 📚 Next Steps

**Customize your workflow**:
- Add to [Best Practices](BEST-PRACTICES.md)
- Share with team: [Team Adoption](TEAM-ADOPTION.md)
- Optimize performance: [Performance Guide](../OPTIMISATION-M4-PRO.md)

**Learn more**:
- [Model Switching Guide](../MODEL-SWITCHING.md)
- [Decision Trees](DECISION-TREES.md)
- [FAQ](FAQ.md)

---

**Related Documentation**:
- [Best Practices](BEST-PRACTICES.md)
- [Team Adoption Guide](TEAM-ADOPTION.md)
- [Command Reference](../COMMANDS.md)

**Back to**: [Documentation Index](../README.md) | [Main README](../../README.md)
