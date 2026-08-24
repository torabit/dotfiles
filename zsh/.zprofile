# Browser
# WSL 固有: xdg-open は無い。wslview (wslu) が Windows の既定ブラウザへ渡す。
if [[ -z "$BROWSER" ]] && (( $+commands[wslview] )); then
  export BROWSER='wslview'
fi

# Pager
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

# Language
# LANG は .zshenv で設定する。非ログインシェルでも必要なため。

# Paths
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

# WSL 固有: Windows 側にインストールした VS Code の code コマンドを使う。
export PATH=$PATH:'/mnt/c/Users/rai-t/AppData/Local/Programs/Microsoft VS Code/bin'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  $HOME/{,s}bin(N)
  /home/linuxbrew/.linuxbrew/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# Less
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
