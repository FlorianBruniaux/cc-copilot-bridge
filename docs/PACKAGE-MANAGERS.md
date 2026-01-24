# Package Manager Installation

The cleanest way to install `claude-switch` - no script execution, proper dependency management, easy updates.

## Homebrew (macOS/Linux)

### Quick Install

```bash
# Add tap
brew tap FlorianBruniaux/tap

# Install
brew install cc-copilot-bridge

# Enable shell aliases
eval "$(claude-switch --shell-config)"
```

### Add to Shell Config

**Recommended** - Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Claude Code Multi-Provider
eval "$(claude-switch --shell-config)"
```

Or with lazy loading:

```bash
# Claude Code Multi-Provider (lazy load)
if command -v claude-switch &> /dev/null; then
  eval "$(claude-switch --shell-config)"
fi
```

### Update

```bash
brew update
brew upgrade claude-switch
```

### Uninstall

```bash
brew uninstall claude-switch
brew untap FlorianBruniaux/tap
```

---

## Debian/Ubuntu (.deb)

### Quick Install

```bash
# Download latest release
VERSION="1.5.2"  # Check releases page for latest
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch_${VERSION}.deb

# Install
sudo dpkg -i claude-switch_${VERSION}.deb

# Install dependencies if missing
sudo apt-get install -f

# Enable shell aliases
eval "$(claude-switch --shell-config)"
```

### Add to Shell Config

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Claude Code Multi-Provider
eval "$(claude-switch --shell-config)"
```

### Update

```bash
# Download new version
VERSION="1.5.3"  # New version
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch_${VERSION}.deb
sudo dpkg -i claude-switch_${VERSION}.deb
```

### Uninstall

```bash
sudo dpkg -r claude-switch
```

---

## RHEL/Fedora/CentOS (.rpm)

### Quick Install

```bash
# Download latest release
VERSION="1.5.2"  # Check releases page for latest
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch-${VERSION}-1.noarch.rpm

# Install
sudo rpm -i claude-switch-${VERSION}-1.noarch.rpm

# Enable shell aliases
eval "$(claude-switch --shell-config)"
```

### Add to Shell Config

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Claude Code Multi-Provider
eval "$(claude-switch --shell-config)"
```

### Update

```bash
# Download new version
VERSION="1.5.3"  # New version
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch-${VERSION}-1.noarch.rpm
sudo rpm -U claude-switch-${VERSION}-1.noarch.rpm
```

### Uninstall

```bash
sudo rpm -e claude-switch
```

---

## Shell Configuration Options

### Method 1: Eval (Dynamic - Recommended)

**Advantages**: Always up-to-date with script updates, no file to maintain
**Disadvantages**: Slight shell startup delay (~10ms)

```bash
# ~/.zshrc or ~/.bashrc
eval "$(claude-switch --shell-config)"
```

### Method 2: Source Static File

**Advantages**: Faster shell startup, can customize aliases
**Disadvantages**: Manual updates when aliases change

```bash
# Generate once
claude-switch --shell-config > ~/.claude/aliases.sh

# Add to ~/.zshrc or ~/.bashrc
source ~/.claude/aliases.sh
```

### Method 3: Lazy Load

**Advantages**: Zero startup delay, loads only when needed
**Disadvantages**: Slight delay on first use

```bash
# ~/.zshrc or ~/.bashrc
claude-switch() {
  unfunction claude-switch
  eval "$(command claude-switch --shell-config)"
  claude-switch "$@"
}
```

### Method 4: Antigen (Plugin Manager)

```bash
# Generate static file
claude-switch --shell-config > ~/.claude/aliases.sh

# Add to ~/.zshrc
antigen bundle ~/.claude/aliases.sh
```

### Method 5: Oh-My-Zsh

```bash
# Create plugin
mkdir -p $ZSH_CUSTOM/plugins/claude-switch
claude-switch --shell-config > $ZSH_CUSTOM/plugins/claude-switch/claude-switch.plugin.zsh

# Add to ~/.zshrc plugins
plugins=(... claude-switch)
```

---

## Comparison: Package Managers vs Curl Install

| Feature | Package Managers | Curl Install |
|---------|------------------|--------------|
| **Dependency Management** | ✅ Automatic (netcat, etc.) | ❌ Manual check |
| **Updates** | ✅ `brew upgrade`, `apt upgrade` | ❌ Re-run script |
| **Uninstall** | ✅ Clean removal | ⚠️ Manual cleanup |
| **System Integration** | ✅ Standard paths | ⚠️ `~/bin` |
| **Security** | ✅ Signed packages (distro) | ⚠️ Bash execution |
| **Shell Config** | ✅ `eval "$(claude-switch --shell-config)"` | ⚠️ Modifies `.zshrc` |
| **Distribution** | ✅ Official packages | ❌ GitHub only |

---

## Troubleshooting

### Command not found after install

**Homebrew**:
```bash
# Verify install
brew list claude-switch

# Check PATH
echo $PATH | grep -o '/usr/local/bin'

# Reload shell
source ~/.zshrc
```

**Debian/Ubuntu**:
```bash
# Verify install
dpkg -l | grep claude-switch

# Check path
which claude-switch

# Should be: /usr/local/bin/claude-switch
```

**RHEL/Fedora**:
```bash
# Verify install
rpm -qa | grep claude-switch

# Check path
which claude-switch
```

### Aliases not working

**Solution**: You need to enable shell config

```bash
# Test immediately
source <(claude-switch --shell-config)

# Add permanently
echo 'eval "$(claude-switch --shell-config)"' >> ~/.zshrc
source ~/.zshrc
```

### Package installation fails

**Homebrew** - Dependency issues:
```bash
# Update Homebrew
brew update

# Install dependencies manually
brew install netcat
```

**Debian/Ubuntu** - Dependency issues:
```bash
# Fix broken dependencies
sudo apt-get install -f

# Install netcat manually
sudo apt-get install netcat
```

**RHEL/Fedora** - Dependency issues:
```bash
# Install netcat (nmap-ncat)
sudo dnf install nmap-ncat
# or
sudo yum install nmap-ncat
```

---

## Why Package Managers?

### For Users

1. **Familiar workflow**: Same commands as other tools (`brew install`, `apt install`)
2. **Dependency management**: Automatic netcat, proper PATH setup
3. **Easy updates**: `brew upgrade`, `apt upgrade` - no re-running scripts
4. **Clean uninstall**: Remove cleanly without leftover files
5. **System integration**: Works with system package managers

### For Maintainers (like Bernard suggested)

1. **No repository push needed**: GitHub Actions builds packages automatically
2. **Distro maintainers handle distribution**: Community can package for Arch, Nix, etc.
3. **Homebrew tap**: Users install via `brew tap FlorianBruniaux/tap`
4. **CI/CD friendly**: Automated builds on tag push
5. **LLM-assisted**: Easy to explain to Claude: "install via brew/apt/rpm"

---

## Migration from Curl Install

If you previously used `curl | bash` installer:

### 1. Uninstall Old Method

```bash
# Remove script
rm ~/bin/claude-switch

# Remove old aliases file (if exists)
rm ~/.claude/aliases.sh

# Remove from shell config
# Edit ~/.zshrc or ~/.bashrc and remove:
#   source ~/.claude/aliases.sh
```

### 2. Install via Package Manager

Choose your platform above (Homebrew, .deb, or .rpm)

### 3. Enable Shell Config

```bash
# Add to ~/.zshrc or ~/.bashrc
eval "$(claude-switch --shell-config)"
```

### 4. Reload Shell

```bash
source ~/.zshrc  # or ~/.bashrc
```

Done! Your aliases (`ccd`, `ccc`, `cco`) should work.

---

## Future Package Managers

Community contributions welcome for:

- **Arch Linux** (AUR package)
- **Nix/NixOS** (nixpkgs)
- **Chocolatey** (Windows)
- **Scoop** (Windows)
- **MacPorts** (macOS alternative to Homebrew)

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
