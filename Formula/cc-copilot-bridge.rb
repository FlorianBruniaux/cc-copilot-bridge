class CcCopilotBridge < Formula
  desc "Multi-provider switcher for Claude Code CLI"
  homepage "https://github.com/FlorianBruniaux/cc-copilot-bridge"
  url "https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.3-test3/cc-copilot-bridge-1.5.3-test3.tar.gz"
  sha256 "d591b8f0780bad18beab417f3036ae71c0c87919f93006d6bb3d79ac5b07e0e2"  # Will be computed by GitHub Actions
  license "MIT"
  version "1.5.3-test3"

  depends_on "netcat"

  # Optional dependencies
  depends_on "ollama" => :optional
  depends_on "node" => :optional  # For copilot-api

  def install
    bin.install "claude-switch"

    # Create log directory
    (var/"log/claude-switch").mkpath

    # Install docs
    doc.install "README.md" if File.exist?("README.md")
    doc.install "QUICKSTART.md" if File.exist?("QUICKSTART.md")
    doc.install Dir["docs/*"] if Dir.exist?("docs")
  end

  def caveats
    <<~EOS
      To enable shell aliases, add to your ~/.zshrc or ~/.bashrc:

        eval "$(claude-switch --shell-config)"

      Or test it first:

        source <(claude-switch --shell-config)

      For more integration options:
        https://github.com/FlorianBruniaux/cc-copilot-bridge/blob/main/docs/INSTALL-OPTIONS.md

      Logs are stored in:
        #{var}/log/claude-switch/claude-switch.log
    EOS
  end

  test do
    assert_match(/claude-switch v\d+\.\d+/, shell_output("#{bin}/claude-switch --version"))
    assert_match "alias ccd=", shell_output("#{bin}/claude-switch --shell-config")
  end
end
