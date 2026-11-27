# The Windows PowerShell twin of scripts/reminiscor-director, for agents whose
# shell on Windows is PowerShell or cmd rather than Git Bash. Run it through
# reminiscor-director.cmd next to it, which passes the arguments on:
#
#   scripts\reminiscor-director.cmd <command> [args...]   run a program command
#   scripts\reminiscor-director.cmd update --check        the installed and latest versions, and what is new
#   scripts\reminiscor-director.cmd update                install the latest release, if newer
#
# It does what the bash script does, into the same folders, so either can be
# used on the same machine: the program from this repo's Releases (checked
# against SHA256SUMS) into %LOCALAPPDATA%\reminiscor-director-program, $Version
# below as the lowest version this plugin works with. Every install stops what
# the old program runs, runs `setup` and starts it again. The data folder is
# the program's own, elsewhere, and is never touched here.
#
# Overrides: REMINISCOR_DIRECTOR_PROGRAM, REMINISCOR_DIRECTOR_HOME,
# REMINISCOR_DIRECTOR_RELEASES and REMINISCOR_DIRECTOR_CHANGELOG, as in the
# bash script.
#
# For the built-in Windows PowerShell 5.1; no admin rights. Keep this file
# ASCII: 5.1 reads it in the ANSI code page. The release workflow rewrites the
# $Version line.
$Version = '0.1.4'
$Repo = 'reminiscor-vr/skills'

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# The program writes UTF-8; read and pass on its output as such.
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

function First-Set { foreach ($v in $args) { if ($v) { return $v } } return '' }
function Log([string]$Text) { [Console]::Error.WriteLine("==> $Text") }
function Die([string]$Text) { throw (New-Object System.InvalidOperationException($Text)) }

$System = 'windows-x64'
$Base = (First-Set $env:REMINISCOR_DIRECTOR_PROGRAM (Join-Path (First-Set $env:LOCALAPPDATA "$env:USERPROFILE\AppData\Local") 'reminiscor-director-program')).TrimEnd('\', '/')
$Releases = First-Set $env:REMINISCOR_DIRECTOR_RELEASES "https://github.com/$Repo/releases/download"
$ChangelogUrl = First-Set $env:REMINISCOR_DIRECTOR_CHANGELOG "https://raw.githubusercontent.com/$Repo/main/CHANGELOG.md"
$Self = "$PSScriptRoot\reminiscor-director.cmd"

function Exe-Of([string]$V) { return "$Base\$V\reminiscor-director\reminiscor-director.exe" }

# The installed version, when its program is there; '' otherwise.
function Get-Installed {
    $file = "$Base\current"
    if (-not (Test-Path -LiteralPath $file)) { return '' }
    $v = ([IO.File]::ReadAllText($file)).Trim()
    if ($v -and (Test-Path -LiteralPath (Exe-Of $v))) { return $v }
    return ''
}

# Whether version $A is older than $B (release versions: 1.2.3).
function Test-Older([string]$A, [string]$B) {
    try { return ([version]$A) -lt ([version]$B) } catch { return $A -ne $B }
}

function Get-Url([string]$Url, [string]$Out) {
    if ($Url -like 'file://*') {
        Copy-Item -LiteralPath ([Uri]$Url).LocalPath -Destination $Out -Force
        return
    }
    $client = New-Object System.Net.WebClient
    try { $client.DownloadFile($Url, $Out) } finally { $client.Dispose() }
}

function Get-Text([string]$Url) {
    if ($Url -like 'file://*') { return [IO.File]::ReadAllText(([Uri]$Url).LocalPath) }
    $client = New-Object System.Net.WebClient
    $client.Encoding = [Text.Encoding]::UTF8
    try { return $client.DownloadString($Url) } finally { $client.Dispose() }
}

# Download, check and unpack version $V into its own folder.
function Get-Program([string]$V) {
    $archive = "reminiscor-director-$V-$System.zip"
    $url = "$Releases/v$V"
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("reminiscor-director-" + [Guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($tmp) | Out-Null
    try {
        Log "downloading reminiscor-director $V ($System)"
        try { Get-Url "$url/$archive" "$tmp\$archive" } catch { Die "could not download $url/$archive ($($_.Exception.Message))" }
        try { Get-Url "$url/SHA256SUMS" "$tmp\SHA256SUMS" } catch { Die "could not download $url/SHA256SUMS ($($_.Exception.Message))" }
        $want = ''
        foreach ($line in [IO.File]::ReadAllLines("$tmp\SHA256SUMS")) {
            $parts = $line.Trim() -split '\s+', 2
            if ($parts.Count -eq 2 -and $parts[1].TrimStart('*') -eq $archive) { $want = $parts[0].ToLower() }
        }
        if (-not $want) { Die "$archive is not listed in SHA256SUMS" }
        $have = (Get-FileHash -Algorithm SHA256 -LiteralPath "$tmp\$archive").Hash.ToLower()
        if ($have -ne $want) { Die "$archive does not match SHA256SUMS; not installed" }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory("$tmp\$archive", "$tmp\unpacked")
        if (-not (Test-Path -LiteralPath "$tmp\unpacked\reminiscor-director\reminiscor-director.exe")) { Die "$archive has no reminiscor-director program" }
        [IO.Directory]::CreateDirectory($Base) | Out-Null
        if (Test-Path -LiteralPath "$Base\$V") { Remove-Item -LiteralPath "$Base\$V" -Recurse -Force }
        Move-Item -LiteralPath "$tmp\unpacked" -Destination "$Base\$V"
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Run a program command, its output shown; its exit code.
function Invoke-Program([string]$Exe, [string[]]$Arguments) {
    $ErrorActionPreference = 'Continue'
    & $Exe @Arguments | Out-Host
    return $LASTEXITCODE
}

# Install version $V in place of the current one, keeping what runs running.
function Install-Version([string]$V) {
    $old = Get-Installed
    Get-Program $V
    $running = $false
    if ($old) {
        $ErrorActionPreference = 'Continue'
        $status = (& (Exe-Of $old) status 2>$null) -join "`n"
        $ErrorActionPreference = 'Stop'
        if ($status -match '(?m)^(ComfyUI|app) +up') {
            $running = $true
            Log "stopping reminiscor-director $old"
            Invoke-Program (Exe-Of $old) @('stop') | Out-Null
        }
    }
    [IO.File]::WriteAllText("$Base\current", "$V`n")
    # Older programs; the data folder is elsewhere and stays.
    Get-ChildItem -LiteralPath $Base -Directory | Where-Object { $_.Name -ne $V } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    $was = ''
    if ($old) { $was = " (was $old)" }
    Log "installed reminiscor-director $V$was"
    $new = Exe-Of $V
    if ((Invoke-Program $new @('setup')) -ne 0) { Die "setup failed; run it again: $Self setup" }
    if ($running) {
        if ((Invoke-Program $new @('start')) -ne 0) { Die "could not start it again: $Self start" }
    }
}

# The first version in a changelog.
function Get-Latest([string]$Changes) {
    foreach ($line in $Changes -split "`r?`n") {
        if ($line -match '^## ([0-9][0-9.]*)( .*)?$') { return $Matches[1] }
    }
    return ''
}

# The sections of a changelog for versions newer than $Since.
function Get-NewerThan([string]$Changes, [string]$Since) {
    $show = $false
    foreach ($line in $Changes -split "`r?`n") {
        if ($line -match '^## ([0-9][^ ]*)') {
            $show = (-not $Since) -or (Test-Older $Since $Matches[1])
        } elseif ($line -like '## *') {
            $show = $false
        }
        if ($show) { $line }
    }
}

try {
    $arch = First-Set $env:PROCESSOR_ARCHITEW6432 $env:PROCESSOR_ARCHITECTURE
    if ($env:OS -ne 'Windows_NT' -or $arch -ne 'AMD64') { Die 'unsupported system: needs Windows x64 (Mac and Linux: scripts/reminiscor-director)' }
    $current = Get-Installed

    if ($args.Count -gt 0 -and $args[0] -eq 'update') {
        try { $changes = Get-Text $ChangelogUrl } catch { Die "could not read $ChangelogUrl; check the network" }
        $newest = Get-Latest $changes
        if (-not $newest) { Die "no version in $ChangelogUrl" }
        if ($current -and -not (Test-Older $current $newest)) {
            "reminiscor-director $current is the latest"
            exit 0
        }
        if ($args.Count -gt 1 -and $args[1] -eq '--check') {
            "installed: $(First-Set $current 'none')"
            "latest: $newest"
            ''
            Get-NewerThan $changes $current
            exit 0
        }
        Install-Version $newest
        $from = ''
        if ($current) { $from = " from $current" }
        "reminiscor-director updated to $newest$from"
        exit 0
    }

    if (-not $current -or (Test-Older $current $Version)) {
        Install-Version $Version
        $current = $Version
    }
    $ErrorActionPreference = 'Continue'
    [string[]]$rest = $args
    & (Exe-Of $current) @rest
    exit $LASTEXITCODE
} catch [System.InvalidOperationException] {
    [Console]::Error.WriteLine("error: $($_.Exception.Message)")
    exit 1
} catch {
    [Console]::Error.WriteLine("error: $($_.Exception.Message)")
    [Console]::Error.WriteLine($_.InvocationInfo.PositionMessage)
    exit 1
}
