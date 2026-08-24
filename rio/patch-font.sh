#!/usr/bin/env bash
#
# HackGen35 Console NF に U+2733 (✳) のグリフを移植して Windows 側へ再インストールする。
#
# 目的:
#   Rio のタブタイトルは文字列の先頭 1 文字だけでフォントを決め、その 1 フォントで
#   文字列全体をシェーピングする (sugarloaf/src/text.rs の shape_for)。文字単位の
#   フォールバックが無い。Claude Code はタイトルを "✳ ..." と設定するため、
#   HackGen が U+2733 を持たないと Segoe UI Emoji が選ばれ、そのフォントは日本語
#   グリフを持たないのでタイトルの日本語が全て豆腐になる。
#   HackGen 自身に U+2733 を持たせて、1 フォントで全体を描けるようにする。
#
# ドナーは Windows 同梱の Segoe UI Symbol。生成物はこの PC でのみ使う。
# 改変フォントなので再配布はしない。dotfiles にはこのスクリプトだけを置く。
#
# 冪等性: 常にバックアップ (.orig) を入力にしてパッチするため何度でも実行できる。
# HackGen を更新したら先に .orig を消してから実行する。
#
# 反映には Rio の再起動が必要。設定ファイルと違い自動では読み直されない。

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
patcher="${script_dir}/patch-font.py"
donor="/mnt/c/Windows/Fonts/seguisym.ttf"
backup_dir="${HOME}/.local/share/hackgen-backup"
venv_dir="${HOME}/.cache/hackgen-patch-venv"
faces=(Regular Bold)

if [[ ! -f "${donor}" ]]; then
  echo "error: ドナーフォントが見つかりません: ${donor}" >&2
  exit 1
fi

# Windows のユーザーフォントディレクトリを %LOCALAPPDATA% から解決する。
cmd_exe="/mnt/c/Windows/System32/cmd.exe"
if [[ ! -x "${cmd_exe}" ]]; then
  cmd_exe="$(command -v cmd.exe || true)"
fi
if [[ -z "${cmd_exe}" ]]; then
  echo "error: cmd.exe が見つかりません。WSL 上で実行してください。" >&2
  exit 1
fi

localappdata_win="$(cd /mnt/c && "${cmd_exe}" /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r\n')"
if [[ -z "${localappdata_win}" || "${localappdata_win}" == '%LOCALAPPDATA%' ]]; then
  echo "error: %LOCALAPPDATA% を解決できませんでした。" >&2
  exit 1
fi
font_dir="$(wslpath -u "${localappdata_win}")/Microsoft/Windows/Fonts"

if [[ ! -d "${font_dir}" ]]; then
  echo "error: フォントディレクトリが見つかりません: ${font_dir}" >&2
  exit 1
fi

if [[ ! -x "${venv_dir}/bin/python" ]]; then
  echo "info: fontTools 用の venv を作成します: ${venv_dir}"
  python3 -m venv "${venv_dir}"
  "${venv_dir}/bin/pip" install --quiet --upgrade pip
  "${venv_dir}/bin/pip" install --quiet fonttools
fi

mkdir -p "${backup_dir}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

for face in "${faces[@]}"; do
  installed="${font_dir}/HackGen35ConsoleNF-${face}.ttf"
  backup="${backup_dir}/HackGen35ConsoleNF-${face}.ttf.orig"

  if [[ ! -f "${installed}" && ! -f "${backup}" ]]; then
    echo "error: フォントが見つかりません: ${installed}" >&2
    exit 1
  fi

  if [[ ! -f "${backup}" ]]; then
    cp "${installed}" "${backup}"
    echo "info: 未改変のフォントを保存しました: ${backup}"
  fi

  out="${tmp_dir}/HackGen35ConsoleNF-${face}.ttf"
  "${venv_dir}/bin/python" "${patcher}" "${backup}" "${donor}" "${out}"
  cp -f "${out}" "${installed}"
  echo "installed: ${installed}"
done

echo
echo "Rio を再起動すると反映される。"
