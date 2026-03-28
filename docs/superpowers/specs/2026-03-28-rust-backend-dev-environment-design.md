# Rust Backend Development Environment Design

## Overview

Axum + sqlx + REST ベースの Rust バックエンド開発環境を dotfiles に追加する。
Brewfile、mise、Neovim プラグイン/設定の 3 層で構成。

## Scope

- Brewfile: Rust 開発用 brew パッケージと cargo ツール追加
- mise: Rust ランタイム管理
- Neovim: rustaceanvim、crates.nvim、neotest-rust 追加 + 関連設定

## 1. Brewfile 変更

### 追加するパッケージ

```ruby
# Rust development
brew "rust-analyzer"   # LSP server
brew "just"            # Command runner (modern Make)
brew "hyperfine"       # CLI benchmarking
brew "sccache"         # Compilation cache
```

### 既に存在するため追加不要

- `protobuf` (L51)
- `bufbuild/buf/buf` (L48)
- `typos-cli` (L35)

### cargo セクションに追加

```ruby
# Rust development tools
cargo "bacon"                # Background compiler (cargo-watch successor)
cargo "cargo-nextest"        # Next-gen test runner
cargo "cargo-binstall"       # Fast binary install from GitHub releases
cargo "sqlx-cli"             # SQLx migrations & query checking
cargo "cargo-deny"           # License/security/duplicate check
cargo "cargo-audit"          # Security vulnerability scanner
cargo "cargo-machete"        # Unused dependency detection
cargo "cargo-expand"         # Macro expansion viewer
cargo "cargo-bloat"          # Binary size analysis
cargo "cargo-llvm-lines"     # Generic code bloat analysis
cargo "cargo-show-asm"       # Assembly output viewer
cargo "cargo-modules"        # Module structure visualization
cargo "cargo-llvm-cov"       # LLVM-based code coverage
cargo "cargo-insta"          # Snapshot testing
cargo "flamegraph"           # CPU flamegraph generation
cargo "cargo-semver-checks"  # Semver violation detection
cargo "cargo-dist"           # Multi-platform release builds
cargo "cargo-release"        # Release automation
cargo "cargo-chef"           # Docker build optimization
```

### mise との棲み分け

- Rust ランタイム (`rust` toolchain) → mise で管理
- cargo ツール → Brewfile の `cargo` セクションで管理（既存パターンに合わせる）
- brew パッケージ → Brewfile の `brew` セクション

## 2. mise 変更

`mise/.config/mise/config.toml` に追加:

```toml
rust = "1.85.0"
```

`idiomatic_version_file_enable_tools` に `"rust"` を追加:

```toml
idiomatic_version_file_enable_tools = ["node", "ruby", "rust"]
```

## 3. Neovim プラグイン追加

### `lua/plugins/init.lua`

`vim.pack.add()` に追加:

```lua
-- Rust
{
    src = "https://github.com/mrcjkb/rustaceanvim",
    version = vim.version.range("5.*"),
},
"https://github.com/saecki/crates.nvim",
-- Testing (Rust adapter)
"https://github.com/rouge8/neotest-rust",
```

`packadd()` に追加:

```lua
packadd("rustaceanvim")
packadd("crates.nvim")
packadd("neotest-rust")
```

`require()` に追加:

```lua
require("plugins.rust")
```

### プラグイン一覧

| プラグイン | 役割 |
|-----------|------|
| rustaceanvim | rust-analyzer LSP 統合 + Rust 拡張機能（マクロ展開、Runnables、DAP 連携等） |
| crates.nvim | Cargo.toml 内バージョン情報インライン表示、補完、アップデート操作 |
| neotest-rust | neotest の Rust アダプター（cargo-nextest 統合、テストデバッグ対応） |

## 4. Neovim 設定ファイル変更

### 4a. 新規: `lua/plugins/rust.lua`

```lua
-- rustaceanvim configuration
-- NOTE: rustaceanvim manages rust-analyzer LSP internally.
-- Do NOT add rust_analyzer to lua/servers/ or vim.lsp.enable().
vim.g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                    extraArgs = { "--all-targets" },
                },
                cargo = {
                    allFeatures = true,
                    buildScripts = { enable = true },
                },
                procMacro = {
                    enable = true,
                    attributes = { enable = true },
                },
                diagnostics = {
                    enable = true,
                    experimental = { enable = true },
                },
                inlayHints = {
                    bindingModeHints = { enable = true },
                    chainingHints = { enable = true },
                    closingBraceHints = { enable = true },
                    closureReturnTypeHints = { enable = true },
                    lifetimeElisionHints = { enable = true },
                    parameterHints = { enable = true },
                    typeHints = { enable = true },
                },
            },
        },
    },
}

-- crates.nvim
require("crates").setup({
    lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
    },
})
```

### 4b. 変更: `lua/plugins/neotest.lua`

adapters に neotest-rust を追加:

```lua
adapters = {
    require("neotest-rspec"),
    require("neotest-rust")({
        args = { "--no-capture" },
        dap_adapter = "codelldb",
    }),
},
```

### 4c. 変更: `lua/plugins/conform.lua`

formatters_by_ft に追加:

```lua
rust = { "rustfmt" },
```

### 4d. 変更: `lua/plugins/treesitter.lua`

ensure_installed に追加:

```lua
"toml",
```

(`"rust"` は既に含まれている)

### 4e. DAP (codelldb)

mason.nvim 経由で `:MasonInstall codelldb` を手動実行。
rustaceanvim が codelldb を自動検出するため、`lua/plugins/dap.lua` への変更は不要。

## 5. ファイル変更サマリー

| ファイル | 操作 |
|---------|------|
| `Brewfile` | brew 4 行 + cargo 19 行追加 |
| `mise/.config/mise/config.toml` | rust ランタイム + settings 追加 |
| `neovim/.config/nvim/lua/plugins/init.lua` | プラグイン 3 個 + packadd 3 行 + require 1 行追加 |
| `neovim/.config/nvim/lua/plugins/rust.lua` | 新規作成 |
| `neovim/.config/nvim/lua/plugins/neotest.lua` | rust アダプター追加 |
| `neovim/.config/nvim/lua/plugins/conform.lua` | rustfmt 追加 |
| `neovim/.config/nvim/lua/plugins/treesitter.lua` | toml パーサー追加 |

## 6. 手動セットアップ手順

実装後に必要な手動操作:

1. `brew bundle` で Brewfile のパッケージをインストール
2. `mise install` で Rust ランタイムをインストール
3. Neovim 起動で vim.pack.add がプラグインをクローン
4. `:MasonInstall codelldb` でデバッガーをインストール
5. `:TSUpdate` で treesitter パーサー更新

## Design Decisions

- **rustaceanvim vs nvim-lspconfig**: rustaceanvim を採用。rust-analyzer の拡張機能（マクロ展開、Runnables、DAP 統合）をフル活用するため。servers/ への設定追加は不要。
- **cargo ツール管理**: Brewfile の `cargo` セクションで統一（既存の `tree-sitter-cli` パターンに合わせる）。mise の `cargo:` は使わない。
- **codelldb**: mason 経由で手動インストール。rustaceanvim が自動検出するため dap.lua への変更は最小限。
- **crates.nvim の補完**: blink.cmp との統合ではなく crates.nvim 自身の LSP 補完を使用。シンプルさ優先。
