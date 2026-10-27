# GIT_Merge Directory

This directory stores merge-context documentation for each commit so team members merging changes understand exactly:
1. What features/changes are intended to be merged.
2. What files/features MUST remain UNTOUCHED.

### Workflow Rule:
- All commit context documentation files remain in `GIT_Merge/`.
- **Do NOT** move files to `archive/` upon creating a commit.
- **Only** move files to `GIT_Merge/archive/` when the latest branch/commit has actually been merged with someone **and** the user explicitly tells you to move it to `archive/`.
