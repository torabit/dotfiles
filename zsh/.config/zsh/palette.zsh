# 生成物。編集は palette.zsh.in を直す。

export FZF_DEFAULT_OPTS='
  --color=light
  --color=fg:#444444,bg:#eeeeee,hl:#d70087
  --color=fg+:#444444,bg+:#e4e4e4,hl+:#d70087
  --color=selected-fg:#444444,selected-bg:#d7d7af
  --color=info:#878787,prompt:#005f87,pointer:#d70087
  --color=marker:#008700,spinner:#d70087
  --color=border:#bcbcbc,header:#005f87,gutter:#eeeeee
  --color=preview-bg:#eeeeee,preview-fg:#444444,preview-border:#bcbcbc
'

# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"
