# Troubleshooting Guide

**Reading time**: 20 minutes | **Skill level**: All levels | **Version**: v1.4.0 | **Last updated**: 2026-01-22

---

## 🐌 Ollama Extremely Slow or Hallucinating with Claude Code

### Symptom

```bash
cco
❯ 1+1 ?
⏱️ Response: 2-6 MINUTES (should be 3-10 seconds)
💻 CPU at 100%
🔥 Mac fans spinning
# OR: hallucinations, "stuck on Explore" behavior, incoherent responses
```

### Root Cause

**Context mismatch**: Claude Code sends ~18K tokens of system prompt + tools, but default Ollama context is 4K tokens.

**Result**: Context is truncated → model hallucinates → regenerates constantly → extreme slowness.

### Diagnosis

1. **Verify effective context**:
   ```bash
   # During cco session (in another terminal)
   ollama ps
   # Look at CONTEXT column - should be 65536 for Claude Code
   ```

2. **Check context usage in Claude Code**:
   ```bash
   # During session
   /context
   ```
   Look for: Free space negative or very low

### Solutions

#### Option 1: Create a 64K Modelfile (Recommended - Persistent)

This is the **official recommended method** from Ollama documentation. It persists across restarts.

```bash
# 1. Create Modelfile directory
mkdir -p ~/.ollama

# 2. Create the Modelfile
cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
FROM devstral-small-2
PARAMETER num_ctx 65536
PARAMETER temperature 0.15
EOF

# 3. Create the model variant
ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k

# 4. Use the 64K model
OLLAMA_MODEL=devstral-64k cco
```

**Why this works**:
- `PARAMETER num_ctx` is embedded in the model → persists across restarts
- `temperature 0.15` reduces hallucinations for code generation
- Custom model variants can be listed with `ollama list`

#### Option 2: Global Environment Variable (Quick Fix)

Less priority than Modelfile, but works as fallback:

```bash
# Set global context length
launchctl setenv OLLAMA_CONTEXT_LENGTH 65536
brew services restart ollama

# Verify
launchctl getenv OLLAMA_CONTEXT_LENGTH
# Should show: 65536
```

**Note**: Environment variable has lower priority than Modelfile PARAMETER.

#### Option 3: Use Copilot or Anthropic (Alternative)

**For large projects or when local performance is insufficient**:

```bash
# Copilot (free with subscription)
ccc
⏱️ Response: 1-3 seconds ✅

# Anthropic Direct (paid)
ccd
⏱️ Response: 1-2 seconds ✅
```

**Why this works**: Both handle 200K+ tokens context natively.

### Verify the Fix

```bash
# 1. Pull recommended model
ollama pull devstral-small-2

# 2. Create 64K Modelfile (see Option 1 above)

# 3. Start session
OLLAMA_MODEL=devstral-64k cco

# 4. Check effective context (in another terminal)
ollama ps
# Expected: CONTEXT = 65536

# 5. Test agentic task
❯ create a file hello.py with print("Hello")
# Should complete in 5-15 seconds, not 2-6 minutes
```

### Memory Considerations (M4 Pro 48GB)

| Context Size | Model RAM | Cache RAM | Total | Free RAM |
|--------------|-----------|-----------|-------|----------|
| 32K | 15 GB | 4-6 GB | ~21 GB | ~27 GB |
| 64K | 15 GB | 8-12 GB | ~27 GB | ~21 GB |

**Recommendation**: Use 64K if possible. If RAM is tight, use 32K or switch to Copilot.

### Recommended Ollama Models (Updated January 2026)

| Model | Size | SWE-bench | Use Case |
|-------|------|-----------|----------|
| **devstral-small-2** (default) | 24B | 68% | Best agentic coding |
| ibm/granite4:small-h | 32B (9B active) | ~62% | Long context, 70% less VRAM |
| qwen3-coder:30b | 30B | 85% | Highest accuracy (needs template work) |

**Sources**:
- [Ollama Context Documentation](https://docs.ollama.com/context-length)
- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/)
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/)

---

## ❌ Model Not Found Error

### Symptom

```bash
cco
ERROR: Model devstral-small-2 not found
  Pull it with: ollama pull devstral-small-2
```

### Cause

Model not installed or model name mismatch.

### Solution

1. **Pull the recommended model**:
   ```bash
   ollama pull devstral-small-2
   ```

2. **Or pull backup model for long context**:
   ```bash
   ollama pull ibm/granite4:small-h
   ```

3. **Check installed models**:
   ```bash
   ollama list
   ```

4. **Override model if needed**:
   ```bash
   OLLAMA_MODEL=ibm/granite4:small-h cco
   ```

---

## 🔑 API Key Prompt on Every Launch

### Symptom

```bash
cco
Detected a custom API key in your environment
ANTHROPIC_API_KEY: <YOUR_API_KEY>
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

## ❌ Reserved Billing Header Error (copilot-api)

### Symptom

```bash
ccc
❯ 1+1
API Error: 400 Bad Request
{"error":{"message":"x-anthropic-billing-header is a reserved keyword and may not be used in the system prompt",
  "code":"invalid_request_body"}}
```

### Cause

**Claude Code v2.1.15+** injecte la chaîne `x-anthropic-billing-header` dans son system prompt pour le tracking billing interne. L'API Anthropic (via copilot-api proxy) rejette cette requête car c'est un **mot-clé réservé** qui ne peut pas apparaître dans les prompts utilisateur.

**Cause technique** : Anthropic réserve certains mots-clés (comme `x-anthropic-billing-header`) pour son infrastructure interne. Quand Claude Code inclut ces mots dans le system prompt, l'API les détecte et rejette la requête pour éviter les conflits.

**Issue GitHub** : [ericc-ch/copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174) (ouverte le 22 janvier 2026)

### Qui est affecté

- ✅ **Anthropic Direct (`ccd`)** : Non affecté (API native gère correctement)
- ❌ **Copilot via copilot-api (`ccc`)** : AFFECTÉ (proxy rejette le header)
- ✅ **Ollama Local (`cco`)** : Non affecté (pas d'API Anthropic)

### Solutions

**Option 1: Utiliser Anthropic Direct (Recommandé)** ⭐

```bash
ccd  # Anthropic API native, gère x-anthropic-billing-header correctement
```

**Avantages**:
- ✅ 100% compatible avec toutes les versions Claude Code
- ✅ Meilleure qualité (pas de proxy)
- ✅ Support officiel Anthropic

**Inconvénients**:
- 💰 Payant (facturation au token)

**Option 2: Utiliser Ollama Local**

```bash
cco  # 100% privé, pas d'API Anthropic
```

**Avantages**:
- ✅ Gratuit, illimité
- ✅ 100% privé (aucune donnée ne quitte la machine)
- ✅ Pas affecté par les problèmes API Anthropic

**Inconvénients**:
- 🐌 Plus lent que cloud (voir [Optimisation M4 Pro](OPTIMISATION-M4-PRO.md))

**Option 3: Attendre un fix de copilot-api**

L'issue est activement suivie sur GitHub. Possibles solutions en développement :
1. Filtrage automatique du header réservé par copilot-api
2. Patch Claude Code pour exclure le header des proxies
3. Configuration Anthropic API pour accepter le header via proxies

**Suivi** : [ericc-ch/copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174)

### Workaround temporaire (NON RECOMMANDÉ)

Un utilisateur a reporté que retirer manuellement `x-anthropic-billing-header` du system message permet de contourner l'erreur, mais :

❌ **Ne PAS utiliser** : Modifier le system prompt casse la session Claude Code
❌ **Fragile** : Cassera à chaque update de Claude Code
❌ **Complexe** : Nécessite d'intercepter et modifier les requêtes

**Préférez les Options 1 ou 2 ci-dessus.**

### Diagnostic

Si tu vois cette erreur sporadiquement :

```bash
# Vérifier la version Claude Code
claude --version
# Si v2.1.15+, le problème est présent

# Vérifier les logs récents
tail -50 ~/.claude/claude-switch.log | grep "400\|billing"

# Tester avec Anthropic Direct
ccd
❯ 1+1
# Si ça fonctionne → confirme que le problème vient de copilot-api
```

### Patch communautaire (Solution avancée)

**⚠️ AVERTISSEMENT** : Cette solution modifie le code source de copilot-api. À utiliser uniquement si tu es à l'aise avec le debugging et prêt à restaurer en cas de problème.

Un utilisateur de la communauté [@mrhanhan](https://github.com/ericc-ch/copilot-api/issues/174) a proposé un patch fonctionnel qui filtre automatiquement le header réservé.

#### Étape 1: Localiser le fichier à patcher

```bash
# Trouver l'installation de copilot-api
which copilot-api
# → /Users/YOU/.nvm/versions/node/vXX.XX.X/bin/copilot-api

# Le fichier à modifier est dans dist/main.js
# Exemple: ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js
```

#### Étape 2: Créer un backup

```bash
cd ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist
cp main.js main.js.backup
echo "✅ Backup créé: main.js.backup"
```

#### Étape 3: Appliquer le patch

Éditer `dist/main.js` et trouver la fonction `translateAnthropicMessagesToOpenAI` (autour de la ligne 897).

**Avant (original)** :
```javascript
function translateAnthropicMessagesToOpenAI(anthropicMessages, system) {
	const systemMessages = handleSystemPrompt(system);
	const otherMessages = anthropicMessages.flatMap((message) =>
		message.role === "user" ? handleUserMessage(message) : handleAssistantMessage(message)
	);
	return [...systemMessages, ...otherMessages];
}
```

**Après (patché)** :
```javascript
function translateAnthropicMessagesToOpenAI(anthropicMessages, system) {
	let systemMessages = handleSystemPrompt(system);
	// FIX #174: Filter x-anthropic-billing-header from system prompt
	systemMessages = systemMessages.map((it) => {
		if (typeof it.content === "string" && it.content.startsWith("x-anthropic-billing-header")) {
			it.content = it.content.replace(
				/x-anthropic-billing-header: \?cc_version=.+; \?cc_entrypoint=\\+\n{0,2}\./,
				""
			);
			console.info('Filtered x-anthropic-billing-header from system message');
		}
		return it;
	});
	const otherMessages = anthropicMessages.flatMap((message) =>
		message.role === "user" ? handleUserMessage(message) : handleAssistantMessage(message)
	);
	return [...systemMessages, ...otherMessages];
}
```

**Modifications apportées** :
1. `const systemMessages` → `let systemMessages` (ligne 2)
2. Ajout du filtre `systemMessages.map()` (lignes 3-12)
3. Log de confirmation quand le header est filtré

#### Étape 4: Redémarrer copilot-api

```bash
# Arrêter le processus actuel
kill $(ps aux | grep "copilot-api start" | grep -v grep | awk '{print $2}')

# Redémarrer avec le patch
copilot-api start
```

#### Étape 5: Tester le patch

**Test automatique** :

Un script de test est disponible dans le projet cc-copilot-bridge :

```bash
# Dans le dépôt cc-copilot-bridge
./scripts/test-billing-header-fix.sh
```

**Test manuel** :

```bash
# Test 1: Requête avec billing header
curl -s -X POST http://localhost:4141/v1/messages \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 100,
    "system": "x-anthropic-billing-header: test\n\nYou are helpful.",
    "messages": [{"role": "user", "content": "Say hello"}]
  }' | jq '.content[0].text // .error'

# Résultat attendu: Réponse normale (pas d'erreur 400)
```

**Test avec Claude Code** :

```bash
ccc
❯ 1+1
```

**Résultat attendu** : Réponse normale sans erreur `invalid_request_body`

#### Vérification des logs

Dans le terminal où copilot-api tourne, tu devrais voir :

```
Filtered x-anthropic-billing-header from system message
```

Chaque fois que Claude Code envoie une requête avec le header réservé.

#### Restaurer l'original

Si le patch cause des problèmes :

```bash
# Arrêter copilot-api
kill $(ps aux | grep "copilot-api start" | grep -v grep | awk '{print $2}')

# Restaurer le backup
cd ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist
cp main.js.backup main.js

# Redémarrer
copilot-api start
```

#### Limitations du patch

**⚠️ Patch temporaire** :
- ❌ Sera écrasé à chaque `npm update copilot-api`
- ❌ Non testé sur toutes les versions de copilot-api
- ❌ Peut ne pas couvrir tous les cas edge

**Après update de copilot-api** :
```bash
# Vérifier si le patch existe toujours
grep -n "FIX #174" ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js

# Si vide → ré-appliquer le patch
```

#### Suivi de l'issue officielle

Surveille [copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174) pour un fix officiel dans une future version.

Une fois le fix intégré officiellement :
```bash
npm update -g copilot-api  # Mettre à jour
# Plus besoin du patch manuel
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

## 🤖 Gemini Agentic Mode Issues (copilot-api)

### Symptom

When using Gemini models with tool-calling (file creation, MCP tools, etc.), you experience:

```bash
COPILOT_MODEL=gemini-3-pro-preview ccc
❯ Create a file called hello.txt with "test"

# Possible symptoms:
# 1. No response or timeout
# 2. Error: model_not_supported
# 3. Error: invalid_request_body
# 4. Error: INVALID_ARGUMENT
# 5. File not created despite "success" message
```

**Simple prompts work fine**:
```bash
COPILOT_MODEL=gemini-3-pro-preview ccc -p "1+1"
✅ Returns: 2
```

**Agentic prompts fail**:
```bash
COPILOT_MODEL=gemini-3-pro-preview ccc -p "Create hello.txt"
❌ No file created, errors in logs
```

### Cause

**Root issue**: copilot-api translates Claude tool calling format → OpenAI format → Gemini format. This translation chain introduces incompatibilities:

1. **Tool Format Mismatch**: Claude uses Anthropic tool schema, Gemini expects Google-specific format
2. **Subagent Calls**: Claude Code spawns subagents (Task tool) that may not work correctly with Gemini
3. **Preview Model Instability**: `gemini-3-*-preview` models are experimental and may have incomplete tool support

**Issue reference**: [copilot-api#151](https://github.com/ericc-ch/copilot-api/issues/151)

### Diagnosis

Run automated diagnostic to identify the exact issue:

```bash
# In cc-copilot-bridge project
cd /path/to/cc-copilot-bridge

# Run test suite
./scripts/test-gemini.sh

# View results
cat debug-gemini/summary.txt
cat debug-gemini/diagnostic-report.md
```

**Diagnostic tests**:
| Test | Scenario | What It Checks |
|------|----------|----------------|
| 1 | Simple calculation | Baseline (non-agentic) |
| 2 | File creation | Direct tool calling |
| 3 | MCP grep tool | MCP schema compatibility |
| 4 | Subagent workaround | If routing through GPT fixes issue |
| 5 | Gemini 2.5 stable | Stable model comparison |

**Decision tree**:
```
Test 1 fails → copilot-api auth/config issue
Test 2 fails, Test 1 OK → Tool format incompatibility
Test 3 fails → MCP schema validation issue (see "MCP Schema Validation Error" section)
Test 4 succeeds, Test 2 fails → Confirms subagent routing fixes issue
Test 5 succeeds, Test 2 fails → Gemini 3 preview limitation
```

### Solutions

**Option 1: Use Stable Gemini 2.5 Pro** ⭐ Recommended

```bash
COPILOT_MODEL=gemini-2.5-pro ccc
# OR
ccc-gemini  # Alias for gemini-2.5-pro

❯ Create hello.txt with "test"
✅ Works reliably for most scenarios
```

**Pros**:
- ✅ More stable than preview models
- ✅ Better tool calling support
- ✅ Production-ready

**Cons**:
- ⚠️ May still have occasional issues with complex multi-tool workflows
- ⚠️ Deprecation scheduled: 17 Feb 2026 → migrate to gemini-3-pro-preview once stable

**Option 2: Use Subagent Workaround (Gemini 3 Preview)**

For preview models, route complex operations through a stable subagent:

```bash
# Manual usage
COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini ccc

❯ Create hello.txt with "test"
✅ Subagent (GPT-5-mini) handles tool calls
```

**How it works**:
- Main agent: Gemini 3 (planning, reasoning)
- Subagent: GPT-5-mini (tool execution)
- When Claude Code spawns Task tool → uses GPT instead of Gemini

**Pros**:
- ✅ Keeps Gemini 3 for main reasoning
- ✅ Stable tool execution via GPT
- ✅ No need to disable MCP servers

**Cons**:
- ⚠️ Slight latency increase (2 models involved)
- ⚠️ Mixed model behavior

**Option 3: Use Claude Models (100% Compatible)** 🚀 Best Quality

```bash
ccc-sonnet  # Claude Sonnet 4.5 (default, balanced)
ccc-opus    # Claude Opus 4.5 (best quality)
ccc-haiku   # Claude Haiku 4.5 (fastest)

❯ Create hello.txt with "test"
✅ Works flawlessly, no workarounds needed
```

**Pros**:
- ✅ 100% tool calling compatibility
- ✅ Best agentic performance
- ✅ No translation issues (native Anthropic format)
- ✅ Best code quality

**Cons**:
- None (Claude via Copilot is the gold standard)

**Option 4: Use GPT Models (Reliable Alternative)**

```bash
COPILOT_MODEL=gpt-4.1 ccc    # Balanced, 0x premium
COPILOT_MODEL=gpt-5 ccc      # Advanced reasoning, 1x premium
COPILOT_MODEL=gpt-5-mini ccc # Ultra fast, 0x premium

❯ Create hello.txt with "test"
✅ Reliable tool calling (with MCP exclusions if needed)
```

**Pros**:
- ✅ Stable tool calling
- ✅ Good agentic performance
- ✅ Fast responses

**Cons**:
- ⚠️ MCP schema validation (see "MCP Schema Validation Error" section)
- ⚠️ May need to disable `grepai` MCP server

### Automated Workaround (claude-switch Integration)

The subagent workaround can be automated in `claude-switch` script:

```bash
# In ~/bin/claude-switch, add to _run_copilot() function:

# Gemini workaround: auto-set subagent for preview models
if [[ "$COPILOT_MODEL" == gemini-3-*-preview ]]; then
    export CLAUDE_CODE_SUBAGENT_MODEL="${CLAUDE_CODE_SUBAGENT_MODEL:-gpt-5-mini}"
    _log "INFO" "Gemini preview detected: subagent=$CLAUDE_CODE_SUBAGENT_MODEL"
fi
```

**Benefits**:
- 🔄 Automatic workaround activation
- 📝 Logged in session logs
- 🎯 Only affects Gemini preview models

### Model Compatibility Matrix

| Model | Simple Prompts | Agentic/Tools | Status | Recommendation |
|-------|----------------|---------------|--------|----------------|
| `claude-sonnet-4.5` | ✅ Excellent | ✅ Excellent | Stable | ⭐ **Best choice** |
| `claude-opus-4.5` | ✅ Excellent | ✅ Excellent | Stable | ⭐ Best quality |
| `gpt-4.1` | ✅ Excellent | ✅ Good | Stable | ✅ Reliable |
| `gpt-5` | ✅ Excellent | ✅ Good | Stable | ✅ Advanced reasoning |
| `gemini-2.5-pro` | ✅ Good | ⚠️ Fair | Deprecating 2/17/26 | ⚠️ Use with caution |
| `gemini-3-pro-preview` | ✅ Good | ❌ Poor | Experimental | ❌ Use subagent workaround |
| `gemini-3-flash-preview` | ✅ Good | ❌ Poor | Experimental | ❌ Use subagent workaround |

### Known Limitations

**Gemini 3 Preview Models**:
- ❌ Direct tool calling unreliable
- ❌ Subagent spawning may fail
- ❌ MCP tool execution inconsistent
- ⚠️ File operations may silently fail

**Gemini 2.5 Pro** (Stable but deprecating):
- ⚠️ Occasional tool calling failures
- ⚠️ Complex multi-tool workflows problematic
- ⚠️ Deprecation: 17 Feb 2026

**Recommended Migration Path**:
```
Current: gemini-2.5-pro
↓
Short-term: gemini-2.5-pro + monitor stability
↓
If issues: Switch to claude-sonnet-4.5 (ccc-sonnet)
↓
When stable: Migrate to gemini-3-pro-preview (with subagent)
```

### Manual Testing

If you prefer manual testing:

```bash
# Create test directory
cd /tmp && mkdir -p gemini-test && cd gemini-test

# Test 1: Baseline (should work)
COPILOT_MODEL=gemini-3-pro-preview ccc -p "Calculate 1+1"

# Test 2: File creation (may fail)
COPILOT_MODEL=gemini-3-pro-preview ccc -p "Create hello.txt with 'test'"

# Test 3: With subagent workaround (should work)
COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini \
  ccc -p "Create hello2.txt with 'test'"

# Test 4: Stable model (should work)
COPILOT_MODEL=gemini-2.5-pro ccc -p "Create hello3.txt with 'test'"

# Verify files created
ls -la hello*.txt
```

### Verify copilot-api Logs

If you see errors, check copilot-api logs:

```bash
# Terminal 1: Start copilot-api in verbose mode
pkill -f copilot-api || true
copilot-api start -v 2>&1 | tee copilot-api-verbose.log

# Terminal 2: Run tests
# ... execute tests ...

# Terminal 1: Look for errors
grep -iE "(error|invalid|model_not_supported)" copilot-api-verbose.log
```

**Common error patterns**:
```
ERROR  HTTP error: { error: { message: 'model_not_supported' } }
ERROR  Invalid schema for function 'mcp__...'
ERROR  INVALID_ARGUMENT: tool_config.function_calling_config ...
```

### Troubleshooting Steps

1. **Verify copilot-api is running**:
   ```bash
   nc -z localhost 4141 && echo "✅ Running" || echo "❌ Not running"
   ```

2. **Check model availability**:
   ```bash
   # In copilot-api logs, you should see:
   # Available models: claude-*, gpt-*, gemini-*
   ```

3. **Test with working model first**:
   ```bash
   # Establish baseline with Claude
   ccc-sonnet -p "1+1"
   # If this fails → copilot-api issue, not Gemini-specific
   ```

4. **Run automated diagnostic**:
   ```bash
   ./scripts/test-gemini.sh
   cat debug-gemini/diagnostic-report.md
   ```

5. **Analyze logs**:
   ```bash
   ./scripts/analyze-copilot-logs.sh debug-gemini/copilot-api-verbose.log
   ```

### Best Practices

**For Production Code**:
```bash
ccc-sonnet   # 100% reliable, best quality
```

**For Experimentation with Gemini**:
```bash
# Use subagent workaround
COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini ccc
```

**For Quick Tasks**:
```bash
ccc-haiku    # Fast, reliable, no Gemini complexity
```

### References

- [copilot-api Issue #151](https://github.com/ericc-ch/copilot-api/issues/151) - Gemini model compatibility
- [Gemini API Tool Calling Docs](https://ai.google.dev/gemini-api/docs/function-calling)
- `scripts/test-gemini.sh` - Automated diagnostic suite
- `debug-gemini/README.md` - Testing workspace documentation

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
devstral-small-2              12 GB     50% GPU  # Should be ~15 GB, 100% GPU
```

### Cause

Not enough RAM or model not fully loaded.

### Solution

1. **Check available RAM**:
   ```bash
   # macOS
   vm_stat | grep free

   # Should have 20GB+ free for devstral-small-2
   ```

2. **Use Granite4 if RAM-limited** (70% less VRAM with hybrid Mamba architecture):
   ```bash
   ollama pull ibm/granite4:small-h
   OLLAMA_MODEL=ibm/granite4:small-h cco
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

But you're using Devstral (not Claude).

### Explanation

**Not a bug**. The local model sees Claude Code's system prompt and adopts that identity. This is normal behavior for instruction-tuned models.

**It doesn't affect**:
- Code quality
- Performance
- Functionality

The model is still **Devstral** (or Granite4), just confused about its identity from the prompt.

---

## 🔍 How to Verify Which Provider is Active

### Method 1: Check Logs

```bash
tail -5 ~/.claude/claude-switch.log
```

**Look for**:
```
[INFO] Provider: Ollama Local - Model: devstral-64k
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

---

## 📚 Related Documentation

- [FAQ](FAQ.md) - Frequently asked questions
- [Decision Trees](DECISION-TREES.md) - Choose the right command/model
- [Best Practices](BEST-PRACTICES.md) - Strategic usage patterns
- [Security Guide](SECURITY.md) - Privacy and data flow
- [Quick Start Guide](../QUICKSTART.md) - Installation guide

---

**Back to**: [Documentation Index](README.md) | [Main README](../README.md)
