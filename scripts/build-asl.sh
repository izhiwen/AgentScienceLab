#!/usr/bin/env bash
# Build and optionally package the ASL independent wrapper with its vendored runtime.

set -euo pipefail

ASL_VERSION="${ASL_VERSION:-0.3.0}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_ROOT="$REPO_ROOT/vendor/aiplus"
DIST_ROOT="$REPO_ROOT/dist"

usage() {
  cat <<'EOF'
Usage:
  scripts/build-asl.sh [--package]

Builds vendor/aiplus/target/release/aiplus after syncing this ASL checkout into
the vendored runtime's bundled ASL asset. With --package, creates a release
tarball under dist/.
EOF
}

PACKAGE=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --package)
      PACKAGE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[ -e "$VENDOR_ROOT/.git" ] || {
  echo "vendor/aiplus submodule is missing. Run: git submodule update --init --recursive" >&2
  exit 1
}

pre_sync_dirty="$(git -C "$VENDOR_ROOT" status --porcelain -- assets/agentsciencelab || true)"
if [ -n "$pre_sync_dirty" ]; then
  echo "vendor/aiplus/assets/agentsciencelab has pre-existing changes; refusing to overwrite them." >&2
  echo "$pre_sync_dirty" >&2
  exit 1
fi

cleanup_synced_asset() {
  git -C "$VENDOR_ROOT" restore --worktree --staged assets/agentsciencelab >/dev/null 2>&1 || true
  git -C "$VENDOR_ROOT" clean -fd -- assets/agentsciencelab >/dev/null 2>&1 || true
}
trap cleanup_synced_asset EXIT

sync_ael_asset() {
  # tar pipe instead of rsync — rsync is not available on Windows
  # git-bash runners, but tar always is (we rely on it for packaging
  # anyway). Same exclude semantics: skip repository-local runtime
  # state, external metadata, build outputs, and media asset files.
  rm -rf "$VENDOR_ROOT/assets/agentsciencelab"
  mkdir -p "$VENDOR_ROOT/assets/agentsciencelab"
  (
    cd "$REPO_ROOT"
    tar -cf - \
      --exclude='./.git' \
      --exclude='./.github' \
      --exclude='./.aiplus' \
      --exclude='./.claude' \
      --exclude='./.codex' \
      --exclude='./.opencode' \
      --exclude='./.agents' \
      --exclude='./.mcp.json' \
      --exclude='./AGENTS.md' \
      --exclude='./CLAUDE.md' \
      --exclude='./opencode.json' \
      --exclude='./.DS_Store' \
      --exclude='./vendor' \
      --exclude='./dist' \
      --exclude='./target' \
      --exclude='Thumbs.db' \
      --exclude='*.gif' \
      --exclude='*.png' \
      --exclude='*.jpg' \
      --exclude='*.mp4' \
      --exclude='*.mov' \
      .
  ) | (cd "$VENDOR_ROOT/assets/agentsciencelab" && tar -xf -)
}

host_triple() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="x86_64" ;;
    arm64|aarch64) arch="aarch64" ;;
  esac
  case "$os" in
    mingw*|msys*|cygwin*) os="windows" ;;
  esac
  printf '%s-%s\n' "$os" "$arch"
}

is_windows_host() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

binary_basename() {
  if is_windows_host; then echo "aiplus.exe"; else echo "aiplus"; fi
}

sync_ael_asset
cargo build --release --bin aiplus --manifest-path "$VENDOR_ROOT/Cargo.toml"
binary_path="$VENDOR_ROOT/target/release/$(binary_basename)"
"$binary_path" --version

if [ "$PACKAGE" -eq 1 ]; then
  triple="$(host_triple)"
  package_dir="$DIST_ROOT/asl-v$ASL_VERSION-$triple"
  rm -rf "$package_dir"
  mkdir -p "$package_dir/bin" "$package_dir/libexec"
  if is_windows_host; then
    cp "$REPO_ROOT/install.ps1" "$package_dir/install.ps1"
    cp "$REPO_ROOT/bin/asl.cmd" "$package_dir/bin/asl.cmd"
    cp "$REPO_ROOT/bin/asl.ps1" "$package_dir/bin/asl.ps1"
    cp "$binary_path" "$package_dir/libexec/asl-support.exe"
  else
    # Bash wrapper remains the Mac/Linux artifact. Windows ships only
    # the native PowerShell wrapper and cmd.exe shim.
    cp "$REPO_ROOT/asl" "$package_dir/bin/asl"
    cp "$binary_path" "$package_dir/libexec/asl-support"
  fi
  cp "$REPO_ROOT/LICENSE" "$package_dir/LICENSE"
  cp "$REPO_ROOT/README.md" "$package_dir/README.md"
  if ! is_windows_host; then
    chmod +x "$package_dir/bin/asl" "$package_dir/libexec/asl-support"
  fi
  tar -C "$DIST_ROOT" -czf "$package_dir.tar.gz" "$(basename "$package_dir")"
  echo "ASL_PACKAGE=$package_dir.tar.gz"
else
  echo "ASL_BUILD=PASS"
fi
