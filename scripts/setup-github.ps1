#Requires -Version 7.2
<#
.SYNOPSIS
    Creates and configures the GitHub space for the Virtual Tone Microphone project.

.DESCRIPTION
    Creates the private repository (or uses the existing one), pushes this folder, configures
    repository settings, collaborators, labels, milestones, issues with epics and sub-issues,
    the project board, starter discussions and branch protection.
    Safe to re-run: things that already exist are skipped.

.EXAMPLE
    pwsh -File scripts/setup-github.ps1 -Repo myname/virtual-tone-mic -Collaborators alice,bob
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$')]
    [string]$Repo,

    [string[]]$Collaborators = @(),
    [string]$ProjectTitle = 'Virtual Tone Microphone',
    [switch]$SkipProject,
    [switch]$SkipDiscussions,
    [switch]$KeepDefaultLabels
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$Owner, $Name = $Repo.Split('/')
$Root    = Split-Path -Parent $PSScriptRoot
$SeedDir = Join-Path $PSScriptRoot 'github'
$Utf8    = [Text.UTF8Encoding]::new($false)
$script:GhOk    = $true
$script:GhError = ''
$Warnings = [Collections.Generic.List[string]]::new()

# ---------------------------------------------------------------- helpers
function Write-Step([string]$Text) { Write-Host "`n== $Text" -ForegroundColor Cyan }
function Write-Ok  ([string]$Text) { Write-Host "  + $Text" -ForegroundColor Green }
function Write-Skip([string]$Text) { Write-Host "  = $Text (exists)" -ForegroundColor DarkGray }
function Write-Note([string]$Text) { Write-Host "  ! $Text" -ForegroundColor Yellow; $Warnings.Add($Text) }

function Invoke-Gh {
    param(
        [Parameter(Mandatory, Position = 0)][string[]]$Arguments,
        [switch]$AllowFail
    )
    $errFile = [IO.Path]::GetTempFileName()
    try {
        $stdout = & gh @Arguments 2> $errFile
        $code   = $LASTEXITCODE
        $script:GhError = (Get-Content $errFile -Raw) ?? ''
    }
    finally { Remove-Item $errFile -ErrorAction SilentlyContinue }
    $script:GhOk = ($code -eq 0)
    if (-not $script:GhOk -and -not $AllowFail) {
        $cmd = ($Arguments | Select-Object -First 2) -join ' '
        throw "gh $cmd failed (exit $code): $($script:GhError.Trim())"
    }
    return ($stdout -join "`n")
}

function Invoke-Git {
    param([Parameter(Mandatory, Position = 0)][string[]]$Arguments)
    $out = & git @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed: $($out -join ' ')" }
    return ($out -join "`n")
}

function New-TempTextFile([string]$Text) {
    $f = [IO.Path]::GetTempFileName()
    [IO.File]::WriteAllText($f, $Text, $Utf8)
    return $f
}

function Read-Seed([string]$File) {
    return (Get-Content (Join-Path $SeedDir $File) -Raw | ConvertFrom-Json)
}

# ---------------------------------------------------------------- 0. checks
Write-Step 'Checking prerequisites'
foreach ($cmd in 'gh', 'git') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "'$cmd' was not found. See docs/github-setup.md for prerequisites."
    }
}
Invoke-Gh @('auth', 'status') | Out-Null
Write-Ok 'gh is installed and logged in'
Set-Location $Root

$Collaborators = @($Collaborators | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

# ---------------------------------------------------------------- 1. placeholders
Write-Step 'Filling in the repository name in docs and templates'
$files = Get-ChildItem -Path $Root -Recurse -File -Force -Include *.md, *.yml, *.yaml |
         Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
$replaced = 0
foreach ($f in $files) {
    $text = [IO.File]::ReadAllText($f.FullName)
    if ($text.Contains('__REPO__') -or $text.Contains('__OWNER__')) {
        $text = $text.Replace('__REPO__', $Repo).Replace('__OWNER__', $Owner)
        [IO.File]::WriteAllText($f.FullName, $text, $Utf8)
        $replaced++
    }
}
Write-Ok "$replaced file(s) updated"

# ---------------------------------------------------------------- 2. git + repository
Write-Step 'Creating the repository and pushing'
if (-not (Test-Path (Join-Path $Root '.git'))) {
    Invoke-Git @('init') | Out-Null
    Write-Ok 'git repository initialised'
}
if (-not (& git config user.email)) {
    throw 'git has no user identity. Run: git config --global user.name "Your Name"; git config --global user.email "you@example.com"'
}
Invoke-Git @('add', '-A') | Out-Null
if (Invoke-Git @('status', '--porcelain')) {
    Invoke-Git @('commit', '-m', 'Set up project structure') | Out-Null
    Write-Ok 'changes committed'
}
& git branch -M main 2>&1 | Out-Null

$hasOrigin = (& git remote) -contains 'origin'
Invoke-Gh @('repo', 'view', $Repo, '--json', 'name') -AllowFail | Out-Null
$repoExists = $script:GhOk
$description = 'Windows virtual microphone driver that generates a test signal, with a control GUI'

if (-not $repoExists -and -not $hasOrigin) {
    Invoke-Gh @('repo', 'create', $Repo, '--private', '--description', $description,
                '--source', $Root, '--remote', 'origin', '--push') | Out-Null
    Write-Ok "created private repo $Repo and pushed"
}
else {
    if (-not $repoExists) {
        Invoke-Gh @('repo', 'create', $Repo, '--private', '--description', $description) | Out-Null
        Write-Ok "created private repo $Repo"
    }
    else { Write-Skip "repo $Repo" }
    if (-not $hasOrigin) { Invoke-Git @('remote', 'add', 'origin', "https://github.com/$Repo.git") | Out-Null }
    & git push -u origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Ok 'pushed main' } else { Write-Note 'git push failed; push manually with: git push -u origin main' }
}

# ---------------------------------------------------------------- 3. settings
Write-Step 'Configuring repository settings'
Invoke-Gh @('repo', 'edit', $Repo,
    '--enable-issues', '--enable-discussions', '--enable-projects', '--enable-wiki=false',
    '--enable-squash-merge', '--enable-merge-commit=false', '--enable-rebase-merge=false',
    '--delete-branch-on-merge',
    '--add-topic', 'windows-driver', '--add-topic', 'audio', '--add-topic', 'wdk', '--add-topic', 'portcls') -AllowFail | Out-Null
if ($script:GhOk) { Write-Ok 'issues, discussions, projects on; wiki off; squash merge; auto-delete branches' }
else { Write-Note "Some repository settings could not be applied: $($script:GhError.Trim())" }

# ---------------------------------------------------------------- 4. collaborators
if ($Collaborators.Count -gt 0) {
    Write-Step 'Inviting collaborators'
    foreach ($u in $Collaborators) {
        Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/collaborators/$u", '-f', 'permission=push') -AllowFail | Out-Null
        if ($script:GhOk) { Write-Ok "invited $u (write access)" }
        else { Write-Note "Could not invite '$u': $($script:GhError.Trim())" }
    }
}

# ---------------------------------------------------------------- 5. labels
Write-Step 'Labels'
$existingLabels = @((Invoke-Gh @('label', 'list', '--repo', $Repo, '--limit', '200', '--json', 'name')) |
                    ConvertFrom-Json | ForEach-Object { $_.name })
if (-not $KeepDefaultLabels) {
    $defaults = 'bug', 'documentation', 'duplicate', 'enhancement', 'good first issue',
                'help wanted', 'invalid', 'question', 'wontfix'
    foreach ($d in $defaults) {
        if ($existingLabels -contains $d) {
            Invoke-Gh @('label', 'delete', $d, '--repo', $Repo, '--yes') -AllowFail | Out-Null
            if ($script:GhOk) { Write-Host "  - removed default label '$d'" -ForegroundColor DarkGray }
        }
    }
}
foreach ($l in (Read-Seed 'labels.json')) {
    Invoke-Gh @('label', 'create', $l.name, '--repo', $Repo, '--color', $l.color,
                '--description', $l.description, '--force') | Out-Null
    Write-Ok $l.name
}

# ---------------------------------------------------------------- 6. milestones
Write-Step 'Milestones'
$existingMs = @((Invoke-Gh @('api', "repos/$Repo/milestones?state=all&per_page=100")) |
                ConvertFrom-Json | ForEach-Object { $_.title })
foreach ($m in (Read-Seed 'milestones.json')) {
    if ($existingMs -contains $m.title) { Write-Skip $m.title; continue }
    Invoke-Gh @('api', "repos/$Repo/milestones", '-f', "title=$($m.title)", '-f', "description=$($m.description)") | Out-Null
    Write-Ok $m.title
}

# ---------------------------------------------------------------- 7. issues and epics
Write-Step 'Issues'
$issueIndex = @{}
(Invoke-Gh @('issue', 'list', '--repo', $Repo, '--state', 'all', '--limit', '1000', '--json', 'number,title,url')) |
    ConvertFrom-Json | ForEach-Object { $issueIndex[$_.title] = $_ }

function New-SeedIssue($Item, [string]$Body) {
    if ($issueIndex.ContainsKey($Item.title)) {
        Write-Skip "#$($issueIndex[$Item.title].number) $($Item.title)"
        return [pscustomobject]@{ Issue = $issueIndex[$Item.title]; Created = $false }
    }
    $bodyFile = New-TempTextFile $Body
    try {
        $ghArgs = @('issue', 'create', '--repo', $Repo, '--title', $Item.title,
                    '--body-file', $bodyFile, '--milestone', $Item.milestone)
        foreach ($lbl in $Item.labels) { $ghArgs += @('--label', $lbl) }
        $out = Invoke-Gh $ghArgs
    }
    finally { Remove-Item $bodyFile -ErrorAction SilentlyContinue }
    $url = ($out -split "`n" | Where-Object { $_ -match '^https://' } | Select-Object -Last 1).Trim()
    $issue = [pscustomobject]@{ number = [int]($url -split '/')[-1]; title = $Item.title; url = $url }
    $issueIndex[$Item.title] = $issue
    Write-Ok "#$($issue.number) $($Item.title)"
    return [pscustomobject]@{ Issue = $issue; Created = $true }
}

$seed = Read-Seed 'issues.json'
$children = @{}
foreach ($item in $seed.issues) {
    $r = New-SeedIssue $item $item.body
    if (-not $children.ContainsKey($item.epic)) { $children[$item.epic] = [Collections.Generic.List[object]]::new() }
    $children[$item.epic].Add($r.Issue)
}

Write-Step 'Epics and sub-issues'
$subIssuesSupported = $true
foreach ($epic in $seed.epics) {
    $kids = $children[$epic.key]
    $list = ($kids | ForEach-Object { "- [ ] #$($_.number)" }) -join "`n"
    $body = "$($epic.body)`n`n## Issues`n$list`n`nProgress also shows in the sub-issues panel and on the project board."
    $r = New-SeedIssue $epic $body
    if (-not $r.Created -or -not $subIssuesSupported) { continue }
    foreach ($k in $kids) {
        $childId = (Invoke-Gh @('api', "repos/$Repo/issues/$($k.number)", '--jq', '.id')).Trim()
        Invoke-Gh @('api', '-X', 'POST', "repos/$Repo/issues/$($r.Issue.number)/sub_issues",
                    '-F', "sub_issue_id=$childId") -AllowFail | Out-Null
        if (-not $script:GhOk) {
            Write-Note "Sub-issues could not be linked ($($script:GhError.Trim())). Epics still list their issues as a checklist."
            $subIssuesSupported = $false
            break
        }
    }
    if ($subIssuesSupported) { Write-Ok "linked $($kids.Count) sub-issues to #$($r.Issue.number)" }
}

# ---------------------------------------------------------------- 8. project board
$projectUrl = $null
if (-not $SkipProject) {
    Write-Step 'Project board'
    $listOut = Invoke-Gh @('project', 'list', '--owner', $Owner, '--format', 'json', '--limit', '100') -AllowFail
    if (-not $script:GhOk) {
        Write-Note "Project board skipped: $($script:GhError.Trim()) - run 'gh auth refresh -s project' and re-run the script."
    }
    else {
        $proj = ($listOut | ConvertFrom-Json).projects | Where-Object { $_.title -eq $ProjectTitle } | Select-Object -First 1
        if ($proj) { Write-Skip "project '$ProjectTitle'" }
        else {
            $proj = Invoke-Gh @('project', 'create', '--owner', $Owner, '--title', $ProjectTitle, '--format', 'json') | ConvertFrom-Json
            Write-Ok "created project '$ProjectTitle'"
        }
        $urlProp = $proj.PSObject.Properties['url']
        if ($urlProp) { $projectUrl = $urlProp.Value }
        $projNum = [string]$proj.number
        Invoke-Gh @('project', 'edit', $projNum, '--owner', $Owner,
                    '--description', 'Work board for the Virtual Tone Microphone project',
                    '--readme', "Board for https://github.com/$Repo. Columns: Todo, In Progress, In review, Done. See CONTRIBUTING.md for the workflow.") -AllowFail | Out-Null
        Invoke-Gh @('project', 'link', $projNum, '--owner', $Owner, '--repo', $Repo) -AllowFail | Out-Null
        if ($script:GhOk) { Write-Ok "linked project to $Repo" } else { Write-Note 'Link the project to the repo manually (Project settings).' }
        $added = 0
        foreach ($i in $issueIndex.Values) {
            Invoke-Gh @('project', 'item-add', $projNum, '--owner', $Owner, '--url', $i.url) -AllowFail | Out-Null
            if ($script:GhOk) { $added++ }
        }
        Write-Ok "$added issue(s) on the board"
    }
}

# ---------------------------------------------------------------- 9. discussions
if (-not $SkipDiscussions) {
    Write-Step 'Discussions'
    $query = 'query($owner:String!,$name:String!){repository(owner:$owner,name:$name){id discussionCategories(first:50){nodes{id slug name}} discussions(first:100){nodes{title}}}}'
    function Get-DiscussionInfo {
        (Invoke-Gh @('api', 'graphql', '-f', "query=$query", '-f', "owner=$Owner", '-f', "name=$Name") | ConvertFrom-Json).data.repository
    }
    $needed = [ordered]@{ 'decisions' = 'Decisions'; 'meeting-notes' = 'Meeting notes'; 'status-updates' = 'Status updates' }
    $info = Get-DiscussionInfo
    $haveSlugs = @($info.discussionCategories.nodes | ForEach-Object { $_.slug })
    $missing = @($needed.Keys | Where-Object { $haveSlugs -notcontains $_ })
    if ($missing.Count -gt 0) {
        Write-Host ''
        Write-Host '  GitHub has no API for creating discussion categories. Please create these now:' -ForegroundColor Yellow
        Write-Host "  https://github.com/$Repo/discussions/categories" -ForegroundColor Yellow
        foreach ($s in $missing) {
            $fmt = 'Open-ended discussion'
            Write-Host ("    - Name: {0,-16} Format: {1}" -f $needed[$s], $fmt) -ForegroundColor Yellow
        }
        Write-Host '  (Name them exactly like this so the discussion forms in .github/DISCUSSION_TEMPLATE apply.)' -ForegroundColor Yellow
        $answer = Read-Host '  Press Enter when done, or type "skip" to continue without them'
        if ($answer -ne 'skip') { $info = Get-DiscussionInfo }
    }
    $categories = @($info.discussionCategories.nodes)
    $titles = @($info.discussions.nodes | ForEach-Object { $_.title })
    $mutation = 'mutation($repo:ID!,$cat:ID!,$title:String!,$body:String!){createDiscussion(input:{repositoryId:$repo,categoryId:$cat,title:$title,body:$body}){discussion{url}}}'
    foreach ($d in (Read-Seed 'discussions.json')) {
        if ($titles -contains $d.title) { Write-Skip $d.title; continue }
        $cat = $categories | Where-Object { $_.slug -eq $d.category } | Select-Object -First 1
        if (-not $cat) { Write-Note "Category '$($d.category)' missing; skipped discussion '$($d.title)'."; continue }
        $bodyFile = New-TempTextFile $d.body
        try {
            Invoke-Gh @('api', 'graphql', '-f', "query=$mutation", '-f', "repo=$($info.id)", '-f', "cat=$($cat.id)",
                        '-f', "title=$($d.title)", '-F', "body=@$bodyFile") | Out-Null
        }
        finally { Remove-Item $bodyFile -ErrorAction SilentlyContinue }
        Write-Ok "[$($cat.name)] $($d.title)"
    }
}

# ---------------------------------------------------------------- 10. branch protection
Write-Step 'Protecting main'
Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/branches/main/protection",
            '--input', (Join-Path $SeedDir 'branch-protection.json')) -AllowFail | Out-Null
if ($script:GhOk) { Write-Ok 'main requires a pull request with 1 approval' }
else { Write-Note 'Branch protection not applied (private repos need GitHub Pro/Team; free for students via the Student Developer Pack). Follow the no-direct-push rule in CONTRIBUTING.md.' }

# ---------------------------------------------------------------- summary
Write-Step 'Done'
Write-Host "  Repository:  https://github.com/$Repo"
Write-Host "  Issues:      https://github.com/$Repo/issues"
Write-Host "  Discussions: https://github.com/$Repo/discussions"
if ($projectUrl) { Write-Host "  Project:     $projectUrl" }
Write-Host ''
Write-Host '  Remaining manual steps (docs/github-setup.md):' -ForegroundColor Cyan
Write-Host '   1. Project: add an "In review" option to the Status field'
Write-Host '   2. Project: add views (By milestone, My work)'
Write-Host '   3. Discussions: pin the Welcome discussion'
Write-Host '   4. Milestones: add due dates when agreed'
if ($Warnings.Count -gt 0) {
    Write-Host ''
    Write-Host '  Warnings:' -ForegroundColor Yellow
    $Warnings | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
}
