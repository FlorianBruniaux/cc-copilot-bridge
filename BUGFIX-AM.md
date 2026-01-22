# BugFix: "am" apparaît automatiquement au démarrage

## 🐛 Problème initial

Quand on lance `ccc-gpt`, le texte "am" apparaît automatiquement dans le prompt, suivi d'une réponse brutale du mode conseiller.

```bash
❯ am    # ← Apparaît automatiquement, pas tapé par l'utilisateur

⏺ Tu veux dire "am" = matin, "am" dans un contexte technique...
```

---

## 🔍 Analyse des causes

### Cause principale identifiée : Injection de prompt avec `eval`

**Fichier** : `~/bin/claude-switch` (version 1.2.0)

**Problème** : Lignes 110-131 et 172-182

```bash
# AVANT (problématique)
_get_system_prompt() {
  echo "--append-system-prompt \"$(cat "${prompt_file}")\""
}

# ...

eval "${claude_cmd} \"\$@\""
```

**Conséquences** :
- Double-escaping des guillemets
- Parsing erroné des newlines dans le prompt (15 lignes)
- Caractères spéciaux mal interprétés
- Possible injection de commandes via contenu du prompt

### Causes secondaires écartées

❌ **Hook UserPromptSubmit** : Vérifié, affiche seulement un warning modèle
❌ **statusLine** : `npx -y ccstatusline@latest` ne génère pas "am"
❌ **Alias shell** : `gam='git am'` existe mais n'est pas déclenché
❌ **Fichier prompt gpt-4.1.txt** : Pas de caractères cachés (vérifié avec xxd)

---

## ✅ Corrections appliquées

### 1. Script `claude-switch` v1.3.0

**Changements** :

```bash
# NOUVEAU (propre)
# === Global arrays for command building ===
declare -a MCP_ARGS=()
declare -a PROMPT_ARGS=()

_set_mcp_args() {
  MCP_ARGS=("--mcp-config" "${config_file}")
}

_set_prompt_args() {
  local prompt_content
  prompt_content=$(cat "${prompt_file}")
  PROMPT_ARGS=("--append-system-prompt" "${prompt_content}")
}

_run_copilot() {
  _set_mcp_args "${model}"
  _set_prompt_args "${model}"

  # Exécution sans eval (arrays bash natifs)
  claude "${MCP_ARGS[@]}" "${PROMPT_ARGS[@]}" "$@"
}
```

**Avantages** :
- ✅ Pas d'eval → pas de double-escaping
- ✅ Arrays bash → gestion native des newlines et caractères spéciaux
- ✅ Séparation claire des arguments → pas de contamination
- ✅ Plus sûr → pas d'injection de commandes possible

### 2. Alias `ccc-gpt` corrigé dans `install.sh`

**Avant** :
```bash
alias ccc-gpt='COPILOT_MODEL=gpt-5.2-codex claude-switch copilot'
```

**Après** :
```bash
alias ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
```

**Raison** : gpt-5.2-codex est incompatible (nécessite endpoint `/responses`)

---

## 🧪 Test de validation

```bash
# 1. Vérifier le script
chmod +x ~/bin/claude-switch
claude-switch --version
# → claude-switch v1.3.0

# 2. Recharger les aliases
source ~/.zshrc

# 3. Tester GPT-4.1
ccc-gpt
# → Ne devrait PLUS afficher "am" automatiquement
```

---

## 📊 Comparaison technique

| Aspect | Version 1.2.0 (avant) | Version 1.3.0 (après) |
|--------|----------------------|---------------------|
| Méthode exécution | `eval` string | Arrays bash natifs |
| Gestion newlines | ❌ Problématique | ✅ Native |
| Gestion quotes | ❌ Double-escaping | ✅ Automatique |
| Sécurité | ⚠️ Injection possible | ✅ Sûr |
| Lisibilité | 🟡 Complexe | ✅ Claire |
| Debugging | 🔴 Difficile | ✅ Simple |

---

## 🔧 Architecture de l'injection (après fix)

```
claude-switch v1.3.0
    ↓
_run_copilot()
    ↓
┌───────────────────┐        ┌─────────────────────┐
│ _set_mcp_args()   │        │ _set_prompt_args()  │
│                   │        │                     │
│ MCP_ARGS=(        │        │ prompt_content=$(   │
│   "--mcp-config"  │        │   cat "gpt-4.1.txt" │
│   "/path/gpt.json"│        │ )                   │
│ )                 │        │ PROMPT_ARGS=(       │
│                   │        │   "--append-..."    │
│                   │        │   "$prompt_content" │
│                   │        │ )                   │
└─────────┬─────────┘        └──────────┬──────────┘
          │                             │
          └─────────────┬───────────────┘
                        ↓
        claude "${MCP_ARGS[@]}" "${PROMPT_ARGS[@]}" "$@"
                        ↓
            Expansion bash propre (pas d'eval)
```

---

## 📝 Fichiers modifiés

1. **`~/bin/claude-switch`**
   - Lignes 21-22 : Ajout arrays globaux
   - Lignes 89-119 : `_set_mcp_args()` refactorisé
   - Lignes 121-151 : `_set_prompt_args()` refactorisé
   - Ligne 193 : Exécution directe (sans eval)

2. **`install.sh`**
   - Ligne 131 : Alias `ccc-gpt` corrigé (gpt-4.1 au lieu de gpt-5.2-codex)

---

## 🎯 Résultat attendu

Après application de ce fix, `ccc-gpt` devrait :

1. ✅ Démarrer normalement
2. ✅ Afficher le header Claude Code avec "gpt-4.1"
3. ✅ Présenter un prompt vide (pas de "am")
4. ✅ Injecter correctement l'identité GPT-4.1 via system prompt
5. ✅ Utiliser le profil MCP restreint (9 serveurs, grepai exclu)

---

## 🚀 Déploiement

Le script `claude-switch` est installé dans `~/bin/`, donc utilisé globalement :

```bash
# Vérifier le chemin
which claude-switch
# → /Users/florianbruniaux/bin/claude-switch

# Version actuelle
claude-switch --version
# → claude-switch v1.3.0

# Tester
ccc-gpt
# → Devrait fonctionner sans "am"
```

---

## 📚 Références

- **Script corrigé** : `~/bin/claude-switch` v1.3.0
- **Install corrigé** : `install.sh` ligne 131
- **Prompt GPT** : `~/.claude/mcp-profiles/prompts/gpt-4.1.txt`
- **MCP Profile** : `~/.claude/mcp-profiles/generated/gpt.json`
- **Logs** : `~/.claude/claude-switch.log`

---

**Date** : 2026-01-22
**Version** : claude-switch v1.3.0
**Status** : ✅ Corrigé
