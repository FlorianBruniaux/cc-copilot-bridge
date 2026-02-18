# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.5.x   | :white_check_mark: |
| < 1.5   | :x:                |

## Security Considerations

### API Keys & Credentials

**cc-copilot-bridge does NOT store or transmit credentials.** It routes requests to:

1. **Anthropic Direct**: Uses `ANTHROPIC_API_KEY` from your environment
2. **GitHub Copilot**: Uses `copilot-api` which handles GitHub OAuth locally
3. **Ollama**: Local inference, no credentials needed

**Your credentials never pass through cc-copilot-bridge scripts.**

### Data Privacy

#### What's Logged

`~/.claude/claude-switch.log` contains:
- Timestamp
- Provider and model used
- Session duration
- Exit codes

**NOT logged:**
- API keys
- Code content
- User prompts or AI responses
- Personal information

#### Log Security

```bash
# Check log permissions (should be 600)
ls -l ~/.claude/claude-switch.log

# Clear logs
> ~/.claude/claude-switch.log

# Disable logging (edit scripts)
# Comment out logging lines in claude-switch
```

### Provider Security

#### Anthropic Direct
- Official API, encrypted HTTPS
- Keys stored in your environment only
- Full Anthropic security guarantees

#### GitHub Copilot (via copilot-api)
- **Third-party proxy** (not official GitHub tool)
- Local OAuth token storage
- See [Risk Disclosure](README.md#-risk-disclosure) in README

#### Ollama Local
- 100% offline, no internet required
- Code never leaves your machine
- No cloud provider risks

### Threat Model

#### Risks We Mitigate
- ✅ API key leakage to logs
- ✅ Credential storage in scripts
- ✅ Unencrypted transmission (all providers use HTTPS/local)

#### Risks Outside Our Control
- ⚠️ GitHub Copilot ToS compliance (see [Risk Disclosure](README.md#-risk-disclosure))
- ⚠️ copilot-api proxy security (third-party dependency)
- ⚠️ Provider-side data handling (Anthropic, GitHub, Ollama)

### Known Issues

#### copilot-api Reserved Header Issue (#174)

**Status**: Mitigated with community patch

**Issue**: copilot-api sends reserved billing headers causing connection failures

**Fix**: Community patch applied automatically during `install.sh`

**Details**: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée)

**Verify patch**:
```bash
grep -A 3 'x-copilot-billing-type' ~/.copilot-api/node_modules/copilot-api/dist/index.mjs
# Should NOT see "x-copilot-billing-type" header
```

## Reporting a Vulnerability

### What to Report

**Security vulnerabilities** (report privately):
- Credential leakage
- Code execution risks
- Privilege escalation
- Data exfiltration

**General bugs** (use public issues):
- Provider routing failures
- Configuration errors
- Documentation issues

### How to Report

**Private reporting:**
1. **Email**: florian@bruniaux.com
2. **Subject**: `[SECURITY] cc-copilot-bridge: Brief description`
3. **Include**:
   - Vulnerability description
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if known)

**Response time:**
- Acknowledgment: 48 hours
- Fix timeline: Depends on severity (critical: 7 days, high: 14 days, medium: 30 days)

### Disclosure Policy

1. **Report received** → Private acknowledgment
2. **Fix developed** → Private testing
3. **Fix released** → Public disclosure after 90 days OR after fix deployment (whichever is sooner)
4. **Credit** → Reporter credited in CHANGELOG (unless anonymity requested)

## Security Best Practices

### For Users

1. **Protect API keys**:
   ```bash
   # Store in secure environment files
   echo "ANTHROPIC_API_KEY=sk-..." >> ~/.zshrc.local
   chmod 600 ~/.zshrc.local
   ```

2. **Audit logs regularly**:
   ```bash
   tail -n 100 ~/.claude/claude-switch.log
   ```

3. **Use Ollama for sensitive code**:
   ```bash
   cco  # 100% offline, no cloud exposure
   ```

4. **Review copilot-api patches**:
   ```bash
   cd ~/.copilot-api
   git log --oneline
   ```

### For Contributors

1. **Never commit credentials** (use `.gitignore`)
2. **Validate user inputs** in scripts
3. **Use secure temp files**: `mktemp -t cc-copilot-bridge`
4. **Test with realistic threat scenarios**

## Compliance

### GDPR / Privacy Laws

**cc-copilot-bridge is a local routing tool:**
- No data collection
- No analytics or tracking
- No cloud storage

**Provider compliance:**
- Anthropic: [Privacy Policy](https://www.anthropic.com/privacy)
- GitHub: [Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement)
- Ollama: Local only, no cloud

### SOC 2 / Enterprise

For enterprise deployments:
- Use **Anthropic Direct** (`ccd`) for SOC 2 compliance
- Use **Ollama** (`cco`) for air-gapped environments
- Avoid **Copilot Bridge** (`ccc`) if ToS risk is unacceptable

## Security Updates

**Subscribe to releases**: [GitHub Releases](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases)

**Check for updates**:
```bash
cd ~/.claude/cc-copilot-bridge
git fetch
git log HEAD..origin/main --oneline
```

## Contact

- **Security issues**: florian@bruniaux.com (private)
- **General issues**: [GitHub Issues](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/FlorianBruniaux/cc-copilot-bridge/discussions)
