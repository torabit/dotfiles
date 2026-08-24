#!/usr/bin/env bash
#
# HackGen35 Console NF に U+2733 (✳) のグリフを移植し、Rio 専用のフォント
# ディレクトリ (%LOCALAPPDATA%\rio\fonts) へ出力する。
#
# 直したい症状:
#   Rio のタブタイトルで日本語だけが豆腐になる。本文の日本語は正常に出る。
#
# 原因:
#   Rio のタブタイトルは文字列の先頭 1 文字だけでフォントを決め、その 1 フォントで
#   文字列全体をシェーピングする (sugarloaf/src/text.rs の shape_for)。文字単位の
#   フォールバックが無い。本文は 1 文字ごとに解決するので日本語が出る。
#   Claude Code はタイトルを "✳ ..." と設定するが、✳ (U+2733) は HackGen に無いため
#   Segoe UI Emoji が選ばれる。そのフォントは ASCII を持つので英数字は出るが、
#   日本語グリフを持たないので日本語が全て .notdef になる。
#   HackGen 自身に U+2733 を持たせて、1 フォントで全体を描けるようにする。
#
# インストール済みフォントを書き換えない理由:
#   %LOCALAPPDATA%\Microsoft\Windows\Fonts の同名ファイルを上書きすると per-user
#   フォントの登録が壊れ、Rio が "Font(s) not found" を出す。ファイル自体は健全で
#   GDI+ の PrivateFontCollection は受け付けるのに、システムのフォントコレクション
#   から外れる。
#   代わりに config.toml の fonts.additional-dirs に出力先を指定する。Rio は
#   additional-dirs をシステムフォントより先に検索するので
#   (sugarloaf/src/font/loader.rs の Database::query)、ファミリー名が同じでも
#   パッチ版が選ばれる。
#
# ドナーは Windows 同梱の Segoe UI Symbol。生成物はこの PC でのみ使う。
# 改変フォントなので再配布はしない。dotfiles にはこのスクリプトだけを置く。
#
# 冪等性: 入力は常にインストール済みの未改変フォント。何度でも実行できる。
# 反映には Rio の再起動が必要。設定ファイルと違い自動では読み直されない。

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
patcher="${script_dir}/patch-font.py"
donor="/mnt/c/Windows/Fonts/seguisym.ttf"
venv_dir="${HOME}/.cache/hackgen-patch-venv"
faces=(Regular Bold)

if [[ ! -f "${patcher}" ]]; then
  echo "error: パッチスクリプトが見つかりません: ${patcher}" >&2
  exit 1
fi

if [[ ! -f "${donor}" ]]; then
  echo "error: ドナーフォントが見つかりません: ${donor}" >&2
  exit 1
fi

cmd_exe="/mnt/c/Windows/System32/cmd.exe"
if [[ ! -x "${cmd_exe}" ]]; then
  cmd_exe="$(command -v cmd.exe || true)"
fi
if [[ -z "${cmd_exe}" ]]; then
  echo "error: cmd.exe が見つかりません。WSL 上で実行してください。" >&2
  exit 1
fi

# cwd が UNC パスだと cmd.exe が警告を出すため /mnt/c で実行する。
localappdata_win="$(cd /mnt/c && "${cmd_exe}" /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r\n')"
if [[ -z "${localappdata_win}" || "${localappdata_win}" == '%LOCALAPPDATA%' ]]; then
  echo "error: %LOCALAPPDATA% を解決できませんでした。" >&2
  exit 1
fi

localappdata="$(wslpath -u "${localappdata_win}")"
system_font_dir="${localappdata}/Microsoft/Windows/Fonts"
out_dir="${localappdata}/rio/fonts"

if [[ ! -d "${system_font_dir}" ]]; then
  echo "error: フォントディレクトリが見つかりません: ${system_font_dir}" >&2
  exit 1
fi

if [[ ! -x "${venv_dir}/bin/python" ]]; then
  echo "info: fontTools 用の venv を作成します: ${venv_dir}"
  python3 -m venv "${venv_dir}"
  "${venv_dir}/bin/pip" install --quiet --upgrade pip
  "${venv_dir}/bin/pip" install --quiet fonttools
fi

mkdir -p "${out_dir}"

for face in "${faces[@]}"; do
  src="${system_font_dir}/HackGen35ConsoleNF-${face}.ttf"
  out="${out_dir}/HackGen35ConsoleNF-${face}.ttf"

  if [[ ! -f "${src}" ]]; then
    echo "error: 元フォントが見つかりません: ${src}" >&2
    exit 1
  fi

  "${venv_dir}/bin/python" "${patcher}" "${src}" "${donor}" "${out}"
done

echo
echo "config.toml の fonts.additional-dirs が次を指していることを確認する:"
echo "  ${localappdata_win}\\rio\\fonts"
echo "Rio を再起動すると反映される。"
