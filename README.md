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
