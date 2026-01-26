# Quick Start Guide

**Reading time**: 5 minutes | **Skill level**: Beginner | **Prerequisites**: Claude Code CLI installed

**Get up and running in 2 minutes**

> 📖 **New to Claude Code?** Start with the [Claude Code Ultimate Guide](https://florianbruniaux.github.io/claude-code-ultimate-guide-landing/) to learn the basics before configuring multiple providers.

---

**What you'll achieve:**
- ✅ Install cc-copilot-bridge and verify setup
- ✅ Run your first command successfully
- ✅ Know which command to use daily

---

## Installation

### Option 1: Package Managers (Recommended) - 30 seconds

**Clean, dependency-managed, easy updates** - no script execution needed

<details>
<summary><b>Homebrew (macOS/Linux)</b></summary>

```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
eval "$(claude-switch --shell-config)"
```

Add to `~/.zshrc` or `~/.bashrc`:
```bash
eval "$(claude-switch --shell-config)"
```

**Update**: `brew upgrade claude-switch`
**Uninstall**: `brew uninstall claude-switch`

</details>

<details>
<summary><b>Debian/Ubuntu (.deb)</b></summary>

```bash
VERSION="1.5.3"  # Check releases for latest
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch_${VERSION}.deb
sudo dpkg -i claude-switch_${VERSION}.deb
eval "$(claude-switch --shell-config)"
```

Add to `~/.bashrc`:
```bash
eval "$(claude-switch --shell-config)"
```

**Uninstall**: `sudo dpkg -r claude-switch`

</details>

<details>
<summary><b>RHEL/Fedora (.rpm)</b></summary>

```bash
VERSION="1.5.3"  # Check releases for latest
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch-${VERSION}-1.noarch.rpm
sudo rpm -i claude-switch-${VERSION}-1.noarch.rpm
eval "$(claude-switch --shell-config)"
```

Add to `~/.bashrc`:
```bash
eval "$(claude-switch --shell-config)"
```

**Uninstall**: `sudo rpm -e claude-switch`

</details>

**Full guide**: [PACKAGE-MANAGERS.md](docs/PACKAGE-MANAGERS.md)

---

### Option 2: Interactive Script Install - 30 seconds

**Respects your shell config** - asks before modifying `.zshrc`/`.bashrc`

```bash
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash
```

**What it does**:
- ✅ Downloads `claude-switch` to `~/bin/`
- ✅ Creates `~/.claude/aliases.sh` with all aliases
- ✅ **ASKS** if you want automatic `.zshrc` modification
- ✅ Provides instructions for antigen, oh-my-zsh, zinit, etc.
- ✅ Verifies prerequisites

**After install**: Choose your integration method (see [INSTALL-OPTIONS.md](docs/INSTALL-OPTIONS.md))
- Standard: `source ~/.zshrc`
- Antigen: Add `antigen bundle ~/.claude/aliases.sh` to `.zshrc`
- Oh-My-Zsh: Link as custom plugin

---

### Option 3: Manual (Security-conscious) - 3 minutes

Perfect if you want to review every step or customize the installation.

#### Prerequisites Check

Verify you have the required tools:

```bash
# Check Claude Code CLI
claude --version
# If missing: npm install -g @anthropic-ai/claude-code

# Check netcat (for provider health checks)
nc -h 2>&1 | head -1
# If missing:
#   macOS: brew install netcat
#   Linux: sudo apt-get install netcat
```

#### Step 1: Create Directories

```bash
# Create binary directory
mkdir -p ~/bin

# Create logs directory
mkdir -p ~/.claude
```

#### Step 2: Download Script

**Option A: With curl**
```bash
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/claude-switch \
  -o ~/bin/claude-switch
```

**Option B: With wget**
```bash
wget -q https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/claude-switch \
  -O ~/bin/claude-switch
```

**Option C: Clone repository (for local development)**
```bash
git clone https://github.com/FlorianBruniaux/cc-copilot-bridge.git
cp cc-copilot-bridge/claude-switch ~/bin/
```

#### Step 3: Make Executable

```bash
chmod +x ~/bin/claude-switch
```

#### Step 4: Configure Shell

**Detect your shell**:
```bash
echo $SHELL
# Output: /bin/zsh → Use ~/.zshrc
# Output: /bin/bash → Use ~/.bashrc
```

**Add aliases to shell config** (`~/.zshrc` or `~/.bashrc`):

```bash
# For zsh users
cat >> ~/.zshrc << 'EOF'

# Claude Code Multi-Provider
export PATH="$HOME/bin:$PATH"
alias ccd='claude-switch direct'
alias ccc='claude-switch copilot'
alias cco='claude-switch ollama'
alias ccs='claude-switch status'

# Copilot Model Shortcuts
alias ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
alias ccc-sonnet='COPILOT_MODEL=claude-sonnet-4.5 claude-switch copilot'
alias ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
alias ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
alias ccc-gemini='COPILOT_MODEL=gemini-2.5-pro claude-switch copilot'
EOF

# For bash users, replace ~/.zshrc with ~/.bashrc in the command above
```

**Manual alternative** (if you prefer editing manually):
1. Open `~/.zshrc` (or `~/.bashrc`) in your editor
2. Scroll to the end of the file
3. Copy-paste the alias block above
4. Save and close

#### Step 5: Reload Shell Configuration

```bash
source ~/.zshrc  # or source ~/.bashrc
```

#### Step 6: Verify Installation

```bash
# Test that claude-switch is in PATH
which claude-switch
# Expected output: /Users/yourname/bin/claude-switch

# Test aliases
ccs
# Expected output: Provider status table
```

**Expected output**:
```
=== Claude Code Provider Status ===

Anthropic API:  ✓ Reachable
copilot-api:    ✗ Not running (install with: npm install -g copilot-api)
Ollama:         ✗ Not running (install with: brew install ollama)

=== Recent Sessions ===
(no logs yet)
```

#### Troubleshooting Manual Installation

| Issue | Solution |
|-------|----------|
| `claude-switch: command not found` | Run `source ~/.zshrc` or restart terminal |
| `Permission denied` | Run `chmod +x ~/bin/claude-switch` |
| Aliases not working | Check you added to correct file (~/.zshrc vs ~/.bashrc) |
| `~/bin` not in PATH | Add `export PATH="$HOME/bin:$PATH"` to shell config |

---

### Security Notes

#### Why Manual Installation?

- ✅ **Review every command** before execution
- ✅ **Understand what's installed** (single script + aliases)
- ✅ **Avoid "curl \| bash"** pattern security concerns
- ✅ **Customize paths** if needed

#### What Gets Modified?

Manual installation touches exactly 3 locations:

| Location | Purpose | Reversible? |
|----------|---------|-------------|
| `~/bin/claude-switch` | Main script (334 lines) | ✅ Yes: `rm ~/bin/claude-switch` |
| `~/.zshrc` (or `~/.bashrc`) | Aliases block (11 lines) | ✅ Yes: Remove block manually |
| `~/.claude/` | Log files directory | ✅ Yes: `rm -rf ~/.claude` |

#### Verify Script Before Installation (Optional)

```bash
# Download and inspect before installing
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/claude-switch \
  -o /tmp/claude-switch-preview

# Review the script
less /tmp/claude-switch-preview

# Check file integrity (optional)
shasum -a 256 /tmp/claude-switch-preview
# Compare with published checksum at:
# https://github.com/FlorianBruniaux/cc-copilot-bridge/releases

# Install after verification
mv /tmp/claude-switch-preview ~/bin/claude-switch
chmod +x ~/bin/claude-switch
```

#### Uninstall Completely

```bash
# Remove script
rm ~/bin/claude-switch

# Remove aliases (manual edit)
# Open ~/.zshrc or ~/.bashrc
# Delete the "Claude Code Multi-Provider" block

# Remove logs (optional)
rm -rf ~/.claude

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

---

## First Use (30 seconds)

### Test Drive: Copilot Mode (Recommended)

**Prerequisites**:
- ✅ GitHub Copilot Pro ($10/mo) or Pro+ ($39/mo) subscription active
- ✅ copilot-api running (`copilot-api start` in separate terminal)

```bash
# Launch Claude Code with Copilot bridge
ccc

# Try asking something
❯ What model am I talking to?
```

**What to expect**:

**Claude Sonnet 4.5 (Default Model)**:
![Claude Sonnet Response](assets/ccc-sonnet.png)

*Note: Model correctly identifies as "Claude Sonnet 4.5" (via system prompt injection)*

### Try Different Models

```bash
# Claude Opus (premium quality)
ccc-opus
❯ Analyze this architecture diagram

# GPT-4.1 (OpenAI)
ccc-gpt
❯ Compare Python vs JavaScript for data processing

# Ollama Offline (100% private)
cco
❯ Review this proprietary encryption algorithm
```

**Visual Examples**:

**Claude Opus 4.5**:
![Claude Opus](assets/ccc-opus.png)

**GPT-4.1**:
![GPT-4.1](assets/ccc-gpt.png)

**Ollama Offline**:
![Ollama](assets/cco.png)

### Check Status

```bash
ccs
```

**Expected output**:
```
=== Claude Code Provider Status ===

Anthropic API:  ✓ Reachable
copilot-api:    ✗ Not running
Ollama:         ✗ Not running

=== Recent Sessions ===
(no logs yet)
```

### Use Anthropic Direct (Immediate)

If you have `ANTHROPIC_API_KEY` set:

```bash
ccd
```

You're in! Start coding with Claude.

---

## Setup Additional Providers (Optional)

### GitHub Copilot (5 minutes)

**Requirements**: Active Copilot Pro ($10/mo) or Pro+ ($39/mo) subscription

> **Note**: Usage consumes your premium request quota. See [Pricing & Limits](README.md#-github-copilot-pricing--limits) for details.

```bash
# 1. Install copilot-api
npm install -g copilot-api

# 2. Start and authenticate
copilot-api start
# Follow the GitHub authentication flow
```

**What to expect**:
![copilot-api start](assets/copilot-api.png)

*copilot-api proxy server running with authentication logs*

```bash
# 3. Test
ccc
```

**Keep copilot-api running** in a terminal or set up auto-start (see [README.md](README.md#advanced-usage)).

### Ollama Local (10 minutes + download time)

**Requirements**: 10-20GB disk space for models

```bash
# 1. Install Ollama
brew install ollama  # macOS
# or download from https://ollama.ai

# 2. Start server
ollama serve &

# 3. Pull a coding model (choose one)
ollama pull devstral-small-2   # Best agentic (default)
# or
ollama pull ibm/granite4:small-h  # Long context, less VRAM

# 4. Test
cco
```

---

## Daily Usage

### Switch Providers

```bash
ccd      # Anthropic (official API)
ccc      # Copilot (uses quota)
cco      # Ollama (offline)
ccs      # Check status
```

### Use Different Models (Copilot)

```bash
ccc-opus     # Claude Opus 4.5 (3x quota)
ccc-sonnet   # Claude Sonnet 4.5 (1x quota)
ccc-haiku    # Claude Haiku 4.5 (0.33x quota)
ccc-gpt      # GPT-4.1 (0x = free)
```

### Pass Arguments

```bash
ccc -c              # Resume session
ccd --model opus    # Use Opus with Anthropic
```

---

## Example Workflow

```bash
# Use GPT-4.1 for routine tasks (doesn't consume quota)
ccc-gpt
> Help me understand this React project structure

# Use Claude Sonnet for complex logic (1x quota)
ccc-sonnet
> Add user authentication with JWT

# Use Anthropic Direct for production review (official API)
ccd
> Review this code for security issues

# Private code: Use local model
cco
> Analyze this proprietary algorithm
```

---

## Troubleshooting

### "claude: command not found"

```bash
npm install -g @anthropic-ai/claude-code
```

### "copilot-api not running"

```bash
copilot-api start
```

Keep it running in a separate terminal.

### "Ollama model not found"

```bash
ollama pull devstral-small-2
```

### Verify Installation

```bash
# Check script is installed
which claude-switch
# Should output: /Users/yourname/bin/claude-switch

# Check aliases are loaded
alias ccs
# Should output: alias ccs='claude-switch status'
```

---

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [MODEL-SWITCHING.md](docs/MODEL-SWITCHING.md) for model selection strategies
- See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for advanced setup

---

**That's it!** You're ready to use cc-copilot-bridge.

For a printable quick reference, see [Cheatsheet](docs/CHEATSHEET.md).

---

## 📚 Next Steps

Now that you're set up:

1. 📖 **Learn all commands** → [Command Reference](docs/COMMANDS.md)
2. 🎯 **Choose right tool** → [Decision Trees](docs/DECISION-TREES.md)
3. 📋 **Print reference** → [Cheatsheet](docs/CHEATSHEET.md)
4. 🆘 **Troubleshooting** → [Common Issues](docs/TROUBLESHOOTING.md)

---

## 🆘 Need Help?

- **Questions?** Check the [FAQ](docs/FAQ.md)
- **Issues?** See [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- **Bug reports**: [Open an issue](https://github.com/FlorianBruniaux/cc-copilot-bridge/issues)

---

**Related Documentation**:
- [Full Documentation Index](docs/README.md)
- [Model Switching Guide](docs/MODEL-SWITCHING.md)
- [Main README](README.md)

