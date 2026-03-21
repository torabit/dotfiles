
# ── Environment ──────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export HOMEBREW_PREFIX=/opt/homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── PATH ─────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
PATH=~/.console-ninja/.bin:$PATH
export PNPM_HOME="/Users/toranosukeujike/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── Options ──────────────────────────────────────────────────
setopt correct
setopt extendedglob
setopt nocaseglob
setopt rcexpandparam
setopt nocheckjobs
setopt numericglobsort
setopt auto_cd

# ── History ──────────────────────────────────────────────────
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500
setopt appendhistory
setopt histignorealldups
unsetopt share_history

# ── Completion ───────────────────────────────────────────────
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
WORDCHARS=${WORDCHARS//\/[&.;]}
fpath=(~/.zfunc ~/.zsh/completions $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ── Plugins ──────────────────────────────────────────────────
source ${HOMEBREW_PREFIX}/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${HOMEBREW_PREFIX}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh
source ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh

# ── Key bindings ─────────────────────────────────────────────
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── Tools ────────────────────────────────────────────────────
eval "$(mise activate zsh)"
eval $(thefuck --alias)
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
[ -s "/Users/toranosukeujike/.bun/_bun" ] && source "/Users/toranosukeujike/.bun/_bun"

# ── Aliases ──────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='eza -l -h -@ -mU --icons --git --time-style=long-iso --color=automatic --group-directories-first'
alias l='ll -aa'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias tmuxs='tmux source-file ~/.tmux.conf'
alias clip='pbcopy'
alias clearbuff="clear && printf '\e[3J'"

# ── Functions ────────────────────────────────────────────────
function create() {
  mkdir -p $1 && cd $1
}

function g() {
  local repo=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :50 $(ghq root)/{}/README.md 2>/dev/null || ls $(ghq root)/{}")
  if [ -n "$repo" ]; then
    cd "$(ghq root)/$repo"
  fi
}

# ── Prompt ───────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Local overrides ─────────────────────────────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
