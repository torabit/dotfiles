# WSL2 (Homebrew on Linux). macOS 固有は darwin ブランチ、
# ネイティブ Linux 固有は linux ブランチにある。

# Taps
tap "hashicorp/tap" # terraform は core から外れた

# CLI tools
brew "atuin"
brew "awscli"
brew "bat"
brew "btop"
brew "chafa" # 端末へ画像をインライン表示する
brew "direnv"
brew "dust"
brew "eza"
brew "fd"
brew "fzf"
brew "gh"
brew "ghq"
brew "git"
brew "git-delta"
brew "go"
brew "hub"
brew "hunk"
brew "jq"
brew "lazygit"
brew "mise"
brew "neovim"
brew "pre-commit"
brew "ripgrep"
brew "starship"
brew "stow"
brew "the_silver_searcher"
brew "tmux"
brew "tree"
# nvim-treesitter がパーサをビルドするのに必要。mise の aqua backend でも
# 取れるが GitHub API のトークンを要求するため、brew から入れる。
brew "tree-sitter-cli"
brew "typos-cli"
brew "unzip"
brew "wget"
brew "zoxide"
brew "zsh" # distro zsh is often outdated

# Zsh plugins
brew "zsh-autosuggestions"
brew "zsh-completions"
brew "zsh-fast-syntax-highlighting"

# Language tools
brew "rust-analyzer"
brew "just"
brew "hyperfine"
brew "sccache"
brew "lua-language-server"

# Infrastructure
brew "hashicorp/tap/terraform"
brew "kubernetes-cli"
brew "minikube"
brew "tailscale"

# ビルドツール。gcc は nvim-treesitter のパーサ生成に、pkgconf は
# cargo でビルドする sqlx-cli などが openssl-sys を通すのに必要。
brew "gcc"
brew "pkgconf"

# Runtimes: mise で管理する (~/.config/mise/config.toml)
#   node / ruby / rust / pnpm / bun と、npm 由来の yarn / prettierd / eslint_d は
#   ここには置かない。brew と二重に持つと PATH の解決順で brew 側が勝ち、
#   mise の固定が効かなくなる。

# Apps
cask "claude-code"

# クリップボードは Windows 側が持つ。WSL には X も Wayland も無いので
# wl-clipboard と xclip は入れない。/mnt/c/Tools/win32yank/win32yank.exe が
# nvim と zsh の橋渡しをする (.zshrc / nvim の options.lua を参照)。

# Go tools
go "golang.org/x/tools/gopls"
go "honnef.co/go/tools/cmd/staticcheck"
