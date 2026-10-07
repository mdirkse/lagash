# Global Agent Instructions

## Datadog interaction
- Never try to access the EU Datadog endpoints.
- Use the pup CLI to interact with Datadog.

## Git usage
- Prefer single-commit PRs. When adding a change on an existing PR, amend the last commit with the new changes and force-push to the remote branch. Only create a new commit on the PR branch when explicitly asked to do so.

## GitHub interaction
- Try to always interact with the GitHub API using the GitHub CLI.

## Tooling
- Never use perl

## Output Preferences
- If a fix only requires changing 2 lines in a longer file, only output those lines or a diff — do not rewrite the whole file.
- Keep conversational fluff to an absolute minimum.
