# Analyse Comparative: AgentAPI vs copilot-api

**Date**: 2026-01-23
**Contexte**: Évaluation de coder/agentapi comme alternative potentielle à ericc-ch/copilot-api

---

## Résumé Exécutif

**Verdict**: Ce sont des outils **complémentaires**, pas des alternatives.

| Critère | coder/agentapi | ericc-ch/copilot-api |
|---------|----------------|----------------------|
| **Mission** | Wrapper HTTP universel pour CLIs d'agents | Proxy Copilot → API OpenAI/Anthropic |
| **Architecture** | Émulateur terminal + parser TUI | Traducteur d'endpoints reverse-engineered |
| **Agents supportés** | 10+ (Claude Code, Aider, Goose, Codex...) | Copilot uniquement (25+ modèles) |
| **Port défaut** | 3284 | 4141 |
| **MCP Support** | ❌ (roadmap) | ✅ (via Claude Code natif) |

---

## Différences Architecturales Clés

### AgentAPI: Terminal Emulator Approach

```
HTTP Request → Keystroke injection → Terminal capture → TUI diff → Response
```

**Avantages**:
- Agnostique au provider
- Multi-agent (Claude Code, Aider, Goose, etc.)
- Pas de reverse-engineering d'API propriétaires
- Contrôle CORS/hosts pour déploiement headless

**Limitations**:
- Fragile aux changements de TUI des agents
- Latence supplémentaire (parsing terminal)
- Dépendance au binaire de l'agent (doit être installé)

### copilot-api: API Translation Layer

```
HTTP Request → Token auth → GitHub Copilot API → Response translation
```

**Avantages**:
- Latence plus faible (appels API directs)
- Accès direct aux modèles (Claude, GPT, Gemini via Copilot)
- Endpoints OpenAI-compatible (drop-in replacement)
- Dashboard quota/usage intégré

**Limitations**:
- Reverse-engineering = risque ToS GitHub
- Dépendance à l'infrastructure Copilot
- Limité aux modèles exposés par Copilot

---

## Comparaison Technique Détaillée

### Protocoles et Endpoints

| Aspect | AgentAPI | copilot-api |
|--------|----------|-------------|
| **Protocol** | HTTP REST | HTTP REST |
| **Auth** | Optional (CORS control) | GitHub OAuth Token |
| **Endpoints** | `/conversations`, `/messages` | `/v1/chat/completions` (OpenAI) |
| **Streaming** | ✅ SSE | ✅ SSE |
| **OpenAI Compatible** | ❌ (custom API) | ✅ (drop-in replacement) |
| **Anthropic Compatible** | ❌ (custom API) | ✅ (translation layer) |

### Modèles Supportés

| Provider | AgentAPI | copilot-api |
|----------|----------|-------------|
| **Claude (Anthropic)** | Via Claude Code CLI | claude-sonnet-4.5, claude-opus-4.5, claude-haiku-4.5 |
| **GPT (OpenAI)** | Via Codex CLI | gpt-4.1, gpt-5, gpt-5-mini |
| **Gemini (Google)** | ❌ Non supporté | gemini-2.5-pro, gemini-3-flash-preview |
| **Ollama** | Via Aider | ❌ Non supporté |
| **DeepSeek** | ❌ Non supporté | ❌ Non supporté |

### Installation et Dépendances

| Aspect | AgentAPI | copilot-api |
|--------|----------|-------------|
| **Installation** | Binary (Go) | npm package |
| **Dépendances runtime** | Agent CLI installé | Node.js 18+ |
| **Taille** | ~15MB binary | ~5MB node_modules |
| **Configuration** | YAML config file | Env vars + CLI flags |

---

## Métriques Communauté (Janvier 2026)

| Métrique | AgentAPI | copilot-api |
|----------|----------|-------------|
| **GitHub Stars** | 792 | 1,300 |
| **Forks** | 76 | 224 |
| **Contributors** | 9 | 16 |
| **npm Downloads** | N/A (binary) | 277/week |
| **Issues ouvertes** | ~20 | ~15 |
| **Dernière release** | v0.3.0 (Jan 2026) | v0.7.0 (Dec 2025) |
| **Âge du projet** | ~6 mois | ~8 mois |

---

## Cas d'Usage

### Choisir AgentAPI si:

1. **Orchestration multi-agents** - Besoin de coordonner Claude + Aider + Goose
2. **CI/CD headless** - Déploiement sans UI avec contrôle CORS/hosts
3. **Construction d'UI custom** - Exposer agents comme service HTTP REST
4. **Éviter le risque ToS** - Pas de reverse-engineering d'API propriétaires
5. **Agent-agnostic workflows** - Même API pour tous les agents

### Choisir copilot-api si:

1. **Exploiter abonnement Copilot Pro+** - Accès gratuit aux modèles premium
2. **Endpoints OpenAI-compatible** - Drop-in replacement pour outils existants
3. **Dashboard quota/usage** - Monitoring intégré
4. **Latence minimale** - Pas de parsing terminal intermédiaire
5. **Multi-modèles via Copilot** - Claude, GPT, Gemini en une config

### Ni l'un ni l'autre si:

- Usage direct Claude Code terminal (pas besoin d'API)
- Pas besoin d'API programmatique
- Budget pour API Anthropic directe

---

## Pour cc-copilot-bridge

**Verdict: Pas de migration nécessaire.**

copilot-api reste le bon choix car:

1. **Use case principal** = Exploiter Copilot Pro+ avec Claude Code CLI
2. **AgentAPI n'apporte rien** si pas de multi-agent orchestration
3. **MCP fonctionne déjà** nativement avec Claude Code
4. **Latence inférieure** avec copilot-api (pas de parsing terminal)

### Complémentarité Possible

Architecture combinée (complexité rarement justifiée):

```
AgentAPI → Claude Code CLI → copilot-api → GitHub Copilot
           ↑                    ↑
    Terminal emulator    API translation
```

**Cas d'usage**: Exposer Claude Code comme service HTTP REST pour intégration tierce.

**Coût**: Complexité accrue, double latence, maintenance de 2 proxies.

**Recommandation**: Éviter sauf besoin spécifique d'API HTTP pour Claude Code.

---

## Risques et Considérations

### copilot-api

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| **ToS GitHub** | Moyenne | Élevé (suspension compte) | Aucune (risque accepté) |
| **Breaking changes API** | Élevée | Moyen | MAJ fréquentes projet |
| **Quota Copilot** | Faible | Moyen | Monitoring usage |

### AgentAPI

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| **Changement TUI agent** | Moyenne | Élevé (parsing cassé) | Tests d'intégration |
| **Latence variable** | Moyenne | Faible | Monitoring |
| **Roadmap MCP** | Incertaine | Moyen | Attendre release stable |

---

## Timeline Évolution

### copilot-api

| Date | Version | Feature |
|------|---------|---------|
| May 2025 | v0.1.0 | Initial release |
| Aug 2025 | v0.5.0 | GPT models support |
| Dec 2025 | v0.7.0 | Gemini models |
| 2026 Q2 | v1.0.0 | Stable API (estimé) |

### AgentAPI

| Date | Version | Feature |
|------|---------|---------|
| Jul 2025 | v0.1.0 | Initial release |
| Oct 2025 | v0.2.0 | Multi-agent support |
| Jan 2026 | v0.3.0 | CORS control |
| 2026 Q2 | v0.5.0 | MCP support (roadmap) |

---

## Prompt Perplexity pour Approfondissement

```
Compare coder/agentapi and ericc-ch/copilot-api for Claude Code CLI integration in 2026:

1. Architectural differences: AgentAPI terminal emulator vs copilot-api API translation - latency benchmarks?

2. Production use cases where AgentAPI is preferred over copilot-api for Claude Code specifically?

3. AgentAPI MCP protocol roadmap timeline and comparison to native Claude Code MCP?

4. GitHub ToS enforcement: documented account suspensions for copilot-api usage patterns?

5. Community adoption trajectory: which project shows stronger momentum for 2026?

Focus on practical differences for GitHub Copilot Pro+ subscribers.
```

---

## Conclusion

| Critère | Gagnant | Justification |
|---------|---------|---------------|
| **Pour cc-copilot-bridge** | copilot-api | Use case = Copilot bridge, pas multi-agent |
| **Pour multi-agent orchestration** | AgentAPI | Agnostique au provider |
| **Pour latence** | copilot-api | Pas de parsing terminal |
| **Pour risque ToS** | AgentAPI | Pas de reverse-engineering |
| **Pour écosystème** | copilot-api | Plus de stars, plus actif |

**Décision**: Conserver copilot-api comme dépendance principale. Surveiller AgentAPI pour future intégration si besoin d'exposer Claude Code comme service HTTP.

---

## Sources

- [coder/agentapi](https://github.com/coder/agentapi) - HTTP wrapper for coding agents
- [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api) - Copilot to OpenAI/Anthropic proxy
- [jimmysong.io - Copilot API Proxy](https://jimmysong.io/ai/copilot-api-proxy/) - Analysis article

---

**Recherche effectuée**: 2026-01-23
**Prochaine révision**: Quand AgentAPI atteint v0.5.0 (MCP support)
