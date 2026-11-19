# AGENTS.md — Ereboros host repo: agent governance

## GitHub pull request governance

- `main` on this repository is **PR-required** (0 approvals).
- The **agent** authors pull requests and addresses review comments (PRs carry the owner's identity).
- The **owner** is the **sole merger/deployer**.

## Status

- Originated from the wiki idea `ideas/github-pr-governance` (filed 2026-11-09; deliberately not implemented at the time).
- The owner deferred refinement of this governance; refinement is planned future work.

## Working policy

- The agent does not push/merge/branch in this repository without owner instruction.
- Code-generation answers are complete snippets for the owner to copy/paste and apply.

## Branching & PR workflow (owner instruction 2026-11-19)

- For each new feature: checkout the default branch (`main`) and pull the latest changes before creating a new, specific feature branch.
- Never reuse old branches — they get deleted when a PR is merged or closed.
- The repository must always be synced with the default branch before any modifications.
- When pushing the first commit on a branch, also create the corresponding pull request.

## PR creation rules

- When creating a pull request, set it as **draft** and assign **@TheWhale01** as reviewer.
