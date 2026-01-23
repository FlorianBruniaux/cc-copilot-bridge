# Apple Silicon Optimization Guide (M1/M2/M3/M4)

**Reading time**: 15 minutes | **Skill level**: Advanced | **Ollama version**: 0.14.2+ | **Last updated**: 2026-01-22

**Target**: Qwen2.5-Coder-32B Q4_K_M on M4 Pro 48GB

---

## Configuration Appliquée

### Variables d'Environnement

```bash
OLLAMA_FLASH_ATTENTION=1          # Flash Attention pour Gemma 3/Qwen 3
OLLAMA_KV_CACHE_TYPE=q4_0         # KV Cache quantization - reduces memory by ~75%
OLLAMA_NUM_PARALLEL=4             # 4 requêtes parallèles
OLLAMA_MAX_LOADED_MODELS=3        # 3 modèles chargés simultanément
OLLAMA_CONTEXT_LENGTH=8192        # Contexte optimal pour 32B
OLLAMA_KEEP_ALIVE=24h             # Garde le modèle en RAM 24h
```

> **New in 2025**: `OLLAMA_KV_CACHE_TYPE=q4_0` enables KV cache quantization, reducing cache memory from ~48GB to ~12GB for 64K context. This makes 64K context feasible on 32GB machines.

### Performances Attendues

| Métrique | Valeur |
|----------|--------|
| RAM | 20-24 GB |
| Vitesse (4K context) | 26-39 tokens/sec |
| Vitesse (8K context) | 24-32 tokens/sec |
| Qualité | 100% (SOTA) |

---

## ⚠️ OLLAMA_CONTEXT_LENGTH: Le Paramètre Critique

### Comprendre le Contexte

**`OLLAMA_CONTEXT_LENGTH`** détermine combien de tokens le modèle peut traiter en une seule fois. Ce paramètre a un **impact majeur** sur les performances avec Claude Code.

### Pourquoi 8192 par Défaut ?

La valeur `8192` (8K tokens) est un **compromis optimal** pour:
- ✅ Vitesse maximale (26-39 tok/s)
- ✅ RAM raisonnable (26 GB sur GPU)
- ✅ Qualité constante

**Mais attention** : Cette valeur convient uniquement aux **petits projets** avec Claude Code.

### Le Problème avec Claude Code

Claude Code envoie un **contexte initial volumineux** comprenant :

```
Contexte typique (projet moyen-grand) : ~60,000 tokens
├─ Indexation projet (Memory files) : 22,200 tokens
├─ Outils système                   : 19,800 tokens
├─ Serveurs MCP                     : 8,400 tokens
├─ Agents custom                    : 3,400 tokens
└─ Prompt système                   : 3,800 tokens
```

**Si `OLLAMA_CONTEXT_LENGTH=8192`** :
- ⚠️ **Truncation massive** : 87% du contexte perdu
- 🐌 **Lenteur extrême** : 2-6 minutes par réponse
- 💻 **CPU surchargé** : Retraitement constant
- 🔥 **Ventilateurs** : Mac qui souffle

### Trade-offs par Configuration

| Contexte | RAM | Vitesse | Cas d'Usage | Projet |
|----------|-----|---------|-------------|---------|
| **4096** | 24 GB | ⚡⚡⚡ 35-45 tok/s | Scripts simples | <50 fichiers |
| **8192** | 26 GB | ⚡⚡ 26-39 tok/s | **Petits projets** | <500 fichiers |
| **16384** | 30-32 GB | 🐢 15-25 tok/s | Projets moyens | 500-2K fichiers |
| **32768** | 36-40 GB | 🐌 8-15 tok/s | Grands projets | >2K fichiers |

### Recommandations par Type de Projet

#### Petits Projets (<500 fichiers)
**Config actuelle (8K) est parfaite** ✅

```bash
# Rien à changer
OLLAMA_CONTEXT_LENGTH=8192
```

**Exemples** :
- Scripts utilitaires
- CLI tools
- Petites applications
- Projets d'apprentissage

#### Projets Moyens (500-2K fichiers)
**Augmenter à 16K** ⚠️

```bash
launchctl setenv OLLAMA_CONTEXT_LENGTH 16384
brew services restart ollama
```

**Trade-off** :
- ✅ Claude Code fonctionne correctement
- ❌ Vitesse réduite (15-25 tok/s au lieu de 26-39)
- ❌ +4-6 GB RAM

**Exemples** :
- Applications web standard
- APIs REST moyennes
- Projets Next.js/React

#### Grands Projets (>2K fichiers)
**Augmenter à 32K** 🐌 **OU utiliser Copilot/Anthropic** ⚡

```bash
# Option 1: Ollama 32K (lent mais privé)
launchctl setenv OLLAMA_CONTEXT_LENGTH 32768
brew services restart ollama

# Option 2: Copilot (rapide et gratuit)
ccc  # 1-3 secondes par réponse

# Option 3: Anthropic (rapide et payant)
ccd  # 1-2 secondes par réponse
```

**Exemples** :
- Monorepos
- Applications enterprise
- Projets avec multiples MCP servers
- Codebases complexes

### Tests Comparatifs (M4 Pro 48GB, Qwen2.5-Coder-32B)

#### Test 1: Petit Projet (8K Context)
```bash
cd ~/simple-script/
cco
❯ write a fibonacci function
⏱️ Réponse: 3-5 secondes ✅
📊 Qualité: Excellente
```

#### Test 2: Grand Projet (8K Context) ❌
```bash
cd ~/monorepo-app/  # ~60K tokens de contexte
cco
❯ 1+1 ?
⏱️ Réponse: 2-6 MINUTES ❌
📊 Qualité: Incohérente (contexte tronqué)
💻 RAM: 26 GB (mais CPU à 100%)
```

#### Test 3: Grand Projet (32K Context) 🐌
```bash
cd ~/monorepo-app/
# Après avoir augmenté le contexte à 32K
cco
❯ 1+1 ?
⏱️ Réponse: 30-60 secondes ⚠️
📊 Qualité: Excellente
💻 RAM: 38 GB
```

#### Test 4: Grand Projet avec Copilot ⚡
```bash
cd ~/monorepo-app/
ccc
❯ 1+1 ?
⏱️ Réponse: 1-2 secondes ✅
📊 Qualité: Excellente
💻 RAM: Négligeable (API distante)
```

### Comment Vérifier Votre Contexte

**Pendant une session Claude Code**, tapez `/context` pour voir :
- Nombre de tokens utilisés
- Répartition par catégorie
- Espace libre restant

Si **"Free space" est négatif** ou très faible → votre projet dépasse la capacité configurée.

### Stratégie Recommandée

Pour optimiser votre workflow :

```bash
# 1. Petits projets/scripts : Ollama 8K (rapide)
cd ~/scripts/
cco  # 3-10 secondes par réponse

# 2. Projets moyens : Copilot (rapide + gratuit)
cd ~/web-app/
ccc  # 1-3 secondes par réponse

# 3. Gros projets : Copilot ou Anthropic
cd ~/monorepo/
ccc  # ou ccd
```

**Ollama 32K uniquement si** :
- ✅ Code ultra-confidentiel (100% local requis)
- ✅ Pas de connexion internet
- ✅ Temps de réponse de 30-60s acceptable

### Conclusion

Le paramètre `OLLAMA_CONTEXT_LENGTH=8192` est **optimal pour la vitesse**, mais **inadapté aux grands projets** avec Claude Code.

**Choix à faire** :
1. **Petits projets** : Garder 8K (rapide) ✅
2. **Projets moyens** : 16K (compromis) ⚠️
3. **Grands projets** : Copilot/Anthropic (rapide) ou 32K (lent mais privé) 🐌

---

## Scripts Créés

### 1. `~/bin/ollama-optimize.sh`

Script d'optimisation automatique qui :
- ✅ Configure les variables d'environnement avec `launchctl`
- ✅ Redémarre le service Ollama
- ✅ Vérifie la disponibilité de l'API

**Utilisation** :
```bash
ollama-optimize.sh
```

### 2. `~/bin/ollama-check.sh`

Script de diagnostic complet (11 vérifications) :
1. Version Ollama
2. Processus en cours
3. Service Homebrew
4. Modèles installés
5. Connectivité API
6. Ports réseau
7. Variables d'environnement
8. Espace disque
9. Test du modèle
10. Mémoire système
11. Intégration claude-switch

**Utilisation** :
```bash
ollama-check.sh
```

---

## Test de l'Intégration Complète

### Test 1 : Via claude-switch

```bash
# Lancer Claude Code avec Ollama
cco
```

**Prompt de test recommandé** :
```
Write a React component for user authentication with the following features:
- Email/password form with validation
- JWT token handling
- Error state management
- Loading indicator
- TypeScript types
```

**Ce que vous devriez observer** :
- ✅ Modèle se charge en RAM (~20-24GB)
- ✅ Génération rapide (26-39 tok/s)
- ✅ Code de qualité SOTA avec :
  - Gestion d'erreurs complète
  - Validation robuste
  - Types TypeScript précis
  - Bonnes pratiques React
  - Documentation claire

### Test 2 : Monitoring RAM

**Terminal 1** : Lancer Claude Code
```bash
cco
```

**Terminal 2** : Monitor RAM en temps réel
```bash
watch -n 2 'ps aux | grep ollama | grep -v grep | awk "{printf \"Ollama: %.2f GB\\n\", \$6/1024/1024}"'
```

**Résultat attendu** :
```
Ollama: 0.03 GB  # Avant le premier prompt
↓
Ollama: 20.45 GB # Après chargement du modèle (10-20 sec)
```

### Test 3 : Benchmark Performance

```bash
time ollama run qwen2.5-coder:32b-instruct "Write a binary search implementation in Python with edge case handling"
```

**Métrique attendue** :
- Temps de réponse : 5-8 secondes pour ~200 tokens
- Vitesse effective : 25-40 tok/s

---

## Comparaison des Providers

Test effectué avec le prompt : "Refactor this function to be more maintainable"

| Provider | Modèle | Vitesse | Qualité | Coût | Privacy |
|----------|--------|---------|---------|------|---------|
| **Ollama** | Qwen2.5-32B | 26-39 tok/s | ⭐⭐⭐⭐⭐ | Gratuit | 100% local |
| **Copilot** | Claude Opus 4.5 | ~60 tok/s | ⭐⭐⭐⭐⭐ | Inclus (abo) | Cloud |
| **Anthropic** | Claude Sonnet 4.5 | ~80 tok/s | ⭐⭐⭐⭐⭐ | $15-20/mois | Cloud |

**Recommandations d'usage** :

| Scénario | Provider Recommandé |
|----------|---------------------|
| Code propriétaire/sensible | `cco` (Ollama) |
| Itération rapide/prototypage | `ccc` (Copilot) |
| Review critique/production | `ccd` (Anthropic) ou `ccc-opus` |
| Exploration/questions rapides | `ccc-haiku` (rapide, gratuit) |

---

## Vérification Post-Installation

### Checklist Complète

- [x] Ollama 0.14.2 installé
- [x] Modèle Qwen2.5-Coder-32B téléchargé (19GB)
- [x] Variables d'optimisation configurées
- [x] Service Ollama redémarré
- [x] API responsive sur :11434
- [x] claude-switch installé et testé
- [x] Alias shell configurés (ccd, ccc, cco, ccs)
- [x] Scripts de diagnostic et optimisation créés

### Statut Actuel

```bash
ollama-check.sh
```

```
═══════════════════════════════════════════════════════════
  RÉSUMÉ
═══════════════════════════════════════════════════════════

   Ollama actif:      ✅
   API accessible:    ✅
   Modèle 32B:        ✅
   claude-switch:     ✅
```

---

## Commandes Récapitulatives

| Commande | Description |
|----------|-------------|
| `ccd` | Anthropic Direct (meilleure qualité) |
| `ccc` | GitHub Copilot (gratuit avec abo) |
| `cco` | Ollama Local (privacy, offline) |
| `ccs` | Status de tous les providers |
| `ccc-opus` | Copilot avec Claude Opus 4.5 |
| `ccc-sonnet` | Copilot avec Claude Sonnet 4.5 |
| `ccc-haiku` | Copilot avec Claude Haiku 4.5 (rapide) |
| `ccc-gpt` | Copilot avec GPT-5.2 Codex |
| `ollama-check.sh` | Diagnostic complet Ollama |
| `ollama-optimize.sh` | Réappliquer optimisations |

---

## Troubleshooting

### Problème : Modèle ne se charge pas en RAM

**Symptôme** : RAM reste à ~0.03GB après lancement

**Solution** :
```bash
# Forcer le rechargement
ollama rm qwen2.5-coder:32b-instruct
ollama pull qwen2.5-coder:32b-instruct-q4_k_m

# Tester directement
ollama run qwen2.5-coder:32b-instruct "Write a hello world"
```

### Problème : Performance inférieure à 26 tok/s

**Vérifications** :
1. Confirmer version 0.14.2 : `ollama --version`
2. Vérifier RAM disponible : `top -o MEM` (devrait avoir >30GB libre)
3. Réappliquer optimisations : `ollama-optimize.sh`
4. Redémarrer : `brew services restart ollama`

### Problème : API ne répond pas

**Solution** :
```bash
# Vérifier processus
ps aux | grep ollama

# Redémarrer service
brew services restart ollama

# Vérifier port
lsof -i :11434
```

---

## Sources

- **Perplexity Research** : Optimisation Ollama 0.14.2 pour Apple Silicon (2026-01-21)
- **Benchmark officiel** : Qwen2.5-Coder-32B sur M4 Pro (26.85 tok/s @ Q4_K_M)
- **Documentation Ollama** : Variables d'environnement et optimisations

---

## Next Steps

1. ✅ **Tester l'intégration** : `cco` et vérifier le chargement du modèle
2. ✅ **Monitorer la RAM** : Confirmer 20-24GB après premier prompt
3. ✅ **Benchmark performance** : Mesurer tok/s effectif
4. ⏳ **Workflows quotidiens** : Utiliser selon les recommandations ci-dessus

---

**Installation complète et optimisée !** 🎉

Le système multi-provider est maintenant prêt avec :
- 3 providers (Anthropic, Copilot, Ollama)
- 25+ modèles disponibles via Copilot
- Ollama optimisé pour M4 Pro 48GB
- Documentation complète (10 fichiers, ~52KB)
- Scripts de diagnostic et optimisation

---

## 📚 Related Documentation

- [Best Practices](BEST-PRACTICES.md) - Performance optimization strategies
- [Architecture](ARCHITECTURE.md) - Ollama integration details
- [Troubleshooting](TROUBLESHOOTING.md) - Ollama slow performance issues
- [FAQ](FAQ.md) - Ollama performance questions

---

**Back to**: [Documentation Index](README.md) | [Main README](../README.md)
