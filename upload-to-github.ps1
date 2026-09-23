$ErrorActionPreference = 'Stop'
$repoUrl = 'https://github.com/3030606794/LuckyTool.git'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$uploadRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('LuckyToolUpload-' + [guid]::NewGuid().ToString('N'))

function Run-Git {
    & git @args
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed (exit $LASTEXITCODE): git $($args -join ' ')"
    }
}

try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git for Windows is not installed. Install it from https://git-scm.com/download/win and run this file again.'
    }
    if (-not (Test-Path (Join-Path $projectRoot 'app/src/main/assets/xposed_init')) -or
        -not (Test-Path (Join-Path $projectRoot '.github/workflows/build.yml'))) {
        throw 'Project files are missing. Extract the whole ZIP first, then run this script inside its root folder.'
    }

    # Clone first so every later upload continues the remote history, even when
    # the user extracts a newer ZIP into a fresh folder.
    Run-Git clone $repoUrl $uploadRoot
    & robocopy $projectRoot $uploadRoot /E /XD .git .gradle .idea build /XF local.properties *.apk | Out-Host
    if ($LASTEXITCODE -ge 8) { throw "Could not copy project files (Robocopy exit $LASTEXITCODE)." }

    Set-Location -LiteralPath $uploadRoot
    $currentBranch = ([string](& git branch --show-current)).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the remote branch.' }
    if ($currentBranch -ne 'main') {
        $hasCommit = & git rev-parse --verify --quiet HEAD
        if ($LASTEXITCODE -eq 0) {
            throw "Remote default branch is $currentBranch, not main. Nothing was pushed."
        }
        Run-Git branch -M main
    }

    Run-Git add --all
    & git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        $configuredName = & git config --get user.name
        $configuredEmail = & git config --get user.email
        if ([string]::IsNullOrWhiteSpace($configuredName) -or
            [string]::IsNullOrWhiteSpace($configuredEmail)) {
            $userName = Read-Host 'Enter your Git commit name'
            $userEmail = Read-Host 'Enter your Git commit email'
            if ([string]::IsNullOrWhiteSpace($userName) -or [string]::IsNullOrWhiteSpace($userEmail)) {
                throw 'Name and email are required for a commit.'
            }
            Run-Git config --local user.name $userName
            Run-Git config --local user.email $userEmail
        }
        Run-Git commit -m 'Update vivo WeChat screenshot experiment'
    } elseif ($LASTEXITCODE -ne 0) {
        throw 'Could not check staged files.'
    } else {
        Write-Host 'No new changes; checking the remote.'
    }

    Write-Host "Pushing to $repoUrl ..."
    Run-Git push -u origin main
    Write-Host 'Upload complete. Open the GitHub repository, then Actions -> Build APK.' -ForegroundColor Green
    Set-Location -LiteralPath $projectRoot
    Remove-Item -LiteralPath $uploadRoot -Recurse -Force -ErrorAction SilentlyContinue
    exit 0
} catch {
    Set-Location -LiteralPath $projectRoot
    Write-Host $_.Exception.Message -ForegroundColor Red
    if (Test-Path $uploadRoot) { Write-Host "Temporary checkout kept for inspection: $uploadRoot" }
    Write-Host 'If GitHub asks for authentication, use the browser sign-in. Do not put a token into this script.'
    Write-Host 'If the remote already has different commits, this script will not force-push.'
    exit 1
}
