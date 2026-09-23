$ErrorActionPreference = 'Stop'
$repoUrl = 'https://github.com/3030606794/LuckyTool.git'
$sshRepoUrl = 'git@github.com:3030606794/LuckyTool.git'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

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

    Set-Location -LiteralPath $projectRoot
    if (-not (Test-Path '.git')) {
        Run-Git init
        Run-Git branch -M main
    } else {
        $currentBranch = (& git branch --show-current).Trim()
        if ($LASTEXITCODE -ne 0 -or $currentBranch -ne 'main') {
            throw 'This folder already contains a Git repository on a branch other than main. Nothing was changed.'
        }
    }

    $remoteNames = @(& git remote)
    if ($LASTEXITCODE -ne 0) { throw 'Could not read Git remotes.' }
    if ($remoteNames -notcontains 'origin') {
        Run-Git remote add origin $repoUrl
    } else {
        $remoteUrl = (& git remote get-url origin).Trim()
        if ($LASTEXITCODE -ne 0 -or ($remoteUrl -ne $repoUrl -and $remoteUrl -ne $sshRepoUrl)) {
            throw "The existing origin points elsewhere: $remoteUrl. Nothing was pushed."
        }
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
        Run-Git commit -m 'Add vivo WeChat screenshot experiment'
    } elseif ($LASTEXITCODE -ne 0) {
        throw 'Could not check staged files.'
    } else {
        Write-Host 'No new changes; checking the remote.'
    }

    Write-Host "Pushing to $repoUrl ..."
    Run-Git push -u origin main
    Write-Host 'Upload complete. Open the GitHub repository, then Actions -> Build APK.' -ForegroundColor Green
    exit 0
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host 'If GitHub asks for authentication, use the browser sign-in. Do not put a token into this script.'
    Write-Host 'If the remote already has different commits, this script will not force-push.'
    exit 1
}
