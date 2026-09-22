# Global Preferences

The dev server is always running on port 8080: the `standup` nginx container (`~/.local/bin/standup` serves the current repo, `standup down` stops it). Reuse it, and never stop or remove it yourself.

## Skills & Automation

- Prefer programmatic, deterministic mechanisms over runtime model instructions when building or editing a skill or slash command, whenever a programmatic path reaches the same goal. Prose the model must execute is a soft dependency that can drift or skip steps. A script or harness mechanism runs the same way every time. Examples: a slash command's `!`-injection plus `allowed-tools` frontmatter for deterministic setup, or baking logic (a greeting, a fresh-vs-resume branch) into the invoked script instead of telling the model to do it.

## Code Style

- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.
- Keep comments to a single line of terse sentence-case fragments, not prose.
- Prefer self-documenting names over a terse name plus an explanatory comment. When a value would need a comment to state its unit or semantic, fold that into the name first (`MISS_MULTIPLIER` not `ADAPT_MISS // weight multiplier on a miss`, `MASTERY_STREAK` not `PROG_MASTER // consecutive corrects to learn a card`). Add comments for variable declarations only when the name genuinely cannot carry the meaning (ex. opaque magic number at a true config point, non-obvious rationale).
- Spell names out in full, never shorthand: `button` not `btn`, `element` not `el`, `index` not `idx`, `previous` not `prev`, `count` not `cnt`. Applies to variables, functions, IDs, classes, and CSS custom properties. Exceptions: established acronyms and initialisms (`id`, `url`, `html`, `api`), `config`, `min`/`max`, and a bare loop counter `i`.
- A trailing (inline) comment gets exactly one space before `//`. Never pad with extra spaces to align trailing comments into a column.
- Never use em dashes or semicolons in anything you write: comments, commit messages, docs, replies. Punctuate with periods, commas, colons, and parentheses. A spaced hyphen serves as a dash. (Semicolons as code statement terminators are fine.)
- Do not add redundant guards or defensive checks for conditions that cannot occur given the surrounding code, type system, or framework guarantees. Examples to avoid: null/undefined checks on values that were just assigned or are guaranteed by the caller, `isset()`/`array_key_exists()` on keys just set, re-validating input already validated upstream, try/catch blocks that only re-throw, fallback branches for impossible states. Only validate at true system boundaries (user input, external APIs, file/network I/O).
- Hidden guard forms count too, hold them to the same bar as an `if`: optional chaining (`?.`, `?.()`) on a value guaranteed present when the code runs (a handler only reachable while its target exists), feature-detecting a browser or platform API no newer than APIs the codebase already uses unconditionally, and emptiness or length checks at a call site whose only trigger guarantees non-empty (a button rendered only when the list has items). Before writing `?.` or an early-return gate, trace who can call this and what state is possible then, and drop the check if no caller can violate it.

## File Paths

- Prefer `~` over hardcoded home directory paths whenever possible (e.g. `~/.local/bin/` instead of `/home/andrewv/.local/bin/`).

## System & Software Setup

- Bloatware-averse. Software should be fast, snappy, and efficient, both to use and to build. When writing software, keep it lean inline with no bloat.
- Install via the system package manager first (apt on Ubuntu).
- When apt lacks the package or ships too old a version, add a third-party repo that points to it. (When later removing the repo, also remove its signing keyring.)
- Avoid Snap: slow startup and load time.
- Keep a lean setup: strip out preinstalled software that goes unused.
- GUI apps for most tasks, command-line tools for code work.
- Keep the host clean: prefer containerized, ephemeral tooling. Spin it up for the task, tear it down after, so it exists only on spin-up. This applies to how you execute work too: package it so it can be dropped later.
- Always disable telemetry and phone-home services, and turn off auto-start daemons that aren't needed.
- `sudo` cannot prompt in Claude sessions (no TTY, `!` commands included). Use `pkexec` for a GUI password prompt.
- Sandboxed Bash can misreport installed packages. Confirm with `dpkg -l` or `/var/log/dpkg.log` unsandboxed before calling one missing.
- Firefox is the Mozilla apt deb (`/usr/lib/firefox/firefox`), never the snap: the firefox-devtools MCP cannot drive snap Firefox (private `/tmp`). Ubuntu's snap shim carries an epoch that outranks every Mozilla build, so an origin `-1` pin in `/etc/apt/preferences.d/mozilla` plus `"^firefox$"` in unattended-upgrades' `Package-Blacklist` keep it out (a 1000 pin alone does not). `claude mcp list` says Connected even with the wrong binary, so check with `get_firefox_info`.

## CLAUDE.md Maintenance

- CLAUDE.md holds what every session needs. Anything that only matters for some files goes in a path-scoped rule: `.claude/rules/<topic>.md` with `paths:` frontmatter, loaded when a matching file is read. A glob with no slash matches that file name at any depth, so anchor a root file as `/name`. A rule without `paths:` loads every session, so that content belongs in CLAUDE.md instead.
- Open files with the Read tool rather than `cat`, `head` or `sed`, since only a Read tool call loads a path-scoped rule.
- When you learn something important about a project (build commands, test commands, architecture patterns, naming conventions, or other project-specific context), proactively add it to the rule whose `paths:` cover the files it concerns, or start a new rule when none does. Add it to the project's CLAUDE.md only when every session needs it.
- When you learn something that applies across all projects (user preferences, workflow patterns, tool usage), proactively add it to the global CLAUDE.md at `~/.claude/CLAUDE.md`, or to `~/.claude/rules/` when it only applies to some file types (`html-css.md`, `javascript.md`).
- If a CLAUDE.md or rule instruction is outdated or conflicts with the current state of the code, update it.
- Keep CLAUDE.md and rule files concise and well-organized. Group related instructions under clear headings. Keep each under 200 lines (Anthropic's documented target) and split a rule that outgrows it.

## Git

- Do not proactively offer to commit.
- Commit messages are one concise subject line, no body. Add a body only when asked or when a non-obvious why cannot fit the subject, never to restate it. Name files with their extension (`Add README.md`).
- Never run `git reset` without asking. Unstage with `git restore --staged <file>` and discard work-tree changes with `git restore <file>`.
- `CLAUDE.md` and `.claude/` are in `~/.gitignore_global`: never stage them, and a `git stash` needs `--all` to carry them.
