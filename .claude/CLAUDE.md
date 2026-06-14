# Global Preferences

## Communication

- Before every code edit, briefly restate the reasoning behind the specific change you're about to make.
- Use the AskUserQuestion modal for yes/no and simple choice confirmations instead of asking inline.
- Do not proactively offer to `/schedule` background agents at the end of replies. Only mention `/schedule` if I explicitly ask about it.

## Code Style

- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.
- Keep comments to a single line of terse sentence-case fragments, not prose. A multi-line comment paragraph justifying a value or approach belongs in the commit message instead.
- Prefer self-documenting names over a terse name plus an explanatory comment. When a value would need a comment to state its unit or semantic, fold that into the name first (`MISS_MULTIPLIER` not `ADAPT_MISS // weight multiplier on a miss`, `MASTERY_STREAK` not `PROG_MASTER // consecutive corrects to learn a card`). Keep the comment only when the name genuinely cannot carry the meaning (an opaque magic number at a true config point, non-obvious rationale).
- Never use em dashes or semicolons in anything you write for me: comments, commit messages, docs, replies. Punctuate with periods, commas, colons, and parentheses. A spaced hyphen serves as a dash. (Semicolons as code statement terminators are fine.)
- Do not add redundant guards or defensive checks for conditions that cannot occur given the surrounding code, type system, or framework guarantees. Examples to avoid: null/undefined checks on values that were just assigned or are guaranteed by the caller, `isset()`/`array_key_exists()` on keys just set, re-validating input already validated upstream, try/catch blocks that only re-throw, fallback branches for impossible states. Only validate at true system boundaries (user input, external APIs, file/network I/O).

## File Paths

- Prefer `~` over hardcoded home directory paths whenever possible (e.g. `~/.local/bin/` instead of `/home/andrewv/.local/bin/`).

## HTML & CSS

- Use the right HTML element for the job (e.g. a `<button>` for an action, not an `<a>` styled as a button).
- Prefer element selectors over class names when the element is unambiguous in its context (e.g. `header`, `nav button`, `.admin-form label`).
- Avoid fragile positional pseudo-selectors like `a:first-child` / `a:last-child` — if you need to distinguish siblings of the same type, use a different element or add a class.

## CLAUDE.md Maintenance

- When you learn something important about a project (build commands, test commands, architecture patterns, naming conventions, or other project-specific context), proactively add it to the project's CLAUDE.md.
- When you learn something that applies across all projects (user preferences, workflow patterns, tool usage), proactively add it to the global CLAUDE.md at `~/.claude/CLAUDE.md`.
- If a CLAUDE.md instruction is outdated or conflicts with the current state of the code, update it.
- Keep CLAUDE.md files concise and well-organized. Group related instructions under clear headings.

## Docker

- When a project uses Docker with bind mounts (e.g. FUSE-based mounts), always `--force-recreate` the relevant container after editing files so changes are visible inside the container. Do this proactively — don't wait for the user to ask.

## Git

- Never stage or commit CLAUDE.md files. They are already ignored by the global git ignore.
- Do not proactively offer commits. Only suggest or make commits when I explicitly ask.
- When I do ask, suggest commits inline in plain text — do NOT use the AskUserQuestion modal for commit offers (this overrides the "use the modal for confirmations" default for commit offers specifically).
- Prefer single-line commit messages when the change is straightforward enough to summarize concisely.
