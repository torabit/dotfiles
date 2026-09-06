# dotfiles
My dotfiles

## Branches
Config is split per OS. Keep OS-specific changes on their own branch.

| branch | target |
| --- | --- |
| `darwin` | macOS |
| `linux` | Linux (Homebrew on Linux) |

配色は [vanadis](https://github.com/torabit/vanadis) が 1 つのパレットから生成する。
生成物はコミットしていないので、`stow` した後に一度実行する必要がある。詳細は
`docs/COLORS.md` を読む。

```zsh
stow --no-folding -t ~ -v vanadis
vanadis apply papercolor-light
```

bat / btop / herdr / hunk / starship は config 全体が生成物なので、dotfiles に
パッケージを持たない。`vanadis apply` が `~/.config` へ直接書く。

i use ```stow```

# Usage
in root dir

リポジトリが `~/ghq` 配下にあるので `-t ~` でターゲットを明示する。省略すると
親ディレクトリ (`~/ghq/github.com/torabit`) にリンクが張られる。

`--no-folding` はディレクトリ自体ではなく中のファイルを個別にリンクする。これが無いと
リンク先に存在しないディレクトリ (`~/.local` など) はディレクトリごと symlink にされ、
stow 管理外のファイルを共存させられなくなる。

`--no-folding` は全パッケージで必須である。省くと `~/.config/bat` のようなパスが
リポジトリを指す symlink になり、その下に vanadis が生成物を書くとリポジトリの中身が
書き換わる。

配色テンプレートの `.in` は `vanadis` パッケージにだけ置く。これはリンクする対象なので
`--ignore='\.in$'` は付けない。

### create link
```zsh
stow --no-folding -t ~ -v dirname
```

### unlink
```zsh
stow -D -t ~ -v dirname
```
