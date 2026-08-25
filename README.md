# dotfiles
My dotfiles

配色は `palette.json` から生成する。生成物はコミットされているので、`stow` する前に
実行する必要はない。色を変えるときだけ実行する。詳細は `docs/COLORS.md` を読む。

```zsh
just build
```

i use ```stow```

# Usage
in root dir

`--ignore='\.in$'` は配色テンプレートの `.in` ファイルをリンク対象から外す。無いと
`~/.config/zsh/palette.zsh.in` のような未使用のリンクがホームに増え、テンプレートを
リネームしたときに `stow -D` で回収できず残留する。

### create link
```zsh
stow -v --ignore='\.in$' dirname
```

### unlink
```zsh
stow -vD --ignore='\.in$' dirname
```
