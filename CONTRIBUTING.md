# Contributing to cc-copilot-bridge

Thanks for considering contributing to cc-copilot-bridge!

## How to Contribute

### Reporting Bugs

Use the [Bug Report template](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues/new?template=bug_report.yml) to report bugs.

**Before submitting:**
- Check [existing issues](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)
- Test with latest version
- Include full environment details

### Suggesting Features

Use the [Feature Request template](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues/new?template=feature_request.yml).

**Good feature requests:**
- Solve real problems
- Include use cases
- Consider existing workarounds

### Asking Questions

Use the [Question template](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues/new?template=question.yml) for:
- Usage questions
- Documentation clarifications
- General discussions

## Pull Requests

### Process

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/your-feature`
3. **Test** your changes thoroughly
4. **Commit** with clear messages: `git commit -m "Add X feature"`
5. **Push**: `git push origin feature/your-feature`
6. **Open a PR** with:
   - Clear description of changes
   - Link to related issue
   - Test results

### Code Standards

- **Shell scripts**: Use ShellCheck for linting
- **Bash**: POSIX-compatible where possible
- **Documentation**: Update relevant docs in `/docs`
- **Testing**: Add tests for new features

### Testing

Before submitting:

```bash
# Test all three providers
./scripts/test-providers.sh

# Test specific provider
ccd --version
ccc --version
cco --version

# Run health checks
ccs
```

## Development Setup

### Requirements

- Bash 4.0+
- jq (JSON processing)
- nc (netcat)
- Claude Code CLI

### Local Testing

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/cc-copilot-bridge.git
cd cc-copilot-bridge

# Install locally
./install.sh

# Test changes
source ~/.claude/aliases.sh
ccs
```

## Documentation

When adding features:
- Update README.md
- Add entries to relevant docs in `/docs`
- Update CHANGELOG.md
- Add examples to documentation

## Commit Message Format

```
type(scope): brief description

Detailed explanation (if needed)

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(ollama): add Granite4 support
fix(copilot): handle missing model env var
docs(readme): clarify Ollama setup steps
```

## Code of Conduct

### Our Standards

- Be respectful and constructive
- Focus on the problem, not the person
- Welcome newcomers
- Give credit where due

### Unacceptable Behavior

- Personal attacks
- Trolling or harassment
- Publishing private information
- Spam or off-topic content

## Questions?

- Open a [Question issue](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues/new?template=question.yml)
- Check [Discussions](https://github.com/FlorianBruniaux/cc-copilot-bridge/discussions)
- Review [Documentation](https://github.com/FlorianBruniaux/cc-copilot-bridge/tree/main/docs)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
