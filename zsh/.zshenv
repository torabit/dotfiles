[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# herdr は自分で更新し、その入り先は ~/.local/bin だけ。brew 版は置いていかれる。
# `hr` の ssh は非対話で .zshrc を読まないため、ここに無いと server が古い方で立つ。
export PATH="$HOME/.local/bin:$PATH"

# lazygit は後のファイルが前を上書きする形でマージする。テーマを分離しておく。
# 非ログイン非対話シェルから起動されても効くよう .zshrc ではなくここに置く。
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
