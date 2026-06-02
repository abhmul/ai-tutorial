---
name: checkpoint
description: "Checkpoint file-modifying work: update today's daily note and commit the coherent current-task slice when safe. Use when the user says checkpoint, before ending after edits, and at coherent milestones. Do not use for read-only sessions unless asked."
---
# Checkpoint

Record a concise daily-note entry and commit a safe, coherent work slice.

## Side effects

Warning: this skill changes files. It writes or appends `daily-notes/YYYY-MM-DD.md` and may create a Git commit unless `--no-commit` is supplied or a stop condition applies. Use it only when those side effects fit the current task scope.

## Arguments

$ARGUMENTS

May include a summary, commit-message hint, or `--no-commit`.

## Procedure

1. Run `git status --short`. Separate current-task changes from unrelated or pre-existing dirty files.
2. If there are no relevant changes and the user did not explicitly request a checkpoint, stop.
3. Update `daily-notes/YYYY-MM-DD.md`, where `YYYY-MM-DD` is `date +%F`.
   - If missing, create this scaffold with computed previous/current/next dates:

     ```md
     ---
     aliases:
     title: YYYY-MM-DD
     tags:
       - daily-note
       - ai-generated
     ---
     # YYYY-MM-DD
     [[PREVIOUS-DATE]]<- [[YYYY-MM-DD]] -> [[NEXT-DATE]]

     ## Session Notes
     ```

   - If present but missing `## Session Notes`, add that heading.
   - Append one H3 entry:

     ```md
     ### <Short Title>

     **Goal:** <one sentence>

     **Changes:**
     - <concise bullets>

     **Decisions:**
     - <concise bullets or "None.">

     **Validation:**
     - <checks run, or "Not run — <reason>.">

     **Open Items:**
     - [ ] <item, or "None.">
     ```

4. Validate: read back the new entry, run `git diff --check`, and run any cheap task-specific check needed for trust.
5. Commit unless `--no-commit` or a stop condition applies:
   - inspect the relevant diff;
   - stage only current-task files and your daily-note hunk (`git add -p` if the daily note was already dirty);
   - use an imperative commit message, honoring any user-provided hint.
6. Report: daily-note path, commit hash or no-commit reason, validation run, and unrelated dirty files left untouched.

## Stop Conditions

Do not commit if changes are incoherent, failing, inseparable from unrelated dirt, insufficiently validated, or would require staging unrelated files, forbidden/read-only files, or `tmp/` files not explicitly authorized for this task.
