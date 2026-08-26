# tmux から herdr への移行 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** tmux と 6 つのプラグインを herdr 単体に置き換え、linux / wsl / darwin の 3 ブランチへ展開する。

**Architecture:** herdr の `config.toml` を `palette.json` から全文生成する (docs/COLORS.md の型 B)。tmux が pane の中身を見て分岐していた Alt+hjkl の判定は、herdr がその機能を持たないため nvim と zsh 側へ移し、`herdr pane focus --direction` を呼ぶ形に反転する。

**Tech Stack:** herdr 0.8.2 (Homebrew)、node の組み込みテストランナー、GNU Stow、zsh、Lua (Neovim)

**Spec:** `docs/superpowers/specs/2026-08-26-tmux-to-herdr-design.md`

## Global Constraints

- herdr のバージョンは 0.8.2。アクション名と設定キーは `herdr --default-config` の出力が正
- 色の hex は `palette.json` にしか書かない。テンプレートからは `{{role.x}}` `{{colors.x}}` で参照する
- 生成物 (`config.toml`) は直接編集しない。1 行目に「生成物。編集は config.toml.in を直す」を置く
- 常体で書く。コメントは理由を書き、値の言い換えを書かない
- コミットは Conventional Commits (`type(scope): 説明`)。scope は `herdr` `nvim` `zsh` `brew` `docs` など
- 作業ブランチは `linux`。wsl と darwin へは linux 完成後に展開する
- push は行わない。ユーザーが明示的に指示したときだけ push する

---

### Task 1: herdr の設定テンプレートを作りキーバインドを移す

**Files:**
- Create: `herdr/.config/herdr/config.toml.in`
- Generated: `herdr/.config/herdr/config.toml` (`just build` が書く)

**Interfaces:**
- Produces: stow 対象ディレクトリ `herdr/`。以降のタスクはこのファイルを追記で育てる

- [ ] **Step 1: 展開の基点にタグを打つ**

wsl と darwin へ cherry-pick する範囲を機械的に取れるようにする。仕様と計画のコミットは
展開しないので、その後ろに打つ。

```bash
git tag herdr-base
```

- [ ] **Step 2: テンプレートの骨格とキーバインドを書く**

`herdr/.config/herdr/config.toml.in` を作る。この段階では色を入れない。

```toml
# 生成物。編集は config.toml.in を直す。

[keys]
prefix = "ctrl+a"

# detach は tmux の prefix+d に合わせる。既定の prefix+q は使わない。
detach = "prefix+d"

# 分割の向きの呼び方が tmux と逆になっている。
# herdr の split_vertical は縦線で割る (tmux の split-window -h)。
split_vertical = "prefix+|"
split_horizontal = "prefix+minus"

# タブの並べ替え。既定では未設定。
move_tab_previous = "ctrl+shift+left"
move_tab_next = "ctrl+shift+right"

# resize mode に入らずに直接広げる。
resize_pane_left = "prefix+ctrl+h"
resize_pane_down = "prefix+ctrl+j"
resize_pane_up = "prefix+ctrl+k"
resize_pane_right = "prefix+ctrl+l"

# Alt+hjkl は意図的にバインドしない。herdr は pane の実行中コマンドを見て
# キーを分岐できず、未バインドのキーは PTY へ素通しされる。この性質を使い、
# 移動するか否かの判定を nvim と zsh 側へ移す。
```

- [ ] **Step 3: 生成して herdr に検証させる**

```bash
just build
mkdir -p ~/.config/herdr && cp herdr/.config/herdr/config.toml ~/.config/herdr/config.toml
herdr config check
```

Expected: 診断が出ずに通る。

`prefix+|` が拒否された場合は `split_vertical = "prefix+v"` (既定) に戻し、テンプレートに
理由をコメントで残す。判断は `herdr config check` の出力を根拠にする。

- [ ] **Step 4: 生成物とテンプレートの一致を確認する**

```bash
just check
```

Expected: 差分なしで終了する。

- [ ] **Step 5: コミット**

```bash
git add herdr
git commit -m "feat(herdr): tmux 相当のキーバインドを持つ設定を追加する"
```

---

### Task 2: 配色を palette.json から流す

**Files:**
- Modify: `herdr/.config/herdr/config.toml.in`

**Interfaces:**
- Consumes: Task 1 のテンプレート
- Produces: `[theme.custom]` の 19 トークンと `[ui] accent`

- [ ] **Step 1: テンプレートに配色を追記する**

`[keys]` セクションの後ろに置く。

```toml
# ── PaperColor Light ──────────────────────────────────────────
# 組み込みテーマは全て暗い。基底の上から全トークンを上書きする。
[theme.custom]
accent = "{{role.accent}}"
panel_bg = "{{role.bg}}"
sidebar_bg = "{{role.bg}}"
active_row_bg = "{{role.hover-bg}}"
selection_bg = "{{role.selection-bg}}"
surface0 = "{{role.hover-bg}}"
surface1 = "{{role.border}}"
surface_dim = "{{role.bg}}"
overlay0 = "{{role.comment}}"
overlay1 = "{{role.border}}"
text = "{{role.fg}}"
subtext0 = "{{role.comment}}"
mauve = "{{colors.purple}}"
green = "{{role.ok}}"
yellow = "{{colors.brown}}"
red = "{{role.error}}"
blue = "{{role.keyword}}"
teal = "{{role.accent-alt}}"
peach = "{{role.accent-warm}}"
```

`yellow` に `{{colors.lemon}}` を使わない。PaperColor Light の lemon は背景が明るい側では
読めない。`brown` が暗い黄として機能する。

- [ ] **Step 2: `[ui] accent` を追記する**

`[theme.custom].accent` とは別に、UI のハイライト色を持つキーがある。

```toml
[ui]
accent = "{{role.accent}}"
```

- [ ] **Step 3: 生成して検証する**

```bash
just build && herdr config check && just check
```

Expected: 3 つとも通る。`herdr config check` が未知のトークン名を報告した場合は、その行を
削除して報告された名前だけを残す。

- [ ] **Step 4: 手書きファイルに hex が漏れていないか確認する**

`docs/COLORS.md` のスウィープを走らせる。

```bash
GEN=$(git ls-files | grep '\.in$' | sed 's/\.in$//')
EXCL=$(printf '%s\n' $GEN | sed 's#^#^#; s#$#$#' | paste -sd'|')
grep -rnIE '#[0-9a-fA-F]{6}' \
  $(git ls-files | grep -vE "\.in$|^palette\.json$|^docs/|^build/|$EXCL") \
  || echo "なし"
```

Expected: 「なし」と出る。

- [ ] **Step 5: コミット**

```bash
git add herdr
git commit -m "feat(herdr): 配色を palette.json から生成する"
```

---

### Task 3: tab bar と残りの UI を設定する

**Files:**
- Modify: `herdr/.config/herdr/config.toml.in`

**Interfaces:**
- Consumes: Task 2 のテンプレート
- Produces: 完成した `config.toml.in`

- [ ] **Step 1: tab bar と window title を追記する**

tmux の `prefix+g` (lazygit の popup) は移さない。使用頻度が低く、nvim が `<C-\>` に
フローティングターミナルを持っているのでそこから起動すれば足りる。linux と darwin では
`[[keys.command]]` を 1 つも書かない。

`[ui]` セクション (Task 2 で `accent` を書いた場所) に足す。

```toml
tab_bar_right = [{ type = "datetime", format = "%H:%M" }]
tab_bar_right_separator = " "

# git branch は tab_bar_right に置かない。command エントリは herdr サーバ側で
# 解決されるためフォーカス中 pane の作業ディレクトリを見られない。sidebar の
# spaces 行が組み込みトークン branch で既定から表示している。

window_title = "{workspace} {tab} @{hostname}"

# tmux では bind c が即座に window を作っていた。名前の入力を挟まない。
prompt_new_tab_name = false
```

- [ ] **Step 2: session と experimental を追記する**

```toml
[session]
resume_agents_on_restore = true

[experimental]
# img alias は chafa -f symbols で文字として描くため画像プロトコルを使わない。
# 外側の端末が kitty graphics を実装したら有効にする。
kitty_graphics = false
```

既定のままで足りるものは書かない。`mouse_capture` と `copy_on_select` は既定 true で
tmux の `set -g mouse on` を満たす。copy mode は既定で vi 風に動く。

- [ ] **Step 3: 生成して検証する**

```bash
just build && herdr config check && just check
```

Expected: 3 つとも通る。

- [ ] **Step 4: コミット**

```bash
git add herdr
git commit -m "feat(herdr): tab bar と永続化を設定する"
```

---

### Task 4: nvim の pane 移動を herdr 呼び出しに反転する

**Files:**
- Modify: `neovim/.config/nvim/lua/keymaps.lua:3`, `neovim/.config/nvim/lua/keymaps.lua:21-24`
- Modify: `neovim/.config/nvim/lua/plugins/init.lua:46-47`, `neovim/.config/nvim/lua/plugins/init.lua:106`
- Modify: `neovim/.config/nvim/nvim-pack-lock.json`

**Interfaces:**
- Consumes: Task 1 が Alt+hjkl をバインドしていないこと
- Produces: `<A-hjkl>` が nvim の split と herdr の pane を跨いで動く状態

- [ ] **Step 1: vim-tmux-navigator を外す**

`neovim/.config/nvim/lua/plugins/init.lua` から次の 2 行を消す。

```lua
	-- Tmux
	"https://github.com/christoomey/vim-tmux-navigator",
```

同ファイルの `packadd("vim-tmux-navigator")` の行も消す。

- [ ] **Step 2: keymaps.lua の 3 行目を消す**

```lua
vim.g.tmux_navigator_no_mappings = 1
```

このグローバル変数は vim-tmux-navigator が既定のマッピングを張るのを止めるためのもので、
プラグインが無ければ意味を持たない。

- [ ] **Step 3: `<A-hjkl>` を書き換える**

`keymaps.lua` の 21 行目から 24 行目を次に置き換える。

```lua
-- nvim の split 内で動けなければ herdr の pane へ抜ける。herdr は pane の
-- 実行中コマンドを見てキーを分岐できないので、判定をこちら側に持つ。
local herdr_direction = { h = "left", j = "down", k = "up", l = "right" }
local function nav(key)
	return function()
		local from = vim.fn.winnr()
		vim.cmd.wincmd(key)
		if vim.fn.winnr() == from then
			vim.system({ "herdr", "pane", "focus", "--direction", herdr_direction[key] })
		end
	end
end

for key, direction in pairs(herdr_direction) do
	vim.keymap.set("n", "<A-" .. key .. ">", nav(key), { desc = "Move to " .. direction .. " window or pane" })
end
```

- [ ] **Step 4: 動作を確認する**

herdr を起動し、pane を左右に割る。片方で nvim を開いて縦に split する。

```bash
herdr
```

Expected: nvim 内で `<A-l>` が右の split へ移り、右端でもう一度押すと右の herdr pane へ移る。
`<A-h>` で戻れる。

`herdr pane focus` が「pane を特定できない」と失敗する場合は `--current` を足す。

```lua
			vim.system({ "herdr", "pane", "focus", "--current", "--direction", herdr_direction[key] })
```

- [ ] **Step 5: lock を再生成する**

```bash
nvim --headless "+quitall"
git diff --stat neovim/.config/nvim/nvim-pack-lock.json
```

Expected: `vim-tmux-navigator` のエントリが消えた差分が出る。手で JSON を編集しない。

- [ ] **Step 6: コミット**

```bash
git add neovim
git commit -m "refactor(nvim): pane 移動の判定を herdr 呼び出しへ移す"
```

---

### Task 5: zsh の alias と Alt+hjkl を herdr に合わせる

**Files:**
- Modify: `zsh/.zshrc:96` (`tmuxs` alias)
- Modify: `zsh/.zshrc:97-104` (`clip`)
- Modify: `zsh/.zshenv:4-5` (lazygit のコメント)

**Interfaces:**
- Consumes: Task 1 が Alt+hjkl をバインドしていないこと
- Produces: シェル pane でも `<A-hjkl>` が動く状態

- [ ] **Step 1: `tmuxs` alias を差し替える**

`zsh/.zshrc` の該当行を置き換える。

```zsh
alias herdrs='herdr server reload-config'
```

- [ ] **Step 2: `clip` から tmux 分岐を消す**

```zsh
if (( $+commands[wl-copy] )); then
  alias clip='wl-copy'
elif (( $+commands[xclip] )); then
  alias clip='xclip -selection clipboard'
else
  # OSC 52: let the terminal emulator own the clipboard (works over SSH)
  clip() { printf '\e]52;c;%s\a' "$(base64 | tr -d '\n')" }
fi
```

herdr は `SSH_CONNECTION` と `SSH_TTY` と WSL を検出して OSC 52 を優先するので、herdr 側に
tmux の `set-clipboard on` に相当する設定は要らない。

- [ ] **Step 3: Alt+hjkl の zle widget を足す**

`zsh/.zshrc` の Key bindings セクション (`bindkey -M vicmd 'v' edit-command-line` の後) に置く。

```zsh
# herdr の pane 移動。herdr 側では Alt+hjkl をバインドせず、キーはここへ届く。
# nvim も同じ判定を自前で持つ (neovim/lua/keymaps.lua)。
if (( $+commands[herdr] )); then
  _herdr_focus_left()  { herdr pane focus --direction left  >/dev/null 2>&1 }
  _herdr_focus_down()  { herdr pane focus --direction down  >/dev/null 2>&1 }
  _herdr_focus_up()    { herdr pane focus --direction up    >/dev/null 2>&1 }
  _herdr_focus_right() { herdr pane focus --direction right >/dev/null 2>&1 }
  zle -N _herdr_focus_left
  zle -N _herdr_focus_down
  zle -N _herdr_focus_up
  zle -N _herdr_focus_right
  bindkey '^[h' _herdr_focus_left
  bindkey '^[j' _herdr_focus_down
  bindkey '^[k' _herdr_focus_up
  bindkey '^[l' _herdr_focus_right
fi
```

- [ ] **Step 4: `.zshenv` のコメントを直す**

`zsh/.zshenv` の 4 行目から 5 行目を置き換える。変数の置き場所は動かさない。

```zsh
# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
# 非ログイン非対話シェルから起動されても効くよう .zshrc ではなくここに置く。
```

- [ ] **Step 5: 動作を確認する**

```bash
exec zsh
```

herdr の中で pane を左右に割り、両方でシェルを開く。

Expected: `<A-l>` と `<A-h>` で pane を行き来できる。`clip` に文字列を流すと手元の
クリップボードに入る (ssh 越しなら OSC 52 経由)。

- [ ] **Step 6: コミット**

```bash
git add zsh
git commit -m "refactor(zsh): clip と pane 移動を herdr 前提にする"
```

---

### Task 6: tmux を消して周辺ファイルを揃える

**Files:**
- Delete: `tmux/.tmux.conf`, `tmux/.tmux.conf.in`
- Modify: `Brewfile:32`, `Brewfile:73-74`
- Modify: `docs/COLORS.md:35`, `docs/COLORS.md:50`, `docs/COLORS.md:78`, `docs/COLORS.md:90`

**Interfaces:**
- Consumes: Task 1 から Task 5 まで
- Produces: リポジトリから tmux への参照が消えた状態

- [ ] **Step 1: stow のリンクを外して tmux を消す**

```bash
stow -vD --ignore='\.in$' tmux
git rm -r tmux
```

先にリンクを外す。ファイルを消してから外すと `stow -D` が対象を見失う。

- [ ] **Step 2: Brewfile を差し替える**

`brew "tmux"` を `brew "herdr"` にする。行の並びはアルファベット順を保つ。

同ファイルのクリップボードに関するコメントの参照先を直す。

```ruby
# Clipboard bridge for nvim. Only needed with a GUI session;
# on headless boxes OSC 52 is used instead (see .zshrc).
```

- [ ] **Step 3: docs/COLORS.md を直す**

型 B の表の行を置き換える。

```markdown
| herdr | `.config/herdr/config.toml` |
```

反映表の行を置き換える。

```markdown
| herdr | `herdrs` alias (`herdr server reload-config`) |
```

「ツールを追加する」節の型 B の説明にある `tmux` を `herdr` にする。

「仕組み」節の tmux の例を herdr の例に差し替える。

```markdown
置換対象は二重波括弧 `{{token}}` だけである。herdr の `{workspace}` のような単一波括弧は
素通しする。
```

- [ ] **Step 4: tmux への参照が残っていないか確認する**

```bash
grep -rn 'tmux' --exclude-dir=.git --exclude-dir=docs/superpowers . || echo "なし"
```

Expected: 「なし」と出る。`docs/superpowers/` の仕様と計画は移行の記録なので残す。

- [ ] **Step 5: 生成物の整合を確認する**

```bash
just build && just check && just test
```

Expected: 3 つとも通る。tmux のテンプレートが消えても `render.mjs` はテンプレートを 1 つ以上
見つけられる。

- [ ] **Step 6: stow して herdr をリンクする**

```bash
stow -v --ignore='\.in$' herdr
ls -l ~/.config/herdr/config.toml
```

Expected: リポジトリ内のファイルへのシンボリックリンクになっている。Task 1 の Step 3 で
手動コピーしたファイルがあれば先に消す。

- [ ] **Step 7: コミット**

```bash
git add -A
git commit -m "chore: tmux を herdr に置き換える"
```

---

### Task 7: linux で実機確認する

**Files:** なし (確認のみ)

**Interfaces:**
- Consumes: Task 6 までの全て

- [ ] **Step 1: 起動して各項目を確認する**

```bash
herdr
```

次を順に確認する。落ちた項目は該当タスクへ戻る。

| 確認項目 | 期待 |
| --- | --- |
| `prefix+\|` と `prefix+-` | 縦割りと横割りができる |
| `<A-hjkl>` (シェル pane) | pane を跨いで移動する |
| `<A-hjkl>` (nvim pane) | split 内で動き、端で pane へ抜ける |
| `ctrl+shift+left/right` | タブが並べ替わる |
| tab bar 右端 | 時刻が出る |
| sidebar | ワークスペース名の下に git branch が出る |
| `prefix+d` して `herdr` | 元のレイアウトに復帰する |
| `echo hi \| clip` | 手元のクリップボードに入る |

- [ ] **Step 2: ssh 越しで確認する**

macOS または WSL から ssh でこの機体に入り、`herdr` を起動する。

Expected: `echo hi | clip` が手元のクリップボードに届く。`prefix+d` して再接続するとレイアウトが
戻る。

- [ ] **Step 3: 結果を報告する**

落ちた項目があれば、確認方法と観測結果と原因の 3 点を揃えて報告する。

---

### Task 8: wsl ブランチへ展開する

**Files:**
- Create: `herdr/.config/herdr/config.toml.in` (wsl 版)
- Modify: `zsh/.zshrc`, `zsh/.zshenv`, `Brewfile`, `docs/COLORS.md`, `neovim/.config/nvim/lua/keymaps.lua`, `neovim/.config/nvim/lua/plugins/init.lua`
- Delete: `tmux/`

**Interfaces:**
- Consumes: linux で確認済みの `config.toml.in`

- [ ] **Step 1: ブランチを切り替える**

```bash
git checkout -b wsl origin/wsl
```

- [ ] **Step 2: linux の変更を持ち込む**

```bash
git cherry-pick herdr-base..linux
```

`herdr-base` は Task 1 で打ったタグ。仕様と計画のコミットはこの範囲に入らない。
競合したら wsl 側の記述を優先して解決する。wsl の `.zshrc` は `clip` が win32yank 固定で、
linux の分岐と形が違う。`clip` の変更は取り込まない。

- [ ] **Step 3: clip-image の M-v を移す**

`herdr/.config/herdr/config.toml.in` に足す。

```toml
# WSL 固有: Windows のクリップボードの画像を ssh 先へ転送し、そのパスを
# 現在の pane へ挿入する。ssh 先のプロセスは Windows のクリップボードに
# 触れないため画像を直接貼れない。転送は WSL 側で走らせる必要がある。
[[keys.command]]
key = "alt+v"
type = "shell"
command = 'p=$(clip-image) && herdr pane send-text "$HERDR_PANE_ID" "$p"'
description = "clip-image のパスを挿入する"
```

`type = "shell"` は背景で走るので、転送に数秒かかっても入力を止めない。

- [ ] **Step 4: ssh バッジを tab bar に足す**

pane border の条件付き色分けは herdr では再現できない。status-left のバッジ側だけ残す。

```toml
tab_bar_right = [
  { type = "command", command = "~/.config/herdr/ssh-badge.sh", interval_seconds = 5, timeout_seconds = 2 },
  { type = "datetime", format = "%H:%M" },
]
```

`herdr/.config/herdr/ssh-badge.sh` を作る。色を持たないので `.in` にしない。

```sh
#!/bin/sh
# フォーカス中の pane で ssh が走っていれば SSH と出す。何も出さないときは空。
herdr pane list 2>/dev/null | grep -q 'focused.*ssh' && echo SSH
```

`herdr pane list` の出力形式を実機で確認し、grep のパターンを合わせる。形式が合わずバッジを
出せない場合はこの Step ごと落とし、その旨をコミットメッセージに書く。

- [ ] **Step 5: 検証する**

```bash
just build && herdr config check && just check
```

Expected: 3 つとも通る。実機での動作確認はこの環境からできない。

- [ ] **Step 6: コミット**

```bash
git add -A
git commit -m "chore: tmux を herdr に置き換える"
```

---

### Task 9: darwin ブランチへ展開する

**Files:**
- Create: `herdr/.config/herdr/config.toml.in` (darwin 版)
- Modify: `zsh/.zshrc`, `zsh/.zshenv`, `Brewfile`, `docs/COLORS.md`, `neovim/.config/nvim/lua/keymaps.lua`, `neovim/.config/nvim/lua/plugins/init.lua`
- Delete: `tmux/`

**Interfaces:**
- Consumes: linux で確認済みの `config.toml.in`

- [ ] **Step 1: ブランチを切り替える**

```bash
git checkout -b darwin origin/darwin
```

- [ ] **Step 2: linux の変更を持ち込む**

```bash
git cherry-pick herdr-base..linux
```

darwin の `.zshrc` は `clip` を持たず `pbcopy` を直接使う。`clip` の変更は取り込まない。

- [ ] **Step 3: darwin 固有の差を反映する**

`[experimental] kitty_graphics` のコメントから ssh の記述を消す。darwin はローカル端末なので
tmux でも `allow-passthrough` を持っていなかった。

```toml
[experimental]
# img alias は chafa -f symbols で文字として描くため画像プロトコルを使わない。
kitty_graphics = false
```

`[terminal] shell_mode` は既定の `"auto"` のままにする。macOS ではログインシェルになる。

- [ ] **Step 4: 検証する**

```bash
just build && just check
```

Expected: 2 つとも通る。`herdr config check` と実機確認はこの環境からできない。

- [ ] **Step 5: コミット**

```bash
git add -A
git commit -m "chore: tmux を herdr に置き換える"
```

---

## 完了条件

- 3 ブランチとも `just check` と `just test` が通る
- linux は Task 7 の確認表が全て通っている
- リポジトリに tmux への参照が残っていない (`docs/superpowers/` の記録を除く)
- push はしていない
