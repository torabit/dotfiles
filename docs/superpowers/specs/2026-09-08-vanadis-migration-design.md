# wsl ブランチを vanadis へ移す

配色の生成を自作の `build/render.mjs` から [vanadis](https://github.com/torabit/vanadis) へ
移す。`origin/darwin` と `origin/linux` は済んでいる。wsl だけが旧来の
`palette.json` + `justfile` のまま残っている。

同時に 2 つを vanadis 管理下へ入れる。Claude Code のカスタムテーマ (dotclaude)、
および Rio の配色。

## 現状

wsl ブランチの仕組み。

```
palette.json                  色の値
build/render.mjs              リポジトリ内の *.in を走査し、兄弟パスへ書く
justfile                      just build / check / test
<pkg>/.../<file>.in           テンプレート。ツールが読むディレクトリに置く
<pkg>/.../<file>              生成物。コミットして stow する
```

生成物がコミットされているので、stow するだけで色が付く。テーマの切り替えは
できない。`palette.json` を書き換えて `just build` する以外の道が無い。

linux / darwin の仕組み。

```
vanadis/.config/vanadis/config.toml     [auto] [cycle] [[targets]]
vanadis/.config/vanadis/templates/      テンプレート
vanadis/.config/vanadis/themes/*.toml   パレット
~/.config/<tool>/...                    vanadis が書く。stow しない。追跡しない
~/.local/state/vanadis/state.toml       適用中のテーマ
```

生成物がリポジトリから消える。テーマを切り替えても diff が出ない。

## 決めること

wsl 固有の事情が 3 つある。linux / darwin の移行では答えが出ていない。

1. Rio は Windows ネイティブアプリで、Windows 側のファイルを読む。symlink では
   繋げない (`rio/sync.sh` が書いている VHD の理由)
2. `herdr/bin/host-colors.py` は wsl だけが持つ。生成物であり、かつ herdr が
   実行するスクリプト
3. dotclaude は別リポジトリ。テーマ本体をどちらが持つか

## 前提

vanadis v0.3.5 を crates.io から入れた。`apply` / `check` / `cycle` / `render` /
`init` / `import` が揃っている。

`reload` の実行は `Command::new(program).args(arguments)` (`src/apply.rs:483`)。
shell を通さず、`~` も `$VAR` も展開しない。書けるのは PATH 上の名前か絶対パス。

Rio の設定監視は `%LOCALAPPDATA%\rio` を `RecursiveMode::NonRecursive` で見る
(`frontends/rioterm/src/watcher.rs:28`)。`themes/` の中を書いても発火しない。
直下の `config.toml` を置き直すと発火し、その再読み込みで `theme` が指す theme
ファイルも読み直される (`rio-backend/src/config/mod.rs:420`)。

Rio の `Colors` は全フィールドに serde の `default` を持つ
(`rio-vt/src/config/colors/mod.rs:97`)。theme ファイルに書くのは設定するキーだけで
よい。theme ファイルが差し替えるのは `colors` だけで、それ以外の設定には触らない
(`rio-backend/src/config/theme.rs:19`)。

## 設計

### vanadis パッケージ

`origin/linux` の `vanadis/.config/vanadis/` を土台にする。wsl の `.in` と linux 版の
差は 9 ファイルで 128 行しかない。内訳は 4 種類。

- ヘッダコメントの「編集は〜を直す」の参照先 (全ファイル)
- 固定名だったものが token になっている (`{{meta.id}}` `{{meta.name}}`
  `{{meta.variant}}` `{{text.*}}`)
- `role.comment` を読んでいた箇所が `role.inactive` になっている (btop の
  `inactive_fg`、lazygit の `inactiveBorderColor`)
- wsl 固有の設定と、linux 側で増えた hunk の設定

前の 3 つは linux 版が正しい。最後の 1 つだけ内容を突き合わせる。linux 版を土台に、
wsl 固有の中身を移す。

target は 12 個。linux の 10 個に `herdr-host-colors` と `rio` を足す。darwin だけが
持つ ghostty は入らない。

| target | output | reload |
| --- | --- | --- |
| bat | `~/.config/bat/themes/vanadis.tmTheme` | `bat cache --build` |
| btop | `~/.config/btop/themes/vanadis.theme` | — |
| claude | `~/.claude/themes/vanadis.json` | — |
| herdr | `~/.config/herdr/config.toml` | `herdr server reload-config` |
| herdr-thumbs | `~/.config/herdr/plugins/config/sd2k.thumbs/config.env` | — |
| herdr-host-colors | `~/.config/herdr/bin/host-colors.py` | — |
| hunk | `~/.config/hunk/config.toml` | — |
| lazygit | `~/.config/lazygit/theme.yml` | — |
| nvim | `~/.config/nvim/lua/palette.lua` | — |
| rio | `~/.config/rio/themes/vanadis.toml` | `rio-sync` |
| starship | `~/.config/starship.toml` | — |
| zsh | `~/.config/zsh/palette.zsh` | — |

テーマは `papercolor-light.toml` と `papercolor-dark.toml` を linux から取る。
どちらも core vocabulary の 33 トークン (`[role]` 17 と `[ansi]` 16) を満たしている。
テンプレートが読む `colors.purple` / `brown` / `slate`、`[diff]` の 4 つ、`[text]` の
3 つも両方が持つ。

### wsl 固有として保持するもの

herdr のテンプレートに移すもの。

- `[[keys.command]]` の `alt+v`。clip-image のパスを pane へ挿入する
- `[experimental] kitty_graphics = true`
- `onboarding = false`。作業ツリーで生成物へ直接書かれている。テンプレートへ移す

`host-colors.py` は shebang を持つが実行権限は無い (0644)。`.zshrc` の `herdr` 関数が
`python3 <path>` で呼ぶので要らない。vanadis は「出力は既にある mode を保つ。新規
作成時はテンプレートの mode を取る」と決めているので (`docs/config.md` の Output)、
テンプレートを 0644 で置けばそのまま維持される。

移行の副産物として `herdr/.config/herdr/bin/__pycache__/` が消える。今それが
リポジトリの中にあるのは、`~/.config/herdr/bin/host-colors.py` がリポジトリを指す
symlink で、python がその隣にキャッシュを書いたため。apply 後は実体が
`~/.config/herdr/bin/` にあるので、キャッシュもそこへ落ちる。未追跡のまま残って
いるので削除する。

hunk は linux に揃える。`menu_bar` / `agent_notes` / `copy_decorations` が増える。

### Rio

`rio/config.toml` を手書きに戻す。hex をゼロにし、`theme = "vanadis"` を足す。色は
theme ファイルだけを生成する。darwin の ghostty と同じ形。

`[colors]` ブロックをそのまま `templates/rio/theme.toml.in` へ移す。theme ファイルが
差し替えるのは `colors` だけなので、fonts / bindings / hints は config.toml 側に
残って影響を受けない。

`rio/sync.sh` を `bin/.local/bin/rio-sync` へ移す。理由は 2 つ。`reload` に書けるのは
PATH 上の名前か絶対パスだけで、追跡するファイルに `/home/torabit/...` を埋めたく
ない。そして `clip-image` と同じ `bin` パッケージに揃う。

`rio-sync` は自分の実体を `readlink -f` で辿ってリポジトリを特定する。stow の symlink
経由でも直接でも動く。送るのは 2 ファイル。

```
~/.config/rio/themes/vanadis.toml  ->  %LOCALAPPDATA%\rio\themes\vanadis.toml
<repo>/rio/config.toml             ->  %LOCALAPPDATA%\rio\config.toml
```

theme を先に置く。順序が逆だと Rio が theme の無い状態で config を読み、
`failed to load theme` を出す。config.toml を後に置くことが監視の発火も兼ねる。

これで `vanadis cycle` から Rio までが繋がる。theme 再生成 → `rio-sync` → Windows 側
2 ファイル更新 → Rio が直下の config.toml の変更を検知 → 再読み込みで theme も読む。

`vanadis check` が見るのは WSL 側の `~/.config/rio/themes/vanadis.toml`。Windows 側の
コピーは範囲外。`rio-sync` が `diff -q` で照合する。

### dotclaude

`claude/.claude/settings.json` の `"theme": "light"` を `"custom:vanadis"` にする。
テーマ本体は dotfiles 側の `templates/claude/vanadis.json.in` が
`~/.claude/themes/vanadis.json` へ生成する。

Claude Code はカスタムテーマを `~/.claude/themes/<slug>.json` から読み、slug は
ファイル名である。ファイル名を `vanadis` に固定すればテーマを切り替えても
settings.json は動かない。dotclaude に差分が出ない。

dotclaude が `--no-folding` で stow されているので、`~/.claude/themes/` を stow 管理外の
ディレクトリとして共存させられる。

linux ブランチの dotclaude も `"light"` のままだが、このブランチでは触らない。

### 消すもの

| 対象 | 理由 |
| --- | --- |
| `justfile`, `build/`, `palette.json` | 旧レンダラ |
| 全 `.in` とその生成物 | vanadis パッケージへ移る |
| `bat/`, `hunk/`, `starship/` | config 全体が生成物。stow する対象が残らない |

`btop` は `btop.conf` が残るのでパッケージは消えない。`color_theme` を `vanadis` に
直す。`herdr` は `bin/confirm-close` と workspace-manager の `config.yml` が残る。
`lazygit` は `config.yml`、`neovim` と `zsh` は手書き分が残る。

### 追随して直すもの

| ファイル | 変更 |
| --- | --- |
| `zsh/.zshrc` | `BAT_THEME='PaperColor-Light'` → `'vanadis'` |
| `btop/.config/btop/btop.conf` | `color_theme = "vanadis"` |
| `neovim/.../plugins/colorscheme.lua` | `&background` と `:colorscheme` を palette 経由にする |
| `mise/.config/mise/config.toml` | `"cargo:vanadis" = "latest"` を追加 |
| `.gitignore` | リポジトリに来なくなる state とログの行を削る |
| `README.md` | vanadis の導入手順。stow から `--ignore` を外す。rio 節 |
| `docs/COLORS.md` | linux 版を土台に rio と host-colors を加えて書き換え |

`colorscheme.lua` は `vim.opt.background = "light"` と
`vim.cmd.colorscheme("PaperColor")` を直接書いていた。どちらもテーマに追随すべき値
なので、`palette.lua` に `variant = "{{meta.variant}}"` と
`colorscheme = "{{text.nvim-colorscheme}}"` を足してそこから読む。`{{text.*}}` に
置くのは、テーマを PaperColor 以外へ替えたときに colorscheme 名も一緒に動く必要が
あるため。両テーマの値が今は同じ `PaperColor` なのは、PaperColor が 1 つの
colorscheme で `&background` により light / dark を切り替えるから。

`plugins/init.lua` の `packadd("papercolor-theme")` は残す。プラグインの導入であって
テーマの選択ではない。別系統のテーマを足すときはここにも `packadd` が要る。トークン
では解決できない。

vanadis は prebuilt binary も Homebrew tap も未公開なので mise の cargo backend に
置く。

stow から `--ignore='\.in$'` を外す。`.in` が vanadis パッケージにしか無くなり、
そこはリンクする対象である。

`.zshrc:123` は `[ -s ... ] && source` で palette.zsh を読むので、apply 前でも落ちない。

## 検証

順序が本質である。今コミットされている生成物は旧レンダラの出力で、動くことが
分かっている。**それを消す前に** 新テンプレートの出力と照合する。一致すれば移行が
無損失だと言える。

1. vanadis パッケージを置いて stow する
2. `vanadis check papercolor-light --only <target>` を target ごとに clean にする
3. `vanadis check papercolor-dark` で core vocabulary の欠けを潰す
4. `vanadis apply papercolor-light --diff` が空になることを確認する。ここが移行の
   無損失性の証明
5. 旧生成物と旧レンダラを削除し、`vanadis apply papercolor-light` を実行する
6. herdr / bat / btop / nvim / hunk / lazygit / starship / fzf / rio を目視する
7. `vanadis cycle` で dark へ往復する
8. 手書きファイルに hex が残っていないか grep する

手順 4 で差分が出るのは、テンプレートが間違っているか、旧生成物が手編集されている
かのどちらかである。`onboarding = false` は後者として既に見つかっている。

```bash
grep -rnIE '#[0-9a-fA-F]{6}' . --exclude-dir=.git --exclude-dir=vanadis
```

`vanadis/` はテンプレートとテーマなので hex を持つのが正しい。

## 実装で判明したこと

### stow が 8 パッケージを折り畳んでいた

`vanadis apply --dry-run` の 1 行目がこれを名指しした。

```
bat: /home/torabit/.config/bat/themes/vanadis.tmTheme resolves to /home/torabit/ghq/github.com/torabit/dotfiles/bat/.config/bat/themes/vanadis.tmTheme
```

`bat` / `btop` / `herdr` / `hunk` / `lazygit` / `nvim` / `git` / `mise` の 8 つが
`--no-folding` 無しで張られており、`~/.config/<tool>` がリポジトリを指す symlink に
なっていた。前の 6 つは vanadis の出力先を含むので、そのまま apply するとリポジトリの
追跡ファイルが書き換わる。全パッケージを張り直した。

これは移行の前提条件であって設計の一部ではない。ただし `docs/COLORS.md` に検出方法と
直し方を書いた。同じことが次のツール追加でも起きる。

### 折り畳みでリポジトリにランタイムファイルが溜まっていた

`~/.config/herdr` と `~/.config/hunk` がリポジトリを指していたため、herdr のログ・
`session.json`・`plugins.json`・`.plugins.lock`・socket・インストール済みプラグインの
git clone、hunk の `state.json` がすべてリポジトリの中に落ちていた。旧 `.gitignore` の
7 行はこれを無視するためのものだった。

stow は `.gitignore` を読まないので、張り直すとこれらもリンク対象になる。実体を
`~/.config/` 側へ移してから張り直した。`--no-folding` で張っている限り再発しないので、
`.gitignore` の該当行は削除した。

### herdr の reload は失敗する

`herdr server reload-config` が `server_not_running` で落ちる。このマシンの herdr は
`hr` alias で ssh 先の server に繋いでおり、ローカルに server が居ない。vanadis は
reload の失敗を報告して残りの target を続けるので、生成物はすべて書かれる。設計上の
問題ではない。

## 却下した案

**Rio の config 全文を生成する。** 今の `config.toml.in` の形を保ち、output を
`~/.config/rio/config.toml` にして `rio-sync` がそこから送る。fonts の
`additional-dirs`、bindings、hints、タブタイトルの根拠コメントまでが vanadis の
templates に入る。色以外を触るたびに vanadis のディレクトリを開くことになる。
darwin の ghostty が既に分割を選んでいる。

**Rio の output に Windows 側のパスを直接書く。**
`/mnt/c/Users/rai-t/AppData/Local/rio/themes/vanadis.toml`。`reload` が要らなくなる
代わりに、`sync.sh` が意図的に避けているユーザ名のハードコードを追跡する config へ
持ち込む。加えて Rio の監視は `themes/` の中で発火しないので、結局 config.toml を
置き直す何かが要る。`reload` は消えない。

**`reload` に絶対パスを書き、`rio/sync.sh` を今の場所に残す。**
`/home/torabit/ghq/github.com/torabit/dotfiles/rio/sync.sh`。ファイルの移動が要らない。
追跡する config に home のパスが入る。`bin` パッケージが既にあるので、PATH 上の名前で
書ける道がある。

**旧レンダラを残して併走させる。** vanadis パッケージを足すが `justfile` と
`build/` と `palette.json` を消さない。色の真実の出どころが 2 つになる。どちらを
直したか分からなくなり、`vanadis check` と `just check` が別々に答える。

**dotclaude 側にテーマ本体を置く。** `claude/.claude/themes/vanadis.json` を
dotclaude が持ち、dotfiles の vanadis がそこへ書く。output がリポジトリの中に
解決してはいけないという制約に反する。vanadis は生成物を rename で被せるので、
dotclaude の追跡ファイルが書き換わる。
