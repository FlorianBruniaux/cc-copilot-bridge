# Package Managers - Explication Complète

Guide détaillé sur le système de distribution via package managers (Homebrew, .deb, .rpm).

---

## Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Homebrew (macOS/Linux)](#homebrew-macoslinux)
3. [Debian/Ubuntu (.deb)](#debianubuntu-deb)
4. [RHEL/Fedora (.rpm)](#rhelfedora-rpm)
5. [GitHub Actions Pipeline](#github-actions-pipeline)
6. [Tester Localement](#tester-localement)
7. [Publier une Release](#publier-une-release)

---

## Vue d'ensemble

### Pourquoi des Package Managers ?

**Problème avec `curl | bash`** :
```bash
# ❌ Ancien système
curl https://example.com/install.sh | bash
# - Exécute du code sans review
# - Modifie .zshrc automatiquement
# - Pas de gestion des dépendances
# - Pas de désinstallation propre
# - Compliqué pour les LLMs à expliquer
```

**Solution avec Package Managers** :
```bash
# ✅ Nouveau système
brew install cc-copilot-bridge
# - Installation standard (comme tous les outils)
# - Dépendances gérées automatiquement
# - Updates via brew upgrade
# - Uninstall propre
# - LLM-friendly : "install via brew/apt/rpm"
```

### Architecture Complète

```
┌─────────────────────────────────────────────────────────────┐
│                    Git Tag Push (v1.5.2)                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Workflow                         │
│  (.github/workflows/build-packages.yml)                     │
│                                                              │
│  1. Compute SHA256 for Homebrew Formula                     │
│  2. Build .deb package (Debian/Ubuntu)                      │
│  3. Build .rpm package (RHEL/Fedora)                        │
│  4. Update Formula/cc-copilot-bridge.rb                         │
│  5. Create GitHub Release                                    │
│  6. Attach all packages to release                          │
└────────┬────────────┬────────────┬─────────────────────────┘
         │            │            │
         ▼            ▼            ▼
   ┌──────────┐ ┌─────────┐ ┌──────────┐
   │ Homebrew │ │  .deb   │ │   .rpm   │
   │  Tap     │ │ Package │ │ Package  │
   └──────────┘ └─────────┘ └──────────┘
         │            │            │
         ▼            ▼            ▼
   ┌──────────┐ ┌─────────┐ ┌──────────┐
   │   brew   │ │  dpkg   │ │   rpm    │
   │ install  │ │ install │ │ install  │
   └──────────┘ └─────────┘ └──────────┘
         │            │            │
         └────────────┴────────────┘
                     │
                     ▼
              /usr/local/bin/claude-switch
                     │
                     ▼
              User runs: eval "$(claude-switch --shell-config)"
```

---

## Homebrew (macOS/Linux)

### Qu'est-ce que Homebrew ?

**Homebrew** est le package manager le plus populaire pour macOS, et fonctionne aussi sur Linux.

**Concepts clés** :
- **Formula** : Recette de build (fichier Ruby `.rb`)
- **Tap** : Repository de formulas (comme un PPA Ubuntu)
- **Cellar** : Où Homebrew installe les packages (`/usr/local/Cellar`)
- **Keg** : Une version spécifique d'un package

### Structure du Tap

```
FlorianBruniaux/homebrew-tap/
├── Formula/
│   └── cc-copilot-bridge.rb    # La formula
└── README.md
```

**Convention Homebrew** :
- Nom du repo : `homebrew-<tap-name>`
- Exemple : `homebrew-tap` devient le tap `FlorianBruniaux/tap`
- URL : `https://github.com/FlorianBruniaux/homebrew-tap`

### Anatomie de la Formula

**Fichier** : `Formula/cc-copilot-bridge.rb`

```ruby
class CcCopilotBridge < Formula
  desc "Multi-provider switcher for Claude Code CLI"
  homepage "https://github.com/FlorianBruniaux/cc-copilot-bridge"

  # URL du tarball source
  url "https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz"

  # SHA256 checksum (sécurité)
  sha256 "abc123..."  # Calculé par GitHub Actions

  license "MIT"
  version "1.5.2"

  # Dépendances (installées automatiquement)
  depends_on "netcat"

  # Dépendances optionnelles
  depends_on "ollama" => :optional
  depends_on "node" => :optional  # Pour copilot-api

  def install
    # Copie le script dans /usr/local/bin
    bin.install "claude-switch"

    # Crée le répertoire de logs
    (var/"log/claude-switch").mkpath

    # Copie la documentation
    doc.install "README.md"
    doc.install "QUICKSTART.md"
    doc.install Dir["docs/*"]
  end

  def caveats
    <<~EOS
      To enable shell aliases, add to your ~/.zshrc or ~/.bashrc:

        eval "$(claude-switch --shell-config)"

      For more integration options:
        https://github.com/FlorianBruniaux/cc-copilot-bridge/blob/main/docs/INSTALL-OPTIONS.md
    EOS
  end

  test do
    assert_match "claude-switch v1.5.2", shell_output("#{bin}/claude-switch --version")
    assert_match "alias ccd=", shell_output("#{bin}/claude-switch --shell-config")
  end
end
```

### Workflow Utilisateur

**1. Ajouter le tap** (une seule fois)
```bash
brew tap FlorianBruniaux/tap
# Clone https://github.com/FlorianBruniaux/homebrew-tap
# dans /usr/local/Homebrew/Library/Taps/florianbruniaux/homebrew-tap
```

**2. Installer le package**
```bash
brew install cc-copilot-bridge
# 1. Download tarball from GitHub
# 2. Verify SHA256 checksum
# 3. Extract to /tmp/claude-switch-XXXXX
# 4. Run install() method
# 5. Copy to /usr/local/Cellar/claude-switch/1.5.2
# 6. Symlink to /usr/local/bin/claude-switch
# 7. Install dependencies (netcat)
```

**3. Configurer le shell**
```bash
eval "$(claude-switch --shell-config)"
# Génère et exécute les aliases dynamiquement
```

**4. Mettre à jour**
```bash
brew update          # Met à jour la liste des formulas
brew upgrade claude-switch  # Upgrade vers nouvelle version
```

**5. Désinstaller**
```bash
brew uninstall claude-switch
# 1. Remove symlinks from /usr/local/bin
# 2. Remove /usr/local/Cellar/claude-switch
# 3. Keep dependencies (sauf si --force)
```

### Créer le Homebrew Tap

**Étape 1 : Créer le repository**
```bash
# Sur GitHub : Create new repository
# Name: homebrew-tap
# Description: Homebrew formulae for FlorianBruniaux projects
# Public
```

**Étape 2 : Structure initiale**
```bash
mkdir homebrew-tap
cd homebrew-tap

# Créer la structure
mkdir Formula
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/

# README
cat > README.md << 'EOF'
# FlorianBruniaux Homebrew Tap

Homebrew formulae for FlorianBruniaux projects.

## Install

```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
```

## Packages

- **claude-switch**: Multi-provider switcher for Claude Code CLI
EOF

# Commit et push
git init
git add .
git commit -m "Initial tap with claude-switch formula"
git remote add origin https://github.com/FlorianBruniaux/homebrew-tap.git
git push -u origin main
```

**Étape 3 : Tester localement**
```bash
# Install depuis le tap local
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge

# Vérifier
claude-switch --version
# claude-switch v1.5.2
```

### SHA256 et Sécurité

**Pourquoi SHA256 ?**
- Vérifier l'intégrité du téléchargement
- Prévenir les attaques man-in-the-middle
- Homebrew refuse d'installer si checksum incorrect

**Comment calculer ?**

GitHub Actions calcule automatiquement :
```bash
# .github/workflows/build-packages.yml
git archive --format=tar.gz --prefix=cc-copilot-bridge-1.5.2/ HEAD > release.tar.gz
SHA256=$(sha256sum release.tar.gz | awk '{print $1}')
sed -i "s/PLACEHOLDER_SHA256/${SHA256}/g" Formula/cc-copilot-bridge.rb
```

**Manuellement** :
```bash
# Télécharger le tarball
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz

# Calculer SHA256
sha256sum v1.5.2.tar.gz
# abc123def456... v1.5.2.tar.gz

# Mettre à jour la formula
sed -i 's/sha256 ".*"/sha256 "abc123def456..."/' Formula/cc-copilot-bridge.rb
```

---

## Debian/Ubuntu (.deb)

### Structure d'un Package .deb

```
claude-switch_1.5.2.deb
└── Contient :
    ├── DEBIAN/
    │   ├── control         # Métadonnées du package
    │   ├── postinst        # Script post-installation (optionnel)
    │   └── prerm           # Script pré-désinstallation (optionnel)
    ├── usr/
    │   ├── local/
    │   │   └── bin/
    │   │       └── claude-switch  # Le script exécutable
    │   └── share/
    │       └── doc/
    │           └── claude-switch/
    │               ├── README.md
    │               ├── QUICKSTART.md
    │               └── docs/
    └── var/
        └── log/
            └── claude-switch/  # Répertoire de logs (optionnel)
```

### Fichier control

**Fichier** : `DEBIAN/control`

```
Package: claude-switch
Version: 1.5.2
Section: utils
Priority: optional
Architecture: all
Depends: netcat
Maintainer: Florian Bruniaux <florian@example.com>
Description: Multi-provider switcher for Claude Code CLI
 Seamlessly switch between Anthropic Direct, GitHub Copilot,
 and Ollama local providers for Claude Code CLI.
Homepage: https://github.com/FlorianBruniaux/cc-copilot-bridge
```

**Champs importants** :
- `Package` : Nom du package (doit être unique)
- `Version` : Version sémantique (1.5.2)
- `Architecture` : `all` (bash script, pas de binaire compilé)
- `Depends` : Dépendances (installées automatiquement)
- `Description` : Description courte + longue (indentée avec espace)

### Build du Package

**Via GitHub Actions** :
```bash
# .github/workflows/build-packages.yml
mkdir -p deb-build/claude-switch_1.5.2/DEBIAN
mkdir -p deb-build/claude-switch_1.5.2/usr/local/bin
mkdir -p deb-build/claude-switch_1.5.2/usr/share/doc/claude-switch

# Copy binary
cp claude-switch deb-build/claude-switch_1.5.2/usr/local/bin/
chmod +x deb-build/claude-switch_1.5.2/usr/local/bin/claude-switch

# Copy docs
cp README.md QUICKSTART.md deb-build/claude-switch_1.5.2/usr/share/doc/claude-switch/

# Create control file
cat > deb-build/claude-switch_1.5.2/DEBIAN/control << EOF
Package: claude-switch
Version: 1.5.2
...
EOF

# Build package
dpkg-deb --build deb-build/claude-switch_1.5.2
# Crée : claude-switch_1.5.2.deb
```

**Manuellement** :
```bash
# Structure
mkdir -p deb-build/claude-switch_1.5.2/{DEBIAN,usr/local/bin,usr/share/doc/claude-switch}

# Copier le script
cp claude-switch deb-build/claude-switch_1.5.2/usr/local/bin/
chmod 755 deb-build/claude-switch_1.5.2/usr/local/bin/claude-switch

# Créer control
cat > deb-build/claude-switch_1.5.2/DEBIAN/control << 'EOF'
Package: claude-switch
Version: 1.5.2
Section: utils
Priority: optional
Architecture: all
Depends: netcat
Maintainer: Florian Bruniaux <florian@example.com>
Description: Multi-provider switcher for Claude Code CLI
 Seamlessly switch between Anthropic Direct, GitHub Copilot,
 and Ollama local providers for Claude Code CLI.
EOF

# Build
dpkg-deb --build deb-build/claude-switch_1.5.2

# Vérifier
dpkg-deb -I claude-switch_1.5.2.deb
dpkg-deb -c claude-switch_1.5.2.deb  # List contents
```

### Installation Utilisateur

**1. Télécharger le .deb**
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch_1.5.2.deb
```

**2. Installer**
```bash
sudo dpkg -i claude-switch_1.5.2.deb
# 1. Extrait les fichiers
# 2. Copie vers /usr/local/bin/claude-switch
# 3. Enregistre le package dans dpkg database
# 4. Exécute postinst script (si présent)
```

**3. Résoudre les dépendances**
```bash
sudo apt-get install -f
# Si netcat manquant, l'installe automatiquement
```

**4. Vérifier**
```bash
dpkg -l | grep claude-switch
# ii  claude-switch  1.5.2  all  Multi-provider switcher...

which claude-switch
# /usr/local/bin/claude-switch

claude-switch --version
# claude-switch v1.5.2
```

**5. Configurer shell**
```bash
echo 'eval "$(claude-switch --shell-config)"' >> ~/.bashrc
source ~/.bashrc
```

**6. Désinstaller**
```bash
sudo dpkg -r claude-switch
# Remove files
# Keep config if any

sudo dpkg -P claude-switch
# Purge (remove everything including config)
```

---

## RHEL/Fedora (.rpm)

### Structure d'un Package .rpm

Les packages RPM sont plus complexes que .deb car ils utilisent un système de build avec spec files.

**Structure de build** :
```
rpm-build/
├── BUILD/          # Répertoire de build temporaire
├── RPMS/           # Packages compilés (.rpm)
├── SOURCES/        # Tarballs sources
├── SPECS/          # Fichiers .spec (recettes)
└── SRPMS/          # Source RPMs
```

### Fichier .spec

**Fichier** : `rpm-build/SPECS/claude-switch.spec`

```spec
Name:           claude-switch
Version:        1.5.2
Release:        1%{?dist}
Summary:        Multi-provider switcher for Claude Code CLI

License:        MIT
URL:            https://github.com/FlorianBruniaux/cc-copilot-bridge
Source0:        %{name}-%{version}.tar.gz

# Dépendances
Requires:       nmap-ncat

# Pas de debuginfo package (bash script)
%global debug_package %{nil}

%description
Seamlessly switch between Anthropic Direct, GitHub Copilot,
and Ollama local providers for Claude Code CLI.

%prep
# Extraction du tarball
%setup -q

%build
# Rien à compiler (bash script)

%install
# Installation dans le buildroot
mkdir -p %{buildroot}%{_bindir}
install -m 755 claude-switch %{buildroot}%{_bindir}/claude-switch

mkdir -p %{buildroot}%{_docdir}/%{name}
cp README.md QUICKSTART.md %{buildroot}%{_docdir}/%{name}/
cp -r docs %{buildroot}%{_docdir}/%{name}/

%files
# Liste des fichiers dans le package
%{_bindir}/claude-switch
%doc %{_docdir}/%{name}

%changelog
* Thu Jan 23 2026 Florian Bruniaux <florian@example.com> - 1.5.2-1
- Initial release
- Multi-provider support (Anthropic, Copilot, Ollama)
- Shell config generator (--shell-config)
```

**Macros RPM** :
- `%{name}` : claude-switch
- `%{version}` : 1.5.2
- `%{release}` : 1
- `%{_bindir}` : /usr/bin
- `%{_docdir}` : /usr/share/doc
- `%{buildroot}` : Répertoire temporaire de build

### Build du Package

**Via GitHub Actions** :
```bash
# .github/workflows/build-packages.yml
mkdir -p rpm-build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Create spec file
cat > rpm-build/SPECS/claude-switch.spec << EOF
...
EOF

# Create source tarball
tar czf rpm-build/SOURCES/claude-switch-1.5.2.tar.gz \
  --transform "s,^,claude-switch-1.5.2/," \
  claude-switch README.md QUICKSTART.md docs

# Build RPM
rpmbuild --define "_topdir $(pwd)/rpm-build" -ba rpm-build/SPECS/claude-switch.spec
# Crée : rpm-build/RPMS/noarch/claude-switch-1.5.2-1.noarch.rpm
```

**Manuellement** :
```bash
# Install rpmbuild tools
sudo dnf install rpm-build  # Fedora
# ou
sudo yum install rpm-build  # RHEL/CentOS

# Create build structure
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Copy spec file
cp claude-switch.spec ~/rpmbuild/SPECS/

# Create source tarball
tar czf ~/rpmbuild/SOURCES/claude-switch-1.5.2.tar.gz \
  --transform "s,^,claude-switch-1.5.2/," \
  claude-switch README.md docs

# Build
rpmbuild -ba ~/rpmbuild/SPECS/claude-switch.spec

# Package créé dans :
# ~/rpmbuild/RPMS/noarch/claude-switch-1.5.2-1.fc39.noarch.rpm
```

### Installation Utilisateur

**1. Télécharger le .rpm**
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch-1.5.2-1.noarch.rpm
```

**2. Installer**

**Fedora** :
```bash
sudo dnf install claude-switch-1.5.2-1.noarch.rpm
# 1. Vérifie les dépendances (nmap-ncat)
# 2. Installe les dépendances manquantes
# 3. Installe le package
# 4. Enregistre dans RPM database
```

**RHEL/CentOS** :
```bash
sudo yum install claude-switch-1.5.2-1.noarch.rpm
# ou
sudo rpm -i claude-switch-1.5.2-1.noarch.rpm
# (rpm -i ne gère PAS les dépendances automatiquement)
```

**3. Vérifier**
```bash
rpm -qa | grep claude-switch
# claude-switch-1.5.2-1.noarch

rpm -ql claude-switch
# /usr/bin/claude-switch
# /usr/share/doc/claude-switch/README.md
# ...

which claude-switch
# /usr/bin/claude-switch
```

**4. Configurer shell**
```bash
echo 'eval "$(claude-switch --shell-config)"' >> ~/.bashrc
source ~/.bashrc
```

**5. Mettre à jour**
```bash
# Télécharger nouvelle version
wget https://github.com/.../claude-switch-1.5.3-1.noarch.rpm

# Upgrade
sudo dnf upgrade claude-switch-1.5.3-1.noarch.rpm
# ou
sudo rpm -U claude-switch-1.5.3-1.noarch.rpm
```

**6. Désinstaller**
```bash
sudo dnf remove claude-switch
# ou
sudo rpm -e claude-switch
```

---

## GitHub Actions Pipeline

### Workflow Complet

**Fichier** : `.github/workflows/build-packages.yml`

**Déclencheurs** :
```yaml
on:
  push:
    tags:
      - 'v*'      # Tout tag commençant par 'v' (v1.5.2, v2.0.0, etc.)
  workflow_dispatch:  # Déclenchement manuel
```

**Étapes** :

#### 1. Compute SHA256 pour Homebrew

```yaml
- name: Compute SHA256 for Homebrew
  id: sha
  run: |
    # Créer un tarball identique à celui de GitHub Releases
    git archive --format=tar.gz --prefix=cc-copilot-bridge-1.5.2/ HEAD > release.tar.gz

    # Calculer SHA256
    SHA256=$(sha256sum release.tar.gz | awk '{print $1}')

    # Exporter pour les étapes suivantes
    echo "SHA256=${SHA256}" >> $GITHUB_OUTPUT
```

#### 2. Update Homebrew Formula

```yaml
- name: Update Homebrew Formula SHA256
  run: |
    # Remplacer PLACEHOLDER par le vrai SHA256
    sed -i "s/PLACEHOLDER_SHA256/${{ steps.sha.outputs.SHA256 }}/g" Formula/cc-copilot-bridge.rb

    # Mettre à jour la version
    sed -i "s/version \".*\"/version \"${{ steps.version.outputs.VERSION }}\"/g" Formula/cc-copilot-bridge.rb
```

#### 3. Build .deb Package

```yaml
- name: Build DEB Package
  run: |
    # Créer structure
    mkdir -p deb-build/claude-switch_1.5.2/DEBIAN
    mkdir -p deb-build/claude-switch_1.5.2/usr/local/bin

    # Copier fichiers
    cp claude-switch deb-build/claude-switch_1.5.2/usr/local/bin/
    chmod +x deb-build/claude-switch_1.5.2/usr/local/bin/claude-switch

    # Créer control file
    cat > deb-build/claude-switch_1.5.2/DEBIAN/control << EOF
    Package: claude-switch
    Version: ${{ steps.version.outputs.VERSION }}
    ...
    EOF

    # Build
    dpkg-deb --build deb-build/claude-switch_1.5.2
```

#### 4. Build .rpm Package

```yaml
- name: Build RPM Package
  run: |
    # Installer rpm-build tools
    sudo apt-get install -y rpm

    # Créer structure
    mkdir -p rpm-build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    # Créer spec file
    cat > rpm-build/SPECS/claude-switch.spec << EOF
    ...
    EOF

    # Créer source tarball
    tar czf rpm-build/SOURCES/claude-switch-1.5.2.tar.gz ...

    # Build
    rpmbuild --define "_topdir $(pwd)/rpm-build" -ba rpm-build/SPECS/claude-switch.spec
```

#### 5. Create GitHub Release

```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  if: startsWith(github.ref, 'refs/tags/')
  with:
    files: |
      claude-switch_*.deb
      claude-switch-*.rpm
      Formula/cc-copilot-bridge.rb
    body: |
      ## Installation

      ### Homebrew
      ```bash
      brew tap FlorianBruniaux/tap
      brew install cc-copilot-bridge
      ```

      ### Debian/Ubuntu
      ```bash
      wget .../claude-switch_1.5.2.deb
      sudo dpkg -i claude-switch_1.5.2.deb
      ```
      ...
```

#### 6. Commit Formula Update

```yaml
- name: Commit updated Formula
  run: |
    git config --local user.email "github-actions[bot]@users.noreply.github.com"
    git config --local user.name "github-actions[bot]"
    git add Formula/cc-copilot-bridge.rb
    git commit -m "Update Homebrew formula SHA256 for v1.5.2"
    git push origin HEAD:main
```

### Permissions Requises

**Dans le repo GitHub** :
```yaml
# .github/workflows/build-packages.yml
permissions:
  contents: write  # Pour créer la release et commit
```

**Settings → Actions → General** :
- ✅ "Read and write permissions"
- ✅ "Allow GitHub Actions to create and approve pull requests"

---

## Tester Localement

### Test Homebrew Formula

**Avant de push** :

```bash
# 1. Calculer SHA256 du tarball
git archive --format=tar.gz --prefix=cc-copilot-bridge-1.5.2/ HEAD > /tmp/test.tar.gz
sha256sum /tmp/test.tar.gz
# abc123...

# 2. Mettre à jour Formula/cc-copilot-bridge.rb
sed -i 's/sha256 ".*"/sha256 "abc123..."/' Formula/cc-copilot-bridge.rb

# 3. Tester localement
brew install --build-from-source Formula/cc-copilot-bridge.rb

# 4. Vérifier
claude-switch --version
eval "$(claude-switch --shell-config)"
ccd --help

# 5. Désinstaller
brew uninstall claude-switch
```

### Test .deb Package

```bash
# 1. Build local
mkdir -p deb-build/claude-switch_1.5.2/{DEBIAN,usr/local/bin}
cp claude-switch deb-build/claude-switch_1.5.2/usr/local/bin/
chmod 755 deb-build/claude-switch_1.5.2/usr/local/bin/claude-switch

cat > deb-build/claude-switch_1.5.2/DEBIAN/control << 'EOF'
Package: claude-switch
Version: 1.5.2
Section: utils
Priority: optional
Architecture: all
Depends: netcat
Maintainer: Test <test@example.com>
Description: Test package
 Multi-provider switcher for Claude Code CLI
EOF

dpkg-deb --build deb-build/claude-switch_1.5.2

# 2. Vérifier le package
dpkg-deb -I claude-switch_1.5.2.deb
dpkg-deb -c claude-switch_1.5.2.deb

# 3. Tester installation
sudo dpkg -i claude-switch_1.5.2.deb

# 4. Vérifier
which claude-switch
claude-switch --version

# 5. Désinstaller
sudo dpkg -r claude-switch
```

### Test .rpm Package

```bash
# 1. Install rpmbuild (si pas déjà fait)
brew install rpm  # macOS
# ou
sudo apt-get install rpm  # Ubuntu

# 2. Build
mkdir -p rpm-build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cat > rpm-build/SPECS/claude-switch.spec << 'EOF'
Name:           claude-switch
Version:        1.5.2
Release:        1
Summary:        Multi-provider switcher
License:        MIT
URL:            https://github.com/FlorianBruniaux/cc-copilot-bridge
Source0:        %{name}-%{version}.tar.gz
Requires:       nmap-ncat
%global debug_package %{nil}

%description
Multi-provider switcher for Claude Code CLI

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_bindir}
install -m 755 claude-switch %{buildroot}%{_bindir}/

%files
%{_bindir}/claude-switch
EOF

# Create tarball
tar czf rpm-build/SOURCES/claude-switch-1.5.2.tar.gz \
  --transform "s,^,claude-switch-1.5.2/," \
  claude-switch

# Build
rpmbuild --define "_topdir $(pwd)/rpm-build" -ba rpm-build/SPECS/claude-switch.spec

# 3. Vérifier
rpm -qpl rpm-build/RPMS/*/claude-switch-*.rpm

# 4. Tester (sur système RPM)
sudo rpm -i rpm-build/RPMS/*/claude-switch-*.rpm
```

---

## Publier une Release

### Processus Complet

**1. Préparer le code**
```bash
# S'assurer que tout est commit
git status

# Vérifier la version dans claude-switch
grep "Version:" claude-switch
# Version: 1.5.2

# Vérifier Formula/cc-copilot-bridge.rb
grep "version" Formula/cc-copilot-bridge.rb
# version "1.5.2"
```

**2. Créer le tag**
```bash
# Créer tag annoté
git tag -a v1.5.2 -m "Release v1.5.2: Package managers support"

# Vérifier
git tag -l -n9 v1.5.2

# Push le tag (déclenche GitHub Actions)
git push origin v1.5.2
```

**3. GitHub Actions Build**

Le workflow démarre automatiquement :
- Compute SHA256
- Build .deb
- Build .rpm
- Update Formula
- Create Release

**Suivre la progression** :
- Aller sur GitHub → Actions
- Voir le workflow "Build Packages"
- Attendre ~5-10 minutes

**4. Vérifier la Release**

Sur GitHub → Releases :
- ✅ Tag: v1.5.2
- ✅ Assets:
  - `claude-switch_1.5.2.deb`
  - `claude-switch-1.5.2-1.noarch.rpm`
  - `cc-copilot-bridge.rb`
  - Source code (zip)
  - Source code (tar.gz)

**5. Mettre à jour le Homebrew Tap**

Le workflow commit automatiquement la Formula mise à jour.

**Vérifier** :
```bash
git pull origin main
cat Formula/cc-copilot-bridge.rb | grep sha256
# sha256 "abc123..."  (plus PLACEHOLDER)
```

**Copier vers homebrew-tap** :
```bash
cd ../homebrew-tap
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/
git add Formula/cc-copilot-bridge.rb
git commit -m "Update claude-switch to v1.5.2"
git push
```

**6. Tester l'installation**

**Homebrew** :
```bash
brew update
brew upgrade claude-switch
# ou si pas encore installé
brew install cc-copilot-bridge
```

**Debian** :
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch_1.5.2.deb
sudo dpkg -i claude-switch_1.5.2.deb
```

**Fedora** :
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch-1.5.2-1.noarch.rpm
sudo dnf install claude-switch-1.5.2-1.noarch.rpm
```

**7. Annoncer la Release**

- Update README.md badges (si applicable)
- Tweet/post sur réseaux sociaux
- Notify users (mailing list, Discord, etc.)

---

## Troubleshooting

### Homebrew Formula SHA256 Mismatch

**Symptôme** :
```
Error: SHA256 mismatch
Expected: abc123...
Actual:   def456...
```

**Solution** :
```bash
# Recalculer le SHA256
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz
sha256sum v1.5.2.tar.gz

# Mettre à jour Formula
sed -i 's/sha256 ".*"/sha256 "NEW_SHA256"/' Formula/cc-copilot-bridge.rb

# Commit et push
git add Formula/cc-copilot-bridge.rb
git commit -m "Fix SHA256 checksum"
git push
```

### .deb Installation Fails

**Symptôme** :
```
dpkg: dependency problems prevent configuration of claude-switch:
 claude-switch depends on netcat; however:
  Package netcat is not installed.
```

**Solution** :
```bash
sudo apt-get install -f
# Installe les dépendances manquantes
```

### .rpm Build Fails

**Symptôme** :
```
error: File /root/rpmbuild/SOURCES/claude-switch-1.5.2.tar.gz: No such file or directory
```

**Solution** :
```bash
# Vérifier que le tarball existe
ls rpm-build/SOURCES/

# Recréer si nécessaire
tar czf rpm-build/SOURCES/claude-switch-1.5.2.tar.gz \
  --transform "s,^,claude-switch-1.5.2/," \
  claude-switch README.md docs
```

### GitHub Actions Permission Denied

**Symptôme** :
```
remote: Permission to FlorianBruniaux/cc-copilot-bridge.git denied
```

**Solution** :
1. Settings → Actions → General
2. Workflow permissions → "Read and write permissions"
3. ✅ "Allow GitHub Actions to create and approve pull requests"

---

## Prochaines Étapes

### Distribution Officielle

Une fois le projet stable, contacter les mainteneurs :

**Homebrew Core** :
- Plus besoin de `brew tap`
- `brew install cc-copilot-bridge` directement
- Processus : https://docs.brew.sh/Adding-Software-to-Homebrew

**Debian Official Repos** :
- Disponible via `apt install claude-switch`
- Processus : https://wiki.debian.org/DebianMentorsFaq

**Fedora/EPEL** :
- Disponible via `dnf install claude-switch`
- Processus : https://docs.fedoraproject.org/en-US/package-maintainers/

### Autres Package Managers

**Arch Linux (AUR)** :
```bash
# PKGBUILD
pkgname=claude-switch
pkgver=1.5.2
...
```

**Nix/NixOS** :
```nix
# default.nix
{ stdenv, fetchFromGitHub, netcat }:
stdenv.mkDerivation {
  pname = "claude-switch";
  version = "1.5.2";
  ...
}
```

**Chocolatey (Windows)** :
```powershell
# claude-switch.nuspec
<?xml version="1.0"?>
<package>
  <metadata>
    <id>claude-switch</id>
    <version>1.5.2</version>
    ...
  </metadata>
</package>
```

---

## Ressources

### Documentation Officielle

- **Homebrew** : https://docs.brew.sh/Formula-Cookbook
- **Debian** : https://www.debian.org/doc/manuals/maint-guide/
- **RPM** : https://rpm-packaging-guide.github.io/
- **GitHub Actions** : https://docs.github.com/en/actions

### Outils Utiles

- **Homebrew Formula Linter** : `brew audit --strict Formula/cc-copilot-bridge.rb`
- **Debian Linter** : `lintian claude-switch_1.5.2.deb`
- **RPM Linter** : `rpmlint claude-switch-1.5.2-1.noarch.rpm`
- **GitHub Actions Validator** : https://rhysd.github.io/actionlint/

### Exemples de Projets

- **fzf** : https://github.com/junegunn/fzf (Homebrew + .deb + .rpm)
- **ripgrep** : https://github.com/BurntSushi/ripgrep (Multi-platform)
- **bat** : https://github.com/sharkdp/bat (Package managers)
