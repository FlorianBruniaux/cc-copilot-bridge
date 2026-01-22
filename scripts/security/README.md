# Security Scripts

Automated security auditing and compliance verification scripts for cc-copilot-bridge.

## Scripts Overview

| Script | Purpose | Frequency | Requires Root |
|--------|---------|-----------|---------------|
| `audit-daily.sh` | Daily security audit | Daily | Optional* |
| `audit-weekly.sh` | Weekly comprehensive audit | Weekly | No |
| `compliance-check.sh` | Compliance verification | As needed | No |
| `network-monitor.sh` | Network traffic monitoring | As needed | Yes |

*Root required for network connection monitoring via `lsof`

---

## Quick Start

```bash
# Daily audit (recommended: run each morning)
./audit-daily.sh

# Weekly audit (recommended: run every Monday)
./audit-weekly.sh

# Compliance check (before working on sensitive projects)
./compliance-check.sh

# Network monitoring (verify data flow)
sudo ./network-monitor.sh 60  # Monitor for 60 seconds
```

---

## Script Details

### audit-daily.sh

**Purpose**: Quick daily security check

**Checks**:
- Recent provider usage (last 10 sessions)
- Active network connections
- Log file size
- Potential secrets in logs
- Active MCP servers
- Disk usage

**Usage**:
```bash
./audit-daily.sh
```

**Sample Output**:
```
=== Claude Code Security Audit ===
Date: Wed Jan 22 10:30:00 PST 2026

Recent Provider Usage (last 10 sessions):
[INFO] Provider: GitHub Copilot - Model: gpt-4.1
[INFO] Provider: Ollama Local

Active Network Connections:
✓ No active connections

Log file size: 128K
✓ No obvious secrets detected

Active MCP Servers:
filesystem
bash
web-search

Claude Code disk usage:
2.4M    /Users/you/.claude

=== Audit Complete ===
```

---

### audit-weekly.sh

**Purpose**: Comprehensive weekly analysis

**Analyzes**:
- Provider usage statistics
- Average session duration
- Error patterns
- MCP profile usage
- Model distribution
- Security recommendations
- Disk usage trends

**Usage**:
```bash
./audit-weekly.sh
```

**Sample Output**:
```
=== Claude Code Weekly Security Audit ===
Week of: Wed Jan 22 10:30:00 PST 2026

Provider Usage Statistics (all time):
  Anthropic Direct: 5 sessions
  GitHub Copilot:   25 sessions
  Ollama Local:     10 sessions

  Distribution:
    Anthropic: 12%
    Copilot:   62%
    Ollama:    25%

Session Duration Analysis:
  Average session duration: 18.5 minutes
  Total sessions: 40

Recent Errors (last 10):
  Total errors: 2
    [ERROR] copilot-api not running on :4141

MCP Profile Usage:
  [INFO] Using restricted MCP profile for gpt-4.1

Model Usage (Copilot):
      15 Model: claude-sonnet-4.5
       8 Model: gpt-4.1
       2 Model: claude-opus-4.5

Security Recommendations:
  ✓ No immediate recommendations

=== Weekly Audit Complete ===
```

---

### compliance-check.sh

**Purpose**: Verify compliance with security policies

**Validates**:
- Provider usage history
- .claudeignore configuration
- Secrets detection in logs
- MCP server risk assessment
- Network configuration
- Privacy-preserving usage
- Data retention policies
- Compliance score calculation

**Usage**:
```bash
./compliance-check.sh
```

**Sample Output**:
```
=== Claude Code Compliance Check ===
Date: Wed Jan 22 10:30:00 PST 2026

Provider Usage History:
  - Anthropic Direct: 5 sessions
  - GitHub Copilot:   25 sessions
  - Ollama Local:     10 sessions

.claudeignore Configuration:
  ✓ Project .claudeignore exists
  ✓ Excludes .env files
  ✓ Excludes key files
  ✓ Excludes secrets

Secrets Detection in Logs:
  ✓ No obvious secrets detected

MCP Server Configuration:
  Active MCP servers: 5
    - filesystem (low risk)
    - bash (low risk)
    - web-search (medium risk - external network)
    - sequential-thinking (low risk)
    - memory (low risk)

Network Configuration:
  - Direct internet access (no proxy)

Privacy-Preserving Usage:
  ✓ Moderate Ollama usage (25% - good privacy)

Data Retention:
  Log file age: 15 days
  Active sessions: 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Compliance Score: 65/70 (92%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ PASS: Good compliance posture

Recommendations:
  ✓ No immediate recommendations

=== Compliance Check Complete ===
```

**Scoring**:
- **60-70**: PASS (good compliance)
- **40-59**: FAIR (review recommendations)
- **0-39**: FAIL (immediate action required)

---

### network-monitor.sh

**Purpose**: Monitor and log network connections

**Monitors**:
- Active Claude Code connections
- Destination IP addresses and ports
- Connection patterns over time
- Provider-specific traffic

**Usage**:
```bash
# Monitor for 60 seconds
sudo ./network-monitor.sh 60

# Monitor for 5 minutes
sudo ./network-monitor.sh 300
```

**Output**: Creates timestamped report file `claude-network-YYYYMMDD-HHMMSS.txt`

**Sample Report**:
```
Claude Code Network Monitoring Report
Generated: Wed Jan 22 10:30:00 PST 2026
Duration: 60 seconds
================================================================================

Iteration 1 - Wed Jan 22 10:30:05 PST 2026
----------------------------------------
claude    12345 user   10u  IPv4  TCP localhost:53210->localhost:11434 (ESTABLISHED)
✓ Active connections detected

Iteration 2 - Wed Jan 22 10:30:10 PST 2026
----------------------------------------
(no active connections)

=================================================================================
Analysis
=================================================================================

Unique Destinations:
localhost:11434

Summary:
  - Anthropic API connections: 0
  - GitHub Copilot connections: 0
  - Localhost connections: 12

Quick Summary:
  - Anthropic API: 0 detections
  - GitHub Copilot: 0 detections
  - Localhost only: 12 detections

Recommendations:
  ✓ Offline mode detected (Ollama) - no external network traffic
```

**Root Required**: Network monitoring requires root privileges for `lsof -i`

---

## Automation

### Cron Jobs (Automated Scheduling)

Add to your crontab (`crontab -e`):

```bash
# Daily audit at 9 AM
0 9 * * * /Users/you/Sites/perso/cc-copilot-bridge/scripts/security/audit-daily.sh >> ~/claude-audit-daily.log 2>&1

# Weekly audit every Monday at 9 AM
0 9 * * 1 /Users/you/Sites/perso/cc-copilot-bridge/scripts/security/audit-weekly.sh >> ~/claude-audit-weekly.log 2>&1

# Compliance check every Friday at 5 PM
0 17 * * 5 /Users/you/Sites/perso/cc-copilot-bridge/scripts/security/compliance-check.sh >> ~/claude-compliance.log 2>&1
```

### Manual Scheduling (Reminders)

Add to your shell profile (`.zshrc` or `.bashrc`):

```bash
# Remind to run audits
alias audit-daily='~/Sites/perso/cc-copilot-bridge/scripts/security/audit-daily.sh'
alias audit-weekly='~/Sites/perso/cc-copilot-bridge/scripts/security/audit-weekly.sh'
alias audit-compliance='~/Sites/perso/cc-copilot-bridge/scripts/security/compliance-check.sh'
```

---

## Troubleshooting

### Script Not Executable

```bash
chmod +x /path/to/script.sh
```

### "lsof: command not found"

Install netcat/lsof:

```bash
# macOS
brew install lsof

# Linux (Ubuntu/Debian)
sudo apt-get install lsof

# Linux (CentOS/RHEL)
sudo yum install lsof
```

### "jq: command not found"

Install jq for JSON parsing:

```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (CentOS/RHEL)
sudo yum install jq
```

### Network Monitor Requires Root

```bash
# Run with sudo
sudo ./network-monitor.sh 60

# Or add to sudoers (advanced)
echo "yourusername ALL=(ALL) NOPASSWD: /path/to/network-monitor.sh" | sudo tee -a /etc/sudoers.d/claude-monitor
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Security Audit

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM
  workflow_dispatch:

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run compliance check
        run: |
          chmod +x scripts/security/compliance-check.sh
          ./scripts/security/compliance-check.sh
      - name: Upload audit report
        uses: actions/upload-artifact@v3
        with:
          name: compliance-report
          path: ~/claude-compliance.log
```

---

## Best Practices

1. **Run daily audits** before starting work on sensitive projects
2. **Review weekly audits** to identify usage patterns and risks
3. **Run compliance checks** before security reviews or audits
4. **Monitor network traffic** when working on proprietary code
5. **Archive reports** for compliance documentation (90+ days)
6. **Automate with cron** for consistent monitoring
7. **Review recommendations** and take action promptly

---

## Security Recommendations

- **Store audit logs securely**: Consider encrypting with GPG
- **Limit log retention**: Rotate logs every 90 days
- **Review compliance scores**: Aim for 60/70 (85%+)
- **Monitor network traffic**: Verify offline mode for sensitive work
- **Document incidents**: Keep security incident log
- **Update scripts regularly**: Check for updates from cc-copilot-bridge repo

---

## Related Documentation

- **SECURITY.md**: Comprehensive security and privacy guide
- **TROUBLESHOOTING.md**: General troubleshooting
- **FAQ.md**: Frequently asked questions

---

## Support

For issues or questions:
- **GitHub Issues**: https://github.com/FlorianBruniaux/cc-copilot-bridge/issues
- **Security concerns**: Create private security advisory on GitHub

---

**Last Updated**: 2026-01-22
**Maintained By**: cc-copilot-bridge project
