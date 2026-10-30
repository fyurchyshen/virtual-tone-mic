# scripts/github/

Seed data used by `../setup-github.ps1`. Edit these files to change what gets created.

| File | Creates |
|---|---|
| `labels.json` | Labels (`type:`, `area:`, `priority:`, `status:`) |
| `milestones.json` | Milestones M0–M4 |
| `issues.json` | Issues, plus one epic per milestone with the issues as sub-issues |
| `discussions.json` | Starter discussions (category given by slug) |
| `branch-protection.json` | Protection rule for `main` |
