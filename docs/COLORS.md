# 色の管理

色の値は `palette.json` にしか書かない。設定ファイルは `*.in` テンプレートから生成する。

## 色を変える

1. `palette.json` を編集する
2. `just build` を実行する
3. 下の反映表に従って各ツールへ適用する

`just check` は生成物がテンプレートと一致するかを検証する。生成物を直接編集してしまった
場合はここで落ちる。

## 生成物とテンプレートの 2 つの型

テンプレートには 2 つの型がある。どちらに属するかで、生成物を直接編集してよいかが変わる。

**型 A（色だけの生成物）**: 手書きの設定ファイルとは別に、色だけを持つ生成物を作り、
そこから読む。生成物自体は編集しない。隣にある手書きファイルは自由に編集してよい。

| ツール | 生成物 | 読む側（手書き、自由に編集可） |
| --- | --- | --- |
| nvim | `lua/palette.lua` | `require("palette")` で読む init.lua など |
| zsh | `.config/zsh/palette.zsh` | `.zshrc` から `source` する |
| lazygit | `.config/lazygit/theme.yml` | `LG_CONFIG_FILE` で `config.yml` とマージする |

**型 B（全文生成）**: ファイルの全体がテンプレートから生成される。ファイルそのものを
直接編集すると、次の `just build` で上書きされて消える。

| ツール | 生成物 |
| --- | --- |
| btop | `.config/btop/themes/papercolor-light.theme` |
| bat | `.config/bat/themes/PaperColor-Light.tmTheme` |
| hunk | `.config/hunk/config.toml` |
| tmux | `.tmux.conf` |
| starship | `.config/starship.toml` |
| パレット一覧 | `PALETTE.md` |

型 B のファイルはどれも先頭付近に「生成物。編集は対応する `.in` を直す」を持つ
(bat の tmTheme は XML 宣言と DOCTYPE が先に来るため 3 行目)。この行が付いている
ファイルは直接編集しない。

## 反映表

生成しただけでは効かないツールがある。`stow` 済みであることを前提とする。

| ツール | 反映方法 |
| --- | --- |
| bat | `bat cache --build` が必須。省くとテーマの変更が反映されない |
| tmux | `tmuxs` alias (`tmux source-file ~/.tmux.conf`) |
| fzf | `exec zsh` |
| starship | 次のプロンプトで反映される。生成物は `starship.toml` 全体なので、直接編集は次の `just build` で失う（型 B） |
| nvim | 再起動 |
| btop | 再起動 |
| hunk | 再起動 |
| lazygit | 再起動 |

## トークンを追加する

1. `palette.json` の `colors` に生の hex を足す。既にある色なら足さない
2. 用途に応じて `role` に `{colors.x}` 参照を足す
3. テンプレートから `{{role.y}}` で参照する
4. `just build` を実行する

`colors` の名前は ANSI ロール名ではなく見た目の名前にする。PaperColor は ANSI スロットの
意味を守っておらず、`ansi.10` (Bright Green) はピンクである。ロール名で命名するとテンプ
レートが嘘になる。

## ツールを追加する

2 つの型がある。include 機構を持つなら型 A を選ぶ。手書き設定が生成物にならないので、
生成物を直接編集して次の `just build` で失う事故が起きない。

**型 A**: 色だけの生成物を作り、手書き設定から読む。nvim (`require("palette")`)、
zsh (`source`)、lazygit (`LG_CONFIG_FILE` のカンマ区切りマージ) がこの型。

**型 B**: 全文をテンプレートにする。ファイルが元々ほぼ色だけの場合 (btop theme、
bat tmTheme、hunk config)、またはツールに include 機構が無い場合 (tmux、starship)。
生成物の 1 行目に「生成物。編集は対応する `.in` を直す」を書く。

starship は include を持たないが `[palettes]` で間接層を張れる。置換をパレットテーブルの
中に閉じ込め、モジュール側は `style = "accent"` と名前で書く。

## 仕組み

`build/render.mjs` がリポジトリ内の `*.in` を走査し、`{{token}}` を `palette.json` の値で
置換して `.in` を外した兄弟パスへ書く。レンダラは出力形式の知識を持たない。ヘッダコメント
はテンプレート自身が書く。

置換対象は二重波括弧 `{{token}}` だけである。tmux の `#{pane_current_path}` のような単一
波括弧は素通しする。

`palette.json` 内の `{path}` は参照であり、レンダラが解決する。未定義参照と循環参照は
`just build` が落ちる。

レンダラの単体テストは `just test` で走る。npm 依存はゼロで、node の組み込み test runner
を使う。

## 手書きファイルに hex が残っていないか確認する

この設計が成り立つ前提は「手書きファイルに hex を 1 つも書かない」ことである。`.in`
ファイルとその生成物 (兄弟パス) は hex を持つのが正しいので、両方を除外して残りを洗う。

```bash
GEN=$(git ls-files | grep '\.in$' | sed 's/\.in$//')
EXCL=$(printf '%s\n' $GEN | sed 's#^#^#; s#$#$#' | paste -sd'|')
grep -rnIE '#[0-9a-fA-F]{6}' \
  $(git ls-files | grep -vE "\.in$|^palette\.json$|^docs/|^build/|$EXCL") \
  || echo "なし"
```

`.in` だけを除外して生成物を除外し忘れると、生成物が意図どおり持っている hex がノイズに
なり、この確認は成立しない。ヒットが出た場合、コメントであっても hex を palette.json の
参照に置き換える。パレットを変えたときにコメントだけが嘘になるのを防ぐため、値を直接
書いた説明文はコメントであっても残さない。
