# Homebrew Formula

Cette Formula permet l'installation de `claude-switch` via Homebrew.

## Pour les Utilisateurs

**Installation** :
```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
eval "$(claude-switch --shell-config)"
```

**Mise à jour** :
```bash
brew update
brew upgrade claude-switch
```

**Désinstallation** :
```bash
brew uninstall claude-switch
brew untap FlorianBruniaux/tap
```

## Pour les Mainteneurs

### Structure du Tap

Le Homebrew tap se trouve dans un repo séparé : `FlorianBruniaux/homebrew-tap`

```
homebrew-tap/
├── Formula/
│   └── cc-copilot-bridge.rb    # Copié depuis cc-copilot-bridge/Formula/
└── README.md
```

### Workflow de Release

**Automatique via GitHub Actions** :

1. **Tag push** déclenche `.github/workflows/build-packages.yml`
2. GitHub Actions :
   - Compute SHA256 du tarball
   - Build packages (.deb, .rpm)
   - Update `Formula/cc-copilot-bridge.rb` avec SHA256
   - Create GitHub Release
   - **Commit Formula update** dans `cc-copilot-bridge`

3. **Copie manuelle vers tap** :
   ```bash
   cd ~/Sites/perso/homebrew-tap
   cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/
   git add Formula/cc-copilot-bridge.rb
   git commit -m "Update claude-switch to v1.5.3"
   git push
   ```

### Tester la Formula Localement

**Avant de pusher vers tap** :

```bash
# 1. Build from local formula
brew install --build-from-source ./Formula/cc-copilot-bridge.rb

# 2. Vérifier
claude-switch --version
eval "$(claude-switch --shell-config)"
ccd --help

# 3. Tester les dépendances
which nc  # Netcat doit être installé

# 4. Désinstaller
brew uninstall claude-switch
```

### Valider la Formula

```bash
# Linter Homebrew
brew audit --strict ./Formula/cc-copilot-bridge.rb

# Style check
brew style ./Formula/cc-copilot-bridge.rb

# Test installation
brew install --build-from-source ./Formula/cc-copilot-bridge.rb
brew test claude-switch
```

### Dépendances

**Requises** :
- `netcat` : Pour health checks de provider

**Optionnelles** :
- `ollama` : Pour provider Ollama local
- `node` : Pour copilot-api (GitHub Copilot provider)

### SHA256 Checksum

**Pourquoi ?**
- Sécurité : Vérifie l'intégrité du téléchargement
- Prévient les attaques man-in-the-middle

**Comment calculer ?**

GitHub Actions calcule automatiquement :
```bash
git archive --format=tar.gz --prefix=cc-copilot-bridge-1.5.2/ HEAD > release.tar.gz
sha256sum release.tar.gz | awk '{print $1}'
```

**Manuellement** :
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz
sha256sum v1.5.2.tar.gz
```

**Si mismatch** :
```bash
# Recalculer
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz
NEW_SHA=$(sha256sum v1.5.2.tar.gz | awk '{print $1}')

# Update Formula
sed -i "s/sha256 \".*\"/sha256 \"${NEW_SHA}\"/" Formula/cc-copilot-bridge.rb

# Commit et push
git add Formula/cc-copilot-bridge.rb
git commit -m "Fix SHA256 checksum for v1.5.2"
git push
```

### Troubleshooting

#### "SHA256 mismatch"

**Cause** : GitHub tarball change entre calcul et download

**Solution** : Recalculer SHA256 (voir ci-dessus)

#### "Could not resolve dependencies"

**Cause** : Netcat pas trouvé

**Solution** :
```bash
brew install netcat
```

#### "File already exists"

**Cause** : Installation précédente

**Solution** :
```bash
brew uninstall claude-switch
brew install cc-copilot-bridge
```

### Ressources

**Documentation officielle Homebrew** :
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Adding Software to Homebrew](https://docs.brew.sh/Adding-Software-to-Homebrew)
- [Homebrew Terminology](https://docs.brew.sh/Formula-Cookbook#homebrew-terminology)

**Guides du projet** :
- [PACKAGE-MANAGERS.md](../docs/PACKAGE-MANAGERS.md) : Guide utilisateur
- [PACKAGE-MANAGERS-EXPLAINED.md](../docs/PACKAGE-MANAGERS-EXPLAINED.md) : Détails techniques
- [RELEASE-PROCESS.md](../docs/RELEASE-PROCESS.md) : Process de release

### Exemples de Formulas

Pour inspiration, voir :
- [fzf](https://github.com/Homebrew/homebrew-core/blob/master/Formula/f/fzf.rb)
- [ripgrep](https://github.com/Homebrew/homebrew-core/blob/master/Formula/r/ripgrep.rb)
- [bat](https://github.com/Homebrew/homebrew-core/blob/master/Formula/b/bat.rb)
