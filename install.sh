#!/bin/bash
# Claude Code Multi-Provider Switcher - Automatic Installer
#
# 🔒 Security-conscious? Review this script or use manual installation:
#    https://github.com/FlorianBruniaux/cc-copilot-bridge/blob/main/QUICKSTART.md#option-2-manual-security-conscious---3-minutes
#
# Usage: curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << 'EOF'
   _____ _                 _         _____          _ _       _
  / ____| |               | |       / ____|        (_) |     | |
 | |    | | __ _ _   _  __| | ___  | (_____      ___| |_ ___| |__
 | |    | |/ _` | | | |/ _` |/ _ \  \___ \ \ /\ / / | __/ __| '_ \
 | |____| | (_| | |_| | (_| |  __/  ____) \ V  V /| | || (__| | | |
  \_____|_|\__,_|\__,_|\__,_|\___| |_____/ \_/\_/ |_|\__\___|_| |_|

EOF
echo -e "${NC}"
echo "Claude Code Multi-Provider Switcher Installer"
echo "=============================================="
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        SHELL_RC="$HOME/.zshrc"
        echo "✓ Detected: macOS"
        ;;
    Linux*)
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_RC="$HOME/.zshrc"
            echo "✓ Detected: Linux (zsh)"
        else
            SHELL_RC="$HOME/.bashrc"
            echo "✓ Detected: Linux (bash)"
        fi
        ;;
    *)
        echo -e "${RED}✗ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

echo ""

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Claude Code
if ! command -v claude &> /dev/null; then
    echo -e "${ORANGE}⚠ Claude Code CLI not found${NC}"
    echo "  Install it with: npm install -g @anthropic-ai/claude-code"
    echo ""
else
    echo -e "${GREEN}✓ Claude Code CLI installed${NC}"
fi

# Check nc (netcat)
if ! command -v nc &> /dev/null; then
    echo -e "${ORANGE}⚠ netcat (nc) not found${NC}"
    echo "  Install it with: brew install netcat (macOS) or apt-get install netcat (Linux)"
    echo ""
else
    echo -e "${GREEN}✓ netcat installed${NC}"
fi

echo ""

# Create ~/bin if it doesn't exist
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
    echo "✓ Created ~/bin directory"
fi

# Download claude-switch script
echo "Downloading claude-switch script..."
SCRIPT_URL="https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/claude-switch"
SCRIPT_PATH="$HOME/bin/claude-switch"

# For local testing, use the current directory
if [ -f "./claude-switch" ]; then
    cp ./claude-switch "$SCRIPT_PATH"
    echo "✓ Copied local claude-switch to ~/bin/"
else
    if command -v curl &> /dev/null; then
        curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH" 2>/dev/null || {
            echo -e "${RED}✗ Failed to download script${NC}"
            echo "  Make sure you have internet connection"
            exit 1
        }
    elif command -v wget &> /dev/null; then
        wget -q "$SCRIPT_URL" -O "$SCRIPT_PATH" || {
            echo -e "${RED}✗ Failed to download script${NC}"
            exit 1
        }
    else
        echo -e "${RED}✗ curl or wget required${NC}"
        exit 1
    fi
    echo "✓ Downloaded claude-switch"
fi

# Make executable
chmod +x "$SCRIPT_PATH"
echo "✓ Made claude-switch executable"

# Add aliases to shell config
echo ""
echo "Configuring shell aliases..."

ALIAS_BLOCK="
# Claude Code Multi-Provider
export PATH=\"\$HOME/bin:\$PATH\"
alias ccd='claude-switch direct'
alias ccc='claude-switch copilot'
alias cco='claude-switch ollama'
alias ccs='claude-switch status'

# Copilot Model Shortcuts
alias ccc-opus='COPILOT_MODEL=claude-opus-4.5 claude-switch copilot'
alias ccc-sonnet='COPILOT_MODEL=claude-sonnet-4.5 claude-switch copilot'
alias ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
alias ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'

# Ollama Model Shortcuts
alias cco-devstral='OLLAMA_MODEL=devstral-small-2 claude-switch ollama'
alias cco-granite='OLLAMA_MODEL=ibm/granite4:small-h claude-switch ollama'
"

if grep -q "Claude Code Multi-Provider" "$SHELL_RC" 2>/dev/null; then
    echo -e "${ORANGE}⚠ Aliases already exist in $SHELL_RC${NC}"
    echo "  Skipping alias configuration"
else
    echo "$ALIAS_BLOCK" >> "$SHELL_RC"
    echo "✓ Added aliases to $SHELL_RC"
fi

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Reload your shell configuration:"
echo -e "   ${BLUE}source $SHELL_RC${NC}"
echo ""
echo "2. Check provider status:"
echo -e "   ${BLUE}ccs${NC}"
echo ""
echo "3. Setup providers (optional):"
echo ""
echo "   📦 GitHub Copilot (free with subscription):"
echo -e "      ${BLUE}npm install -g copilot-api${NC}"
echo -e "      ${BLUE}copilot-api start${NC}"
echo ""
echo "   🔒 Ollama (local, private - recommended: devstral-small-2):"
echo -e "      ${BLUE}brew install ollama${NC}  # macOS"
echo -e "      ${BLUE}ollama serve${NC}"
echo -e "      ${BLUE}ollama pull devstral-small-2${NC}"
echo ""
echo "   ⚠️  IMPORTANT: Create 64K context Modelfile for Claude Code:"
echo -e "      ${BLUE}mkdir -p ~/.ollama${NC}"
echo -e "      ${BLUE}cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'${NC}"
echo "      FROM devstral-small-2"
echo "      PARAMETER num_ctx 65536"
echo "      PARAMETER temperature 0.15"
echo "      EOF"
echo -e "      ${BLUE}ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k${NC}"
echo ""
echo "   📦 Alternative: Pull backup model for long-context tasks:"
echo -e "      ${BLUE}ollama pull ibm/granite4:small-h${NC}"
echo ""
echo "4. Start using:"
echo -e "   ${BLUE}ccd${NC}        # Anthropic Direct"
echo -e "   ${BLUE}ccc${NC}        # GitHub Copilot"
echo -e "   ${BLUE}cco${NC}        # Ollama Local"
echo -e "   ${BLUE}ccc-opus${NC}   # Copilot with Opus model"
echo ""
echo "Documentation:"
echo "  https://github.com/FlorianBruniaux/cc-copilot-bridge"
echo ""
echo -e "${ORANGE}⚠ Don't forget to: source $SHELL_RC${NC}"
echo ""
