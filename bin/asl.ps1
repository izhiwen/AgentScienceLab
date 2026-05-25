$ErrorActionPreference = "Stop"

$script:AelVersion = if ($env:ASL_VERSION) { $env:ASL_VERSION.TrimStart("v") } else { "0.3.0" }
$script:AelRepo = if ($env:ASL_REPO) { $env:ASL_REPO } else { "izhiwen/AgentScienceLab" }
$script:MinimumSupported = if ($env:ASL_MINIMUM_SUPPORTED_VERSION) { $env:ASL_MINIMUM_SUPPORTED_VERSION } else { "v0.3.0" }
$script:BinDir = Split-Path -Parent $PSCommandPath
$script:AelRoot = $script:BinDir
if (Test-Path (Join-Path (Split-Path -Parent $script:BinDir) "libexec")) {
  $script:AelRoot = Split-Path -Parent $script:BinDir
}
if ([string]::IsNullOrEmpty($env:AIPLUS_BRAND)) { $env:AIPLUS_BRAND = "ASL" }
if ([string]::IsNullOrEmpty($env:AIPLUS_TEAM)) { $env:AIPLUS_TEAM = "agentsciencelab" }
if ([string]::IsNullOrEmpty($env:AIPLUS_DEFAULT_ROLE)) { $env:AIPLUS_DEFAULT_ROLE = "pi" }

function Write-AelError([string]$Message) {
  [Console]::Error.WriteLine("asl: $Message")
}

function Write-AelOut([string]$Text = "") {
  Write-Output $Text
}

function Exit-WithError([string]$Message, [int]$Code = 1) {
  Write-AelError $Message
  exit $Code
}

function Show-Usage {
  $text = @"
ASL $script:AelVersion

Usage:
  asl install [codex|claude-code|opencode|all]   set up the research team here (once per project)
  asl update [--dry-run]                          update the installed asl CLI
  asl uninstall [--purge] [--yes]                 remove the installed asl CLI
  asl                                             open the lobby - pick or describe who you want to talk to
  asl <role>                                      shortcut: resume the last chat with that role
  asl status                                      show installed team + active runtime
  asl refresh [--dry-run]                         refresh managed project assets
  asl doctor [--fix] [--yes]                      self-check and fix common drift

Roles you can chat with directly:
  asl pi                                          项目经理 - 派单、跟进、汇总
  asl advisor                                     顾问 - 反思、识别策略、框架
  asl writer                                      写手 - 起草段落、引言、改稿
  asl ra-stata                                    实证 RA - 回归、表格、Stata
  asl ra-python                                   数据 RA - 清洗、合并、Python
  asl theorist                                    理论 - 识别假设、模型
  asl referee                                     内审 - 内部自审
  asl replicator                                  复现 - clean-room 复跑
  asl pm                                          项目管理 - Gantt、deadline

Advanced (you rarely need these once you are in chat):
  asl talk [--runtime RUNTIME] <role> [prompt...]
  asl talk --resume <role> [--last|--list]
  asl route <role> <task...>
  asl update [--dry-run]
  asl uninstall [--purge] [--yes]
  asl --version

Environment variables:
  ASL_AIPLUS_BIN=/path/to/asl-support             use a specific bundled runtime

Recommended flow:
  asl install                       # Windows: set up the team once per project
  asl                               # then open the lobby - pick who you want
                                    # type/say who you want (PI, Advisor, ...)
                                    # or "我想反思 RD 设计" and it routes you to Advisor

Two-window pattern (for serious paper work):
  Window 1: asl advisor             # consult on framing / identification
  Window 2: asl pi                  # issue execution instructions

Examples:
  asl install
  asl update --dry-run                # preview an available CLI update
  asl uninstall --yes                 # remove the installed CLI, keep project files
  asl                               # opens the lobby
  asl pi                            # resume PI for this project
  asl advisor                       # resume Advisor for this project
  asl advisor --fresh               # open a new Advisor session
"@
  Write-AelOut $text
}

function Get-InstallDir {
  if ($env:ASL_INSTALL_DIR) { return $env:ASL_INSTALL_DIR }
  if ($env:LOCALAPPDATA) { return (Join-Path $env:LOCALAPPDATA "Programs\ASL\bin") }
  return (Join-Path $env:USERPROFILE "AppData\Local\Programs\ASL\bin")
}

function Get-LibexecDir {
  if ($env:ASL_LIBEXEC_DIR) { return $env:ASL_LIBEXEC_DIR }
  if ($env:LOCALAPPDATA) { return (Join-Path $env:LOCALAPPDATA "Programs\ASL\libexec") }
  return (Join-Path $env:USERPROFILE "AppData\Local\Programs\ASL\libexec")
}

function Normalize-Version([string]$Value) {
  if ($Value.StartsWith("v")) { return $Value.TrimStart("v") }
  return $Value
}

function Parse-Version-From-Url([string]$Url) {
  if ($Url -match "/tag/(v?[0-9][^/?#]*)") {
    return (Normalize-Version $Matches[1])
  }
  return $null
}

function Get-LatestReleaseVersion {
  if ($env:ASL_UPDATE_LATEST_VERSION) {
    return (Normalize-Version $env:ASL_UPDATE_LATEST_VERSION)
  }
  if ($env:ASL_TEST_LATEST_EFFECTIVE_URL) {
    $parsed = Parse-Version-From-Url $env:ASL_TEST_LATEST_EFFECTIVE_URL
    if ($parsed) { return $parsed }
  }
  $latestUrl = if ($env:ASL_RELEASES_LATEST_URL) { $env:ASL_RELEASES_LATEST_URL } else { "https://github.com/$script:AelRepo/releases/latest" }
  try {
    $request = [System.Net.WebRequest]::Create($latestUrl)
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
    Exit-WithError "could not resolve latest ASL release"
  }
  Exit-WithError "could not parse latest ASL release"
}

function Get-CurrentInstalledVersion {
  $installed = Join-Path (Get-InstallDir) "asl.ps1"
  $versionOut = ""
  if (Test-Path $installed) {
    $versionOut = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installed --version 2>$null | Select-Object -First 1)
  }
  if (-not $versionOut) {
    $versionOut = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath --version 2>$null | Select-Object -First 1)
  }
  if ($versionOut -match "^ASL\s+(v?[0-9]+(?:\.[0-9]+){1,2})") {
    return (Normalize-Version $Matches[1])
  }
  return $null
}

function Get-WindowsAsset([string]$Version) {
  $v = Normalize-Version $Version
  return "asl-v$v-windows-x86_64.tar.gz"
}

function Copy-Url([string]$Source, [string]$Destination) {
  if ($Source -match "^file://") {
    Copy-Item -LiteralPath ([System.Uri]$Source).LocalPath -Destination $Destination -Force
    return
  }
  Invoke-WebRequest -Uri $Source -OutFile $Destination -UseBasicParsing
}

function Test-Sha256([string]$Sidecar, [string]$Asset) {
  $expected = ((Get-Content -LiteralPath $Sidecar -TotalCount 1) -split "\s+")[0]
  if (-not $expected) { Exit-WithError "checksum sidecar is empty: $Sidecar" }
  $actual = (Get-FileHash -LiteralPath $Asset -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $expected.ToLowerInvariant()) {
    Exit-WithError "checksum mismatch for $(Split-Path -Leaf $Asset)"
  }
}

function Get-SubstrateBin {
  $candidates = @()
  if ($env:ASL_AIPLUS_BIN) { $candidates += $env:ASL_AIPLUS_BIN }
  $candidates += @(
    (Join-Path $script:BinDir "libexec\asl-support.exe"),
    (Join-Path (Split-Path -Parent $script:BinDir) "libexec\asl-support.exe"),
    (Join-Path $script:AelRoot "libexec\asl-support.exe"),
    (Join-Path $script:AelRoot "vendor\aiplus\target\release\aiplus.exe")
  )
  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) { return $candidate }
  }
  Exit-WithError "bundled runtime not built. Install ASL again or run scripts/build-asl.sh."
}

function Invoke-SubstrateQuiet([string[]]$SubArgs) {
  $bin = Get-SubstrateBin
  $tmp = New-TemporaryFile
  try {
    & $bin @SubArgs > $tmp 2>&1
    $status = $LASTEXITCODE
    if ($status -ne 0) {
      Get-Content -LiteralPath $tmp | ForEach-Object { [Console]::Error.WriteLine($_) }
    }
    return $status
  } finally {
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  }
}

function Invoke-SubstrateVisible([string[]]$SubArgs) {
  $bin = Get-SubstrateBin
  & $bin @SubArgs
  return $LASTEXITCODE
}

function Invoke-SubstrateInteractive([string[]]$SubArgs) {
  $bin = Get-SubstrateBin
  if ($SubArgs.Count -gt 0) {
    & $bin @SubArgs
  } else {
    & $bin
  }
  return $LASTEXITCODE
}

function Invoke-Update([string[]]$UpdateArgs) {
  $dryRun = $false
  foreach ($arg in $UpdateArgs) {
    switch ($arg) {
      "--dry-run" { $dryRun = $true }
      "-h" { Write-AelOut "Usage: asl update [--dry-run]"; return 0 }
      "--help" { Write-AelOut "Usage: asl update [--dry-run]"; return 0 }
      default { Exit-WithError "usage: asl update [--dry-run]" }
    }
  }

  $latest = Get-LatestReleaseVersion
  $installed = Get-CurrentInstalledVersion
  if (-not $installed) { Exit-WithError "could not determine installed ASL version" }
  if ($installed -eq $latest) {
    Write-AelOut "ASL $installed is already up-to-date"
    return 0
  }

  $asset = Get-WindowsAsset $latest
  $baseUrl = if ($env:ASL_BASE_URL) { $env:ASL_BASE_URL.TrimEnd("/") } else { "https://github.com/$script:AelRepo/releases/download/v$latest" }
  $targetInstall = Get-InstallDir
  $targetLibexec = Get-LibexecDir
  Write-AelOut "ASL $installed -> ASL $latest"
  Write-AelOut "download=$baseUrl/$asset"
  Write-AelOut "install_dir=$targetInstall"
  Write-AelOut "libexec_dir=$targetLibexec"

  if ($dryRun) {
    Write-AelOut "DRY_RUN=YES"
    Write-AelOut "would_verify=$baseUrl/$asset.sha256"
    Write-AelOut "would_replace=$targetInstall\asl.cmd"
    Write-AelOut "would_replace=$targetInstall\asl.ps1"
    Write-AelOut "would_replace=$targetLibexec\asl-support.exe"
    return 0
  }

  $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("asl-update-" + [System.Guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
  try {
    $assetPath = Join-Path $tmpDir $asset
    $sidecarPath = Join-Path $tmpDir "$asset.sha256"
    Copy-Url "$baseUrl/$asset.sha256" $sidecarPath
    Copy-Url "$baseUrl/$asset" $assetPath
    Test-Sha256 $sidecarPath $assetPath
    $extract = Join-Path $tmpDir "extract"
    New-Item -ItemType Directory -Force -Path $extract | Out-Null
    & tar -xzf $assetPath -C $extract
    if ($LASTEXITCODE -ne 0) { Exit-WithError "tar extraction failed with exit code $LASTEXITCODE" }
    $cmd = Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "asl.cmd" | Select-Object -First 1
    $ps1 = Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "asl.ps1" | Select-Object -First 1
    $support = Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "asl-support.exe" | Select-Object -First 1
    if (-not $cmd) { Exit-WithError "release archive did not contain bin/asl.cmd" }
    if (-not $ps1) { Exit-WithError "release archive did not contain bin/asl.ps1" }
    if (-not $support) { Exit-WithError "release archive did not contain libexec/asl-support.exe" }
    New-Item -ItemType Directory -Force -Path $targetInstall, $targetLibexec | Out-Null
    Copy-Item -LiteralPath $cmd.FullName -Destination (Join-Path $targetInstall "asl.cmd") -Force
    Copy-Item -LiteralPath $ps1.FullName -Destination (Join-Path $targetInstall "asl.ps1") -Force
    Copy-Item -LiteralPath $support.FullName -Destination (Join-Path $targetLibexec "asl-support.exe") -Force
    Write-AelOut "UPDATE_STATUS=PASS"
    Write-AelOut "installed=$targetInstall\asl.cmd"
    return 0
  } finally {
    Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Confirm-Uninstall([bool]$Purge) {
  $message = "Remove ASL from this machine"
  if ($Purge) { $message += " and purge this project team directory" }
  $answer = Read-Host "$message? [y/N]"
  return ($answer -in @("y", "Y", "yes", "YES"))
}

function Invoke-Uninstall([string[]]$UninstallArgs) {
  $purge = $false
  $yes = $false
  foreach ($arg in $UninstallArgs) {
    switch ($arg) {
      "--purge" { $purge = $true }
      "--yes" { $yes = $true }
      "-y" { $yes = $true }
      "-h" { Write-AelOut "Usage: asl uninstall [--purge] [--yes]"; return 0 }
      "--help" { Write-AelOut "Usage: asl uninstall [--purge] [--yes]"; return 0 }
      default { Exit-WithError "usage: asl uninstall [--purge] [--yes]" }
    }
  }
  if (-not $yes) {
    if (-not (Confirm-Uninstall $purge)) {
      Write-AelOut "UNINSTALL_STATUS=CANCELLED"
      return 1
    }
  }
  $removed = $false
  $install = Get-InstallDir
  $libexec = Get-LibexecDir
  Write-AelOut "ASL uninstall"
  foreach ($target in @((Join-Path $install "asl.cmd"), (Join-Path $install "asl.ps1"), (Join-Path $libexec "asl-support.exe"))) {
    if (Test-Path $target) {
      Remove-Item -LiteralPath $target -Force
      Write-AelOut "removed=$target"
      $removed = $true
    } else {
      Write-AelOut "not_found=$target"
    }
  }
  $projectState = Join-Path (Get-Location) ".aiplus"
  if ($purge -and (Test-Path $projectState)) {
    Remove-Item -LiteralPath $projectState -Recurse -Force
    Write-AelOut "removed=$projectState"
    $removed = $true
  } elseif ($purge) {
    Write-AelOut "not_found=$projectState"
  }
  if (-not $removed) { Write-AelOut "removed=none" }
  if (-not $purge) { Write-AelOut "preserved=$projectState" }
  Write-AelOut "UNINSTALL_STATUS=PASS"
  return 0
}

function Show-OnboardingHint {
  if ($env:ASL_NO_ONBOARDING -eq "1") { return }
  $text = @"
Quick start (your team is ready):

  asl                  open the lobby - pick who to talk to (PI / Advisor / ...)
  asl advisor          jump straight to Advisor for paper framing
  asl pi               jump straight to PI for orchestration

Tip: open two terminal windows for the Owner->Advisor + Owner->PI flow
(one window per role).

More: asl --help
"@
  Write-AelOut $text
}

function Get-CommandNameOrDefault([string]$Name) {
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  return $cmd
}

function Detect-Runtime {
  if ($env:ASL_RUNTIME) { return $env:ASL_RUNTIME }
  if (Get-CommandNameOrDefault "codex") { return "codex" }
  if (Get-CommandNameOrDefault "claude") { return "claude-code" }
  if (Get-CommandNameOrDefault "opencode") { return "opencode" }
  return "codex"
}

function Runtime-FromManifest {
  $path = Join-Path (Get-Location) ".aiplus\manifest.json"
  if (-not (Test-Path $path)) { return "" }
  try {
    $manifest = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    foreach ($preferred in @("codex", "claude-code", "opencode")) {
      if ($manifest.runtimeAdapters -contains $preferred) { return $preferred }
    }
  } catch {
    return ""
  }
  return ""
}

function Invoke-Install([string[]]$InstallArgs) {
  $runtime = ""
  $dryRun = $false
  $passArgs = @()
  $i = 0
  while ($i -lt $InstallArgs.Count) {
    $arg = $InstallArgs[$i]
    switch -Regex ($arg) {
      "^(codex|claude-code|opencode|all)$" {
        if (-not $runtime) { $runtime = $arg } else { $passArgs += $arg }
      }
      "^--runtime$" {
        if ($i + 1 -ge $InstallArgs.Count) { Exit-WithError "--runtime requires a value" }
        $i++
        $runtime = $InstallArgs[$i]
      }
      "^--runtime=" {
        $runtime = $arg.Substring("--runtime=".Length)
      }
      "^--dry-run$" {
        $dryRun = $true
        $passArgs += $arg
      }
      default {
        $passArgs += $arg
      }
    }
    $i++
  }
  if (-not $runtime) { $runtime = Detect-Runtime }
  if ($dryRun) {
    Write-AelOut "ASL install dry-run"
    $dryRunRuntimes = if ($runtime -eq "all") { @("codex", "claude-code", "opencode") } else { @($runtime) }
    foreach ($dryRunRuntime in $dryRunRuntimes) {
      Write-AelOut "  runtime=$dryRunRuntime"
      Write-AelOut "    would bootstrap the project runtime adapter"
      Write-AelOut "    would install the AgentScienceLab research team"
      Write-AelOut "    would set AgentScienceLab as the active team"
      Write-AelOut "    would register the MCP server with $dryRunRuntime (native tool-use for chat)"
    }
    Write-AelOut "ASL_DRY_RUN=PASS"
    return 0
  }
  if ($runtime -eq "all") {
    $failures = 0
    $summary = @()
    foreach ($installRuntime in @("codex", "claude-code", "opencode")) {
      $result = Invoke-InstallRuntimeFlow -Runtime $installRuntime -PassArgs $passArgs
      if ($result.Success) {
        Write-AelOut "ASL install runtime=$installRuntime status=PASS"
        $summary += "$installRuntime PASS"
      } else {
        $failures++
        [Console]::Error.WriteLine("ASL install runtime=$installRuntime status=FAIL step=$($result.Step) reason=$($result.Reason)")
        $summary += "$installRuntime FAIL ($($result.Reason))"
      }
    }
    Write-AelOut "ASL installed: $($summary -join ', ')"
    if ($failures -eq 0) {
      Write-AelOut "Next: asl                  # chat with your team in plain English / Chinese"
      Show-OnboardingHint
      return 0
    }
    return 1
  }
  $installArgs = @("install", $runtime, "--allow-version-skew") + $passArgs
  $status = Invoke-SubstrateQuiet $installArgs
  if ($status -ne 0) { return $status }
  $status = Invoke-SubstrateQuiet @("add", "agentsciencelab")
  if ($status -ne 0) { return $status }
  $status = Invoke-SubstrateQuiet @("agent", "set-team", "agentsciencelab")
  if ($status -ne 0) { return $status }
  $status = Invoke-SubstrateQuiet @("mcp-register", "--runtime", $runtime)
  if ($status -eq 0) {
    Write-AelOut "ASL installed for runtime=$runtime (chat tools registered)"
  } else {
    [Console]::Error.WriteLine("ASL installed for runtime=$runtime (chat tools not registered; fallback active)")
  }
  Write-AelOut "Next: asl                  # chat with your team in plain English / Chinese"
  Show-OnboardingHint
  return 0
}

function Get-InstallFailureReason([int]$Status) {
  if ($Status -eq 0) { return "" }
  return "exit_code=$Status"
}

function Invoke-InstallRuntimeFlow([string]$Runtime, [string[]]$PassArgs) {
  $status = Invoke-SubstrateQuiet (@("install", $Runtime, "--allow-version-skew") + $PassArgs)
  if ($status -ne 0) {
    return [pscustomobject]@{ Success = $false; Step = "install"; Reason = (Get-InstallFailureReason $status) }
  }
  $status = Invoke-SubstrateQuiet @("add", "agentsciencelab")
  if ($status -ne 0) {
    return [pscustomobject]@{ Success = $false; Step = "add"; Reason = (Get-InstallFailureReason $status) }
  }
  $status = Invoke-SubstrateQuiet @("agent", "set-team", "agentsciencelab")
  if ($status -ne 0) {
    return [pscustomobject]@{ Success = $false; Step = "set-team"; Reason = (Get-InstallFailureReason $status) }
  }
  $status = Invoke-SubstrateQuiet @("mcp-register", "--runtime", $Runtime)
  if ($status -ne 0) {
    return [pscustomobject]@{ Success = $false; Step = "mcp-register"; Reason = (Get-InstallFailureReason $status) }
  }
  return [pscustomobject]@{ Success = $true; Step = ""; Reason = "" }
}

function Invoke-Talk([string[]]$TalkArgs) {
  return (Invoke-SubstrateInteractive (@("agent", "talk") + $TalkArgs))
}

function Get-RoleTalkArgs([string]$Role, [string[]]$Rest) {
  $fresh = $false
  $filtered = @()
  foreach ($part in $Rest) {
    if ($part -eq "--fresh") {
      $fresh = $true
    } else {
      $filtered += $part
    }
  }
  $talkArgs = @("agent", "talk")
  if (-not $fresh) { $talkArgs += "--resume" }
  $talkArgs += $Role
  $talkArgs += $filtered
  return $talkArgs
}

function Maybe-PrintFirstWelcome {
  if ($env:ASL_NO_ONBOARDING -eq "1") { return }
  $markerDir = Join-Path (Get-Location) ".aiplus\agents"
  $marker = Join-Path $markerDir ".asl-greeted"
  if (-not (Test-Path $marker)) {
    Write-AelOut "Welcome to ASL - your research team is ready."
    Write-AelOut ""
    New-Item -ItemType Directory -Force -Path $markerDir | Out-Null
    New-Item -ItemType File -Force -Path $marker | Out-Null
  }
}

function Invoke-ChatDefault {
  if (-not (Test-Path (Join-Path (Get-Location) ".aiplus\manifest.json"))) {
    $message = @"
asl: this project is not set up yet.

Run this once to install the research team:
  asl install

Then run "asl" to chat with your team in plain language.
"@
    [Console]::Error.WriteLine($message)
    exit 1
  }

  Maybe-PrintFirstWelcome
  return (Invoke-SubstrateInteractive @())
}

function Test-AieconlabProject {
  $root = Get-Location
  if (Test-Path (Join-Path $root ".aiplus\modules\agentsciencelab")) { return $true }
  $manifest = Join-Path $root ".aiplus\manifest.json"
  if ((Test-Path $manifest) -and ((Get-Content -LiteralPath $manifest -Raw) -match '"agentsciencelab"')) {
    return $true
  }
  $team = Join-Path $root ".aiplus\team.toml"
  if ((Test-Path $team) -and ((Get-Content -LiteralPath $team -Raw) -match '(?m)^\s*(active_team|team)\s*=\s*"?agentsciencelab"?')) {
    return $true
  }
  return $false
}

function Test-AelConsultantTeam {
  if (-not (Test-AieconlabProject)) { return 0 }
  $consultant = Join-Path (Get-Location) ".aiplus\consultant-team.toml"
  if (-not (Test-Path $consultant)) { return 0 }

  $text = Get-Content -LiteralPath $consultant -Raw
  $missing = $false
  foreach ($needle in @(
    'id = "design"',
    'id = "contribution"',
    'id = "reproducibility"',
    'id = "irb"',
    'id = "ai_integration"',
    'id = "top_tier_referee"',
    'id = "jmp_audience"',
    'id = "external_replicator"',
    'id = "submission"',
    'id = "working-paper-post"',
    'id = "referee-response-send"',
    'id = "data-share"',
    'id = "authorship-change"'
  )) {
    if (-not $text.Contains($needle)) { $missing = $true }
  }
  if ($text -notmatch 'light[.]review_mode\s*=\s*"skip"') { $missing = $true }
  if ($text -match 'id = "(product_market|ux_plain_english|trust_safety|implementation_qa|runtime_qa|strategic_critic)"') {
    $missing = $true
  }

  if ($missing) {
    Write-AelOut 'NEEDS_FIX ael_consultant_team_mismatch expected=agentsciencelab_research_config path=.aiplus/consultant-team.toml fix="asl install"'
    return 1
  }
  Write-AelOut "PASS ael_consultant_team_research_config path=.aiplus/consultant-team.toml"
  return 0
}

function Invoke-Doctor([string[]]$DoctorArgs) {
  $bin = Get-SubstrateBin
  $subArgs = @("doctor") + $DoctorArgs
  & $bin @subArgs
  $status = $LASTEXITCODE
  $consultantStatus = 0
  foreach ($item in @(Test-AelConsultantTeam)) {
    if ($item -is [int]) {
      $consultantStatus = [int]$item
    } elseif ($null -ne $item) {
      Write-AelOut $item
    }
  }
  if ($status -ne 0) { return $status }
  return $consultantStatus
}

function Invoke-Main([string[]]$Argv) {
  $cmd = if ($Argv.Count -gt 0) { $Argv[0] } else { "" }
  $rest = @()
  if ($Argv.Count -gt 1) { $rest = $Argv[1..($Argv.Count - 1)] }
  switch ($cmd) {
    "" { return (Invoke-ChatDefault) }
    "chat" {
      if ($rest.Count -gt 0) {
        Exit-WithError "asl chat does not accept arguments. Use 'asl' for the lobby, or 'asl `"...`"' for natural-language routing."
      }
      return (Invoke-ChatDefault)
    }
    { $_ -in @("pi", "advisor", "writer", "ra-stata", "ra-python", "theorist", "referee", "replicator", "pm") } {
      return (Invoke-SubstrateInteractive (Get-RoleTalkArgs $cmd $rest))
    }
    "-h" { Show-Usage; return 0 }
    "--help" { Show-Usage; return 0 }
    "help" { Show-Usage; return 0 }
    "-V" { Write-AelOut "ASL $script:AelVersion (aiplus 0.6.19+)"; return 0 }
    "--version" { Write-AelOut "ASL $script:AelVersion (aiplus 0.6.19+)"; return 0 }
    "version" { Write-AelOut "ASL $script:AelVersion (aiplus 0.6.19+)"; return 0 }
    "install" { return (Invoke-Install $rest) }
    "talk" { return (Invoke-Talk $rest) }
    "status" { return (Invoke-SubstrateVisible (@("agent", "status") + $rest)) }
    "refresh" { return (Invoke-SubstrateVisible (@("refresh") + $rest)) }
    "doctor" { return (Invoke-Doctor $rest) }
    "update" { return (Invoke-Update $rest) }
    "uninstall" { return (Invoke-Uninstall $rest) }
    "route" { return (Invoke-SubstrateVisible (@("agent", "route") + $rest)) }
    "telemetry" { Exit-WithError "asl telemetry has been removed" }
    "invite" { return (Invoke-SubstrateVisible (@("agent", "invite") + $rest)) }
    "dismiss" { return (Invoke-SubstrateVisible (@("agent", "dismiss") + $rest)) }
    "integrate" { return (Invoke-SubstrateVisible (@("agent", "integrate") + $rest)) }
    "substrate" { return (Invoke-SubstrateVisible $rest) }
    { $Argv.Count -eq 1 -and -not $cmd.StartsWith("-") } {
      return (Invoke-SubstrateInteractive @("agent", "talk", $cmd))
    }
    default {
      if ($Argv.Count -gt 1) {
        Exit-WithError "unknown command or multi-word natural-language input: $($Argv -join ' '). Use 'asl `"...`"' for freeform requests, or 'asl talk ...' for explicit chat."
      }
      Exit-WithError "unknown command: $cmd"
    }
  }
}

$status = 0
$output = Invoke-Main @($args)
foreach ($item in @($output)) {
  if ($item -is [int]) {
    $status = [int]$item
  } elseif ($null -ne $item) {
    Write-Output $item
  }
}
exit $status
