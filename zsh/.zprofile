# Browser
if [[ -z "$BROWSER" ]] && (( $+commands[xdg-open] )); then
  export BROWSER='xdg-open'
fi

# Pager
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

# Language
if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Paths
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

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
