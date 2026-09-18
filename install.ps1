<#
.SYNOPSIS
    Installs this Rainmeter setup: Rainmeter itself if it is missing, the skins,
    the plugins, the layouts and the active config.

.DESCRIPTION
    Run it one of two ways.

      From inside a copy of the repo (git clone, or the unzipped download):
          double-click install.cmd, or run .\install.ps1
        The skins are used where they are - nothing is copied out of the folder,
        so keep it somewhere permanent.

      On its own (nothing downloaded yet):
          the script fetches the repo into -Path first, with git if it is
          installed and as a zip otherwise, then carries on as above.

    Rainmeter's existing Rainmeter.ini is backed up next to itself before it is
    replaced, and the script prints how to undo everything when it finishes.

.PARAMETER Path
    Where to put the repo when it has to be downloaded.
    Default: Documents\rainmeter-enigma-trent in your user profile. (Not
    Documents\Rainmeter - Rainmeter keeps its own default Skins folder there.)

.PARAMETER SkipRainmeter
    Do not try to install Rainmeter; fail if it is missing.

.PARAMETER DownloadOnly
    Fetch the repo into -Path and stop. Nothing in Rainmeter is touched.
#>
[CmdletBinding()]
param(
    [string]$Path = (Join-Path $env:USERPROFILE 'Documents\rainmeter-enigma-trent'),
    [switch]$SkipRainmeter,
    [switch]$DownloadOnly
)

$ErrorActionPreference = 'Stop'
$Repo = 'DrTHunter/rainmeter-enigma-trent'
$Branch = 'main'

function Step([string]$Text) { Write-Host ''; Write-Host "== $Text" -ForegroundColor Cyan }
function Info([string]$Text) { Write-Host "   $Text" }
function Warn([string]$Text) { Write-Host "   $Text" -ForegroundColor Yellow }

function Find-Rainmeter {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'Rainmeter\Rainmeter.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Rainmeter\Rainmeter.exe')
    )
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
    return $null
}

# A folder counts as "the repo" when it has the three things the install needs.
function Test-RepoRoot([string]$Dir) {
    return $Dir -and (Test-Path (Join-Path $Dir 'Skins\Enigma')) -and
           (Test-Path (Join-Path $Dir 'Rainmeter.ini')) -and (Test-Path (Join-Path $Dir 'Layouts'))
}

# ---------------------------------------------------------------------------
Step 'Locating the setup files'

$root = $null
if (Test-RepoRoot $PSScriptRoot) {
    $root = $PSScriptRoot
    Info "Using this folder: $root"
}
elseif (Test-RepoRoot $Path) {
    $root = $Path
    Info "Already downloaded: $root"
}
else {
    if ((Test-Path $Path) -and (Get-ChildItem $Path -Force | Select-Object -First 1)) {
        throw "$Path already exists and is not this setup. Move it aside, or pass -Path with an empty folder."
    }
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Info "Cloning $Repo into $Path (about 8 MB) ..."
        & git clone -c core.longpaths=true --depth 1 --branch $Branch "https://github.com/$Repo.git" $Path
        if ($LASTEXITCODE -ne 0) { throw "git clone failed (see the message above). Check your internet connection and that -Path is writable." }
    }
    else {
        $zip = Join-Path $env:TEMP 'rainmeter-enigma-trent.zip'
        $unpack = Join-Path $env:TEMP 'rainmeter-enigma-trent-unpack'
        Info "Downloading $Repo as a zip (about 8 MB) ..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        try { Invoke-WebRequest "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip -UseBasicParsing }
        catch { throw "Download failed ($($_.Exception.Message)). Download the zip from the GitHub page yourself and run install.cmd from inside it." }
        if (Test-Path $unpack) { Remove-Item $unpack -Recurse -Force }
        Info 'Unpacking ...'
        Expand-Archive $zip -DestinationPath $unpack -Force
        $inner = Get-ChildItem $unpack -Directory | Select-Object -First 1
        New-Item -ItemType Directory -Force (Split-Path $Path -Parent) | Out-Null
        if (Test-Path $Path) { Remove-Item $Path -Force }
        Move-Item $inner.FullName $Path
        Remove-Item $zip, $unpack -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-RepoRoot $Path)) { throw "Downloaded to $Path but it does not look like the setup (no Skins\Enigma)." }
    $root = $Path
    Info "Downloaded to $root"
}

if ($DownloadOnly) { Step 'Done (download only)'; Info "Run install.cmd inside $root to finish."; return }

# ---------------------------------------------------------------------------
Step 'Checking for Rainmeter'

$exe = Find-Rainmeter
if (-not $exe) {
    if ($SkipRainmeter) { throw 'Rainmeter is not installed. Get it from https://www.rainmeter.net/ and run this again.' }
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Info 'Rainmeter is not installed - installing it with winget ...'
        & winget install --id Rainmeter.Rainmeter -e --silent --accept-source-agreements --accept-package-agreements
        $exe = Find-Rainmeter
    }
    if (-not $exe) {
        Warn 'Could not install Rainmeter automatically.'
        Warn 'Download and install it from https://www.rainmeter.net/ (the default options are fine), then run this again.'
        Start-Process 'https://www.rainmeter.net/'
        return
    }
}
Info "Rainmeter: $exe"

# ---------------------------------------------------------------------------
Step 'Closing Rainmeter'

if (Get-Process Rainmeter -ErrorAction SilentlyContinue) {
    & $exe '!Quit'
    for ($i = 0; $i -lt 20 -and (Get-Process Rainmeter -ErrorAction SilentlyContinue); $i++) { Start-Sleep -Milliseconds 500 }
    if (Get-Process Rainmeter -ErrorAction SilentlyContinue) { throw 'Rainmeter would not close. Exit it from its tray icon and run this again.' }
    Info 'Closed.'
}
else { Info 'It was not running.' }

# ---------------------------------------------------------------------------
Step 'Installing layouts, plugins and config'

$settings = Join-Path $env:APPDATA 'Rainmeter'
New-Item -ItemType Directory -Force $settings | Out-Null

$liveIni = Join-Path $settings 'Rainmeter.ini'
$backup = $null
if (Test-Path $liveIni) {
    $backup = Join-Path $settings ('Rainmeter.ini.before-install-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Copy-Item $liveIni $backup
    Info "Backed up your current config to $backup"
}

# Rainmeter.ini and every layout carry an absolute SkinPath from the machine
# they were saved on. Point them at wherever this copy of the repo lives.
$skinPath = (Join-Path $root 'Skins').TrimEnd('\') + '\'
$unicode = [Text.Encoding]::Unicode
function Set-SkinPath([string]$Source, [string]$Destination) {
    $text = [IO.File]::ReadAllText($Source, $unicode)
    if ($text -match '(?m)^SkinPath=') {
        $text = [regex]::Replace($text, '(?m)^SkinPath=[^\r\n]*', { param($m) "SkinPath=$skinPath" })
    }
    else {
        $text = [regex]::Replace($text, '(?m)^\[Rainmeter\][^\r\n]*\r?\n', { param($m) $m.Value + "SkinPath=$skinPath`r`n" }, 1)
    }
    New-Item -ItemType Directory -Force (Split-Path $Destination -Parent) | Out-Null
    [IO.File]::WriteAllText($Destination, $text, $unicode)
}

Set-SkinPath (Join-Path $root 'Rainmeter.ini') $liveIni
Info "Config installed, skins folder set to $skinPath"

$layoutCount = 0
Get-ChildItem (Join-Path $root 'Layouts') -Directory | ForEach-Object {
    $dest = Join-Path (Join-Path $settings 'Layouts') $_.Name
    New-Item -ItemType Directory -Force $dest | Out-Null
    Get-ChildItem $_.FullName -File | ForEach-Object {
        if ($_.Name -eq 'Rainmeter.ini') { Set-SkinPath $_.FullName (Join-Path $dest $_.Name) }
        else { Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force }
    }
    $layoutCount++
}
Info "$layoutCount layouts installed."

$pluginSource = Join-Path $root 'Plugins'
if (Test-Path $pluginSource) {
    $pluginDest = Join-Path $settings 'Plugins'
    New-Item -ItemType Directory -Force $pluginDest | Out-Null
    $plugins = Get-ChildItem $pluginSource -Filter *.dll
    $plugins | ForEach-Object { Copy-Item $_.FullName (Join-Path $pluginDest $_.Name) -Force }
    Info "$($plugins.Count) plugins installed."
}

# ---------------------------------------------------------------------------
# The Setup panel writes your calendar addresses and location into files that
# git tracks. In a clone, tell git to ignore local edits to them so they can
# never be committed and pushed by accident.
if ((Test-Path (Join-Path $root '.git')) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    Step 'Protecting your personal settings from git'
    foreach ($personal in @('Skins/Enigma/@Resources/User/Options.inc')) {
        & git -C $root update-index --skip-worktree $personal 2>$null
    }
    Info 'Local edits to Options.inc are now invisible to git.'
}

# ---------------------------------------------------------------------------
Step 'Starting Rainmeter'

Start-Process $exe
Start-Sleep -Seconds 5
if (Get-Process Rainmeter -ErrorAction SilentlyContinue) { Info 'Running.' } else { Warn 'Rainmeter did not start - launch it from the Start menu.' }

# ---------------------------------------------------------------------------
Step 'Finished'

Info 'Next: click the gear in the top bar to set your weather location, calendars, feeds and drives.'
Info 'The layout was built on a 1920x1080 screen; on another resolution drag the widgets where you want them.'
Info ''
Info 'To undo: exit Rainmeter, then'
if ($backup) { Info "  copy `"$backup`" back over `"$liveIni`"" }
else { Info "  delete `"$liveIni`" (Rainmeter recreates a default one)" }
Info "  and delete $root if you no longer want the skins."
