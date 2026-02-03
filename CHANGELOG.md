# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Automated Homebrew Tap Sync**: GitHub Actions now auto-syncs Formula to `FlorianBruniaux/homebrew-tap` on release
- **Daily Tap Sync Verification**: New workflow `.github/workflows/verify-tap-sync.yml` checks tap is in sync daily
- Documentation: MLX vs GGUF note in Ollama sections (CLAUDE.md, README.md) - explains performance trade-offs on Apple Silicon
- **Complete Aliases Documentation**: New `docs/ALIASES.md` - comprehensive reference for all 30+ aliases
  - Organized by category: Core providers, Claude, GPT, Codex, Gemini, Ollama, Semantic
  - Tables with models, billing tiers, use cases, and status (✅ Tested / ⚠️ UNTESTED)
  - Examples for each alias family
  - Compatibility matrix (MCP support, tool calling, file creation)
  - Decision tree for choosing the right alias
  - Advanced usage patterns (dynamic override, chaining with tools)
  - Troubleshooting section specific to aliases

### Changed
- **Homebrew Package Renamed**: `claude-switch` → `cc-copilot-bridge` (matches repo name)
- **Deterministic SHA256**: Release tarball created explicitly, SHA256 computed from actual release asset
- **Formula URL**: Now points to release asset instead of GitHub archive (prevents SHA256 mismatch)

### Fixed
- **SHA256 Mismatch Bug**: `git archive` produced different tarball than GitHub, causing install failures

## [1.5.3] - 2026-01-26

### Added

**📚 Documentation Updates** - Ollama 0.15.0+ integration

- **FAQ Entry**: "Can I use `ollama launch` instead of `claude-switch ollama`?"
  - Comparative table showing 7 feature differences
  - Clear use cases: `ollama launch` for quick tests, `claude-switch` for production
  - Setup instructions and context size warnings
  - Link to Ollama v0.15.0 release notes

### Changed

**Ollama Version Requirements Updated**:
- `docs/OPTIMISATION-M4-PRO.md`: Updated from 0.14.2+ to **0.15.0+** (4 locations)
  - Header metadata (version + last updated date)
  - Post-installation checklist
  - Troubleshooting verification instructions
  - Added Ollama v0.15.0 and v0.15.1 to sources section

**GLM-4.7-Flash Model Status** (3 files):
- `README.md`, `CLAUDE.md`, `docs/MODEL-SWITCHING.md`
- Status changed: ❌ "Untested with Claude Code" → ⚠️ "Ollama 0.15.1+ required"
- Reason: v0.15.1 fixes repetitive answers and improves tool calling quality
- Updated "Use Case" column: "Speed-optimized variant" → "Tool calling fix (v0.15.1)"

### Technical Details

**Ollama Release Notes Integration**:
- **v0.15.0** (2026-01-21):
  - New `ollama launch` command for zero-config Claude Code integration
  - Multi-line string support (`"""`) in `ollama run` (CLI only, not API)
  - Memory reduction for GLM-4.7-Flash models
- **v0.15.1** (2026-01-24):
  - GLM-4.7-Flash: Fixed repetitive answers + improved tool calling
  - Performance improvements for macOS and ARM64 Linux
  - Fixed bug where `ollama launch` didn't detect `claude` command

**Impact Assessment**:
- `ollama launch` is a **convenience CLI feature** for beginners
- Does NOT replace `claude-switch` (lacks multi-provider, logging, MCP profiles)
- Context size issue (18K tokens) still requires 64K Modelfile configuration
- **Recommendation**: `ollama launch` for quick tests, `claude-switch` for production workflows

### Files Modified
- `claude-switch` (version bump to 1.5.3)
- `docs/OPTIMISATION-M4-PRO.md` (4 changes)
- `README.md` (1 change)
- `CLAUDE.md` (1 change)
- `docs/MODEL-SWITCHING.md` (1 change)
- `docs/FAQ.md` (new entry + date update)

## [1.5.2] - 2026-01-24

### Added

**🎉 Package Managers Support** - Major installation overhaul per community feedback

- **Distribution Methods**:
  - Homebrew Formula (`Formula/cc-copilot-bridge.rb`) for macOS/Linux
  - `.deb` package build for Debian/Ubuntu
  - `.rpm` package build for RHEL/Fedora/CentOS
  - GitHub Actions automated build pipeline (`.github/workflows/build-packages.yml`)

- **`--shell-config` Option** - Respectful shell configuration:
  - Generates aliases dynamically (no static file)
  - User controls their own `.zshrc`/`.bashrc`
  - Compatible with antigen, oh-my-zsh, zinit, sheldon
  - Usage: `eval "$(claude-switch --shell-config)"`

- **Comprehensive Documentation**:
  - `docs/PACKAGE-MANAGERS.md` - User guide (installation per platform)
  - `docs/PACKAGE-MANAGERS-EXPLAINED.md` - Technical deep-dive (100+ pages)
  - `docs/PACKAGE-MANAGERS-SUMMARY.md` - Quick overview
  - `docs/RELEASE-PROCESS.md` - Maintainer guide
  - `docs/INSTALL-OPTIONS.md` - 6 shell integration methods
  - `Formula/README.md` - Homebrew maintainer guide

### Changed

**Installation Script Refactor** (`install.sh`):
- ✅ **Now asks permission** before modifying `.zshrc`/`.bashrc`
- ✅ Default choice: manual configuration (option 2)
- ✅ Creates `~/.claude/aliases.sh` instead of direct modification
- ✅ Provides instructions for antigen, oh-my-zsh, zinit
- ✅ Shows clear warning if user refuses configuration

**Documentation Updates**:
- `README.md` - Package managers as recommended installation method
- `QUICKSTART.md` - 3 installation options (package > script > manual)
- `CLAUDE.md` - New "Package Managers Distribution" section

**User Experience Improvements**:
- Standard installation methods (`brew install`, `apt install`, `dnf install`)
- Automatic dependency management (netcat installed automatically)
- Easy updates (`brew upgrade`, `apt upgrade`)
- Clean uninstall (`brew uninstall`, `dpkg -r`, `rpm -e`)

### Fixed

- **Issue**: `curl | bash` installer modified `.zshrc` without asking (invasive)
- **Issue**: No support for plugin managers (antigen, oh-my-zsh)
- **Issue**: Difficult for LLMs to explain installation process
- **Solution**: Package managers + `--shell-config` option

### Technical Details

- **Version**: 1.5.2 (in `claude-switch` and `Formula/cc-copilot-bridge.rb`)
- **Homebrew Dependencies**: `netcat` (required), `ollama` (optional), `node` (optional)
- **GitHub Actions**: Automatically computes SHA256, builds packages, creates releases
- **SHA256**: Computed automatically for Homebrew Formula security

### Installation

**Homebrew** (recommended):
```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
eval "$(claude-switch --shell-config)"
```

**Debian/Ubuntu**:
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch_1.5.2.deb
sudo dpkg -i claude-switch_1.5.2.deb
eval "$(claude-switch --shell-config)"
```

**RHEL/Fedora**:
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch-1.5.2-1.noarch.rpm
sudo rpm -i claude-switch-1.5.2-1.noarch.rpm
eval "$(claude-switch --shell-config)"
```

### Migration from 1.5.1

**Option 1: Package Manager** (recommended):
```bash
# Remove old installation
rm ~/bin/claude-switch
rm ~/.claude/aliases.sh
# Remove "source ~/.claude/aliases.sh" from .zshrc

# Install via Homebrew
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
echo 'eval "$(claude-switch --shell-config)"' >> ~/.zshrc
source ~/.zshrc
```

**Option 2: Keep Script Install**:
```bash
# Re-run installer (now asks permission)
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash
# Choose option 2 (manual)
# Add to .zshrc: eval "$(claude-switch --shell-config)"
```

## [1.5.1] - 2026-01-23

### Added

**Unified Fork Launcher (PR #167 + #170) - EXPERIMENTAL**
- 🚀 New launcher `scripts/launch-unified-fork.sh` combining both PRs from caozhiyuan/copilot-api:
  - **PR #167**: Gemini 3 thinking support (`thought_signature`, `reasoning_text`, `reasoning_opaque`)
  - **PR #170**: GPT Codex `/responses` endpoint support
- ✨ Source: `caozhiyuan/copilot-api` branch `all` (updated 2026-01-22)
- ✨ Auto-clones fork if not present, auto-updates every 24h
- ✨ Checks PR merge status (informational) before starting
- ✨ Supports both `bun` and `npm` runtimes
- ✨ New aliases: `ccunified`, `ccc-gemini3`, `ccc-gemini3-pro`

**⚠️ IMPORTANT - Experimental Status**:

| Feature | Status | Notes |
|---------|--------|-------|
| GPT Codex (/responses) | ✅ Tested | Works, same as v1.5.0 |
| Standard models | ✅ Working | Claude, GPT-4.1, Gemini 2.5, etc. |
| **Gemini 3 agentic mode** | ⚠️ UNTESTED | PR #167 adds thinking, NOT tool calling fix |

**What PR #167 actually adds**:
- Support for Gemini 3 "thinking" response fields
- This is NOT the same as fixing tool calling format translation
- The core issue (Claude → OpenAI → Gemini format) may still exist
- **Requires testing before claiming it works**

**Supported Models via Unified Fork**:
| Model | Endpoint | Status |
|-------|----------|--------|
| `gpt-5.2-codex` | /responses | ✅ Tested |
| `gpt-5.1-codex-*` | /responses | ✅ Tested |
| All Claude, GPT-4.1, etc. | /chat/completions | ✅ Working |
| `gemini-3-flash-preview` | /chat/completions | ⚠️ Untested agentic |
| `gemini-3-pro-preview` | /chat/completions | ⚠️ Untested agentic |

### Changed

- 📝 Updated README.md with unified fork section
- 📝 Updated TROUBLESHOOTING.md with Gemini 3 unified fork solution
- 📝 Updated CLAUDE.md with unified fork documentation

### Migration from v1.5.0

If you were using `launch-responses-fork.sh` for Codex models:
```bash
# Old way (Codex only)
ccfork && ccc-codex

# New way (Codex + Gemini 3 thinking)
ccunified && ccc-codex
# OR
ccunified && ccc-gemini3
```

### Links

- Fork source: [caozhiyuan/copilot-api](https://github.com/caozhiyuan/copilot-api/tree/all)
- PR #167: [Gemini 3 thinking](https://github.com/ericc-ch/copilot-api/pull/167)
- PR #170: [Codex /responses](https://github.com/ericc-ch/copilot-api/pull/170)
- Release: [v1.5.1](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.1)

---

## [1.5.0] - 2026-01-23

### Added

**GPT Codex Model Support (via copilot-api PR #170)**
- 🚀 Added support for all GPT Codex models via fork of copilot-api
  - `gpt-5.2-codex` (latest, recommended)
  - `gpt-5.1-codex`
  - `gpt-5.1-codex-mini`
  - `gpt-5.1-codex-max`
  - `gpt-5-codex`
- ✨ New launcher script `scripts/launch-responses-fork.sh`:
  - Auto-detects if PR #170 is merged (uses official npm if so)
  - Clones and builds fork automatically if needed
  - Health check before launching Claude Code
- ✨ New aliases: `ccfork`, `ccc-codex`, `ccc-codex-std`, `ccc-codex-mini`, `ccc-codex-max`
- 📝 New documentation:
  - `docs/ALL-MODEL-COMMANDS.md` - Complete model reference (42 models)
  - `docs/ALL-MODEL-ALIASES.sh` - Ready-to-use alias file
  - `docs/QUICK-LAUNCH-GUIDE.md` - Fast setup guide
  - `docs/research/RESPONSES-API-TEST-RESULTS.md` - Fork test results (6/6 passed)

**Why Fork Required?**
- Codex models use OpenAI's `/responses` endpoint (launched Oct 2025)
- Official copilot-api v0.7.0 only supports `/chat/completions`
- PR #170 adds `/responses` endpoint support
- **Tracking**: [ericc-ch/copilot-api#170](https://github.com/ericc-ch/copilot-api/pull/170)

**Research Documentation**
- 📊 Added AgentAPI vs copilot-api comparative analysis in `docs/research/AGENTAPI-VS-COPILOT-API.md`:
  - Architectural differences: Terminal emulator vs API translation layer
  - Complementary tools verdict (not alternatives)
  - Use case decision matrix
  - Community metrics (Jan 2026)
  - Recommendation: Keep copilot-api for cc-copilot-bridge use case

**Security Documentation (Ollama)**
- 🔐 Added Ollama security vulnerabilities section in `docs/SECURITY.md`:
  - CNVD-2025-04094: No authentication by default (Critical)
  - Model File OOB Write: RCE potential via malformed .gguf (High)
  - Model Poisoning: Unrestricted upload API (High)
- 🔐 Added recommended hardening steps (firewall, resource limits)
- 🔐 Source: Cisco Shodan Case Study on Ollama (2025)

**Air-Gapped Model Verification Protocol**
- 🔒 Added 3-stage verification protocol in `docs/SECURITY.md`:
  - Stage 1: Download with SHA-256 checksums
  - Stage 2: Transfer with archive verification
  - Stage 3: Import with individual checksum verification
- 🔒 Added audit trail requirements for regulated environments
- 🔒 Reference: GitHub Issue #9756 (Ollama cannot verify integrity in air-gapped)

**KV Cache Quantization Documentation**
- ✨ Documented `OLLAMA_KV_CACHE_TYPE=q4_0` (Ollama 2025 feature)
- ✨ Reduces KV cache memory by ~75% (48GB → 12GB for 64K context)
- ✨ Enables 64K context on 32GB machines

### Changed

**Memory Requirements Updated**
- 🔧 Corrected RAM specs in `CLAUDE.md`:
  - Devstral 24B: 30-37GB total (was 23-27GB)
  - Granite4 32B: 34-41GB total
  - **Minimum**: 32GB for 24B, **48GB recommended** for 32B + 64K
- 🔧 Updated `docs/OPTIMISATION-M4-PRO.md` with q4_0 cache type

**Model Recommendations**
- ⚠️ Added warning for non-agentic models in `CLAUDE.md`:
  - CodeLlama:13b (~40% SWE-bench) - No tool calling
  - Llama3.1:8b (**15%** SWE-bench) - "Catastrophic failure" on agentic tasks
- ⚠️ Note: High HumanEval ≠ agentic capability (Llama3.1:8b = 68% HumanEval but 15% SWE-bench)

### Security

- 🔐 Added `.gitleaks.toml` configuration for secret detection
- 🔐 Added GitHub Actions workflow `.github/workflows/security-scan.yml` for automated security scanning
- 🔐 Gitleaks scans on every push/PR to detect accidentally committed credentials

### Changed

**Security Hardening**
- 🔧 Replaced `sk-dummy` placeholder with `<PLACEHOLDER>` in `claude-switch` script
- 🔧 Replaced token-like examples (`sk-...`) with `<YOUR_API_KEY>` in documentation
- 🔧 Sanitized all credential placeholders across docs (CLAUDE.md, ARCHITECTURE.md, FEATURES.md, BEST-PRACTICES.md, TROUBLESHOOTING.md)
- 🔧 Added explanatory comments for placeholder values (e.g., "copilot-api ignores this value")

**Documentation Cleanup**
- 📝 CHEATSHEET.md: Complete rewrite (250 → 39 lines) - now a true printable quick reference
  - Removed emojis (ASCII-only for terminal/printer compatibility)
  - Removed duplicate content from README/COMMANDS/TROUBLESHOOTING
  - Updated version v1.2.0 → v1.4.0
  - Max line width: 65 columns (fits 80-column terminals)
- 📝 QUICKSTART.md: Removed duplicate cheat sheet table, replaced with link
- 📝 COMMANDS.md: Updated version header v1.2.0 → v1.4.0

---

## [1.4.0] - 2026-01-22

### Changed

**Ollama Provider Overhaul**
- 🔧 **Default model changed**: `qwen2.5-coder:32b-instruct` → `devstral-small-2` (68% SWE-bench, better agentic coding)
- 🔧 **Backup model added**: `ibm/granite4:small-h` (70% less VRAM with hybrid Mamba architecture)
- 🔧 **Context warning**: Script now warns if Ollama context < 32K (Claude Code needs ~18K for system prompt + tools)

**New Aliases**
- `cco-devstral` → Devstral-small-2 (default, best agentic)
- `cco-granite` → Granite4 (long context, RAM-efficient)

### Added

**Ollama Context Configuration**
- ✨ New `_check_ollama_context()` function warns when context is too low
- 📝 Instructions for creating 64K Modelfile (persistent context configuration)
- 📝 Verification command: `ollama ps` shows effective context

**Documentation Updates**
- 📝 CLAUDE.md: Updated Ollama section with new models, context setup, memory footprint
- 📝 TROUBLESHOOTING.md: Complete rewrite of Ollama slow/hallucination section with 64K Modelfile solution
- 📝 MODEL-SWITCHING.md: New "Modèles Ollama" section with Devstral, Granite4, and context configuration
- 📝 README.md: Updated Ollama section with context warning and new recommended models

### Technical Details

**Why Devstral over Qwen2.5?**
- Devstral uses Mistral/OpenAI-style tool-calling format → more compatible with Claude Code
- Qwen2.5 emits tools in `content` instead of structured `tool_calls` → parsing issues
- Confirmed bug: "stuck on Explore" behavior with Qwen2.5 ([GitHub issue](https://github.com/QwenLM/Qwen3-Coder/issues/180))

**Context Configuration**
- Claude Code sends ~18K tokens of system prompt + tools
- Default Ollama context (4K) causes: hallucinations, "stuck on Explore", 2-6 min responses
- Recommended: 64K Modelfile (persistent) > environment variable (global fallback)
- Verification: `ollama ps` shows CONTEXT column (not `ollama show`)

**Memory Footprint (M4 Pro 48GB with 64K context)**
- Devstral Q4_K_M: 15GB model + 8-12GB cache = ~27GB total → ~21GB free
- Granite4 hybrid: ~10GB active → more headroom for context

### Sources

- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/) - Original Ollama + Claude Code research
- [docs.ollama - Context](https://docs.ollama.com/context-length) - Official context configuration
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/) - Community SWE-bench results
- [Devstral HuggingFace](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) - Model card
- [Granite4 InfoQ](https://www.infoq.com/news/2025/11/ibm-granite-mamba2-enterprise/) - Architecture details

### Links

- Release: [v1.4.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.4.0)
- Commits: [v1.3.0...v1.4.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.3.0...v1.4.0)

---

## [1.3.0] - 2026-01-22

### Fixed

**claude-switch v1.3.0 - Prompt Injection Bug**
- 🐛 Fixed "am" appearing automatically at startup when using `ccc-gpt`
- 🔧 Replaced `eval` string execution with native bash arrays for prompt injection
- ✅ Proper handling of newlines and special characters in system prompts
- 🔐 Eliminated command injection vulnerability from prompt content
- 📝 Technical details: [BUGFIX-AM.md](BUGFIX-AM.md)

**install.sh**
- 🐛 Fixed `ccc-gpt` alias pointing to incompatible `gpt-5.2-codex` → changed to `gpt-4.1`

### Added

**Documentation**
- 📝 Documentation complète de l'issue copilot-api #174 (Reserved Billing Header Error) dans TROUBLESHOOTING.md
- 📝 Guide détaillé d'application du patch communautaire (@mrhanhan) pour filtrer `x-anthropic-billing-header`
- 📝 Documentation du script de test automatique dans scripts/README.md

**Scripts**
- ✨ Nouveau script `scripts/test-billing-header-fix.sh` pour tester le fix de l'issue #174
  - Vérifie que copilot-api filtre correctement le header réservé
  - Test automatique avec requêtes système simulant Claude Code v2.1.15+
  - Validation complète : requête avec billing header + requête normale (contrôle)
- 📋 Nouveau `scripts/README.md` documentant tous les scripts utilitaires du projet

**Visual Examples**
- 📸 6 screenshots ajoutés dans `assets/` pour documentation visuelle
  - Claude Sonnet 4.5 (default model)
  - Claude Opus 4.5 (premium quality)
  - GPT-4.1 (OpenAI)
  - Ollama offline (100% private)
  - Help menu (claude-switch --help)
  - copilot-api proxy server logs
- 🎨 Screenshots intégrés dans README.md (Usage + Features sections)
- 🎨 Screenshots intégrés dans QUICKSTART.md (First Use section)

**Documentation Overhaul**
- 📝 **TL;DR technique** ajouté en haut du README (compréhension immédiate)
- 📝 **Optimisation positionnement GitHub** : killer metrics en ligne 28 (au lieu de 101)
- 📝 **Positionnement confiant** : "Serving Copilot Pro+ subscribers specifically"
- 📝 Retrait langage défensif et marketing excessif
- 📝 Structure claire : Core (Copilot) → Bonus (Ollama) → Fallback (Anthropic)

**Patch Communautaire**
- 🔧 Patch appliqué à copilot-api v0.7.0 pour filtrer `x-anthropic-billing-header`
  - Modifie `dist/main.js` fonction `translateAnthropicMessagesToOpenAI`
  - Ajoute filtrage regex pour supprimer le header réservé du system prompt
  - Log de confirmation : "Filtered x-anthropic-billing-header from system message"
  - Backup automatique créé : `dist/main.js.backup`

### Fixed

- ✅ Résolution de l'erreur `invalid_request_body` avec Claude Code v2.1.15+ via copilot-api
- ✅ Compatibilité restaurée entre Claude Code CLI et GitHub Copilot proxy

### Changed

**Repository Organization**
- 🗂️ Création du dossier `claudedocs/` (non versionné) pour documentation interne
- 🗂️ Documentation déplacée dans `docs/` (CHEATSHEET, CODE_OF_CONDUCT, CONTRIBUTING, FEATURES, ROADMAP)
- 🗂️ VERSION déplacé dans `scripts/`
- 🧹 Nettoyage : RECAP.md et SUMMARY.txt supprimés (obsolètes)

**TROUBLESHOOTING.md**
- ⚠️ Ajout section "Reserved Billing Header Error" avec 3 solutions
  - Option 1: Utiliser Anthropic Direct (`ccd`) - Recommandé
  - Option 2: Utiliser Ollama Local (`cco`) - Alternative gratuite
  - Option 3: Attendre fix officiel copilot-api
- 🔧 Ajout section "Patch communautaire" avec guide étape par étape
  - Localisation du fichier à patcher
  - Création backup
  - Application du patch
  - Tests de validation
  - Procédure de restauration
  - Limitations et suivi de l'issue officielle

### Technical Details

**Patch copilot-api #174**
- Fichier modifié : `~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js`
- Fonction patchée : `translateAnthropicMessagesToOpenAI` (ligne 897)
- Regex utilisée : `/x-anthropic-billing-header: \?cc_version=.+; \?cc_entrypoint=\\+\n{0,2}\./`
- Impact : Filtre automatique du header réservé avant envoi à l'API Anthropic
- Compatibilité : Testé avec copilot-api v0.7.0, Claude Code v2.1.15

**Script de test**
- Langage : Bash
- Dépendances : `curl`, `nc`, `jq`
- Tests : 2 requêtes POST /v1/messages (avec/sans billing header)
- Exit code : 0 si succès, 1 si échec
- Logs : Console + vérification logs copilot-api

### Links

- Issue GitHub : [copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174)
- Patch original : [@mrhanhan comment](https://github.com/ericc-ch/copilot-api/issues/174#issuecomment)
- Documentation : [TROUBLESHOOTING.md - Patch communautaire](docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée)
- Release : [v1.3.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.3.0)
- Commits : [v1.2.0...v1.3.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.2.0...v1.3.0)

---

## [1.2.0] - 2026-01-21

### Added

**MCP Profiles System**
- ✨ Auto-generated MCP profiles for strict model validation (GPT-4.1)
- ✨ Model identity injection via system prompts
- ✨ Dynamic profile selection based on model type

**Documentation**
- 📝 MCP-PROFILES.md guide
- 📝 MODEL-SWITCHING.md comprehensive guide

---

## [1.0.0] - 2026-01-20

### Added

**Core Features**
- ✨ Multi-provider support: Anthropic Direct, GitHub Copilot, Ollama
- ✨ Dynamic model switching via `COPILOT_MODEL` environment variable
- ✨ Health checks before provider switching (port availability, model existence)
- ✨ Comprehensive session logging (timestamps, durations, exit codes, models used)
- ✨ Smart shell aliases for instant switching
- ✨ Status command to check all providers at once

**Providers**
- 🚀 **Anthropic Direct**: Official API, best quality, production-ready
- 💰 **GitHub Copilot**: Free with Copilot Pro+ subscription (via copilot-api proxy)
- 🔒 **Ollama Local**: 100% private, offline capable, local inference

**Shell Aliases**
- `ccd` → Anthropic Direct
- `ccc` → GitHub Copilot (default: Sonnet 4.5)
- `cco` → Ollama Local
- `ccs` → Status check all providers
- `ccc-opus` → Copilot with Claude Opus 4.5
- `ccc-sonnet` → Copilot with Claude Sonnet 4.5
- `ccc-haiku` → Copilot with Claude Haiku 4.5
- `ccc-gpt` → Copilot with GPT-5.2 Codex

**Supported Models** (via GitHub Copilot)
- **Claude**: Opus 4.5, Sonnet 4.5, Sonnet 4, Opus 41, Haiku 4.5
- **GPT**: 5.2 Codex, 5.2, 5.1 Codex, 5.1 Codex Max, 5 Mini, 4o variants
- **Gemini**: 3 Pro Preview, 3 Flash Preview, 2.5 Pro
- **Grok**: Code Fast 1
- **Embedding**: text-embedding-3-small

**Documentation**
- 📚 Comprehensive README with examples and troubleshooting
- 📖 MODEL-SWITCHING.md guide for dynamic model selection
- 🏗️ REPO-STRUCTURE.md for repo organization
- ⚙️ Automatic installation script with OS detection

**Logging Features**
- Session start/end timestamps
- Provider and model used
- Working directory path
- Process ID tracking
- Duration calculation (minutes/seconds)
- Exit code tracking
- Colored console output (errors, warnings, info)

### Technical Details

**Script Features**
- Bash 4+ compatible
- Error handling with `set -euo pipefail`
- Health check functions with timeouts
- Session tracking with environment variables
- Colored output for better UX
- Modular function design
- Fail-fast on missing dependencies

**Environment Variables Set**
- `ANTHROPIC_BASE_URL` (provider-specific)
- `ANTHROPIC_AUTH_TOKEN` (provider-specific)
- `ANTHROPIC_MODEL` (dynamic model selection)
- `ANTHROPIC_API_KEY` (Ollama)
- `DISABLE_NON_ESSENTIAL_MODEL_CALLS` (Copilot)
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (Copilot)
- `COPILOT_MODEL` (user-controlled model override)

**Tested Platforms**
- ✅ macOS (M4 Pro, 48GB RAM)
- ✅ Linux (Ubuntu/Debian)
- ❌ Windows (not supported yet)

### Performance

**Latency Benchmarks** (tested on MacBook Pro M4 Pro)
- Anthropic Direct: ~1-2s first token
- GitHub Copilot: ~1-2s first token
- Ollama 32b: ~5-10s first token (local)
- Ollama 7b: ~2-3s first token (local)

**Resource Usage**
- Script overhead: <5MB RAM
- Log file: ~1KB per session
- No background processes

### Security & Privacy

**Data Flow**
- Anthropic Direct: Data sent to Anthropic cloud
- GitHub Copilot: Data sent through Copilot API (Microsoft/GitHub)
- Ollama: 100% local, no external data transmission

**Logging Privacy**
- Log file location: `~/.claude/claude-switch.log`
- Contains: timestamps, providers, durations, working directories
- Does NOT contain: code content, API keys, personal data
- Recommended: Add to `.gitignore`

### Known Limitations

- No Windows support (Bash script)
- Requires netcat (nc) for health checks
- copilot-api must be manually started/managed
- Ollama requires manual model pulling
- No automatic provider fallback on failure
- No cost tracking

### Breaking Changes

None (initial release)

### Deprecated

None (initial release)

### Removed

None (initial release)

### Fixed

None (initial release)

### Security

- No known security vulnerabilities
- Script does not handle API keys directly
- Relies on existing environment variables
- Log file contains only metadata

---

## [Unreleased]

### Planned for v1.1

- [ ] Windows PowerShell support
- [ ] Shell completion (Bash/Zsh)
- [ ] Automated tests (health checks, model switching)
- [ ] Better error messages for common issues
- [ ] Config file support (`~/.claude-switch.conf`)

### Planned for v1.2

- [ ] Web UI for status monitoring
- [ ] Cost tracking per provider
- [ ] Usage analytics and reports
- [ ] Automatic provider selection based on context
- [ ] Background service mode for copilot-api

### Planned for v2.0

- [ ] Plugin system for custom providers
- [ ] OpenRouter integration
- [ ] Perplexity integration
- [ ] Team configuration sync
- [ ] Session replay from logs

---

## Contributing

See [REPO-STRUCTURE.md](REPO-STRUCTURE.md) for contribution guidelines.

---

## Links

- **Repository**: https://github.com/FlorianBruniaux/cc-copilot-bridge
- **Issues**: https://github.com/FlorianBruniaux/cc-copilot-bridge/issues

[1.5.1]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.1
[1.5.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.0
[1.4.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.4.0
[1.3.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.3.0
[1.2.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.2.0
[1.0.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.0.0
[Unreleased]: https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.5.1...HEAD
