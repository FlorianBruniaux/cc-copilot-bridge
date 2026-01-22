# Contributing to cc-copilot-bridge

**Welcome!** Whether you're fixing a bug, adding a provider, or improving documentation, every contribution helps make cc-copilot-bridge better for the community.

## Quick Links

- [Report an Issue](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues/new)
- [Start a Discussion](https://github.com/FlorianBruniaux/cc-copilot-bridge/discussions)
- [Code of Conduct](./CODE_OF_CONDUCT.md)

---

## Ways to Contribute

| Type | Examples | Effort |
|------|----------|--------|
| **Report** | Bugs, compatibility issues, broken links | 2 min |
| **Improve** | Fix typos, clarify docs, update commands | 5-15 min |
| **Add Features** | New providers, model support, scripts | 30-120 min |
| **Enhance Docs** | New guides, translations, examples | 15-60 min |
| **Test** | Verify on different platforms, models | 10-30 min |

**Not sure where to start?** Check [issues labeled `good first issue`](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

---

## Reporting Issues

Found a bug or have a suggestion?

1. **Search existing issues** — Someone may have reported it
2. **Open a new issue** with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment:
     - OS (macOS/Linux)
     - Shell (bash/zsh)
     - Claude Code version: `claude --version`
     - cc-copilot-bridge version: `cat ~/bin/claude-switch | grep "^# Version"`

**Issue Templates**:
- Bug report
- Feature request
- Documentation improvement
- Provider/model request

---

## Pull Request Process

### 1. Fork & Clone

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/cc-copilot-bridge.git
cd cc-copilot-bridge
```

### 2. Create a Branch

```bash
git checkout -b fix/copilot-api-check
# or
git checkout -b feature/add-openrouter-provider
# or
git checkout -b docs/improve-faq
```

**Branch naming**:
- `fix/*` - Bug fixes
- `feat/*` - New features
- `docs/*` - Documentation
- `chore/*` - Maintenance

### 3. Make Changes

Follow [Development Guidelines](#development-guidelines) below.

### 4. Test Your Changes

**For script changes**:
```bash
# Test all providers
~/bin/claude-switch status

# Test specific provider
~/bin/claude-switch copilot
# Verify it works, then exit

# Check for bash errors
bash -n ~/bin/claude-switch
```

**For documentation**:
- Preview markdown rendering
- Test all code examples
- Verify all links work
- Run spell check

### 5. Commit

```bash
git add .
git commit -m "fix: improve copilot-api health check

- Added timeout parameter to nc command
- Better error messages when port unreachable
- Tested on macOS Sequoia and Ubuntu 24.04

Fixes #42"
```

**Commit message format**:
```
<type>: <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`

### 6. Submit PR

Include in PR description:
- **What**: Clear description of changes
- **Why**: Reason for the change
- **How**: Implementation approach (for complex changes)
- **Testing**: What you tested and results
- **Related**: Link to issues (Fixes #X, Closes #Y)

---

## Development Guidelines

### Code Style (Bash Scripts)

**Follow these patterns**:

```bash
#!/bin/bash
# Script description
# Usage: script-name <args>

set -euo pipefail  # REQUIRED: Strict error handling

# Use clear variable names
LOG_FILE="${HOME}/.claude/claude-switch.log"
NOT: log_file="~/.claude/claude-switch.log"

# Function naming
_private_function() {  # Prefix with _ for internal functions
  local var="value"    # Use local for function variables
}

public_function() {    # No prefix for exported functions
  ...
}

# Error handling
command || {
  echo "ERROR: Failed to run command"
  return 1
}
```

**Shellcheck compliance**:
```bash
# All scripts must pass shellcheck
shellcheck ~/bin/claude-switch
```

### Documentation Style

**Follow existing patterns**:

```markdown
# Document Title

**Reading time**: X minutes | **Skill level**: Level | **Last updated**: Date

---

## Section

[Content]

---

## Related Documentation

- [Doc 1](link)
- [Doc 2](link)

**Back to**: [Documentation Index](docs/README.md)
```

**Requirements**:
- Add reading time estimate
- Specify skill level (Beginner/Intermediate/Advanced)
- Include cross-links to related docs
- Add "Back to" navigation

### Testing Requirements

**Before submitting**:

- [ ] Script works on macOS
- [ ] Script works on Linux (if applicable)
- [ ] All providers tested (`ccs` shows all green)
- [ ] Documentation links work
- [ ] Code examples are copy-paste ready
- [ ] Shellcheck passes (for bash scripts)
- [ ] No breaking changes (or clearly documented)

---

## Adding New Providers

Want to add a new provider (e.g., OpenRouter, Vertex AI)?

**Steps**:

1. **Add provider function** in `claude-switch`:
```bash
_run_openrouter() {
  # Health check
  _check_openrouter || return 1

  # Set environment variables
  export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1"
  export ANTHROPIC_AUTH_TOKEN="${OPENROUTER_API_KEY}"

  # Session tracking
  _session_start "openrouter"
  claude "$@"
  local rc=$?
  _session_end $rc
  return $rc
}
```

2. **Add health check**:
```bash
_check_openrouter() {
  if [[ -z "${OPENROUTER_API_KEY}" ]]; then
    _log "ERROR" "OPENROUTER_API_KEY not set"
    return 1
  fi
  _log "INFO" "OpenRouter health: OK"
}
```

3. **Add to main() switch**:
```bash
case "${mode}" in
  # ...existing cases...
  or|openrouter) _run_openrouter "$@" ;;
esac
```

4. **Update documentation**:
- README.md (architecture diagram, providers table)
- QUICKSTART.md (setup instructions)
- docs/COMMANDS.md (new command)
- docs/FAQ.md (provider-specific Q&A)

5. **Test thoroughly** with all edge cases

6. **Submit PR** with complete testing documentation

---

## Adding Documentation

**For new guides**:

1. Follow template in `docs/TEMPLATE.md` (if exists)
2. Include metadata (reading time, skill level)
3. Add cross-links to related docs
4. Update `docs/README.md` index
5. Test all code examples
6. Add to navigation in parent docs

---

## Community Guidelines

### Be Respectful

- Constructive feedback only
- No personal attacks
- Assume good intentions
- Help newcomers

### Be Professional

- Test before submitting
- Clear, concise descriptions
- Follow existing patterns
- Document your changes

### Be Patient

- Maintainers are volunteers
- Reviews may take time
- Be open to feedback
- Iterate based on suggestions

---

## Recognition

**Contributors will be**:
- Listed in release notes
- Credited in commits (`Co-Authored-By`)
- Mentioned in CHANGELOG.md
- Thanked in community updates

**Significant contributions** may earn:
- Collaborator status
- Mention in README contributors section
- Featured in blog posts/announcements

---

## Development Setup

### Prerequisites

```bash
# Install dependencies
brew install shellcheck  # macOS
# or
apt-get install shellcheck  # Linux

# Install jq for JSON parsing
brew install jq

# Install testing tools
npm install -g copilot-api  # For testing Copilot provider
brew install ollama         # For testing Ollama provider
```

### Local Testing

```bash
# Test script locally
./claude-switch status

# Test installation script
./install.sh  # In a test directory

# Run shellcheck
shellcheck claude-switch install.sh scripts/*.sh

# Test all providers
./claude-switch direct
./claude-switch copilot
./claude-switch ollama
```

---

## Release Process

**For maintainers** (creating releases):

1. **Update VERSION**: `echo "1.3.0" > VERSION`
2. **Update CHANGELOG.md**: Add release notes
3. **Update version in scripts**: grep for old version, replace
4. **Test thoroughly**: All providers, all platforms
5. **Commit**: `git commit -m "chore: bump version to 1.3.0"`
6. **Tag**: `git tag -a v1.3.0 -m "Release v1.3.0"`
7. **Push**: `git push origin main --tags`
8. **Create GitHub Release**: Use CHANGELOG content

---

## Questions?

- **General questions**: [GitHub Discussions](https://github.com/FlorianBruniaux/cc-copilot-bridge/discussions)
- **Bug reports**: [GitHub Issues](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)
- **Security issues**: Email [florian.bruniaux@gmail.com](mailto:florian.bruniaux@gmail.com)

---

## Attribution

By contributing, you agree that your contributions will be licensed under the MIT License.

**Thank you for making cc-copilot-bridge better!** 🙏

---

**Related**:
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Development Guide](docs/ARCHITECTURE.md)
- [Documentation Index](docs/README.md)
