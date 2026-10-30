# Setting up the GitHub space

One person does this once. Everything except a few manual steps is done by
`scripts/setup-github.ps1`.

## Prerequisites
1. **Git** and **PowerShell 7** (`winget install Microsoft.PowerShell`).
2. **GitHub CLI**: `winget install GitHub.cli`
3. Log in and add the project scope:
   ```
   gh auth login
   gh auth refresh -s project
   ```
4. Ask your teammates for their GitHub usernames.

## Run the script
From the root of this folder:
```
pwsh -File scripts/setup-github.ps1 -Repo <your-username>/virtual-tone-mic -Collaborators user1,user2
```

It will:
1. Fill in the repo name in the docs and templates.
2. Create the **private** repository and push this code (or push to it if it already exists).
3. Configure the repo: Issues, Discussions and Projects on, wiki off, squash merge, delete branches after merge.
4. Invite the collaborators.
5. Replace GitHub's default labels with the project's label scheme.
6. Create milestones M0–M4.
7. Create all issues, plus one epic per milestone with the issues linked as sub-issues.
8. Create the project board, link it to the repo and add every issue.
9. Pause and ask you to create three discussion categories (GitHub has no API for that), then create
   the starter discussions.
10. Try to protect `main` (see note below).

It's safe to run again: existing labels, milestones, issues and discussions are skipped.

Useful options: `-SkipProject`, `-SkipDiscussions`, `-KeepDefaultLabels`.

## Manual steps afterwards (about 5 minutes)
1. **Project board → Status field:** add an **In review** option between *In Progress* and *Done*.
2. **Project board → views:** add
   - *Board* grouped by Status (default),
   - *By milestone*: Table view grouped by Milestone,
   - *My work*: Table filtered by `assignee:@me`.
3. **Project → Workflows:** turn on *Item closed → Done* and *Pull request merged → Done* (usually on by default).
4. **Discussions:** pin the "Welcome" discussion.
5. **Milestones:** add due dates once you agree on them.
6. Fill in `docs/team.md` and `.github/CODEOWNERS` after the kickoff discussion.

## Note on protecting `main`
For **private** repositories, branch protection needs GitHub Pro/Team. Students get Pro for free through
the GitHub Student Developer Pack. Without it, the script prints a warning and continues; just follow
the "no direct pushes to main" rule from CONTRIBUTING.md.
