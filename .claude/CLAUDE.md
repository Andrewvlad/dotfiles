# Global Preferences

## Communication

- Before every code edit, briefly restate the reasoning behind the specific change you're about to make.

## Code Style

- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.

## CSS

- First, use the right HTML element for the job (e.g. a `<button>` for an action, not an `<a>` styled as a button). Then prefer element selectors over class names when the element is unambiguous in its context (e.g. `header`, `nav button`, `.admin-form label`). Avoid fragile positional pseudo-selectors like `a:first-child` / `a:last-child` — if you need to distinguish siblings of the same type, use a different element or add a class.

## CLAUDE.md Maintenance

- When you learn something important about a project (build commands, test commands, architecture patterns, naming conventions, or other project-specific context), proactively add it to the project's CLAUDE.md.
- When you learn something that applies across all projects (user preferences, workflow patterns, tool usage), proactively add it to the global CLAUDE.md at `~/.claude/CLAUDE.md`.
- If a CLAUDE.md instruction is outdated or conflicts with the current state of the code, update it.
- Keep CLAUDE.md files concise and well-organized. Group related instructions under clear headings.

## Git

- Never stage or commit CLAUDE.md files. They are already ignored by the global git ignore.
- Proactively suggest commits when a logical unit of work is complete. Don't wait for the user to ask.
- Prefer single-line commit messages when the change is straightforward enough to summarize concisely.
