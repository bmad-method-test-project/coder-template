# PR Title (required)

Your PR title **must** follow Conventional Commits.

## Allowed types (PR title prefix)

Use one of these types at the start of the PR title:
- `feat:` → **minor** release
- `fix:` → **patch** release
- `perf:` → **patch** release
- `refactor:` → **patch** release (use when behavior is unchanged)
- `docs:` → no release (unless `!` is used)
- `test:` → no release (unless `!` is used)
- `build:` → no release (unless `!` is used)
- `ci:` → no release (unless `!` is used)
- `chore:` → no release (unless `!` is used)
- `revert:` → **patch** release

## Breaking changes (major)

PR titles only have one line, so breaking changes must be marked with `!`:
- `feat!: drop support for X` → **major** release
- `refactor(api)!: change request format` → **major** release

## Examples

- `feat: add configurable namespace`
- `fix: correct pvc size default`
- `perf: reduce startup time`
- `refactor!: remove deprecated parameter`

> Tip: If you want releases to be fully automated, use **Squash and merge** and configure GitHub to **Default to PR title for squash merge commits**.
