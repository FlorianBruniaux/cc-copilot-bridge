# Dynamic Model Switching Guide

**Reading time**: 15 minutes | **Skill level**: Intermediate | **Version**: v1.4.0 | **Last updated**: 2026-01-22

---

Le script `claude-switch` supporte maintenant le changement dynamique de modèle pour GitHub Copilot via la variable d'environnement `COPILOT_MODEL` et pour Ollama via `OLLAMA_MODEL`.

## Modèles disponibles via copilot-api

⚠️ **Important**: Tous les modèles ne sont pas compatibles avec l'endpoint `/chat/completions` utilisé par copilot-api. Voir section Compatibilité ci-dessous.

### ✅ Claude Models (Testés et fonctionnels)
- `claude-sonnet-4.5` ⭐ (défaut, meilleur rapport qualité/vitesse)
- `claude-opus-4.5` (meilleure qualité, plus lent)
- `claude-haiku-4.5` (le plus rapide)
- `claude-sonnet-4`

### ✅ GPT Models (Compatibles avec `/chat/completions`)
- ✅ `gpt-4.1` (défaut, 0x premium, équilibré) ⭐
- ✅ `gpt-5` (raisonnement avancé, 1x premium)
- ✅ `gpt-5-mini` (ultra rapide, 0x premium)
- ⚠️ `gpt-4o` (stable mais **déprécié le 17 février 2026**)

### ❌ GPT Codex Models (INCOMPATIBLES - requièrent endpoint `/responses`)
- ❌ `gpt-5.2-codex` (GA depuis 14 jan 2026, mais `/responses` uniquement)
- ❌ `gpt-5.1-codex` (Preview, `/responses` uniquement)
- ❌ `gpt-5.1-codex-mini` (Preview, `/responses` uniquement)
- ❌ `gpt-5-codex` (Preview, `/responses` uniquement)

### ✅ Gemini Models
- `gemini-3-pro-preview` (performant)
- `gemini-3-flash-preview` (rapide)

### ⚠️ Autres
- ✅ `grok-code-fast-1` (rapide, spécialisé code)
- ✅ `raptor-mini` (léger, rapide)

### ❌ Modèles dépréciés (17 février 2026)
- `claude-opus-4.1` → Utiliser `claude-opus-4.5` à la place
- `gemini-2.5-pro` → Utiliser `gemini-3-pro-preview` à la place

## ⚠️ Compatibilité des modèles - Limitation Architecturale Majeure

### Problème: Endpoint `/responses` vs `/chat/completions`

**copilot-api (v0.7.0) ne supporte QUE l'endpoint `/chat/completions`**. Tous les modèles GPT Codex (spécialisés code) nécessitent le nouvel endpoint `/responses` lancé par OpenAI en octobre 2025.

### Incompatibilité Confirmée - Tous les Modèles Codex

**TOUS les modèles de la famille Codex sont INCOMPATIBLES** :

| Modèle | Status OpenAI | Erreur copilot-api |
|--------|---------------|-------------------|
| `gpt-5.2-codex` | GA (14 jan 2026) | ❌ "not accessible via /chat/completions endpoint" |
| `gpt-5.1-codex` | Preview | ❌ Même erreur |
| `gpt-5.1-codex-mini` | Preview | ❌ Même erreur |
| `gpt-5-codex` | Preview | ❌ Même erreur |

**Cause technique** : Les modèles Codex utilisent un paradigme stateful avec `previous_response_id` pour le contexte, incompatible avec l'API Chat Completions classique.

### Solutions de Contournement

**Option 1 : Utiliser les modèles GPT compatibles** (recommandé) :
- `gpt-4.1` (0x premium, inclus, équilibré)
- `gpt-5` (1x premium, raisonnement avancé)
- `gpt-5-mini` (0x premium, rapide)

**Option 2 : Utiliser Claude via Copilot** (100% compatible) :
- `claude-sonnet-4.5` (meilleur rapport qualité/vitesse)
- `claude-opus-4.5` (qualité maximale)

**Option 3 : Attendre une mise à jour copilot-api** :
- Requiert réécriture du routeur API (modification majeure)
- Aucune roadmap annoncée à ce jour
- PR communautaire en discussion mais pas de timeline

**Option 4 : Utiliser les interfaces natives** :
- VS Code native (Codex disponible)
- GitHub.com Chat (Codex disponible)
- copilot-cli (Codex disponible)

## Méthodes pour changer de modèle

### Méthode 1: Variable d'environnement (One-shot)

```bash
# Utiliser Opus pour une session
COPILOT_MODEL=claude-opus-4.5 claude-switch copilot

# Utiliser GPT-4.1 (compatible, inclus)
COPILOT_MODEL=gpt-4.1 ccc

# Utiliser Haiku (ultra rapide)
COPILOT_MODEL=claude-haiku-4.5 ccc
```

### Méthode 2: Aliases prédéfinis (Recommandé)

Déjà configurés dans votre `~/.zshrc`:

```bash
# Après `source ~/.bash_aliases`:

ccc-opus     # Claude Opus 4.5 (meilleure qualité)
ccc-sonnet   # Claude Sonnet 4.5 (défaut)
ccc-haiku    # Claude Haiku 4.5 (ultra rapide)
ccc-gpt      # GPT-4.1 (alternative GPT, 0x premium)
```

### Méthode 3: Export permanent (Session shell)

```bash
# Définir pour toute la session shell
export COPILOT_MODEL=claude-opus-4.5

# Tous les appels à `ccc` utiliseront Opus
ccc
ccc
ccc

# Reset au défaut
unset COPILOT_MODEL
```

## Comparaison des modèles Claude via Copilot

| Modèle | Qualité | Vitesse | Usage recommandé |
|--------|---------|---------|------------------|
| **claude-opus-4.5** | ⭐⭐⭐⭐⭐ | 🐢 Lent | Code critique, architecture |
| **claude-sonnet-4.5** | ⭐⭐⭐⭐ | ⚡ Rapide | Développement quotidien (défaut) |
| **claude-haiku-4.5** | ⭐⭐⭐ | ⚡⚡⚡ Ultra rapide | Refactoring simple, questions rapides |

## Exemples d'usage

### Workflow hybride

```bash
# Morning: Exploration rapide avec Haiku
ccc-haiku
> Explore this codebase structure

# Afternoon: Développement avec Sonnet (équilibre)
ccc-sonnet
> Implement user authentication

# Code Review: Qualité maximale avec Opus
ccc-opus
> Review this PR for security issues and architecture
```

### Comparaison de modèles

```bash
# Tester la même question avec différents modèles
COPILOT_MODEL=claude-sonnet-4.5 ccc
> Optimize this algorithm

COPILOT_MODEL=gpt-4.1 ccc
> Optimize this algorithm

COPILOT_MODEL=claude-opus-4.5 ccc
> Optimize this algorithm
```

## Modèles GPT via Copilot

### GPT-4.1 (Recommandé, équilibré)

```bash
COPILOT_MODEL=gpt-4.1 ccc
```

**Avantages**:
- ✅ 100% compatible avec copilot-api (endpoint `/chat/completions`)
- 0x premium (inclus dans l'abonnement)
- Équilibré qualité/vitesse
- Bon pour usage général

**Limitations**:
- ⚠️ Validation MCP stricte (peut échouer sur certains outils)
- Workaround: `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1`

**Usage**: Alternative GPT à Claude Sonnet pour le développement quotidien

### GPT-5 (Raisonnement avancé)

```bash
COPILOT_MODEL=gpt-5 ccc
```

**Avantages**:
- Raisonnement avancé
- Meilleure qualité que GPT-4.1

**Limitations**:
- 1x premium (coût supplémentaire)

**Usage**: Tâches complexes nécessitant raisonnement poussé

### GPT-5-mini (Ultra rapide)

```bash
COPILOT_MODEL=gpt-5-mini ccc
```

**Avantages**:
- Très rapide
- 0x premium (inclus)
- Bon pour questions simples

**Usage**: Refactoring basique, questions rapides

## Modèles Ollama (Local - Updated January 2026)

### Modèles recommandés

| Model | Size | SWE-bench | Context | Use Case |
|-------|------|-----------|---------|----------|
| **devstral-small-2** (default) | 24B | 68% | 256K native | Best agentic coding |
| ibm/granite4:small-h | 32B (9B active) | ~62% | 1M | Long context, 70% less VRAM |
| qwen3-coder:30b | 30B | 85% | 256K | Highest accuracy (needs template work) |

### Devstral-small-2 (Recommandé)

```bash
# Default
cco
# Or explicit
OLLAMA_MODEL=devstral-small-2 cco
# Or with 64K context Modelfile (recommended)
OLLAMA_MODEL=devstral-64k cco
```

**Avantages**:
- ✅ Meilleur modèle agentic pour coding (68% SWE-bench)
- ✅ Format tool-calling Mistral/OpenAI standard → compatible Claude Code
- ✅ Pas de problème "stuck on Explore" (contrairement à Qwen2.5)
- 24B paramètres → ~15GB VRAM

**Usage**: Développement quotidien offline, code propriétaire

### IBM Granite4 (Long Context)

```bash
OLLAMA_MODEL=ibm/granite4:small-h cco
# Or alias
cco-granite
```

**Avantages**:
- ✅ Architecture hybride Mamba → 70% moins de VRAM pour long contexte
- ✅ 1M tokens contexte natif
- ✅ 9B paramètres actifs seulement → rapide

**Limitations**:
- SWE-bench ~62% (inférieur à Devstral)

**Usage**: Projets avec beaucoup de fichiers, contexte limité RAM

### Configuration contexte 64K (CRITIQUE)

⚠️ **IMPORTANT**: Claude Code envoie ~18K tokens de system prompt + tools. Le contexte par défaut (4K) cause:
- Hallucinations
- Comportement "stuck on Explore"
- Réponses lentes (2-6 minutes au lieu de 5-15 secondes)

**Solution recommandée (Modelfile persistant)**:

```bash
# 1. Créer le Modelfile
mkdir -p ~/.ollama
cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
FROM devstral-small-2
PARAMETER num_ctx 65536
PARAMETER temperature 0.15
EOF

# 2. Créer le modèle
ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k

# 3. Utiliser
OLLAMA_MODEL=devstral-64k cco
```

**Vérifier le contexte effectif**: `ollama ps` (pas `ollama show`)

### Sources

- [Ollama Context Documentation](https://docs.ollama.com/context-length)
- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/)
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/)
- [Devstral HuggingFace](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)

## Logs avec modèles

Le script log maintenant le modèle utilisé:

```bash
$ cat ~/.claude/claude-switch.log

[2026-01-21 16:30:12] [INFO] Provider: GitHub Copilot (via copilot-api) - Model: claude-opus-4.5
[2026-01-21 16:30:12] [INFO] Session started: mode=copilot:claude-opus-4.5 pid=12345
[2026-01-21 16:32:45] [INFO] Session ended: mode=copilot:claude-opus-4.5 duration=2m33s exit=0

[2026-01-21 16:35:01] [INFO] Provider: GitHub Copilot (via copilot-api) - Model: gpt-4.1
[2026-01-21 16:35:01] [INFO] Session started: mode=copilot:gpt-4.1 pid=12567
```

### Analyser l'usage par modèle

```bash
# Sessions par modèle
grep "mode=copilot:" ~/.claude/claude-switch.log | cut -d':' -f4 | sort | uniq -c

# Exemple output:
# 12 claude-sonnet-4.5
#  5 claude-opus-4.5
#  3 gpt-4.1
#  2 claude-haiku-4.5
```

## Ajouter vos propres aliases

Éditez `~/.zshrc`:

```bash
# Copilot models
alias ccc-gemini='COPILOT_MODEL=gemini-3-pro-preview claude-switch copilot'
alias ccc-grok='COPILOT_MODEL=grok-code-fast-1 claude-switch copilot'
alias ccc-gpt4='COPILOT_MODEL=gpt-4o-2024-11-20 claude-switch copilot'

# Ollama models (already in install.sh)
alias cco-devstral='OLLAMA_MODEL=devstral-small-2 claude-switch ollama'
alias cco-granite='OLLAMA_MODEL=ibm/granite4:small-h claude-switch ollama'

# Custom 64K Modelfile variant
alias cco-64k='OLLAMA_MODEL=devstral-64k claude-switch ollama'

# Reload
source ~/.zshrc
```

## Status avec modèle actuel

```bash
$ ccs
=== Claude Code Provider Status ===

Anthropic API:  ✓ Reachable
copilot-api:    ✓ Running (:4141)
Ollama:         ✓ Running (1 models)

=== Recent Sessions ===
[2026-01-21 16:30:12] [INFO] Session started: mode=copilot:claude-opus-4.5 pid=12345
[2026-01-21 16:32:45] [INFO] Session ended: mode=copilot:claude-opus-4.5 duration=2m33s exit=0
```

## Troubleshooting

### Modèle non reconnu

Si vous spécifiez un modèle inexistant:

```bash
COPILOT_MODEL=invalid-model ccc
```

copilot-api retournera une erreur. Vérifiez les modèles disponibles:

```bash
# Dans les logs de copilot-api start
copilot-api start

# Vous verrez:
# ℹ Available models:
# - claude-sonnet-4.5
# - claude-opus-4.5
# ...
```

### Modèle par défaut

Sans `COPILOT_MODEL`, le script utilise `claude-sonnet-4.5` (meilleur compromis).

Pour changer le défaut, éditez `~/bin/claude-switch` ligne 100:

```bash
local model="${COPILOT_MODEL:-claude-opus-4.5}"  # Nouveau défaut: Opus
```

## Recommandations stratégiques

### Développement quotidien
```bash
ccc-sonnet  # ou juste `ccc`
```

### Code critique (PR, prod)
```bash
ccc-opus
```

### Questions rapides
```bash
ccc-haiku
```

### Comparaison/expérimentation
```bash
# Tester plusieurs modèles
ccc-sonnet  # Baseline Claude
ccc-gpt     # Alternative GPT
ccc-opus    # Maximum quality
```

### Coût zero via Copilot

Tous ces modèles sont **gratuits** avec votre abonnement Copilot Pro+, contrairement à l'API Anthropic directe:

```bash
# Gratuit (Copilot)
ccc-opus   # Claude Opus via Copilot = $0
ccc-gpt    # GPT-4.1 via Copilot = $0

# Payant (Anthropic Direct)
ccd --model opus  # ~$15/million tokens input
```

## Conclusion

Vous avez maintenant accès à **15+ modèles compatibles** via une seule commande:

```bash
# Claude family
ccc-opus, ccc-sonnet, ccc-haiku

# GPT family
ccc-gpt (+ custom aliases)

# Autres
COPILOT_MODEL=<model> ccc
```

Le tout **gratuitement** avec votre abonnement Copilot Pro+ existant.

---

**Astuce Pro**: Créez un alias pour votre modèle préféré:

```bash
alias cc='ccc-sonnet'  # Votre go-to command
```

---

## 📚 Related Documentation

- [Command Reference](COMMANDS.md) - All available commands
- [Decision Trees](DECISION-TREES.md) - Which model for which task
- [Best Practices](BEST-PRACTICES.md) - Strategic model selection
- [MCP Profiles](MCP-PROFILES.md) - Model compatibility with MCP
- [FAQ](FAQ.md) - Model switching questions

---

**Back to**: [Documentation Index](README.md) | [Main README](../README.md)
