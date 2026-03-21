# PaperColor Light Palette

dotfiles 全体で使用する PaperColor Light のカラーパレット。
各設定ファイルではこのパレットの色を直接ハードコーディングする。
色を変更する場合はここを参照し、各ファイルを手動で更新する。

## Base Colors

| Name       | Hex       | Role                 |
|------------|-----------|----------------------|
| bg         | `#eeeeee` | 背景                 |
| fg         | `#444444` | 前景（通常テキスト） |

## ANSI 16 Colors

| Index | Name     | Hex       | ANSI Role      | 用途例                   |
|-------|----------|-----------|----------------|--------------------------|
| 0     | color00  | `#eeeeee` | Black          | 背景                     |
| 1     | color01  | `#af0000` | Red            | エラー、diff 削除        |
| 2     | color02  | `#008700` | Green          | diff 追加、成功          |
| 3     | color03  | `#5f8700` | Yellow         | 文字列                   |
| 4     | color04  | `#0087af` | Blue           | リンク、属性             |
| 5     | color05  | `#878787` | Magenta        | コメント、非アクティブ   |
| 6     | color06  | `#005f87` | Cyan           | 関数、見出し、アクセント |
| 7     | color07  | `#444444` | White          | 前景                     |
| 8     | color08  | `#bcbcbc` | Bright Black   | ボーダー（非アクティブ） |
| 9     | color09  | `#d70000` | Bright Red     | 強調エラー               |
| 10    | color10  | `#d70087` | Bright Green   | 型、キーワード、ピンク   |
| 11    | color11  | `#8700af` | Bright Yellow  | クラス、パープル         |
| 12    | color12  | `#d75f00` | Bright Blue    | 定数、数値、オレンジ     |
| 13    | color13  | `#d75f00` | Bright Magenta | (= color12)              |
| 14    | color14  | `#005faf` | Bright Cyan    | キーワード               |
| 15    | color15  | `#005f87` | Bright White   | (= color06)              |

## Semantic Colors

| Name         | Hex       | 用途                       |
|--------------|-----------|----------------------------|
| comment      | `#878787` | コメント                   |
| keyword      | `#005faf` | キーワード                 |
| string       | `#5f8700` | 文字列リテラル             |
| function     | `#444444` | 関数名                     |
| type         | `#d70087` | 型名                       |
| constant     | `#d75f00` | 定数、数値                 |
| error        | `#af0000` | エラー                     |
| todo         | `#00af5f` | TODO                       |
| visual       | `#0087af` | 選択                       |
| search_bg    | `#ffff5f` | 検索ハイライト背景         |
| cursor_bg    | `#005f87` | カーソル背景               |
| linenumber   | `#b2b2b2` | 行番号                     |

## UI Colors (dotfiles 共通)

各ツールでの使い分け。

| Role             | Hex       | 使用箇所                                 |
|------------------|-----------|------------------------------------------|
| accent (pink)    | `#d70087` | tmux アクティブ、starship、fzf pointer   |
| accent (cyan)    | `#005f87` | starship dir、fzf prompt、tmux session   |
| accent (orange)  | `#d75f00` | starship cmd_duration、lazygit           |
| inactive         | `#878787` | tmux 非アクティブ window、fzf info       |
| border           | `#bcbcbc` | fzf border、tmux pane border             |
| selection bg     | `#d7d7af` | fzf selected-bg、tmux mode               |
| hover bg         | `#e4e4e4` | fzf bg+                                  |

## 使用ファイル一覧

- `alacritty/.config/alacritty.toml` - ターミナルカラー
- `starship/.config/starship.toml` - プロンプト
- `tmux/.tmux.conf` - ステータスバー、ボーダー
- `lazygit/.config/lazygit/config.yml` - テーマ、delta pager
- `bat/.config/bat/themes/PaperColor-Light.tmTheme` - シンタックスハイライト
- `zsh/.zshrc` - fzf 配色 (`FZF_DEFAULT_OPTS`)
