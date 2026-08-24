# WSL は LANG を /etc/default/locale から pam_env 経由で渡すため、
# 非ログインシェルでは未設定になる。LANG が空だと less が UTF-8 を
# 判別できず、日本語を含むファイルを binary 扱いして表示を拒む。
# git の pager も less なので diff や log が読めなくなる。
export LANG=${LANG:-C.UTF-8}

# rustup 未導入の環境では env が存在しないので、あれば読む。
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
