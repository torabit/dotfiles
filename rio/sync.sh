#!/usr/bin/env bash
#
# WSL 側 dotfiles の Rio 設定を Windows 側 %LOCALAPPDATA%\rio\config.toml へ反映する。
#
# Rio は Windows ネイティブアプリなので stow の対象外。手動コピーで同期する。
#
# symlink を使わない理由:
#   WSL2 のファイルシステムが VHD 方式になった影響で、WSL 起動前は Windows 側から
#   リンク先 (\\wsl.localhost\...) を解決できず、Rio の設定読み込みが失敗する。
#   そのため実体をコピーする。
#
# Rio は設定ファイルの保存を検知して即座に再読み込みするため、再起動は不要。

set -euo pipefail

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="${src_dir}/config.toml"

if [[ ! -f "${src}" ]]; then
  echo "error: 設定ファイルが見つかりません: ${src}" >&2
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

# %LOCALAPPDATA% を Windows 側から取得する。ユーザー名をハードコードしない。
# cwd が UNC パスだと cmd.exe が警告を出すため /mnt/c で実行する。
localappdata_win="$(cd /mnt/c && "${cmd_exe}" /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r\n')"
if [[ -z "${localappdata_win}" || "${localappdata_win}" == '%LOCALAPPDATA%' ]]; then
  echo "error: %LOCALAPPDATA% を解決できませんでした。" >&2
  exit 1
fi

dest_dir="$(wslpath -u "${localappdata_win}")/rio"
dest="${dest_dir}/config.toml"

mkdir -p "${dest_dir}"

# 既存が symlink の場合は取り除いてから実体をコピーする
if [[ -L "${dest}" ]]; then
  echo "info: 既存の symlink を削除します: ${dest}"
  rm -f "${dest}"
fi

cp -f "${src}" "${dest}"

if ! diff -q "${src}" "${dest}" >/dev/null; then
  echo "error: コピー後の内容が一致しません: ${dest}" >&2
  exit 1
fi

echo "synced: ${src}"
echo "     -> ${dest}"
