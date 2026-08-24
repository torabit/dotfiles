# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Prompt
source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Load plugins
export ZSH_PLUGINS=/home/linuxbrew/.linuxbrew/

source ${ZSH_PLUGINS}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ${ZSH_PLUGINS}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${ZSH_PLUGINS}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source ${ZSH_PLUGINS}/opt/fzf/shell/key-bindings.zsh
source ${ZSH_PLUGINS}/opt/fzf/shell/completion.zsh

# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# General options
setopt correct
setopt extendedglob
setopt nocaseglob
setopt rcexpandparam
setopt nocheckjobs
setopt numericglobsort

# History
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500
setopt inc_append_history
setopt histignorealldups
# Don't want common history between shells
unsetopt share_history

# Editor setting
export EDITOR=nvim

# Hub
eval "$(hub alias -s)"

# Completion
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word
fpath=(~/.zfunc ~/.zsh/completions $fpath) 
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Thefuck
eval $(thefuck --alias)

# Aliases
alias git='hub'
alias ls='ls --color=auto'
alias ll='eza -l -h -@ -mU --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias l='ll -aa'
alias vim='nvim'
alias dot='cd ~/dotfiles'
alias tmuxs='tmux source-file ~/.tmux.conf'
alias zshrc='vim ~/.zshrc'
alias clip='/mnt/c/Tools/win32yank/win32yank.exe -i --crlf'
alias clearbuff="clear && printf '\e[3J'"

# Custom functions
function create() {
  mkdir -p $1 && cd $1
}

# Auto-cd
setopt auto_cd

# FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'

bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh 
eval "$(anyenv init -)"

# Report the working directory and running command as the terminal title.
# Without this the title stays at whatever ConPTY set at startup
# (C:\WINDOWS\SYSTEM32\wsl.exe), since zsh never updates it.
autoload -Uz add-zsh-hook
_title_precmd() { print -P -n '\e]2;%~\a' }
_title_preexec() { print -P -n '\e]2;%~ | '"${1%% *}"'\a' }
add-zsh-hook precmd _title_precmd
add-zsh-hook preexec _title_preexec
