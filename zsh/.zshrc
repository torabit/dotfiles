
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
# 解決できていたが、brew cleanup で消えると compinit や add-zsh-hook などの
# autoload 関数が一切引けなくなる。share/zsh/functions はバージョンに依存しない
# ので明示的に足す。
fpath=(~/.zfunc ~/.zsh/completions ${HOMEBREW_PREFIX}/share/zsh/functions $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# bash 形式の補完 (complete -C) を使うツール向け。
autoload -U +X bashcompinit && bashcompinit
(( $+commands[aws_completer] )) && complete -C aws_completer aws
# terraform 自身が COMP_LINE/COMP_POINT を読んで候補を返す。
# terraform -install-autocomplete が書く Cellar の絶対パスは
# バージョン更新で切れるため、PATH 上の名前で参照する。
(( $+commands[terraform] )) && complete -o nospace -C terraform terraform

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

# vi のモードはプロンプト記号ではなくカーソル形状で示す。starship は zsh の visual
# mode を判別できず (starship#6390)、記号を出すには再描画のたびに starship と
# git status を走らせることになる。形状なら描画コストがかからない。
# visual mode の範囲は fast-syntax-highlighting が反転させるので、形状は vicmd と
# 同じでよい。ohmyzsh#8004 と同じ割り当て。
_vi_cursor_shape() {
  case $KEYMAP in
    vicmd|visual) print -n '\e[2 q' ;;  # 塗りつぶし
    *)            print -n '\e[6 q' ;;  # 縦棒
  esac
}
# starship も zle-keymap-select を張る。zle -N で直接束ねると片方が落ちるので
# add-zle-hook-widget を使う。starship 側は既存の widget を見つけて包む実装。
autoload -Uz add-zle-hook-widget
add-zle-hook-widget keymap-select _vi_cursor_shape
add-zle-hook-widget line-init _vi_cursor_shape

# 実行するコマンドに vicmd の形状を引き継がせない。
_vi_cursor_reset() { print -n '\e[6 q' }
autoload -Uz add-zsh-hook
add-zsh-hook preexec _vi_cursor_reset

# ── Terminal title ───────────────────────────────────────────
# WSL 固有: ConPTY が起動時に設定したタイトル (wsl.exe のパス) が更新されずに
# 残る。zsh が OSC 2 を送らないためで、precmd と preexec で直接送って解決する。
autoload -Uz add-zsh-hook
_title_precmd() { print -P -n '\e]2;%~\a' }
_title_preexec() { print -P -n '\e]2;%~ | '"${1%% *}"'\a' }
add-zsh-hook precmd _title_precmd
add-zsh-hook preexec _title_preexec

# ── Tools ────────────────────────────────────────────────────
(( $+commands[mise] )) && eval "$(mise activate zsh)"
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
[ -s "$HOME/.config/zsh/palette.zsh" ] && source "$HOME/.config/zsh/palette.zsh"
export BAT_THEME='PaperColor-Light'
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── Aliases ──────────────────────────────────────────────────
alias git='hub'
alias ls='ls --color=auto'
alias ll='eza -l -h -@ -mU --icons --git --time-style=long-iso --color=auto --group-directories-first'
alias l='ll -aa'
alias vim='nvim'
alias dot='cd $(ghq root)/github.com/torabit/dotfiles'
alias herdrs='herdr server reload-config'
# ssh 先の herdr へ繋ぐ。使い方は `hr lura`。
# 通知音は client 側で鳴るため、ssh 先で herdr を立ち上げるのではなくこちらから繋ぐ。
# --remote は既定で手元の keybinding を送るが、[[keys.command]] だけは送られない。
# server を指定して ssh 先の config をそのまま使い、popup と plugin action を残す。
alias hr='herdr --remote-keybindings server --remote'
alias zshrc='vim ~/.zshrc'
# WSL 固有: クリップボードは Windows 側が持つ。win32yank で橋渡しする。
# X も Wayland も無いので wl-copy と xclip は使えない。
alias clip='/mnt/c/Tools/win32yank/win32yank.exe -i --crlf'
alias clearbuff="clear && printf '\e[3J'"
# 端末で画像を見る。-f symbols の明示が必要。既定の auto は Rio を画像プロトコル
# 対応と判定して sixel を選ぶが、Windows 版 Rio は sixel を描画しないため何も
# 表示されない (raphamorim/rio#729)。文字で描くので粗いが確実に映る。
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

# WSL 固有: 通知音を鳴らすのは server ではなく herdr の client プロセス。音源は
# 48kHz の mp3 で、mp3 を扱えるのが mpg123 しかないため必ずそれが使われる。
# WSLg の RDPSink は実レイテンシが 97ms あるのに mpg123 は buffer を 145ms しか
# 取らず、転送のジッタで枯れてノイズが乗る。libpulse に外から buffer 長を指示して
# 回避する。実効 1s 確保すれば消える (270ms ではまだ乗った)。
# 変数は libpulse 全体に効くので、他のプログラムを巻き込まないよう herdr に絞る。
function herdr() {
  PULSE_LATENCY_MSEC=2000 command herdr "$@"
}

# ── Local overrides ─────────────────────────────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ── Init (must be at the end of .zshrc) ─────────────────────
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh)"
