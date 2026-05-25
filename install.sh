#!/bin/sh
set -eu

REPO="izhiwen/AgentScienceLab"
ASL_VERSION_VALUE="${ASL_VERSION:-}"
ASL_RELEASES_LATEST_URL="${ASL_RELEASES_LATEST_URL:-https://github.com/$REPO/releases/latest}"
ASL_MINIMUM_SUPPORTED_MAJOR="${ASL_MINIMUM_SUPPORTED_MAJOR:-0}"
ASL_MINIMUM_SUPPORTED_MINOR="${ASL_MINIMUM_SUPPORTED_MINOR:-1}"
ASL_MINIMUM_SUPPORTED_PATCH="${ASL_MINIMUM_SUPPORTED_PATCH:-0}"
ASL_MINIMUM_SUPPORTED_VERSION="${ASL_MINIMUM_SUPPORTED_VERSION:-v$ASL_MINIMUM_SUPPORTED_MAJOR.$ASL_MINIMUM_SUPPORTED_MINOR.$ASL_MINIMUM_SUPPORTED_PATCH}"
INSTALL_DIR="${ASL_INSTALL_DIR:-$HOME/.local/bin}"
LIBEXEC_DIR="${ASL_LIBEXEC_DIR:-$(dirname "$INSTALL_DIR")/libexec}"
DRY_RUN=0
ADD_TO_PATH=0

usage() {
  cat <<'USAGE'
Install the asl command.

Usage:
  sh install.sh [--dry-run] [--add-to-path]

Environment:
  ASL_VERSION      Release version to install, default latest GitHub release
  ASL_INSTALL_DIR  Install directory for the asl wrapper, default $HOME/.local/bin
  ASL_LIBEXEC_DIR  Install directory for bundled runtime support, default ../libexec
  ASL_BASE_URL     Override release base URL for tests/mirrors

Flags:
  --dry-run        Print what would happen without writing
  --add-to-path    Append the install directory to your shell profile if needed
  -h, --help       Show this help

The installer downloads the ASL release package for this platform, verifies the
package SHA256 sidecar, and installs:
  - asl wrapper to $ASL_INSTALL_DIR/asl
  - bundled runtime support to $ASL_LIBEXEC_DIR/asl-support

It does not require sudo, install project files, upload data, collect telemetry,
or modify Codex/Claude Code/OpenCode config. It edits shell profiles only when
--add-to-path is set.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --add-to-path)
      ADD_TO_PATH=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR required command not found: $1" >&2
    exit 1
  fi
}

resolve_version() {
  if [ -n "$ASL_VERSION_VALUE" ]; then
    echo "$ASL_VERSION_VALUE"
    return 0
  fi
  if version_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$ASL_RELEASES_LATEST_URL" 2>/dev/null)"; then
    version="$(printf '%s' "$version_url" | sed -E 's#^.*/tag/##')"
    if [ -n "$version" ] && [ "$version" != "$version_url" ]; then
      echo "$version"
      return 0
    fi
  fi
  echo "WARNING could not resolve latest ASL release; falling back to $ASL_MINIMUM_SUPPORTED_VERSION" >&2
  echo "$ASL_MINIMUM_SUPPORTED_VERSION"
}

detect_asset() {
  version_no_v="$(printf '%s' "$VERSION" | sed 's/^v//')"
  os="$(uname -s)"
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="x86_64" ;;
    arm64|aarch64) arch="aarch64" ;;
  esac
  case "$os:$arch" in
    Darwin:aarch64|Darwin:x86_64)
      echo "asl-v$version_no_v-darwin-$arch.tar.gz"
      ;;
    *)
      echo "ERROR no ASL $VERSION package for: $os $arch" >&2
      echo "" >&2
      echo "Supported platforms (v0.2.0+):" >&2
      echo "  - macOS Apple Silicon (Darwin arm64)" >&2
      echo "  - Intel Windows (preview — manual download, see release page)" >&2
      echo "" >&2
      echo "Dropped platforms in v0.2.0 (matching upstream substrate decision):" >&2
      echo "  - Linux x86_64 / aarch64" >&2
      echo "  - Intel Mac (Darwin x86_64)" >&2
      echo "" >&2
      echo "Windows users: run the PowerShell installer:" >&2
      echo "  irm https://raw.githubusercontent.com/$REPO/main/install.ps1 | iex" >&2
      exit 1
      ;;
  esac
}

fetch() {
  src="$1"
  dst="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$src" -o "$dst"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$src" -O "$dst"
  else
    echo "ERROR curl or wget is required" >&2
    exit 1
  fi
}

profile_display() {
  path="$1"
  case "$path" in
    "$HOME"/*)
      echo "~/${path#"$HOME"/}"
      ;;
    *)
      echo "$path"
      ;;
  esac
}

append_path_to_profile() {
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    zsh)
      profile="$HOME/.zshrc"
      line="export PATH=\"$INSTALL_DIR:\$PATH\""
      source_hint="source ~/.zshrc"
      ;;
    bash)
      profile="$HOME/.bashrc"
      line="export PATH=\"$INSTALL_DIR:\$PATH\""
      source_hint="source ~/.bashrc"
      ;;
    fish)
      profile="$HOME/.config/fish/config.fish"
      line="set -gx PATH \"$INSTALL_DIR\" \$PATH"
      source_hint="source ~/.config/fish/config.fish"
      mkdir -p "$(dirname "$profile")"
      ;;
    *)
      echo "ERROR unsupported shell for --add-to-path: ${SHELL:-unknown}" >&2
      echo "Add this to your shell profile manually:" >&2
      echo "  export PATH=\"$INSTALL_DIR:\$PATH\"" >&2
      exit 1
      ;;
  esac

  touch "$profile"
  display="$(profile_display "$profile")"
  if grep -Fqx "$line" "$profile"; then
    echo "PATH_PROFILE_ALREADY_CONFIGURED=$display"
    echo "$display already contains the ASL PATH line"
    echo "restart your shell or run: $source_hint"
    return 0
  fi
  printf '%s\n' "$line" >> "$profile"
  echo "PATH_PROFILE_APPENDED=$display"
  echo "appended to $display"
  echo "restart your shell or run: $source_hint"
}

sha256_verify() {
  sidecar="$1"
  asset="$2"
  asset_name="$(basename "$asset")"
  expected="$(awk '{print $1}' "$sidecar" | head -n 1)"
  if [ -z "$expected" ]; then
    echo "ERROR checksum sidecar is empty: $sidecar" >&2
    exit 1
  fi
  printf '%s  %s\n' "$expected" "$asset_name" > "$TMP_DIR/asset.sha256"
  if command -v shasum >/dev/null 2>&1; then
    (cd "$(dirname "$asset")" && shasum -a 256 -c "$TMP_DIR/asset.sha256")
  elif command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "$asset")" && sha256sum -c "$TMP_DIR/asset.sha256")
  else
    echo "ERROR shasum or sha256sum is required for checksum verification" >&2
    exit 1
  fi
}

need_cmd uname
need_cmd mktemp
need_cmd tar
need_cmd chmod
need_cmd basename

VERSION="$(resolve_version)"
ASSET="$(detect_asset)"
BASE_URL="${ASL_BASE_URL:-https://github.com/$REPO/releases/download/$VERSION}"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

echo "ASL installer"
echo "version=$VERSION"
echo "asset=$ASSET"
echo "install_dir=$INSTALL_DIR"
echo "libexec_dir=$LIBEXEC_DIR"
echo "writes=$INSTALL_DIR/asl"
if [ "$ADD_TO_PATH" -eq 1 ]; then
  echo "shell_profile_edits=opt-in"
else
  echo "shell_profile_edits=none"
fi
echo "telemetry=none"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY_RUN=YES"
  echo "download=$BASE_URL/$ASSET"
  echo "checksum=$BASE_URL/$ASSET.sha256"
  if [ "$ADD_TO_PATH" -eq 1 ]; then
    echo "add_to_path=would_update_profile_if_needed"
  fi
  exit 0
fi

fetch "$BASE_URL/$ASSET.sha256" "$TMP_DIR/$ASSET.sha256"
fetch "$BASE_URL/$ASSET" "$TMP_DIR/$ASSET"
sha256_verify "$TMP_DIR/$ASSET.sha256" "$TMP_DIR/$ASSET"

mkdir -p "$TMP_DIR/extract"
tar -xzf "$TMP_DIR/$ASSET" -C "$TMP_DIR/extract"

ASL_BIN="$(find "$TMP_DIR/extract" -type f -path "*/bin/asl" | head -n 1)"
SUPPORT_BIN="$(find "$TMP_DIR/extract" -type f -path "*/libexec/asl-support" | head -n 1)"
if [ ! -f "$ASL_BIN" ]; then
  echo "ERROR release archive did not contain bin/asl" >&2
  exit 1
fi
if [ ! -f "$SUPPORT_BIN" ]; then
  echo "ERROR release archive did not contain libexec support binary" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR" "$LIBEXEC_DIR"
cp "$ASL_BIN" "$INSTALL_DIR/asl"
cp "$SUPPORT_BIN" "$LIBEXEC_DIR/asl-support"
chmod 755 "$INSTALL_DIR/asl" "$LIBEXEC_DIR/asl-support"

echo "INSTALL_STATUS=PASS"
echo "installed=$INSTALL_DIR/asl"

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    if [ "$ADD_TO_PATH" -eq 1 ]; then
      append_path_to_profile
    else
      echo "PATH_NOTICE=$INSTALL_DIR is not on PATH"
      echo "Add this to your shell profile if you want to run asl from any terminal:"
      echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
    ;;
esac

echo "Next:"
echo "  cd MyProject"
echo "  asl                          # auto-sets-up the team on first run, then opens the lobby"
echo "  asl advisor                  # or jump straight to advisor"
echo "  asl pi                       # or straight to PI"
