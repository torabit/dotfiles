
# ── Environment ──────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew

eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# ── PATH ─────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH" # go install targets (gopls, staticcheck, ...)
PATH=~/.console-ninja/.bin:$PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
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
for _plugin in \
  ${HOMEBREW_PREFIX}/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  ${HOMEBREW_PREFIX}/share/zsh-history-substring-search/zsh-history-substring-search.zsh \
  ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh \
  ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh
do
  [[ -r $_plugin ]] && source $_plugin
done
unset _plugin

# ── Key bindings ─────────────────────────────────────────────
KEYTIMEOUT=1
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── Tools ────────────────────────────────────────────────────
(( $+commands[mise] )) && eval "$(mise activate zsh)"
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
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
export BAT_THEME='PaperColor-Light'
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── Aliases ──────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='eza -l -h -@ -mU --icons --git --time-style=long-iso --color=auto --group-directories-first'
alias l='ll -aa'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias tmuxs='tmux source-file ~/.tmux.conf'
if (( $+commands[wl-copy] )); then
  alias clip='wl-copy'
elif (( $+commands[xclip] )); then
  alias clip='xclip -selection clipboard'
elif [[ -n $TMUX ]]; then
  alias clip='tmux load-buffer -w -'
else
  # OSC 52: let the terminal emulator own the clipboard (works over SSH)
  clip() { printf '\e]52;c;%s\a' "$(base64 | tr -d '\n')" }
fi
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

# ── Local overrides ─────────────────────────────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ── Init (must be at the end of .zshrc) ─────────────────────
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh)"
