# Release Process - Guide Rapide

Guide étape par étape pour publier une nouvelle version de `claude-switch`.

---

## TL;DR - Checklist Rapide

```bash
# 1. Update version
vim claude-switch  # Changer Version: 1.5.3
vim Formula/cc-copilot-bridge.rb  # Changer version "1.5.3"

# 2. Commit
git add -A
git commit -m "Release v1.5.3: Description des changements"

# 3. Tag & Push
git tag -a v1.5.3 -m "Release v1.5.3"
git push origin main
git push origin v1.5.3

# 4. Attendre GitHub Actions (~5-10 min)
# Vérifie : https://github.com/FlorianBruniaux/cc-copilot-bridge/actions

# 5. Update Homebrew Tap
cd ../homebrew-tap
git pull origin main  # GitHub Actions a commit la formula
# ou copie manuellement :
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/
git add Formula/cc-copilot-bridge.rb
git commit -m "Update claude-switch to v1.5.3"
git push

# 6. Tester
brew update
brew upgrade claude-switch
claude-switch --version  # Doit afficher v1.5.3
```

---

## Étapes Détaillées

### 1. Préparer la Release

#### A. Vérifier l'état du code

```bash
cd ~/Sites/perso/cc-copilot-bridge

# S'assurer que tout est commit
git status
# On branch main
# nothing to commit, working tree clean

# S'assurer d'être à jour
git pull origin main
```

#### B. Mettre à jour la version

**Fichier 1** : `claude-switch`
```bash
vim claude-switch

# Ligne 5 :
# Version: 1.5.2 - Package manager friendly: --shell-config option
# → Changer en :
# Version: 1.5.3 - Description du changement

# Ligne 427 :
# -v|--version) echo "claude-switch v1.5.2" ;;
# → Changer en :
# -v|--version) echo "claude-switch v1.5.3" ;;
```

**Fichier 2** : `Formula/cc-copilot-bridge.rb`
```bash
vim Formula/cc-copilot-bridge.rb

# Ligne 6 :
# version "1.5.2"
# → Changer en :
# version "1.5.3"

# Note : SHA256 sera mis à jour automatiquement par GitHub Actions
```

#### C. Update CHANGELOG (optionnel mais recommandé)

```bash
vim CHANGELOG.md

# Ajouter en haut :
## [1.5.3] - 2026-01-24

### Added
- Nouvelle feature X

### Fixed
- Bug Y corrigé

### Changed
- Amélioration Z
```

### 2. Commit les Changements

```bash
# Add all changes
git add -A

# Commit avec message descriptif
git commit -m "Release v1.5.3: Description concise des changements majeurs"

# Exemples de bons messages :
# git commit -m "Release v1.5.3: Add --shell-config option for package managers"
# git commit -m "Release v1.5.3: Fix Ollama context size detection"
# git commit -m "Release v1.5.3: Add Gemini 3 support via unified fork"
```

### 3. Créer et Pusher le Tag

```bash
# Créer tag annoté avec message
git tag -a v1.5.3 -m "Release v1.5.3: Description des changements

- Feature 1
- Feature 2
- Bug fix 3"

# Vérifier le tag
git tag -l -n9 v1.5.3

# Push le code
git push origin main

# Push le tag (déclenche GitHub Actions)
git push origin v1.5.3
```

### 4. Suivre le Build GitHub Actions

#### A. Aller sur GitHub Actions

https://github.com/FlorianBruniaux/cc-copilot-bridge/actions

#### B. Voir le workflow "Build Packages"

Étapes à vérifier :
- ✅ Checkout code
- ✅ Set version from tag
- ✅ Compute SHA256 for Homebrew
- ✅ Update Homebrew Formula SHA256
- ✅ Build DEB Package
- ✅ Build RPM Package
- ✅ Create Release
- ✅ Commit updated Formula

**Durée** : ~5-10 minutes

#### C. En cas d'erreur

**Voir les logs** :
- Cliquer sur l'étape en rouge
- Lire l'erreur
- Corriger localement
- Re-tag (supprimer l'ancien d'abord)

```bash
# Supprimer tag local et remote
git tag -d v1.5.3
git push --delete origin v1.5.3

# Corriger le code
vim ...
git add -A
git commit -m "Fix release issue"

# Re-créer le tag
git tag -a v1.5.3 -m "Release v1.5.3"
git push origin main
git push origin v1.5.3
```

### 5. Vérifier la GitHub Release

#### A. Aller sur Releases

https://github.com/FlorianBruniaux/cc-copilot-bridge/releases

#### B. Vérifier les assets

✅ **Assets attendus** :
- `claude-switch_1.5.3.deb` (~5-10 KB)
- `claude-switch-1.5.3-1.noarch.rpm` (~10-15 KB)
- `cc-copilot-bridge.rb` (Formula Homebrew)
- `Source code (zip)`
- `Source code (tar.gz)`

✅ **Release notes** :
- Instructions Homebrew
- Instructions Debian
- Instructions RHEL/Fedora
- Lien vers documentation

### 6. Mettre à Jour Homebrew Tap

#### A. Vérifier le commit automatique

GitHub Actions a normalement commit la formula mise à jour dans `cc-copilot-bridge`.

```bash
cd ~/Sites/perso/cc-copilot-bridge
git pull origin main

# Vérifier la formula
cat Formula/cc-copilot-bridge.rb | grep -E "version|sha256"
# version "1.5.3"
# sha256 "abc123..." (plus PLACEHOLDER)
```

#### B. Copier vers homebrew-tap

```bash
cd ~/Sites/perso/homebrew-tap

# Option 1 : Pull si GitHub Actions a push directement (si configuré)
git pull origin main

# Option 2 : Copie manuelle (plus sûr)
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/

# Vérifier les changements
git diff Formula/cc-copilot-bridge.rb

# Commit
git add Formula/cc-copilot-bridge.rb
git commit -m "Update claude-switch to v1.5.3"
git push
```

#### C. Tester le tap

```bash
# Update Homebrew
brew update

# Si déjà installé
brew upgrade claude-switch

# Si pas installé
brew install FlorianBruniaux/tap/cc-copilot-bridge

# Vérifier
claude-switch --version
# claude-switch v1.5.3
```

### 7. Tester les Packages

#### A. Test Homebrew

```bash
# Fresh install sur machine de test
brew uninstall claude-switch
brew install FlorianBruniaux/tap/cc-copilot-bridge

# Vérifier version
claude-switch --version

# Tester shell config
eval "$(claude-switch --shell-config)"

# Tester aliases
ccd --help
ccc --help
cco --help
```

#### B. Test .deb (Ubuntu/Debian)

```bash
# Télécharger
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.3/claude-switch_1.5.3.deb

# Installer
sudo dpkg -i claude-switch_1.5.3.deb

# Vérifier
which claude-switch
claude-switch --version

# Tester
eval "$(claude-switch --shell-config)"
ccd --help
```

#### C. Test .rpm (Fedora/RHEL)

```bash
# Télécharger
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.3/claude-switch-1.5.3-1.noarch.rpm

# Installer
sudo dnf install claude-switch-1.5.3-1.noarch.rpm

# Vérifier
which claude-switch
claude-switch --version

# Tester
eval "$(claude-switch --shell-config)"
ccd --help
```

### 8. Mettre à Jour la Documentation

#### A. Update README badges (si applicable)

```bash
vim README.md

# Update version badge
[![Version](https://img.shields.io/badge/version-1.5.3-blue.svg)](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases)
```

#### B. Update docs si nécessaire

```bash
# Si changements API ou usage
vim docs/QUICKSTART.md
vim docs/COMMANDS.md

git add docs/
git commit -m "docs: Update for v1.5.3"
git push
```

### 9. Annoncer la Release

#### A. Update projet GitHub

- Épingler la release si majeure
- Update GitHub About section si nécessaire

#### B. Notifications (optionnel)

- Twitter/X : "Released claude-switch v1.5.3 🚀 ..."
- Reddit : r/commandline, r/bash
- Hacker News (si release majeure)
- Blog post (si changements significatifs)

---

## Release Types

### Patch Release (1.5.2 → 1.5.3)

**Quand** : Bug fixes, small improvements

**Processus** :
- Update version
- Tag & push
- Pas besoin d'annoncer largement

### Minor Release (1.5.3 → 1.6.0)

**Quand** : New features, non-breaking changes

**Processus** :
- Update version
- Update CHANGELOG avec features
- Tag & push
- Annoncer sur réseaux sociaux
- Blog post optionnel

### Major Release (1.6.0 → 2.0.0)

**Quand** : Breaking changes, major refactor

**Processus** :
- Update version
- Write migration guide
- Update all docs
- Tag & push
- Annoncer largement
- Blog post détaillé
- Emails aux users

---

## Rollback d'une Release

### Si la release a un bug critique

#### 1. Supprimer le tag Git

```bash
# Local
git tag -d v1.5.3

# Remote
git push --delete origin v1.5.3
```

#### 2. Supprimer la GitHub Release

- Aller sur Releases
- Cliquer sur la release
- "Delete release"

#### 3. Corriger le bug

```bash
# Fix le code
vim ...

# Commit
git add -A
git commit -m "Fix critical bug in v1.5.3"
```

#### 4. Re-release avec version patch

```bash
# Nouvelle version (1.5.4)
vim claude-switch  # Version: 1.5.4
vim Formula/cc-copilot-bridge.rb  # version "1.5.4"

git add -A
git commit -m "Release v1.5.4: Fix critical bug from v1.5.3"

git tag -a v1.5.4 -m "Release v1.5.4: Fix critical bug"
git push origin main
git push origin v1.5.4
```

---

## Pre-Release Testing

### Avant de tag v1.5.3 (recommandé pour releases majeures)

#### 1. Créer un pre-release tag

```bash
git tag -a v1.5.3-rc1 -m "Release candidate 1"
git push origin v1.5.3-rc1
```

GitHub Actions build, mais :
- Marquer "Pre-release" sur GitHub
- Tester intensivement
- Corriger bugs
- Créer rc2, rc3... si nécessaire

#### 2. Quand stable, tag final

```bash
git tag -a v1.5.3 -m "Release v1.5.3"
git push origin v1.5.3
```

---

## Automatisation Avancée (Future)

### Release-Please (Google)

Génère automatiquement CHANGELOGs et releases basés sur Conventional Commits.

```yaml
# .github/workflows/release-please.yml
on:
  push:
    branches:
      - main

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/release-please-action@v3
        with:
          release-type: simple
          package-name: claude-switch
```

### Semantic Release

Automatise versioning basé sur commits.

```json
// .releaserc.json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github"
  ]
}
```

---

## Troubleshooting Release

### GitHub Actions ne démarre pas

**Cause** : Tag pas poussé ou workflow permissions

**Solution** :
```bash
# Vérifier que le tag existe
git ls-remote --tags origin | grep v1.5.3

# Si manquant, push
git push origin v1.5.3

# Vérifier permissions
# Settings → Actions → General → Read/Write
```

### SHA256 mismatch Homebrew

**Cause** : GitHub tarball change entre calcul et download

**Solution** :
```bash
# Recalculer manuellement
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.3.tar.gz
sha256sum v1.5.3.tar.gz

# Update Formula
vim Formula/cc-copilot-bridge.rb
# Remplacer SHA256

# Commit et update tap
git add Formula/cc-copilot-bridge.rb
git commit -m "Fix SHA256 for v1.5.3"
git push

cd ../homebrew-tap
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/
git add Formula/cc-copilot-bridge.rb
git commit -m "Fix SHA256 for claude-switch v1.5.3"
git push
```

### Package build fails

**Cause** : Dépendance manquante dans CI

**Solution** :
```yaml
# .github/workflows/build-packages.yml
- name: Install dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y rpm
```

---

## Checklist Complète

Avant de pusher le tag final :

- [ ] Code tests pass localement
- [ ] Version updated dans `claude-switch`
- [ ] Version updated dans `Formula/cc-copilot-bridge.rb`
- [ ] CHANGELOG updated (optionnel)
- [ ] Git status clean
- [ ] Commit message descriptif
- [ ] Tag créé avec message
- [ ] GitHub Actions permissions OK
- [ ] Homebrew tap existe et accessible

Après release :

- [ ] GitHub Actions succeeded
- [ ] Release créée sur GitHub
- [ ] Assets présents (.deb, .rpm, .rb)
- [ ] Homebrew tap updated
- [ ] Tests Homebrew passed
- [ ] Tests .deb passed (si possible)
- [ ] Tests .rpm passed (si possible)
- [ ] Documentation updated
- [ ] Annonce faite (si applicable)

---

## Contact & Help

**Issues** : https://github.com/FlorianBruniaux/cc-copilot-bridge/issues

**Questions** : Ouvrir une Discussion sur GitHub

**Urgent** : Email maintainer (voir GitHub profile)
