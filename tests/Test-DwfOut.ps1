<#
.SYNOPSIS
    Builds dwfout.arx for each AutoCAD/ObjectARX version and verifies DWFOUTCLI under accoreconsole.

.DESCRIPTION
    For each version:
      1. msbuild dwfout.vcxproj /p:ArxVersion=<v> /p:ArxSdkDir=<SdkRoot>\ARX<v>
      2. Copies solids.dwg to a temp folder (keeps .dwl/.dwl2 lock files out of the repo)
      3. Runs accoreconsole.exe with a script: arxload (CRX) -> DWFOUTCLI -> output name -> QUIT
      4. Asserts: exit code 0, no "Unknown command" in the log, output .dwfx exists,
         is non-empty and starts with the ZIP signature 'PK' (DWFX is an OPC/ZIP package).

    Exit code is the number of failed versions.

.EXAMPLE
    .\tests\Test-DwfOut.ps1
    .\tests\Test-DwfOut.ps1 -Versions 2027 -Configuration Debug
    .\tests\Test-DwfOut.ps1 -SdkRoot E:\Sdks -AcadRoot 'E:\Autodesk' -SkipBuild
#>
[CmdletBinding()]
param(
    [string[]] $Versions      = @('2026', '2027'),
    [string]   $SdkRoot       = 'D:\SDKS',
    [string]   $AcadRoot      = 'D:\ACAD',
    [ValidateSet('Debug', 'Release')]
    [string]   $Configuration = 'Release',
    [ValidateSet('arx', 'crx')]
    [string[]] $ModuleTypes   = @('crx'),   # accoreconsole loads CRX only; ARX fails ARXLOAD by design
    [string]   $MSBuild       = 'msbuild',
    [string]   $OutputDir,                  # if set, keep a copy of each DWFX as dwfout-<ver>-<type>.dwfx
    [switch]   $SkipBuild,
    [int]      $TimeoutSeconds = 180
)

$ErrorActionPreference = 'Stop'
$repo    = Split-Path -Parent $PSScriptRoot
$project = Join-Path $repo 'dwfout.vcxproj'
$dwg     = Join-Path $repo 'solids.dwg'

function Test-OneVersion([string] $version, [string] $type) {
    $tag      = "$version/$type"
    $sdk      = Join-Path $SdkRoot "ARX$version"
    $console  = Join-Path $AcadRoot "AutoCAD $version\accoreconsole.exe"
    $arx      = Join-Path $repo "bins\$version\dwfout.$type"
    $work     = Join-Path ([IO.Path]::GetTempPath()) "dwfout-test-$version-$type-$([guid]::NewGuid().ToString('N').Substring(0,8))"

    foreach ($required in @($sdk, $console, $dwg)) {
        if (-not (Test-Path $required)) { throw "Missing prerequisite: $required" }
    }

    if (-not $SkipBuild) {
        Write-Host "[$tag] building ($Configuration) against $sdk"
        & $MSBuild $project /nologo /v:m /p:Configuration=$Configuration /p:Platform=x64 `
            /p:ArxVersion=$version /p:ArxSdkDir=$sdk /p:ArxModuleType=$type
        if ($LASTEXITCODE -ne 0) { throw "msbuild failed with exit code $LASTEXITCODE" }
    }
    if (-not (Test-Path $arx)) { throw "Build output not found: $arx" }

    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $testDwg = Join-Path $work 'solids.dwg'
        $outFile = Join-Path $work 'out.dwfx'
        $scrFile = Join-Path $work 'test.scr'
        $logFile = Join-Path $work 'console.log'
        Copy-Item $dwg $testDwg

        # AutoCAD scripts accept forward slashes; avoids backslash/escape surprises.
        $fwd = { param($p) $p.Replace('\', '/') }
        @(
            'FILEDIA 0'
            "(arxload `"$(& $fwd $arx)`")"
            'DWFOUTCLI'
            (& $fwd $outFile)
            '_ALL'                   # "Objects to publish [All/Select] <All>:" prompt from export3dDWF
            '_YES'                   # "Publish With Materials [No/Yes] <Yes>:" prompt
            '_.QUIT Y'
        ) | Set-Content -Path $scrFile -Encoding ASCII

        Write-Host "[$tag] running accoreconsole"
        $proc = Start-Process -FilePath $console `
            -ArgumentList @('/i', "`"$testDwg`"", '/s', "`"$scrFile`"", '/l', 'en-US') `
            -RedirectStandardOutput $logFile -NoNewWindow -PassThru
        if (-not $proc.WaitForExit($TimeoutSeconds * 1000)) {
            $proc.Kill($true)
            Start-Sleep -Milliseconds 500
            Write-Host "[$tag] console log at timeout:" -ForegroundColor Yellow
            Write-Host (Get-Content $logFile -Raw -ErrorAction SilentlyContinue)
            Write-Host "[$tag] script used ($scrFile):" -ForegroundColor Yellow
            Write-Host (Get-Content $scrFile -Raw)
            throw "accoreconsole timed out after $TimeoutSeconds s"
        }

        $log = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
        $failures = @()
        if ($proc.ExitCode -ne 0)            { $failures += "accoreconsole exit code $($proc.ExitCode)" }
        if ($log -match 'Unknown command')   { $failures += 'command not registered (Unknown command in log)' }
        if (-not (Test-Path $outFile))       { $failures += 'DWFX not created' }
        else {
            $bytes = [IO.File]::ReadAllBytes($outFile)
            if ($bytes.Length -eq 0)                                  { $failures += 'DWFX is empty' }
            elseif ($bytes[0] -ne 0x50 -or $bytes[1] -ne 0x4B)        { $failures += 'DWFX is not a ZIP/OPC package (no PK header)' }
        }

        if ($failures) {
            Write-Host "[$tag] console log:" -ForegroundColor Yellow
            Write-Host $log
            throw ($failures -join '; ')
        }
        if ($OutputDir) {
            New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
            $kept = Join-Path $OutputDir "dwfout-$version-$type.dwfx"
            Copy-Item $outFile $kept -Force
            Write-Host "[$tag] kept $kept"
        }
        Write-Host "[$tag] PASS ($((Get-Item $outFile).Length) bytes)" -ForegroundColor Green
    }
    finally {
        Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$failed = 0
foreach ($v in $Versions) {
    foreach ($t in $ModuleTypes) {
        try { Test-OneVersion $v $t }
        catch {
            $failed++
            Write-Host "[$v/$t] FAIL: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
exit $failed
