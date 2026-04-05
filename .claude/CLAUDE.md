# Global Preferences

## Communication

- Before every code edit, briefly restate the reasoning behind the specific change you're about to make.

## Code Style

- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.

## CLAUDE.md Maintenance

- When you learn something important about a project (build commands, test commands, architecture patterns, naming conventions, or other project-specific context), proactively suggest adding it to the project's CLAUDE.md.
- When you learn something that applies across all projects (user preferences, workflow patterns, tool usage), proactively suggest adding it to the global CLAUDE.md at `~/.claude/CLAUDE.md`.
- If a CLAUDE.md instruction is outdated or conflicts with the current state of the code, flag it and suggest an update.
- Keep CLAUDE.md files concise and well-organized. Group related instructions under clear headings.

## Git

- Never stage or commit CLAUDE.md files. They are maintained manually by the user.
