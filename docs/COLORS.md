# 色の管理

色の値はテーマファイルにしか書かない。各ツールの config は
[vanadis](https://github.com/torabit/vanadis) がテンプレートから生成する。

```
vanadis/.config/vanadis/     stow する。git 管理する
├── config.toml              [auto] [cycle] と [[targets]]
├── templates/<target>/      テンプレート
└── themes/*.toml            パレット

~/.config/<tool>/...         vanadis が生成する。stow しない。git 管理しない
~/.local/state/vanadis/      どのテーマを適用中か。git 管理しない
```

生成物はリポジトリに入らない。テーマを切り替えても dotfiles に差分は出ない。
逆に、vanadis を入れていないマシンでは stow しても色付きの config は手に入らない。

## 色を変える

1. `vanadis/.config/vanadis/themes/<theme>.toml` を編集する
2. `vanadis apply <theme> --diff` で差分を見る
3. `vanadis apply <theme>` を実行する

`vanadis check` は生成物がテンプレートの出力と一致するかを検証する。生成物を直接
編集してしまった場合はここで落ちる。編集はテンプレートに移す。

## テーマを切り替える

```zsh
vanadis apply papercolor-dark
vanadis apply --variant dark    # config.toml の [auto] を引く
vanadis cycle                   # [cycle] の順に 1 つ進める
```

## テーマ

| id | variant | 出どころ |
| --- | --- | --- |
| `papercolor-light` | light | PaperColor Light を手で書き起こしたもの |
| `papercolor-dark` | dark | `vanadis import base24/papercolor-dark` |

`papercolor-dark` は import したままではテンプレートが読むトークンを持たない。
`colors.purple` / `brown` / `slate`、`[diff]` の 4 つ、`[text]` の 3 つを足してある。
テーマを増やすときも同じ 10 個が要る。`vanadis check <新テーマ>` が名前を列挙する。

## 生成物とテンプレートの 2 つの型

テンプレートには 2 つの型がある。どちらに属するかで、手書きの設定を隣に置けるかが
変わる。

**型 A（色だけの生成物）**: 色だけを持つ生成物を作り、手書きの設定ファイルから読む。
生成物は編集しない。読む側は自由に編集してよい。

| target | 生成物 | 読む側（手書き、自由に編集可） |
| --- | --- | --- |
| nvim | `~/.config/nvim/lua/palette.lua` | `require("palette")` する lua |
| zsh | `~/.config/zsh/palette.zsh` | `.zshrc` から `source` する |
| lazygit | `~/.config/lazygit/theme.yml` | `LG_CONFIG_FILE` で `config.yml` とマージ |

**型 B（全文生成）**: ファイル全体が生成される。ツールに include 機構が無いか、
元々ほぼ色だけのファイルがこれになる。

| target | 生成物 |
| --- | --- |
| bat | `~/.config/bat/themes/vanadis.tmTheme` |
| btop | `~/.config/btop/themes/vanadis.theme` |
| herdr | `~/.config/herdr/config.toml` |
| herdr-thumbs | `~/.config/herdr/plugins/config/sd2k.thumbs/config.env` |
| hunk | `~/.config/hunk/config.toml` |
| starship | `~/.config/starship.toml` |

型 B のファイルは先頭付近に「生成物。編集は対応するテンプレートを直す」を持つ
(bat の tmTheme は XML 宣言と DOCTYPE が先に来るため 3 行目)。

型 B のツールは dotfiles にパッケージを持たない。config 全体が生成物なので、
stow する対象が残らない。

## 出力名にテーマ名を入れない

bat と btop の生成物は `vanadis.tmTheme` と `vanadis.theme` である。btop はテーマ
ディレクトリを列挙して中身を一覧に出すので、`papercolor-light.theme` のままだと
gruvbox に切り替えた後もその名前で並ぶ。

bat はファイル名ではなく tmTheme 内の `name` でテーマを選ぶ。ここは固定名 `vanadis`
を書いてあるので、テーマを切り替えても `.zshrc` の `BAT_THEME` は追随させなくてよい。

## 反映

生成しただけでは効かないツールがある。

| target | 反映方法 | vanadis が走らせるか |
| --- | --- | --- |
| bat | `bat cache --build` が必須。省くとキャッシュ済みのテーマを配り続ける | する |
| herdr | `herdr server reload-config` | する |
| starship | 次のプロンプトで反映される | 走らせるものが無い |
| zsh (fzf) | `exec zsh`。fzf は色を環境変数から読む | しない。vanadis は子プロセスなのでユーザのシェルを置き換えられない |
| nvim / btop / hunk / lazygit | 再起動 | コマンドが無い |

## 色ではない値もテーマに追随させる

variant で切り替わるのは色だけではない。`--color=light` や、別ツールが持つ自前の
テーマ名がそのまま残ると、dark を適用しても fzf と delta だけ light のままになる。

| 場所 | テンプレートの書き方 |
| --- | --- |
| fzf の `--color=light` | `--color={{meta.variant}}` |
| delta の `--light` | `--{{meta.variant}}` |
| delta の `--syntax-theme` | `{{text.delta-syntax-theme}}` |
| hunk の `base` | `{{text.hunk-base}}` |
| herdr の `[theme] name` | `{{text.herdr-base}}` |
| hunk の `theme` / `label` | `{{meta.id}}` / `{{meta.name}}` |

`vanadis check` はこれを拾えない。どれも有効な値なので、生成物は clean のまま通る。
テンプレートを書くときに一度掃く。

## トークンを追加する

1. テーマの `[colors]` に生の hex を足す。既にある色なら足さない
2. 用途に応じて `[role]` に `{{colors.x}}` 参照を足す
3. テンプレートから `{{role.y}}` で参照する
4. 全テーマに同じトークンを足す。足し忘れは `vanadis check <そのテーマ>` が
   `undefined tokens` として行番号付きで出す

`[colors]` の名前は ANSI ロール名ではなく見た目の名前にする。PaperColor は ANSI
スロットの意味を守っておらず、`ansi.10` (Bright Green) はピンクである。ロール名で
命名するとテンプレートが嘘になる。

## ツールを追加する

include 機構を持つなら型 A を選ぶ。手書き設定が生成物にならないので、生成物を直接
編集して次の apply で失う事故が起きない。

1. テンプレートを `vanadis/.config/vanadis/templates/<target>/` に置く。ツールが読む
   ディレクトリには置かない。btop のようにテーマディレクトリを列挙するツールが
   `.in` をテーマとして拾う
2. `config.toml` に `[[targets]]` を足す。`output` は `~/.config/...` を指す
3. `vanadis check <theme> --only <target>` が clean になるまでテンプレートを直す
4. `stow --no-folding -t ~ vanadis` でテンプレートを張り直す

`output` がリポジトリの中に解決してはいけない。stow がディレクトリごと畳んで
symlink にしていると (`--no-folding` を付けずに stow したパッケージ)、
`~/.config/bat/themes/x` のような普通のパスがリポジトリの中を指す。vanadis は
生成物を rename で被せるので、そのままだとリポジトリが書き換わる。

## 手書きファイルに hex が残っていないか確認する

この設計が成り立つ前提は「手書きファイルに hex を 1 つも書かない」ことである。
生成物はリポジトリに入らないので、除外するものは無い。

```bash
grep -rnIE '#[0-9a-fA-F]{6}' . --exclude-dir=.git --exclude-dir=vanadis
```

`vanadis/` はテンプレートとテーマなので hex を持つのが正しい。それ以外にヒットが
出たら、コメントであっても hex をトークン参照に置き換える。パレットを変えたときに
コメントだけが嘘になるのを防ぐため、値を直接書いた説明文はコメントであっても残さない。
