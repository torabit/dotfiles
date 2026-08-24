# dotfiles
My dotfiles

i use ```stow```

# Usage
in root dir

### create link
```zsh
stow -v dirname
```

### unlink
```zsh
stow -vD dirname
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
配色は `PALETTE.md` を参照する。

### フォントのパッチ

```zsh
./rio/patch-font.sh
```

HackGen35 Console NF に U+2733 (✳) のグリフを移植する。Rio のタブタイトルは
文字列の先頭 1 文字だけでフォントを決め、その 1 フォントで全体をシェーピングする
(`sugarloaf/src/text.rs` の `shape_for`)。文字単位のフォールバックが無い。
Claude Code はタイトルを "✳ ..." と設定するため、HackGen が U+2733 を持たないと
Segoe UI Emoji が選ばれ、そのフォントは日本語グリフを持たないのでタイトルの日本語が
全て豆腐になる。

ドナーは Windows 同梱の Segoe UI Symbol。改変フォントなので再配布はしない。
未改変のフォントは `~/.local/share/hackgen-backup` に置く。HackGen を更新したら
バックアップを消してから再実行する。反映には Rio の再起動が必要。
