# dotfiles
My dotfiles

## Branches
OS ごとに分ける。OS 固有の変更はそのブランチに留める。

| branch | target |
| --- | --- |
| `darwin` | macOS |
| `linux` | Linux (Homebrew on Linux) |
| `wsl` | WSL2 + Rio (Homebrew on Linux) |

ツールの導入は `Brewfile` と `mise/.config/mise/config.toml` を見る。

```zsh
brew bundle
mise install
```

配色は `palette.json` から生成する。生成物はコミットされているので、`stow` する前に
実行する必要はない。色を変えるときだけ実行する。詳細は `docs/COLORS.md` を読む。

```zsh
just build
```

i use ```stow```

# Usage
in root dir

リポジトリが `~/ghq` 配下にあるので `-t ~` でターゲットを明示する。省略すると
親ディレクトリ (`~/ghq/github.com/torabit`) にリンクが張られる。

`--no-folding` はディレクトリ自体ではなく中のファイルを個別にリンクする。これが無いと
リンク先に存在しないディレクトリ (`~/.local` など) はディレクトリごと symlink にされ、
stow 管理外のファイルを共存させられなくなる。

`--ignore='\.in$'` は配色テンプレートの `.in` ファイルをリンク対象から外す。無いと
`~/.config/zsh/palette.zsh.in` のような未使用のリンクがホームに増え、テンプレートを
リネームしたときに `stow -D` で回収できず残留する。

### create link
```zsh
stow --no-folding --ignore='\.in$' -t ~ -v dirname
```

### unlink
```zsh
stow -D --ignore='\.in$' -t ~ -v dirname
```

## Rio (stow 対象外)

Rio は Windows ネイティブアプリなので stow ではリンクできない。
`rio/config.toml` を編集したら次で Windows 側へ反映する。

```zsh
./rio/sync.sh
```

`%LOCALAPPDATA%\rio\config.toml` へ実体をコピーする。symlink は使わない。
WSL2 が VHD 方式になった影響で、WSL 起動前は Windows 側からリンク先を解決できず
Rio の設定読み込みが失敗するため。

Rio は保存を検知して即座に再読み込みするので再起動は不要。
配色は `palette.json` から生成する。手順は `docs/COLORS.md` を読む。

### フォントのパッチ

```zsh
./rio/patch-font.sh
```

HackGen35 Console NF に U+2733 (✳) のグリフを移植し、`%LOCALAPPDATA%\rio\fonts`
へ出力する。`config.toml` の `fonts.additional-dirs` がこのディレクトリを指す。

Rio のタブタイトルは文字列の先頭 1 文字だけでフォントを決め、その 1 フォントで全体を
シェーピングする (`sugarloaf/src/text.rs` の `shape_for`)。文字単位のフォールバックが
無い。Claude Code はタイトルを "✳ ..." と設定するが、✳ は HackGen に無いので
Segoe UI Emoji が選ばれ、そのフォントは日本語グリフを持たないためタイトルの日本語が
全て豆腐になる。HackGen 自身に ✳ を持たせて 1 フォントで描けるようにする。

インストール済みフォントは書き換えない。同名ファイルを上書きすると per-user フォントの
登録が壊れ、Rio が "Font(s) not found" を出す。Rio は `additional-dirs` をシステム
フォントより先に検索するので、ファミリー名が同じでもパッチ版が選ばれる。

ドナーは Windows 同梱の Segoe UI Symbol。改変フォントなので再配布はしない。
反映には Rio の再起動が必要。

## clip-image

Windows のクリップボードにある画像を ssh 先へ転送し、リモート側の絶対パスを表示する。
ssh 先で動かしている Claude Code へ画像を渡すために使う。ローカルの Claude Code は
貼り付けで受け取れるが、ssh 先のプロセスは Windows のクリップボードに触れない。

```zsh
clip-image           # 既定の ssh 先へ転送
clip-image myhost    # ホストを指定
```

WSL 側のシェルで実行する。ssh 先では `powershell.exe` に届かないので動かない。
転送後、リモートのパスを Windows のクリップボードへ入れ替えるので、ssh 先の
Claude Code では Ctrl+V でそのパスを貼り付ければよい。画像そのものは渡さない。

herdr でも `Alt+V` (`key = "alt+v"`) で転送とパス挿入をまとめて実行できる
(`herdr/.config/herdr/config.toml`)。herdr サーバが WSL 側で動いていて、ssh はその
配下の pane なので、転送を WSL 側で走らせつつ結果を ssh 先の pane へ送り込める。
`herdr pane send-text` は Enter を送らないので内容を確認してから送信する。

ローカルの Claude Code で Ctrl+V が効くのは、WSL 上のプロセスが `powershell.exe`
経由でクリップボードを読めるため。ssh 先のプロセスにはその経路が無く、Ctrl+V は
キーストロークが ssh 越しに送られるだけで画像データは流れない。

Windows のクリップボードは `powershell.exe` 経由で読む。WSL 側の `xclip` や
`wl-clipboard` は WSL 内のクリップボードを指すので Windows 側の内容は取れない。
画像は PNG に変換して base64 で受け取る。`Clipboard.GetImage` は STA アパートメント
でないと null を返すため `-Sta` を付けている。

転送先は `~/.cache/clip-image`。転送のついでに `CLIP_IMAGE_KEEP_DAYS` (既定 30) より古い
分を消すので、リモート側に cron を置く必要はない。掃除が失敗しても転送結果には影響しない。
ホストと保存先は `CLIP_IMAGE_HOST` と `CLIP_IMAGE_REMOTE_DIR` で変えられる。

## 画像のインライン表示

`chafa` で端末に画像を出す。herdr は `experimental.kitty_graphics` で kitty graphics の
passthrough を通す (`herdr/.config/herdr/config.toml`)。tmux の `allow-passthrough on` を
引き継いだ設定で、herdr 側ではまだ experimental 扱い。描画が乱れる場合は false に戻す。

```zsh
chafa -f kitty path/to/image.png
```
