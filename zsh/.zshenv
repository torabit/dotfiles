. "$HOME/.cargo/env"

# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
# 非ログイン非対話シェルから起動されても効くよう .zshrc ではなくここに置く。
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
