# Analyse du Dossier examples/multi-provider

**Date**: 2026-01-22
**Contexte**: Préparation pour extraction vers repo dédié

---

## 📊 Inventaire Actuel (17 fichiers)

| Fichier | Lignes | Type | Statut | Recommandation |
|---------|--------|------|--------|----------------|
| **README.md** | 956 | 📖 Doc principale | ✅ CORE | **Garder** - Point d'entrée essentiel |
| **MCP-PROFILES.md** | 446 | 📖 Doc MCP Profiles | ✅ CORE | **Garder + MAJ** - Feature majeure |
| **QUICKSTART.md** | 229 | 📖 Guide rapide | ✅ CORE | **Garder** - Onboarding 2min |
| **MODEL-SWITCHING.md** | 367 | 📖 Guide modèles | ✅ CORE | **Garder** - Switching dynamique |
| **OPTIMISATION-M4-PRO.md** | 446 | 📖 Guide perf | ✅ CORE | **Garder** - Apple Silicon |
| **TROUBLESHOOTING.md** | 639 | 📖 Dépannage | ✅ CORE | **Garder** - Support critique |
| **COMMANDS.md** | 357 | 📖 Référence CLI | ✅ CORE | **Garder** - Commandes détaillées |
| **CHANGELOG.md** | 183 | 📝 Historique | ✅ CORE | **Garder** - Versioning |
| **claude-switch** | 179 | 🔧 Script | ✅ CORE | **Garder** - Outil principal |
| **install.sh** | 179 | 🔧 Installer | ✅ CORE | **Garder** - Setup auto |
| **mcp-check.sh** | 177 | 🔧 Diagnostic | ✅ CORE | **Garder** - Validation MCP |
| **RECAP.md** | 1363 | 📊 Recherche | ⚠️ ARCHIVE | **Archiver** - Rapport modèles Ollama |
| **INDEX.md** | 429 | 📋 Inventaire | ❌ OBSOLETE | **Supprimer** - Redondant avec README |
| **STATUS.md** | 324 | 📋 Statut | ❌ OBSOLETE | **Supprimer** - Info périmée |
| **RESUME-FINAL.md** | 339 | 📋 Résumé | ❌ OBSOLETE | **Supprimer** - Duplique STATUS |
| **REPO-STRUCTURE.md** | 384 | 📋 Proposition | ❌ OBSOLETE | **Supprimer** - Devenu réalité |
| **multi-provider-setup.md** | 361 | 📖 Setup ancien | ❌ OBSOLETE | **Supprimer** - Fusionné README |

**Total**: 7179 lignes
**Après nettoyage**: ~4800 lignes (-33%)

---

## 🎯 Recommandations par Catégorie

### ✅ CORE FILES (11 fichiers) - À Garder

**Documentation**:
1. **README.md** - Point d'entrée, vue d'ensemble
2. **QUICKSTART.md** - Setup en 2 minutes
3. **MODEL-SWITCHING.md** - Switching dynamique de modèles
4. **OPTIMISATION-M4-PRO.md** - Optimisation Apple Silicon
5. **TROUBLESHOOTING.md** - Résolution de problèmes
6. **COMMANDS.md** - Référence complète des commandes
7. **MCP-PROFILES.md** - MCP Profiles System (à mettre à jour)
8. **CHANGELOG.md** - Historique des versions

**Scripts**:
9. **claude-switch** - Script principal
10. **install.sh** - Installeur automatique
11. **mcp-check.sh** - Diagnostic MCP

### ⚠️ ARCHIVE (1 fichier) - À Déplacer

12. **RECAP.md** → `docs/research/ollama-models-comparison.md`
   - Recherche précieuse sur modèles Ollama
   - Pas essentiel au quotidien
   - Garder pour référence historique

### ❌ OBSOLETE (5 fichiers) - À Supprimer

13. **INDEX.md** - Redondant (info dans README)
14. **STATUS.md** - Périmé (v1.1.0 dépassée avec MCP Profiles)
15. **RESUME-FINAL.md** - Duplique STATUS.md
16. **REPO-STRUCTURE.md** - Proposition devenue réalité
17. **multi-provider-setup.md** - Fusionné dans README

---

## 📝 Mises à Jour Requises

### 1. MCP-PROFILES.md

**Ajouter**:
- ✅ Section "System Prompts par Modèle"
- ✅ Workflow complet avec injection d'identité
- ✅ Exemples de prompts personnalisés (GPT-4.1, Gemini)
- ✅ Documentation `_get_system_prompt()` function
- ✅ Architecture mise à jour (dossier prompts/)

### 2. claude-switch --help

**Vérifier**:
- ❌ Pas de mention MCP Profiles
- ❌ Pas de mention System Prompts
- ✅ Mentions modèles à jour

**Ajouter**:
```
MCP Profiles System:
  Auto-detection of problematic MCP servers for strict models (GPT-4.1, Gemini)
  System prompts injection for correct model identity
  ~/.claude/mcp-profiles/generate.sh   # Generate MCP profiles
  ~/.claude/mcp-profiles/excludes.yaml # Edit exclusions
```

### 3. README.md

**Ajouter section**:
```markdown
## MCP Profiles & Model Identity

GPT-4.1 and Gemini models require strict JSON schema validation. The system automatically:
- Excludes incompatible MCP servers (e.g., grepai)
- Injects correct model identity prompts
- See MCP-PROFILES.md for details
```

### 4. TROUBLESHOOTING.md

**Ajouter**:
- Section "MCP Schema Validation Errors"
- Section "Model Identity Confusion"
- Référence vers MCP-PROFILES.md

---

## 🏗️ Structure Proposée pour Repo Dédié

```
claude-code-switcher/              # Nom de repo proposé
├── README.md                      # Doc principale (nettoyée)
├── LICENSE                        # MIT
├── CHANGELOG.md                   # Historique versions
├── QUICKSTART.md                  # Setup 2min
├── claude-switch                  # Script principal
├── install.sh                     # Installeur
├── .github/
│   └── workflows/
│       └── release.yml            # CI/CD
├── docs/
│   ├── MODEL-SWITCHING.md         # Switching dynamique
│   ├── MCP-PROFILES.md            # MCP Profiles System
│   ├── OPTIMISATION-M4-PRO.md     # Apple Silicon
│   ├── TROUBLESHOOTING.md         # Dépannage
│   ├── COMMANDS.md                # Référence CLI
│   └── research/
│       └── ollama-models.md       # Ancien RECAP.md
├── scripts/
│   ├── mcp-check.sh               # Diagnostic MCP
│   ├── ollama-check.sh            # Check Ollama (si existe)
│   └── ollama-optimize.sh         # Optimize M4 (si existe)
└── examples/
    └── custom-prompts/
        ├── gpt-4.1-custom.txt     # Exemple prompt GPT
        └── gemini-custom.txt      # Exemple prompt Gemini
```

**Taille estimée**: ~4.8K lignes de doc + scripts

---

## 🎬 Plan d'Action

### Phase 1: Nettoyage (Maintenant)

1. ✅ Supprimer fichiers obsolètes (5 fichiers)
2. ✅ Archiver RECAP.md → docs/research/
3. ✅ Mettre à jour MCP-PROFILES.md (System Prompts)
4. ✅ Mettre à jour --help claude-switch
5. ✅ Ajouter section MCP Profiles dans README.md

### Phase 2: Extraction Repo (Après)

1. Créer nouveau repo `claude-code-switcher`
2. Copier fichiers CORE
3. Réorganiser selon structure proposée
4. Ajouter CI/CD GitHub Actions
5. Premier release v1.2.0

### Phase 3: Liens Croisés

1. Ajouter lien dans guide principal → switcher repo
2. Ajouter badge dans switcher → guide principal

---

## 💡 Suggestions de Noms de Repo

**Format**: `claude-code-{concept}`

| Nom | Pros | Cons | Score |
|-----|------|------|-------|
| **claude-code-switcher** | Clair, action-oriented | Générique | ⭐⭐⭐⭐ |
| **claude-code-providers** | Descriptif, technique | Moins dynamique | ⭐⭐⭐ |
| **claude-code-multi** | Court, moderne | Trop vague | ⭐⭐ |
| **claude-switch** | Ultra-court, mémorable | Collision potentielle | ⭐⭐⭐⭐⭐ |
| **copilot-bridge** | Innovant, spécialisé | Exclut Ollama | ⭐⭐ |
| **claude-router** | Tech, networking vibe | Moins évident | ⭐⭐⭐ |

**Recommandation**: `claude-switch` (simple, mémorable, correspond au script)

**Alternatives**:
- `claude-code-switcher` (si `claude-switch` pris)
- `cc-multi` (très court mais moins SEO)

---

## 📊 Métriques Finales

| Métrique | Avant | Après | Gain |
|----------|-------|-------|------|
| **Fichiers MD** | 14 | 8 | -43% |
| **Lignes doc** | ~6000 | ~4000 | -33% |
| **Scripts** | 3 | 3 | 0% |
| **Clarté structure** | ⭐⭐ | ⭐⭐⭐⭐⭐ | +150% |

---

## ✅ Actions Immédiates

1. [ ] Supprimer 5 fichiers obsolètes
2. [ ] Mettre à jour MCP-PROFILES.md (Section System Prompts)
3. [ ] Mettre à jour claude-switch --help
4. [ ] Ajouter section MCP dans README.md
5. [ ] Créer docs/research/ et y archiver RECAP.md
6. [ ] Brainstorm final sur nom de repo
7. [ ] Créer le nouveau repo
8. [ ] Premier commit + release v1.2.0
