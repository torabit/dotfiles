# tmux から herdr への移行

## 目的

tmux と 6 つのプラグイン (tpm, sensible, resurrect, continuum, thumbs, agent-sidebar) の組み合わせを
herdr 単体に置き換える。herdr はエージェントの状態表示とセッション永続化をネイティブに持つため、
現在プラグインで補っている機能の大半が設定なしで手に入る。

対象は `linux`、`wsl`、`darwin` の 3 ブランチ。linux を完成させてから他へ展開する。

## 前提

herdr は tmux 互換ではない。設定は移植ではなく書き直しになる。
実際のキー名とアクション名は `herdr --default-config` の出力を正とする。docs は網羅していない。

## 移行後の対応

| 現行 | herdr |
| --- | --- |
| `prefix C-a` | `[keys] prefix = "ctrl+a"` |
| `mode-keys vi` | copy mode が既定で vi 風 |
| `set-clipboard on` | 設定不要。`SSH_CONNECTION` / `SSH_TTY` / WSL を検出して OSC 52 を優先する |
| `allow-passthrough on` | `[experimental] kitty_graphics`。既定 false のまま |
| `mouse on` | `[ui] mouse_capture` |
| `bind \| -` | `split_horizontal` / `split_vertical` を再バインド |
| `bind r` reload | reload config アクション |
| `bind g` lazygit popup | `[[keys.command]] type = "popup"` |
| `C-hjkl` resize | resize アクション |
| `status-right` | `[ui] tab_bar_right` の `command` と `datetime` |
| resurrect + continuum | ネイティブ永続化と `[session] resume_agents_on_restore` |
| agent-sidebar | ネイティブ sidebar |
| tpm + sensible | 不要 |

## 設計

### 生成パイプライン

`herdr/.config/herdr/config.toml.in` を新設し、全文生成する (docs/COLORS.md の型 B)。
herdr の config.toml は include を持たず、テーマも同じファイルに書くため tmux と同じ扱いになる。
先頭に「生成物。編集は config.toml.in を直す」を置く。stow 対象は `herdr`。

`[theme.custom]` が受けるトークンは 19 個 (accent, panel_bg, sidebar_bg, active_row_bg,
selection_bg, surface0, surface1, surface_dim, overlay0, overlay1, text, subtext0, mauve,
green, yellow, red, blue, teal, peach)。`palette.json` の `{{role.*}}` をここへ流す。
tmux のスタイル指定より粒度が粗いので、配色は完全一致しない。

`@sidebar_color_*` の 30 行は herdr のネイティブ sidebar に吸収されて消える。

### Alt+hjkl の判定を反転する

herdr は pane の実行中コマンドを見てキーを分岐できない。未バインドのキーは PTY へ素通しされる。
この性質を使い、判定を herdr 側から呼び出し側へ移す。

- herdr: Alt+hjkl を一切バインドしない
- nvim: `<A-h>` で `wincmd h` を試し、`winnr()` が変わらなければ `herdr pane focus --direction left` を呼ぶ
- zsh: zle widget で同じコマンドを呼ぶ

vim-tmux-navigator と `vim.g.tmux_navigator_no_mappings` は削除する。

fzf など他の TUI が前面にいるときは効かない。現行の `is_vim` 正規表現も fzf を含んでおり
キーを fzf へ渡しているので、挙動は変わらない。

### lazygit popup

```toml
[[keys.command]]
key = "prefix+g"
type = "popup"
command = "zsh -c lazygit"
width = "80%"
height = "80%"
```

`sh -c` では `.zshenv` が読まれず `LG_CONFIG_FILE` が未設定になり、テーマ分離が壊れる。
`zsh -c` は非ログイン非対話でも `.zshenv` を読むのでこれを使う。
popup はフォーカス中 pane の作業ディレクトリを継承する。

### 既定 config を見て決める分

`bind -r e kill-pane -a` (他の pane を全て閉じる) と `C-S-Left` / `C-S-Right` (タブの並べ替え)
は相当アクションの有無を docs から確認できなかった。`herdr --default-config` の出力で
アクション名を探し、無ければ落とす。

### tab bar

`[ui] tab_bar_right` に git branch を出す `command` エントリと `datetime` を置く。
`command` は `interval_seconds` ごとに非同期で走り、成功時の最終行を使う。

タブラベルは `#{b:pane_current_path}` に相当するトークンが無い。タブ名は手動 rename か
pane の terminal title 依存になる。

## 捨てるもの

- tmux-thumbs。画面上のテキストをラベルで掴む機能に相当するものが無い。copy mode の `/` 検索と
  ダブルクリックのトークンコピーで代替する
- タブラベルの作業ディレクトリ自動表示
- wsl の ssh 警告色のうち pane border 側 (下記)

## ブランチ別の差分

### linux

上記がそのまま当てはまる。`clip` は wl-copy と xclip が無ければ OSC 52 関数に落ちるので、
`$TMUX` 分岐を消すだけでよい。

### wsl

`M-v` の clip-image (Windows クリップボードの画像を ssh 先へ転送し、パスを pane へ挿入する)
を移す。

```toml
[[keys.command]]
key = "alt+v"
type = "shell"
command = 'p=$(clip-image) && herdr pane send-text "$HERDR_PANE_ID" "$p"'
```

ssh 中の pane を警告色で示す条件付きスタイルは再現できない。herdr の pane border 色は静的で、
pane の実行中コマンドを見て切り替える仕組みが無い。`tab_bar_right` の `command` エントリで
フォーカス中の pane が ssh のときだけ `SSH` を出す形にし、status-left のバッジ側だけ残す。
分割時にどの pane が ssh かは見分けられなくなる。

thumbs を捨てるので `@thumbs-command` の win32yank 指定は消える。`clip` alias は win32yank の
ままで変わらない。

### darwin

`set-clipboard`、`allow-passthrough`、`set-titles` を持たない。ローカル端末なので不要。
移す量は linux より少ない。`clip` は pbcopy のままで変わらない。

## 周辺ファイル

| ファイル | 変更 |
| --- | --- |
| `neovim/.config/nvim/lua/keymaps.lua` | `<A-hjkl>` を herdr 呼び出しへ。`tmux_navigator_no_mappings` を削除 |
| `neovim/.config/nvim/lua/plugins/init.lua` | vim-tmux-navigator を削除 |
| `neovim/.config/nvim/nvim-pack-lock.json` | 同上 |
| `zsh/.zshrc` | `tmuxs` alias を差し替え、`clip` の `$TMUX` 分岐を削除、Alt+hjkl の zle widget を追加 |
| `zsh/.zshenv` | lazygit の `LG_CONFIG_FILE` を `.zshenv` に置いた理由を herdr の記述へ |
| `Brewfile` | `brew "tmux"` を `brew "herdr"` へ。OSC 52 のコメントの参照先を直す |
| `docs/COLORS.md` | 型 B の表と反映表の tmux 行を herdr へ |
| `tmux/` | 削除 |

## 検証

自動:

- `just check` が通る (生成物とテンプレートが一致する)
- `just test` が通る
- 手書きファイルに hex が残っていないか docs/COLORS.md のスウィープで確認する

実機 (linux のみ):

- prefix+g の lazygit がテーマ付きで開く
- Alt+hjkl が nvim の split と herdr の pane を跨いで動く
- Alt+hjkl がシェル pane でも動く
- tab bar に git branch と時計が出る
- detach してから attach で復帰する
- ssh 越しに `clip` が手元のクリップボードに届く

wsl と darwin はこの環境から動作確認できない。`just check` と目視レビューまでが限界になる。

## 実施順序

1. herdr をインストールし `herdr --default-config` を控える
2. `herdr/.config/herdr/config.toml.in` を書き `just build`
3. nvim のキーマップ
4. zsh
5. tmux 削除、Brewfile、docs
6. linux で実機確認
7. wsl と darwin へ展開
