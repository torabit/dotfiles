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
