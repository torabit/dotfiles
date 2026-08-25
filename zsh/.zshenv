. "$HOME/.cargo/env"

# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
# tmux の prefix+g (display-popup -E lazygit) は非ログイン非対話シェルを
# 経由するため .zshrc は読まれない。.zshenv なら通るので、ここに置く。
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
