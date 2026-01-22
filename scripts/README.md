# Scripts Utilitaires

Scripts de diagnostic, de test et de maintenance pour le projet cc-copilot-bridge.

---

## 📋 Liste des Scripts

### `mcp-check.sh` - Diagnostic MCP

Vérifie la compatibilité des serveurs MCP configurés avec différents modèles (Claude, GPT, Gemini).

**Usage** :
```bash
# Vérifier tous les serveurs MCP configurés
./scripts/mcp-check.sh

# Analyser les logs récents pour détecter les erreurs MCP
./scripts/mcp-check.sh --parse-logs
```

**Détecte** :
- Serveurs MCP avec schémas JSON invalides
- Incompatibilités avec GPT-4.1 (validation stricte)
- Commandes MCP manquantes ou non installées

**Sortie exemple** :
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

Servers checked: 3
Compatibility issues: 1
```

**Documentation** : [MCP-PROFILES.md](../docs/MCP-PROFILES.md)

---

### `test-billing-header-fix.sh` - Test du Fix Issue #174

Teste que le patch copilot-api filtre correctement `x-anthropic-billing-header` du system prompt.

**Usage** :
```bash
# Lancer le test automatique
./scripts/test-billing-header-fix.sh
```

**Pré-requis** :
- copilot-api doit être actif sur le port 4141
- Le patch communautaire doit être appliqué (voir TROUBLESHOOTING.md)

**Tests effectués** :
1. ✅ System prompt avec `x-anthropic-billing-header` → doit être accepté (filtré)
2. ✅ System prompt normal → doit être accepté
3. ✅ Vérification que les deux types de requêtes fonctionnent

**Sortie exemple** :
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test du fix pour issue copilot-api #174
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Vérification de copilot-api...
✅ copilot-api actif sur :4141

2️⃣  Test 1: System prompt avec x-anthropic-billing-header...
✅ SUCCÈS: Requête acceptée sans erreur

3️⃣  Test 2: System prompt normal (contrôle)...
✅ SUCCÈS: Requête normale fonctionne également

✅ Tous les tests passent - Le fix fonctionne !
```

**En cas d'échec** :
- Vérifier que copilot-api est lancé : `nc -z localhost 4141`
- Vérifier que le patch est appliqué : `grep "FIX #174" ~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js`
- Voir logs copilot-api pour messages d'erreur détaillés

**Documentation** : [TROUBLESHOOTING.md - Patch communautaire](../docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée)

---

## 🔧 Scripts de Sécurité

Le dossier `security/` contient des scripts spécialisés pour l'audit de sécurité.

**Voir** : [security/README.md](security/README.md)

---

## 🚀 Contribuer

Pour ajouter un nouveau script :

1. **Créer le script** dans `scripts/` avec extension `.sh`
2. **Rendre exécutable** : `chmod +x scripts/nouveau-script.sh`
3. **Ajouter shebang** : `#!/bin/bash` en première ligne
4. **Ajouter documentation** : Mettre à jour ce README.md
5. **Tester** : Vérifier que le script fonctionne sur macOS/Linux

### Template de script

```bash
#!/bin/bash
# Nom du script - Description courte
# Usage: ./script.sh [options]

set -euo pipefail  # Fail fast

# Fonction principale
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Nom du Script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Logique du script ici

    echo "✅ Terminé"
}

# Point d'entrée
main "$@"
```

---

## 📚 Liens Utiles

- [Documentation principale](../README.md)
- [Guide de dépannage](../docs/TROUBLESHOOTING.md)
- [Guide des commandes](../docs/COMMANDS.md)
- [FAQ](../docs/FAQ.md)

---

**Dernière mise à jour** : 2026-01-22
