
# ── Environment ──────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
# 1Password SSH agent (ssh_config を読まないツール向け)
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
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
source ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh
source ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh

# ── Key bindings ─────────────────────────────────────────────
KEYTIMEOUT=1
# 矢印キーは意図的に未バインド: ↑ は atuin が init 時に奪い、↓ は zsh 既定の
# down-line-or-history が残る。どちらも複数行バッファ内では行移動として動く。

# コマンドライン全体を $EDITOR で編集する (長い複数行コマンドの修正用)。
# 保存して閉じるとバッファに戻る。実行はされないので Enter は自分で押す。
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^G'   edit-command-line  # 既定の list-expand を置き換え
bindkey -M vicmd '^G'   edit-command-line
bindkey -M vicmd 'v'    edit-command-line  # 既定の visual-mode を置き換え

# ── Tools ────────────────────────────────────────────────────
eval "$(mise activate zsh)"
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

# カレントディレクトリ配下のディレクトリを選んで claude を起動
function cclaude() {
  local dir
  dir=$( (echo "."; fd --type d --hidden --exclude .git) | fzf --preview 'eza -la --icons {} 2>/dev/null || ls -la {}' ) || return
  [ -n "$dir" ] || return
  cd "$dir" && claude
}

# ── Local overrides ─────────────────────────────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ── Init (must be at the end of .zshrc) ─────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
