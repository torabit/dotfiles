# WSL は LANG を /etc/default/locale から pam_env 経由で渡すため、
# 非ログインシェルでは未設定になる。LANG が空だと less が UTF-8 を
# 判別できず、日本語を含むファイルを binary 扱いして表示を拒む。
# git の pager も less なので diff や log が読めなくなる。
export LANG=${LANG:-C.UTF-8}

# rustup 未導入の環境では env が存在しないので、あれば読む。
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
# 非ログイン非対話シェルから起動されても効くよう .zshrc ではなくここに置く。
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
