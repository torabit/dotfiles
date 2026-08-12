# Linux (Homebrew on Linux). macOS-only entries live on the darwin branch.

# Taps
tap "bufbuild/buf"
tap "ktr0731/evans"

# CLI tools
brew "atuin"
brew "awscli"
brew "bat"
brew "btop"
brew "dust"
brew "eza"
brew "fd"
brew "fzf"
brew "gh"
brew "ghq"
brew "git"
brew "git-delta"
brew "go"
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
brew "bufbuild/buf/buf"
brew "ktr0731/evans/evans"
brew "protobuf"
brew "protolint"

# Runtimes: mise で管理する (~/.config/mise/config.toml)
#   node / ruby / rust / pnpm と、npm 由来の prettierd / eslint_d はここには置かない。
#   brew と二重に持つと PATH の解決順で brew 側が勝ち、mise の固定が効かなくなる。

# Services
brew "redis"

# Libraries (explicit dependencies)
brew "ffmpeg"
brew "vips"

# Apps
cask "claude-code"

# Clipboard bridge for nvim/tmux. Only needed with a GUI session;
# on headless boxes OSC 52 is used instead (see .tmux.conf / .zshrc).
# brew "wl-clipboard"
# brew "xclip"

# Go tools
go "golang.org/x/tools/gopls"
go "github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc"
go "honnef.co/go/tools/cmd/staticcheck"
