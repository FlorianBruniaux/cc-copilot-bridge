# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

---

## [1.0.0] - 2026-01-21

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

- **Repository**: https://github.com/FlorianBruniaux/claude-switch (upcoming)
- **Ultimate Guide**: https://github.com/FlorianBruniaux/claude-code-ultimate-guide
- **Issues**: https://github.com/FlorianBruniaux/claude-switch/issues (upcoming)

[1.0.0]: https://github.com/FlorianBruniaux/claude-switch/releases/tag/v1.0.0
[Unreleased]: https://github.com/FlorianBruniaux/claude-switch/compare/v1.0.0...HEAD
