# Claude Code Multi-Provider - Troubleshooting Guide

**Version**: 1.1.0
**Date**: 2026-01-21

---

## 🐌 Ollama Extremely Slow with Claude Code

### Symptom

```bash
cco
❯ 1+1 ?
⏱️ Response: 2-6 MINUTES (should be 3-10 seconds)
💻 CPU at 100%
🔥 Mac fans spinning
```

### Root Cause

**Context mismatch**: Claude Code sends ~60K tokens of context, but Ollama is configured for 8K tokens.

**Result**: 87% of context is truncated → model constantly reprocesses → extreme slowness.

### Diagnosis

1. **Check your context usage**:
   ```bash
   # During cco session
   /context
   ```

   Look for:
   - Memory files: >20K tokens
   - Total context: >50K tokens
   - Free space: negative or very low

2. **Verify Ollama context**:
   ```bash
   launchctl getenv OLLAMA_CONTEXT_LENGTH
   # Should show: 8192
   ```

3. **Check model loading**:
   ```bash
   ollama ps
   # Look at SIZE column (should be 26 GB for 32B model)
   ```

### Solutions

#### Option 1: Use Copilot or Anthropic (Recommended)

**For large projects (>500 files)**, switch to a cloud provider:

```bash
# Copilot (free with subscription)
ccc
❯ same prompt
⏱️ Response: 1-3 seconds ✅

# Anthropic Direct (paid)
ccd
❯ same prompt
⏱️ Response: 1-2 seconds ✅
```

**Why this works**: Both handle 100K+ tokens context natively.

#### Option 2: Increase Ollama Context

**Warning**: This will make Ollama slower (but still functional).

```bash
# For medium projects (500-2K files)
launchctl setenv OLLAMA_CONTEXT_LENGTH 16384
brew services restart ollama

# For large projects (>2K files)
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
brew services restart ollama
```

**Trade-offs**:
| Context | RAM | Speed | Works with Claude Code |
|---------|-----|-------|------------------------|
| 8K | 26 GB | ⚡ 26-39 tok/s | ❌ Small projects only |
| 16K | 30-32 GB | 🐢 15-25 tok/s | ⚠️ Medium projects |
| 32K | 36-40 GB | 🐌 8-15 tok/s | ✅ Large projects |

#### Option 3: Reduce Claude Code Context

Create a `.claudeignore` file in your project root:

```bash
# .claudeignore
node_modules/
dist/
build/
.next/
.git/
coverage/
*.log
*.lock
```

**Effect**: Reduces Memory files tokens → smaller total context.

### Recommended Approach by Project Size

| Project Size | Files | Recommended Solution |
|--------------|-------|---------------------|
| Small | <500 | Keep Ollama 8K ⚡ |
| Medium | 500-2K | Switch to Copilot ⚡ |
| Large | >2K | Switch to Copilot/Anthropic ⚡ |
| Privacy-critical | Any | Ollama 32K (slow but private) 🐌 |

---

## ❌ Model Not Found Error

### Symptom

```bash
cco
ERROR: Model qwen2.5-coder not found
  Pull it with: ollama pull qwen2.5-coder:32b
```

### Cause

Model name mismatch between script and installed model.

### Solution

1. **Check installed models**:
   ```bash
   ollama list
   ```

2. **Pull the correct model**:
   ```bash
   ollama pull qwen2.5-coder:32b-instruct
   ```

3. **Or override model**:
   ```bash
   OLLAMA_MODEL=qwen2.5-coder:7b cco
   ```

---

## 🔑 API Key Prompt on Every Launch

### Symptom

```bash
cco
Detected a custom API key in your environment
ANTHROPIC_API_KEY: sk-ant-...ollama
Do you want to use this API key?
  1. Yes
  2. No (recommended) ✓
```

### Cause

`ANTHROPIC_API_KEY` set in script triggers Claude Code validation.

### Solution

**Already fixed in v1.1.0+**. If using older version:

1. Edit `~/bin/claude-switch`
2. In `_run_ollama()` function, remove:
   ```bash
   export ANTHROPIC_API_KEY="ollama"
   ```
3. Keep only:
   ```bash
   export ANTHROPIC_BASE_URL="http://localhost:11434"
   export ANTHROPIC_AUTH_TOKEN="ollama"
   ```

---

## ❌ Model Not Accessible Error (copilot-api)

### Symptom

```bash
ccc-gpt  # or COPILOT_MODEL=gpt-5.2-codex ccc
ERROR  Failed to create chat completions Response { status: 400
ERROR  HTTP error: { error:
   { message: 'model gpt-5.2-codex is not accessible via the /chat/completions endpoint',
     code: 'unsupported_api_for_model' } }
```

### Cause

**TOUS les modèles de la famille GPT Codex** nécessitent l'endpoint OpenAI `/responses` (lancé en octobre 2025) au lieu du standard `/chat/completions`. copilot-api (v0.7.0) ne supporte que `/chat/completions`, rendant **TOUS les modèles Codex incompatibles** :

- ❌ `gpt-5.2-codex` (GA depuis 14 jan 2026)
- ❌ `gpt-5.1-codex` (Preview)
- ❌ `gpt-5.1-codex-mini` (Preview)
- ❌ `gpt-5-codex` (Preview)

**Cause technique** : Les modèles Codex utilisent un paradigme stateful avec `previous_response_id` pour le contexte, incompatible avec l'API Chat Completions classique.

### Solution

**Option 1: Utiliser des modèles GPT compatibles (Recommandé)**

```bash
# Modèles GPT 100% compatibles avec copilot-api:
COPILOT_MODEL=gpt-4.1 ccc       # Équilibré, 0x premium (inclus)
COPILOT_MODEL=gpt-5 ccc         # Raisonnement avancé, 1x premium
COPILOT_MODEL=gpt-5-mini ccc    # Ultra rapide, 0x premium
```

**Option 2: Utiliser Claude via Copilot (100% compatible)**

```bash
ccc-sonnet  # Claude Sonnet 4.5 (défaut, fiable)
ccc-opus    # Claude Opus 4.5 (meilleure qualité)
ccc-haiku   # Claude Haiku 4.5 (ultra rapide)
```

**Option 3: Suivre le développement du fix**

Le PR communautaire [ericc-ch/copilot-api#117](https://github.com/ericc-ch/copilot-api/pull/117) travaille sur le support de l'endpoint `/responses`.

### Modèles testés et fonctionnels

| Modèle | Statut | Usage |
|--------|--------|-------|
| `claude-sonnet-4.5` | ✅ Fonctionne | Développement quotidien |
| `claude-opus-4.5` | ✅ Fonctionne | Code critique |
| `claude-haiku-4.5` | ✅ Fonctionne | Questions rapides |
| `gpt-4.1` | ✅ Fonctionne | Usage général, 0x premium |
| `gpt-5` | ✅ Fonctionne | Raisonnement avancé, 1x premium |
| `gpt-5-mini` | ✅ Fonctionne | Ultra rapide, 0x premium |
| `gemini-3-pro-preview` | ✅ Fonctionne | Alternative |
| `grok-code-fast-1` | ✅ Fonctionne | Code spécialisé |
| `raptor-mini` | ✅ Fonctionne | Léger |
| `gpt-5.2-codex` | ❌ Incompatible | Endpoint `/responses` requis |
| `gpt-5.1-codex` | ❌ Incompatible | Endpoint `/responses` requis |
| `gpt-5.1-codex-mini` | ❌ Incompatible | Endpoint `/responses` requis |
| `gpt-5-codex` | ❌ Incompatible | Endpoint `/responses` requis |

### Modèles dépréciés (17 février 2026)

```bash
# À remplacer avant le 17 février 2026:
claude-opus-4.1 → claude-opus-4.5
gemini-2.5-pro → gemini-3-pro-preview
```

---

## ⚠️ MCP Schema Validation Error (GPT-4.1)

### Symptom

Quand tu utilises GPT-4.1, tu vois des erreurs API dans Claude Code :

```bash
COPILOT_MODEL=gpt-4.1 ccc
❯ 1+1
API Error: 400 {"error":{"message":"Invalid schema for function 'mcp__grepai__grepai_index_status':
In context=(), object schema missing properties.","code":"invalid_function_parameters"}}
```

**Ces erreurs apparaissent également dans les logs de copilot-api** (terminal où `copilot-api start` tourne) :

```
ERROR  HTTP error: { error:
   { message:
      "Invalid schema for function 'mcp__grepai__grepai_index_status': In context=(), object schema missing properties.",
     code: 'invalid_function_parameters' } }
```

### Cause

**GPT-4.1 applique une validation stricte des schémas JSON** pour les outils MCP (Model Context Protocol). Certains serveurs MCP ont des schémas incomplets ou invalides qui passent avec Claude (permissif) mais échouent avec GPT-4.1.

**Problème typique** : Schéma déclaré comme `"type": "object"` sans définir `"properties": {}`, ce qui est techniquement invalide selon JSON Schema.

**Serveurs MCP problématiques connus**:
- ❌ `grepai`: `grepai_index_status` - object schema missing properties

### Solution

**Option 1: Utiliser Claude (100% compatible MCP)** ⭐ Recommandé

```bash
ccc-sonnet   # Claude Sonnet 4.5 (défaut)
ccc-opus     # Claude Opus 4.5 (meilleure qualité)
ccc-haiku    # Claude Haiku 4.5 (ultra rapide)
```

**Avantages**:
- ✅ 100% compatible avec tous les serveurs MCP
- ✅ Validation permissive (accepte schémas imparfaits)
- ✅ Meilleure qualité que GPT-4.1

**Option 2: Désactiver le serveur MCP problématique**

Éditez `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    // "grepai": {          <- Commenté ou supprimé
    //   "command": "grepai",
    //   "args": ["mcp-serve"]
    // },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}
```

Puis relancez Claude Code.

**Option 3: Reporter le problème au mainteneur**

Si un serveur MCP que tu utilises a ce problème, ouvre une issue:
- grepai: https://github.com/grepAI/grepai/issues
- Autres serveurs: Cherche le repo GitHub du serveur

### Diagnostic

**Quand tu vois l'erreur "Invalid schema for function 'mcp__...'", lance le diagnostic** :

```bash
# Vérifier tous les serveurs MCP configurés
mcp-check.sh

# Avec analyse des logs récents de Claude Code
mcp-check.sh --parse-logs
```

Le script identifiera le serveur MCP problématique et te proposera 4 solutions.

**Output exemple**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MCP Server Compatibility Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 3 MCP server(s) configured:

━━━ grepai ━━━
Command: grepai mcp-serve
✓ Command installed
✗ Known compatibility issue:
  grepai_index_status: object schema missing properties
  Impact: Fails with GPT-4.1 (strict validation)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Servers checked: 3
Compatibility issues: 1

═══ Recommendations ═══

Option 1: Use Claude models (100% MCP compatible)
  ccc-sonnet   # Claude Sonnet 4.5
  ccc-opus     # Claude Opus 4.5

Option 2: Disable problematic MCP servers
  Edit: /Users/you/.claude/claude_desktop_config.json
  Remove or comment out problematic servers

Option 3: Report issue to MCP server maintainer
  Example: https://github.com/grepAI/grepai/issues
```

### Comparaison: Claude vs GPT-4.1

| Aspect | Claude | GPT-4.1 |
|--------|--------|---------|
| **Validation MCP** | Permissive | Stricte |
| **Schémas imparfaits** | ✅ Accepte | ❌ Rejette |
| **Compatibilité** | 100% | ~80% (selon serveurs) |
| **Recommandation** | ⭐ Défaut | Backup si Claude indisponible |

### Pourquoi Claude est meilleur pour copilot-api

1. **100% compatible endpoint `/chat/completions`**
2. **100% compatible MCP tools (validation permissive)**
3. **Pas de breaking changes sur updates MCP**
4. **Meilleure qualité de code générée**

**Conclusion**: Pour une expérience sans friction avec copilot-api, **utilise Claude par défaut**.

---

## 🔌 Provider Not Running

### Copilot: Port 4141 Not Responding

**Symptom**:
```bash
ccc
ERROR: copilot-api not running on :4141
  Start it with: copilot-api start
```

**Solution**:
```bash
# Start copilot-api
copilot-api start

# If OAuth expired, re-authenticate
copilot-api stop
copilot-api start
```

### Ollama: Port 11434 Not Responding

**Symptom**:
```bash
cco
ERROR: Ollama not running on :11434
  Start it with: ollama serve
```

**Solution**:
```bash
# Check Homebrew service
brew services info ollama

# Restart if needed
brew services restart ollama

# Verify it's running
curl http://localhost:11434/api/tags
```

---

## 💾 Out of Memory / Slow Performance

### Symptom

```bash
ollama ps
NAME                          SIZE      PROCESSOR
qwen2.5-coder:32b-instruct    12 GB     50% GPU  # Should be 26 GB, 100% GPU
```

### Cause

Not enough RAM or model not fully loaded.

### Solution

1. **Check available RAM**:
   ```bash
   # macOS
   vm_stat | grep free

   # Should have 25GB+ free for 32B model
   ```

2. **Use smaller model** if RAM-limited:
   ```bash
   # For 24GB RAM
   ollama pull qwen2.5-coder:14b
   OLLAMA_MODEL=qwen2.5-coder:14b cco

   # For 16GB RAM
   ollama pull qwen2.5-coder:7b
   OLLAMA_MODEL=qwen2.5-coder:7b cco
   ```

3. **Close other applications** to free RAM.

---

## 🚫 Permission Denied Errors

### Symptom

```bash
claude-switch: permission denied
```

### Solution

```bash
chmod +x ~/bin/claude-switch
chmod +x ~/bin/ollama-check.sh
chmod +x ~/bin/ollama-optimize.sh
```

---

## 🔄 Changes Not Applied After Optimization

### Symptom

After running `ollama-optimize.sh`, performance unchanged.

### Cause

Environment variables set but service not restarted.

### Solution

```bash
# Restart Ollama service
brew services restart ollama

# Verify variables are set
launchctl getenv OLLAMA_FLASH_ATTENTION  # Should show: 1
launchctl getenv OLLAMA_CONTEXT_LENGTH   # Should show: 8192

# Wait 10 seconds for service to start
sleep 10

# Test
ollama ps
```

---

## 📊 Model Shows Wrong Identity

### Symptom

```bash
cco
❯ who are you?
⏺ I am Claude, created by Anthropic...
```

But you're using Qwen2.5-Coder (not Claude).

### Explanation

**Not a bug**. The local model sees Claude Code's system prompt and adopts that identity. This is normal behavior for instruction-tuned models.

**It doesn't affect**:
- Code quality
- Performance
- Functionality

The model is still **Qwen2.5-Coder**, just confused about its identity from the prompt.

---

## 🔍 How to Verify Which Provider is Active

### Method 1: Check Logs

```bash
tail -5 ~/.claude/claude-switch.log
```

**Look for**:
```
[INFO] Provider: Ollama Local - Model: qwen2.5-coder:32b-instruct
[INFO] Session started: mode=ollama:...
```

### Method 2: Check Process Variables

```bash
# Find Claude Code PID
ps aux | grep "claude --model"

# Check environment (replace PID)
cat /proc/PID/environ | tr '\0' '\n' | grep ANTHROPIC
```

**Expected for Ollama**:
```
ANTHROPIC_BASE_URL=http://localhost:11434
ANTHROPIC_AUTH_TOKEN=ollama
```

### Method 3: Monitor Network Traffic

```bash
# Terminal 1: Monitor Ollama port
sudo tcpdump -i lo0 -A 'tcp port 11434'

# Terminal 2: Launch cco and send prompt
# You should see JSON traffic in Terminal 1
```

---

## 🆘 Get Help

If issues persist:

1. **Run full diagnostic**:
   ```bash
   ollama-check.sh > diagnostic.txt
   ```

2. **Check provider status**:
   ```bash
   ccs  # Status of all providers
   ```

3. **Review logs**:
   ```bash
   tail -50 ~/.claude/claude-switch.log
   ```

4. **Report issue** with:
   - Output of `ollama-check.sh`
   - Last 20 lines of `~/.claude/claude-switch.log`
   - Output of `ollama ps`
   - Your project size (file count)

---

## 📚 Related Documentation

- [README.md](README.md) - Full documentation
- [OPTIMISATION-M4-PRO.md](OPTIMISATION-M4-PRO.md) - Performance optimization guide
- [STATUS.md](STATUS.md) - Implementation status
- [COMMANDS.md](COMMANDS.md) - Command reference

---

**Last Updated**: 2026-01-21
**Version**: 1.1.0
