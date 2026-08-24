#!/usr/bin/env bash
#
# IME のインライン表示パッチを当てた rio.exe を WSL 側でクロスビルドし、
# C:\Program Files\Rio\rio.exe を置き換える。
#
# 直したい症状:
#   rio で日本語を入力しても変換中の文字列が一切見えない。確定するまで何も出ない。
#
# 原因:
#   rio 0.5.26 には未確定文字列 (preedit) を描画するコードが無い。rio-window は
#   Windows から composition string を正しく取得して Ime::Preedit を送出し、
#   frontends/rioterm もそれを保持するが、描画側は先頭 1 文字を
#   renderable_content.cursor.content へ代入するだけで、そのフィールドはどこからも
#   読まれない。一方 rio-window は WM_IME_COMPOSITION で DefWindowProc を呼ばず
#   OS 側の描画を抑止している。結果、自前でも OS でも描かれない。
#
# なぜ自前ビルドなのか:
#   メンテナ自身の実装 PR raphamorim/rio#1849 が CI 全 green のまま未マージで、
#   main と衝突している。それを v0.5.26 へ移植したブランチを fork に置き、
#   マージされるまでこのスクリプトでビルドする。
#   #1849 がマージされたら、このスクリプトと fork は不要になる。
#
# ターゲットを x86_64-pc-windows-gnu にする理由:
#   msvc ターゲットは link.exe と Windows SDK を要求し、Windows 側に Visual Studio
#   Build Tools (数 GB) を入れることになる。gnu なら WSL 側の mingw-w64 だけで済み、
#   Windows 側を汚さない。rio の CI も MSYS2 (MINGW64/UCRT64/CLANG64) で通っている。
#
# mingw は posix threads 版を使う:
#   apt の update-alternatives 既定は win32 threads で、その libstdc++ は
#   std::once_flag / std::call_once を持たない。glslang-sys の C++ が
#   native/glslang/SPIRV/doc.cpp:1824 で落ちる。wgpu feature は Windows では必須で
#   librashader を外せないため、ツールチェイン側を合わせる。
#   CI が MSYS2 UCRT64 で通るのも UCRT64 の gcc が posix threads だから。
#
# debug ビルドは使えない:
#   このサイズのバイナリを最適化なしでリンクすると PE の export ordinal 上限を
#   超える。rio の CI にも同じ注記がある (.github/workflows/test.yml)。
#   thin LTO を使うのは出荷プロファイルの fat LTO よりビルドが速いから。
#   CI の msys2 スモークビルドと同じ設定。
#
# Program Files を上書きすることの注意:
#   毎回 UAC の昇格が入る。また MSI のアップグレードや修復で素の exe に戻される。
#   戻された場合は次回実行時に検知して警告する。
#   差し替えは rename 方式なので rio が起動中でも実行できるが、走っている
#   インスタンスは古い exe を掴んだままなので、反映には rio の再起動が必要。
#
# Rust は mise 管理 (~/.config/mise/config.toml の rust)。RUSTUP_TOOLCHAIN が
# mise によって張られるので、リポジトリの rust-toolchain.toml の pin は効かない。
# windows-gnu ターゲットは mise が管理しているツールチェインへ追加する。
#
# クロスビルドの設定は全て環境変数で渡し、rio のツリーの .cargo/config.toml は
# 書き換えない。fork のブランチにパッチ本体以外の差分を混ぜないため
# (上流へ投げるときに邪魔になる)。
#
# 冪等性: 何度でも実行できる。素の exe の退避は初回だけ。

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
linker="${script_dir}/mingw-gcc-static"
src_dir="${HOME}/ghq/github.com/torabit/rio"
branch_hint="torabit/fix/ime-preedit-inline"
target="x86_64-pc-windows-gnu"

die() {
  echo "error: $*" >&2
  exit 1
}

# ---- 事前チェック ----

[[ -x "${linker}" ]] || die "リンカラッパが実行可能ではありません: ${linker}"

if [[ ! -d "${src_dir}/.git" ]]; then
  cat >&2 <<EOF
error: rio の fork が見つかりません: ${src_dir}

  ghq get git@github.com:torabit/rio.git
  cd ${src_dir}
  git switch ${branch_hint}
EOF
  exit 1
fi

missing_apt=()
for bin in x86_64-w64-mingw32-gcc-posix x86_64-w64-mingw32-g++-posix \
           x86_64-w64-mingw32-ar x86_64-w64-mingw32-objdump; do
  command -v "${bin}" >/dev/null || missing_apt+=("${bin}")
done
command -v cmake >/dev/null || missing_apt+=(cmake)

if (( ${#missing_apt[@]} > 0 )); then
  cat >&2 <<EOF
error: 次のコマンドが見つかりません: ${missing_apt[*]}

  sudo apt-get install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 cmake
EOF
  exit 1
fi

if ! rustup target list --installed | grep -qx "${target}"; then
  cat >&2 <<EOF
error: Rust の ${target} ターゲットが入っていません。

  rustup target add ${target}
EOF
  exit 1
fi

cmd_exe="/mnt/c/Windows/System32/cmd.exe"
if [[ ! -x "${cmd_exe}" ]]; then
  cmd_exe="$(command -v cmd.exe || true)"
fi
[[ -n "${cmd_exe}" ]] || die "cmd.exe が見つかりません。WSL 上で実行してください。"

# 非対話の bash では Windows の PATH が引き継がれないことがあるため絶対パスで解決する。
powershell_exe="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
if [[ ! -x "${powershell_exe}" ]]; then
  powershell_exe="$(command -v powershell.exe || true)"
fi
[[ -n "${powershell_exe}" ]] || die "powershell.exe が見つかりません。"

# cwd が UNC パスだと cmd.exe が警告を出すため /mnt/c で実行する。
win_env() {
  (cd /mnt/c && "${cmd_exe}" /c "echo %$1%" 2>/dev/null | tr -d '\r\n')
}

program_files_win="$(win_env ProgramFiles)"
[[ -n "${program_files_win}" && "${program_files_win}" != '%ProgramFiles%' ]] \
  || die "%ProgramFiles% を解決できませんでした。"

localappdata_win="$(win_env LOCALAPPDATA)"
[[ -n "${localappdata_win}" && "${localappdata_win}" != '%LOCALAPPDATA%' ]] \
  || die "%LOCALAPPDATA% を解決できませんでした。"

dest="$(wslpath -u "${program_files_win}")/Rio/rio.exe"
[[ -f "${dest}" ]] || die "Rio がインストールされていません: ${dest}"

backup_dir="$(wslpath -u "${localappdata_win}")/rio/bin"
backup="${backup_dir}/rio-vanilla.exe"
marker="${backup_dir}/installed.sha256"

# ---- ビルド ----

cd "${src_dir}"
echo "source: ${src_dir}"
echo "branch: $(git branch --show-current || echo '(detached)')  commit: $(git rev-parse --short HEAD)"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "warn: 作業ツリーに未コミットの変更があります。それを含めてビルドします。"
fi

export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER="${linker}"
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix
export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix
export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
export CARGO_PROFILE_RELEASE_LTO=thin
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=8
export CARGO_PROFILE_RELEASE_DEBUG=0

echo
echo "building ${target} ..."
cargo build --locked -p rioterm --release --features wgpu --target "${target}"

built="${src_dir}/target/${target}/release/rio.exe"
[[ -f "${built}" ]] || die "ビルド成果物が見つかりません: ${built}"

# 単体で動く exe になっているかの不変条件。libstdc++-6.dll が残っていると
# Windows 側に無いので起動できない (exit 53)。mingw-gcc-static の役目の確認。
if x86_64-w64-mingw32-objdump -p "${built}" | grep -qi "libstdc++"; then
  die "libstdc++-6.dll への依存が残っています。${linker} が使われていない可能性があります。"
fi

echo "built: ${built} ($(du -h "${built}" | cut -f1))"

# ---- インストール ----

mkdir -p "${backup_dir}"

if [[ ! -f "${backup}" ]]; then
  # 初回のみ。2 回目以降に退避すると、自分が入れたパッチ版を「素の版」として
  # 保存してしまう。
  cp -f "${dest}" "${backup}"
  echo "backed up: ${dest}"
  echo "        -> ${backup}"
elif [[ -f "${marker}" ]] \
     && [[ "$(cat "${marker}")" != "$(sha256sum "${dest}" | cut -d' ' -f1)" ]]; then
  # 前回入れた exe と現物が違う。MSI のアップグレードか修復で置き換えられた模様。
  # 「素の版と一致するか」では判定できない。初回はまだ何も入れていないので
  # 一致するのが正常で、誤検知になる。
  echo "warn: 前回インストールした exe が別のものに置き換わっています。"
  echo "      MSI のアップグレードか修復で戻された模様。入れ直します。"
fi

# 昇格が必要なのは差し替えだけ。ps1 に落として実行するのは、bash から
# PowerShell の入れ子クォートを組み立てるのを避けるため。
#
# 起動中の rio.exe は上書きできないが rename はできる。実行中のインスタンスは
# 元のファイルを掴んだまま動き続け、次に起動したときから新しい exe が使われる。
# rio を端末として使っている最中でも差し替えられるようにこの形にしている
# (閉じてから実行する手順は、rio の中で作業していると成立しない)。
ps1="${backup_dir}/install.ps1"
ps1_log="${backup_dir}/install.log"
rm -f "${ps1_log}"

# 生成する ps1 は ASCII だけで書く。日本語コメントを入れてはいけない。
# PowerShell 5.1 は BOM の無い .ps1 をシステムの ANSI コードページ (日本語環境では
# CP932) として読む。UTF-8 の日本語が誤デコードされると後続の行がコメントに
# 飲まれ、変数が未定義になったまま実行が続く。実際に $old が null になって
# Move-Item が PSArgumentNullException で落ちた。説明はこちら側に書く。
#
# ps1 の内容:
#   1. 過去の差し替えで残った旧 exe を掃除する。まだプロセスが掴んでいると
#      消せないので失敗は無視して次回に回す。
#   2. 現在の rio.exe を一意な名前へ rename する。掴まれている旧 exe と
#      名前が衝突しないようタイムスタンプを入れる。
#   3. 新しい exe を rio.exe として置く。置けなかったら rename を巻き戻す。
#      rio.exe が存在しない状態で終わらせない。
#   4. 結果をログファイルへ書く。昇格した子の標準出力は親から拾えないため。
cat > "${ps1}" <<EOF
\$ErrorActionPreference = 'Stop'
\$log = '$(wslpath -w "${ps1_log}")'
try {
  \$dest = '$(wslpath -w "${dest}")'
  \$src  = '$(wslpath -w "${built}")'

  Get-ChildItem -LiteralPath (Split-Path -Parent \$dest) -Filter 'rio.exe.*.old' -ErrorAction SilentlyContinue |
    ForEach-Object { try { Remove-Item -LiteralPath \$_.FullName -Force } catch { } }

  \$old = "\$dest.\$([DateTime]::UtcNow.Ticks).old"
  Move-Item -LiteralPath \$dest -Destination \$old -Force
  try {
    Copy-Item -LiteralPath \$src -Destination \$dest -Force
  } catch {
    Move-Item -LiteralPath \$old -Destination \$dest -Force
    throw
  }
  'OK' | Out-File -FilePath \$log -Encoding utf8
} catch {
  "\$(\$_.Exception.GetType().FullName): \$(\$_.Exception.Message)" | Out-File -FilePath \$log -Encoding utf8
  exit 1
}
EOF

echo
echo "installing (UAC の昇格を求めます。承認してください) ..."
# 昇格した子の終了コードを -PassThru で拾う。承認を拒否した場合はここが
# 非 0 になるか、そもそも例外になる。原因を ps1 側のログから出す。
exit_code="$("${powershell_exe}" -NoProfile -ExecutionPolicy Bypass -Command "
  try {
    \$p = Start-Process powershell -Verb RunAs -Wait -PassThru -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$(wslpath -w "${ps1}")'
    Write-Output \$p.ExitCode
  } catch {
    Write-Output 'denied'
  }" 2>&1 | tr -d '\r\n')"

inner="$(tr -d '\r\0\357\273\277' < "${ps1_log}" 2>/dev/null || true)"

# 失敗したときは ps1 とログを残す。生成したスクリプトを見ないと原因が分からない。
if [[ "${exit_code}" == "denied" ]]; then
  die "UAC の昇格が拒否されました。Program Files を書き換えるには承認が必要です。"
fi
if [[ "${exit_code}" != "0" ]]; then
  die "昇格したプロセスが失敗しました (exit=${exit_code:-unknown}): ${inner:-理由不明}
     生成したスクリプト: ${ps1}"
fi

rm -f "${ps1}" "${ps1_log}"

# ---- 検証 ----

cmp -s "${built}" "${dest}" || die "コピー後の内容が一致しません: ${dest}"

version="$("${dest}" --version 2>&1 | tr -d '\r')" \
  || die "インストールした exe の実行に失敗しました: ${dest}"

# 次回実行時に「MSI に戻されたか」を判定するための記録。ハッシュだけを置く。
# sha256sum -c 形式にすると相対パスで記録され、照合時の cwd が
# rio のソースディレクトリなので必ず外す。
sha256sum "${dest}" | cut -d' ' -f1 > "${marker}"

echo
echo "installed: ${dest}"
echo "version:   ${version}"
echo "vanilla:   ${backup}"
echo
echo "起動中の rio は古い exe を掴んだままなので、反映には再起動が必要。"
