param(
  [switch]$AddToPath,
  [switch]$DryRun,
  [switch]$Help
)

$ErrorActionPreference = "Stop"

$Repo = if ($env:ASL_REPO) { $env:ASL_REPO } else { "izhiwen/AgentScienceLab" }
$MinimumSupported = if ($env:ASL_MINIMUM_SUPPORTED_VERSION) { $env:ASL_MINIMUM_SUPPORTED_VERSION } else { "v0.3.0" }
$LatestUrl = if ($env:ASL_RELEASES_LATEST_URL) { $env:ASL_RELEASES_LATEST_URL } else { "https://github.com/$Repo/releases/latest" }
$VersionOverride = $env:ASL_VERSION
$BaseLocal = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $env:USERPROFILE "AppData\Local" }
$InstallDir = if ($env:ASL_INSTALL_DIR) { $env:ASL_INSTALL_DIR } else { Join-Path $BaseLocal "Programs\ASL\bin" }
$LibexecDir = if ($env:ASL_LIBEXEC_DIR) { $env:ASL_LIBEXEC_DIR } else { Join-Path $BaseLocal "Programs\ASL\libexec" }

function Show-Usage {
  @"
Install the asl command.

Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1 [-DryRun] [-AddToPath]

Environment:
  ASL_VERSION      Release version to install, default latest GitHub release
  ASL_INSTALL_DIR  Install directory for asl.cmd and asl.ps1
  ASL_LIBEXEC_DIR  Install directory for bundled runtime support
  ASL_BASE_URL     Override release base URL for tests/mirrors

Flags:
  -DryRun          Print what would happen without writing
  -AddToPath       Append the install directory to the user PATH if needed
  -Help            Show this help

The installer downloads the ASL release package for Windows, verifies the
package SHA256 sidecar, and installs:
  - asl.cmd and asl.ps1 to the install directory
  - bundled runtime support to the libexec directory

It does not require administrator rights, install project files, upload data,
collect telemetry, or modify runtime config. It edits PATH only when -AddToPath
is set.
"@
}

function Normalize-Version([string]$Value) {
  if ($Value.StartsWith("v")) { return $Value }
  return "v$Value"
}

function Parse-Version-From-Url([string]$Url) {
  if ($Url -match "/tag/(v?[0-9][^/?#]*)") {
    return (Normalize-Version $Matches[1])
  }
  return $null
}

function Resolve-Version {
  if ($VersionOverride) {
    return (Normalize-Version $VersionOverride)
  }

  if ($env:ASL_TEST_LATEST_EFFECTIVE_URL) {
    $parsed = Parse-Version-From-Url $env:ASL_TEST_LATEST_EFFECTIVE_URL
    if ($parsed) { return $parsed }
  }

  try {
    $request = [System.Net.WebRequest]::Create($LatestUrl)
    $request.Method = "HEAD"
    $request.AllowAutoRedirect = $true
    $response = $request.GetResponse()
    try {
      $parsed = Parse-Version-From-Url $response.ResponseUri.AbsoluteUri
      if ($parsed) { return $parsed }
    } finally {
      $response.Close()
    }
  } catch {
    Write-Warning "could not resolve latest ASL release; falling back to $MinimumSupported"
    return (Normalize-Version $MinimumSupported)
  }

  Write-Warning "could not resolve latest ASL release; falling back to $MinimumSupported"
  return (Normalize-Version $MinimumSupported)
}

function Get-Asset-Name([string]$Version) {
  $versionNoV = $Version.TrimStart("v")
  return "asl-v$versionNoV-windows-x86_64.tar.gz"
}

function Copy-Url([string]$Source, [string]$Destination) {
  if ($Source -match "^file://") {
    $localPath = ([System.Uri]$Source).LocalPath
    Copy-Item -LiteralPath $localPath -Destination $Destination -Force
    return
  }
  Invoke-WebRequest -Uri $Source -OutFile $Destination -UseBasicParsing
}

function Sanitize-SubstrateOutput([string]$Text) {
  $Text = $Text -replace "(?<![./-])\bAiPlus\b", "ASL"
  $Text = $Text -replace "(?<![./-])\baiplus\b", "asl"
  $Text = $Text -replace "(?<![./-])\bAIPLUS\b", "ASL"
  return $Text
}

function Test-Sha256([string]$Sidecar, [string]$Asset) {
  $expected = ((Get-Content -LiteralPath $Sidecar -TotalCount 1) -split "\s+")[0]
  if (-not $expected) {
    throw "checksum sidecar is empty: $Sidecar"
  }
  $actual = (Get-FileHash -LiteralPath $Asset -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $expected.ToLowerInvariant()) {
    throw "checksum mismatch for $(Split-Path -Leaf $Asset): expected $expected actual $actual"
  }
  Write-Host "SHA256_STATUS=PASS"
}

function Test-PathEntry([string]$PathValue, [string]$Entry) {
  if (-not $PathValue) { return $false }
  $target = $Entry.TrimEnd("\")
  foreach ($part in ($PathValue -split ";")) {
    if ($part.TrimEnd("\").Equals($target, [System.StringComparison]::OrdinalIgnoreCase)) {
      return $true
    }
  }
  return $false
}

function Escape-SingleQuoted([string]$Value) {
  return $Value.Replace("'", "''")
}

function Show-Manual-PathCommand([string]$Dir) {
  $escaped = Escape-SingleQuoted $Dir
  Write-Host "PATH_NOTICE=$Dir is not on PATH"
  Write-Host "Run this PowerShell command if you want to run asl from any terminal:"
  Write-Host "  `$p=[Environment]::GetEnvironmentVariable('Path','User'); if (-not ((`$p -split ';') -contains '$escaped')) { [Environment]::SetEnvironmentVariable('Path', ((`$p.TrimEnd(';') + ';$escaped').Trim(';')), 'User') }"
}

function Send-EnvironmentBroadcast {
  if ($env:ASL_SKIP_PATH_BROADCAST -eq "1") { return }
  $signature = @"
using System;
using System.Runtime.InteropServices;
public static class AelEnvironmentBroadcast {
  [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
  public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@
  try {
    Add-Type -TypeDefinition $signature -ErrorAction SilentlyContinue | Out-Null
    $result = [UIntPtr]::Zero
    [AelEnvironmentBroadcast]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, "Environment", 0x2, 5000, [ref]$result) | Out-Null
  } catch {
    Write-Warning "PATH was updated, but broadcasting the environment change failed. Open a new terminal if asl is not found."
  }
}

function Add-InstallDir-ToPath([string]$Dir) {
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if (Test-PathEntry $userPath $Dir) {
    Write-Host "PATH_USER_ALREADY_CONFIGURED=$Dir"
    return
  }

  $newPath = if ($userPath) { ($userPath.TrimEnd(";") + ";$Dir") } else { $Dir }
  [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
  $env:Path = if ($env:Path) { "$env:Path;$Dir" } else { $Dir }
  Send-EnvironmentBroadcast
  Write-Host "PATH_USER_APPENDED=$Dir"
  Write-Host "Open a new terminal, then run: asl"
}

if ($Help) {
  Show-Usage
  exit 0
}

$Version = Resolve-Version
$Asset = Get-Asset-Name $Version
$BaseUrl = if ($env:ASL_BASE_URL) { $env:ASL_BASE_URL.TrimEnd("/") } else { "https://github.com/$Repo/releases/download/$Version" }

Write-Host "ASL installer"
Write-Host "version=$Version"
Write-Host "asset=$Asset"
Write-Host "install_dir=$InstallDir"
Write-Host "libexec_dir=$LibexecDir"
Write-Host "writes=$InstallDir\asl.cmd"
Write-Host "path_edits=$(if ($AddToPath) { 'opt-in' } else { 'none' })"
Write-Host "telemetry=none"

if ($DryRun) {
  Write-Host "DRY_RUN=YES"
  Write-Host "download=$BaseUrl/$Asset"
  Write-Host "checksum=$BaseUrl/$Asset.sha256"
  if ($AddToPath) {
    Write-Host "add_to_path=would_update_user_path_if_needed"
  }
  exit 0
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("asl-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
try {
  $AssetPath = Join-Path $TempDir $Asset
  $SidecarPath = Join-Path $TempDir "$Asset.sha256"
  Copy-Url "$BaseUrl/$Asset.sha256" $SidecarPath
  Copy-Url "$BaseUrl/$Asset" $AssetPath
  Test-Sha256 $SidecarPath $AssetPath

  $ExtractDir = Join-Path $TempDir "extract"
  New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null
  & tar -xzf $AssetPath -C $ExtractDir
  if ($LASTEXITCODE -ne 0) {
    throw "tar extraction failed with exit code $LASTEXITCODE"
  }

  $Cmd = Get-ChildItem -LiteralPath $ExtractDir -Recurse -File -Filter "asl.cmd" | Select-Object -First 1
  $Ps1 = Get-ChildItem -LiteralPath $ExtractDir -Recurse -File -Filter "asl.ps1" | Select-Object -First 1
  $Support = Get-ChildItem -LiteralPath $ExtractDir -Recurse -File -Filter "asl-support.exe" | Select-Object -First 1
  if (-not $Cmd) { throw "release archive did not contain bin/asl.cmd" }
  if (-not $Ps1) { throw "release archive did not contain bin/asl.ps1" }
  if (-not $Support) { throw "release archive did not contain libexec/asl-support.exe" }

  New-Item -ItemType Directory -Force -Path $InstallDir, $LibexecDir | Out-Null
  Copy-Item -LiteralPath $Cmd.FullName -Destination (Join-Path $InstallDir "asl.cmd") -Force
  Copy-Item -LiteralPath $Ps1.FullName -Destination (Join-Path $InstallDir "asl.ps1") -Force
  Copy-Item -LiteralPath $Support.FullName -Destination (Join-Path $LibexecDir "asl-support.exe") -Force

  Write-Host "INSTALL_STATUS=PASS"
  Write-Host "installed=$InstallDir\asl.cmd"

  if (-not (Test-PathEntry $env:Path $InstallDir)) {
    if ($AddToPath) {
      Add-InstallDir-ToPath $InstallDir
    } else {
      Show-Manual-PathCommand $InstallDir
    }
  }

  Write-Host "Next:"
  Write-Host "  cd MyProject"
  Write-Host "  asl install                  # once per project - sets up the research team"
  Write-Host "  asl                          # opens the lobby - pick who to talk to (PI, Advisor, writer, ...)"
  Write-Host "  asl advisor                  # or jump straight to advisor"
  Write-Host "  asl pi                       # or straight to PI"
} finally {
  Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
