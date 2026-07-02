# Global Preferences

## Communication

- Before every code edit, briefly restate the reasoning behind the specific change you're about to make.
- Use the AskUserQuestion modal for yes/no and simple choice confirmations instead of asking inline.
- Do not proactively offer to `/schedule` background agents at the end of replies. Only mention `/schedule` if I explicitly ask about it.

## Skills & Automation

- Prefer programmatic, deterministic mechanisms over runtime model instructions when building or editing a skill or slash command, whenever a programmatic path reaches the same goal. Prose the model must execute is a soft dependency that can drift or skip steps. A script or harness mechanism runs the same way every time. Examples: a slash command's `!`-injection plus `allowed-tools` frontmatter for deterministic setup, or baking logic (a greeting, a fresh-vs-resume branch) into the invoked script instead of telling the model to do it.

## Code Style

- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.
- Keep comments to a single line of terse sentence-case fragments, not prose.
- Prefer self-documenting names over a terse name plus an explanatory comment. When a value would need a comment to state its unit or semantic, fold that into the name first (`MISS_MULTIPLIER` not `ADAPT_MISS // weight multiplier on a miss`, `MASTERY_STREAK` not `PROG_MASTER // consecutive corrects to learn a card`). Add comments for variable declarations only when the name genuinely cannot carry the meaning (ex. opaque magic number at a true config point, non-obvious rationale).
- A trailing (inline) comment gets exactly one space before `//`. Never pad with extra spaces to align trailing comments into a column.
- Never use em dashes or semicolons in anything you write: comments, commit messages, docs, replies. Punctuate with periods, commas, colons, and parentheses. A spaced hyphen serves as a dash. (Semicolons as code statement terminators are fine.)
- Do not add redundant guards or defensive checks for conditions that cannot occur given the surrounding code, type system, or framework guarantees. Examples to avoid: null/undefined checks on values that were just assigned or are guaranteed by the caller, `isset()`/`array_key_exists()` on keys just set, re-validating input already validated upstream, try/catch blocks that only re-throw, fallback branches for impossible states. Only validate at true system boundaries (user input, external APIs, file/network I/O).

## File Paths

- Prefer `~` over hardcoded home directory paths whenever possible (e.g. `~/.local/bin/` instead of `/home/andrewv/.local/bin/`).

## HTML & CSS

- Use the appropriate HTML element for the job (e.g. a `<button>` for an action, not an `<a>` styled as a button).
- Prefer element selectors over class names when the element is unambiguous in its context (e.g. `header`, `nav button`, `.admin-form label`).
- Avoid fragile positional pseudo-selectors like `a:first-child` / `a:last-child` — if you need to distinguish siblings of the same type, use a different element or add a class.
- Nest state, modifier, and pseudo selectors inside their parent block with native CSS `&` (`&.answered` inside `#answerGrid`, plus `&:hover`, `&.active`, `&::after`) rather than repeating the parent as a flat compound selector (`#answerGrid.answered` written separately). Apply this by default when adding or tidying CSS. A rule that targets a genuinely different element stays flat.

## CLAUDE.md Maintenance

- When you learn something important about a project (build commands, test commands, architecture patterns, naming conventions, or other project-specific context), proactively add it to the project's CLAUDE.md.
- When you learn something that applies across all projects (user preferences, workflow patterns, tool usage), proactively add it to the global CLAUDE.md at `~/.claude/CLAUDE.md`.
- If a CLAUDE.md instruction is outdated or conflicts with the current state of the code, update it.
- Keep CLAUDE.md files concise and well-organized. Group related instructions under clear headings.

## Docker

- When a project uses Docker with bind mounts (e.g. FUSE-based mounts), always `--force-recreate` the relevant container after editing files so changes are visible inside the container. Do this proactively — don't wait for the user to ask.

## Browser Automation (Claude in Chrome)

- Default to reusing an existing tab in the Claude (MCP) tab group when it is inactive/idle. This overrides the harness default of always opening a new tab. Call `tabs_context_mcp` first to read the group and each tab's state.
- Only open a new tab when the existing Claude-group tab(s) are actively in use, and create it inside that same Claude tab group, not a detached tab elsewhere.

## Git

- Never stage or commit CLAUDE.md files. They are already ignored by the global git ignore.
- Do not proactively offer commits. Only suggest or make commits when asked for.
- When I do ask, suggest commits inline in plain text.
- Prefer single-line commit messages when the change is straightforward enough to summarize concisely.
