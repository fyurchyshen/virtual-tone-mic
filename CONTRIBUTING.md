# How we work

## Where things go

| What | Where |
|---|---|
| Quick questions, "are you around?", pings | Team chat |
| A piece of work (task, bug, investigation) | **Issue** |
| A question someone else might also have | **Discussions → Q&A** |
| A design choice that needs agreement | **Discussions → Decisions**, then recorded as an **ADR** in `docs/adr/` |
| Notes from a meeting or call | **Discussions → Meeting notes** |
| Progress summary (e.g. for our supervisor) | **Discussions → Status updates** |
| Knowledge that should last (setup steps, gotchas) | `docs/` |

Rule of thumb: if it was decided in chat or on a call, write it down in Discussions or an issue,
so nobody has to scroll through chat history later.

## Issue workflow

1. Pick an issue from the **Todo** column. Prefer the current milestone and higher priority.
2. **Assign yourself** before starting so nobody duplicates work.
3. Move it to **In progress** on the board.
4. If you get blocked, add the `status: blocked` label and say why in a comment.
5. Open a PR, move the issue to **In review**.
6. Merging the PR with `Closes #<n>` closes the issue and moves it to **Done**.

Epics (`type: epic`) group the issues of one milestone; their checklists update automatically.

## Labels

| Prefix | Meaning |
|---|---|
| `type:` | task, bug, research, decision, epic, docs |
| `area:` | driver, interface, lib, gui, tests, infra |
| `priority:` | P0 (needed for the core spec), P1 (important), P2 (nice to have) |
| `status:` | blocked, needs discussion |

## Branches and commits

- `main` is always buildable. Nobody pushes to it directly.
- Branch name: `<issue-number>-short-description`, e.g. `12-sine-generator`.
- Commit messages: short imperative summary, e.g. `Add square wave generator`.
- We squash-merge PRs, so the PR title becomes the commit on `main`. Make it descriptive.

## Pull requests

- Link the issue (`Closes #12`) and fill in the template, especially **how it was tested**.
- At least **one** teammate reviews before merging.
- Reviewers: be specific and kind. Authors: answer every comment, even with just "done".
- Keep PRs small. Several small PRs get reviewed faster than one huge one.

## Changing the shared interface (`common/`)

Anything in `common/` affects both the driver and the library.

1. Discuss the change first (issue or Decisions discussion).
2. Update the driver **and** the library in the same PR.
3. Bump `VTM_INTERFACE_VERSION` if a struct layout changes.

## Driver coding conventions

- Annotate functions with their IRQL (`_IRQL_requires_max_(PASSIVE_LEVEL)` etc.).
- Pageable code: `PAGED_CODE()` at the top and placed in the PAGE section. **Never** call pageable code from the DPC.
- Everything the DPC touches lives in **nonpaged** memory.
- Use a pool tag for every allocation and free everything on unload/remove.
- Check every `NTSTATUS`. Validate every IOCTL input buffer size and value.
- Run the build with **Code Analysis** enabled; fix warnings rather than suppressing them.

## Definition of Done

An issue is done when:
- [ ] The acceptance criteria in the issue are met.
- [ ] Code builds without warnings (Debug and Release, x64).
- [ ] It was tested in the VM, and the PR says how.
- [ ] Driver changes were tested with Driver Verifier enabled.
- [ ] Docs are updated if behaviour, setup or the interface changed.
- [ ] A teammate approved the PR.
