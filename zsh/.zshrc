
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
setopt inc_append_history
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
# brew の zsh 5.9.2 は既定の fpath に Cellar/zsh/5.9 を焼き込んでいるが、その
# バージョンのディレクトリは存在しない。旧バージョンが Cellar に残っている間は
# 解決できるため気づかないが、brew cleanup で消えた時点で compinit や
# add-zsh-hook などの autoload 関数が一切引けなくなる。share/zsh/functions は
# バージョンに依存しないので明示的に足す。
fpath=(~/.zfunc ~/.zsh/completions ${HOMEBREW_PREFIX}/share/zsh/functions $fpath)
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
  ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh \
  ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh
do
  [[ -r $_plugin ]] && source $_plugin
done
unset _plugin

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

# herdr の pane 移動。herdr 側では Alt+hjkl をバインドせず、キーはここへ届く。
# nvim も同じ判定を自前で持つ (neovim/.config/nvim/lua/keymaps.lua)。
if (( $+commands[herdr] )); then
  _herdr_focus_left()  { herdr pane focus --current --direction left  >/dev/null 2>&1 }
  _herdr_focus_down()  { herdr pane focus --current --direction down  >/dev/null 2>&1 }
  _herdr_focus_up()    { herdr pane focus --current --direction up    >/dev/null 2>&1 }
  _herdr_focus_right() { herdr pane focus --current --direction right >/dev/null 2>&1 }
  zle -N _herdr_focus_left
  zle -N _herdr_focus_down
  zle -N _herdr_focus_up
  zle -N _herdr_focus_right
  for _keymap in viins vicmd; do
    bindkey -M $_keymap '^[h' _herdr_focus_left
    bindkey -M $_keymap '^[j' _herdr_focus_down
    bindkey -M $_keymap '^[k' _herdr_focus_up
    bindkey -M $_keymap '^[l' _herdr_focus_right
  done
  unset _keymap
fi

# ── Tools ────────────────────────────────────────────────────
(( $+commands[mise] )) && eval "$(mise activate zsh)"
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
[ -s "$HOME/.config/zsh/palette.zsh" ] && source "$HOME/.config/zsh/palette.zsh"
export BAT_THEME='PaperColor-Light'
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── Aliases ──────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='eza -l -h -@ -mU --icons --git --time-style=long-iso --color=auto --group-directories-first'
alias l='ll -aa'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias herdrs='herdr server reload-config'
if (( $+commands[wl-copy] )); then
  alias clip='wl-copy'
elif (( $+commands[xclip] )); then
  alias clip='xclip -selection clipboard'
else
  # OSC 52: let the terminal emulator own the clipboard (works over SSH)
  clip() { printf '\e]52;c;%s\a' "$(base64 | tr -d '\n')" }
fi
alias clearbuff="clear && printf '\e[3J'"
# 端末で画像を見る。Alacritty は画像プロトコル (sixel / kitty graphics) を実装して
# いないので auto でも symbols に落ちるが、端末を変えても挙動が変わらないよう
# 明示する。文字で描くので粗い。
alias img='chafa -f symbols'

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
