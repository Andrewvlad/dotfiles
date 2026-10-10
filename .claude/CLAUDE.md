# Global Preferences

The dev server is always running on port 8080. Reuse it.

## Skills & Automation

- Prefer programmatic, deterministic mechanisms over runtime model instructions when building or editing a skill or slash command, whenever a programmatic path reaches the same goal. Prose the model must execute is a soft dependency that can drift or skip steps. A script or harness mechanism runs the same way every time. Examples: a slash command's `!`-injection plus `allowed-tools` frontmatter for deterministic setup, or baking logic (a greeting, a fresh-vs-resume branch) into the invoked script instead of telling the model to do it.

## Writing Dtyle

- Use American English spelling when you write (`gray`, `color`, `center`) except for names you don't control (`aria-labelledby`, third-party APIs, quotes, proper nouns).
- Never use em dashes or semicolons. Instead, punctuate with periods, commas, colons, and parentheses. A spaced hyphen serves as a dash. (Semicolons as code statement terminators are fine.)

## Working Style

- When the user reverts one of your cleanup edits, that spot is an intentional exception to the rule it broke, so never redo it.

## Code Style

- Bloatware-averse. Software should be fast, snappy, and efficient, both to use and to build. When writing software, keep it lean inline with no bloat.
- Use spaces, not tabs. Indentation is 4 spaces.
- Do not remove comments unless the associated code was also removed.
- Avoid comments as much as possible: the code should be self-explanatory. A needed comment is one short sentence-case line, not prose.
- Prefer self-documenting names over a terse name plus an explanatory comment. When a value would need a comment to state its unit or semantic, fold that into the name first (`MISS_MULTIPLIER` not `ADAPT_MISS // weight multiplier on a miss`, `MASTERY_STREAK` not `PROG_MASTER // consecutive corrects to learn a card`). Add comments for variable declarations only when the name genuinely cannot carry the meaning (ex. opaque magic number at a true config point, non-obvious rationale).
- Spell names out in full, never shorthand: `button` not `btn`, `element` not `el`, `index` not `idx`, `previous` not `prev`, `count` not `cnt`. Applies to variables, functions, IDs, classes, and CSS custom properties. Exceptions: established acronyms and initialisms (`id`, `url`, `html`, `api`), `config`, `min`/`max`, and a bare loop counter `i`.
- A trailing (inline) comment gets exactly one space before `//`. Never pad with extra spaces to align trailing comments into a column.
- Do not add redundant guards or defensive checks for conditions that cannot occur given the surrounding code, type system, or framework guarantees. Examples to avoid: null/undefined checks on values that were just assigned or are guaranteed by the caller, `isset()`/`array_key_exists()` on keys just set, re-validating input already validated upstream, try/catch blocks that only re-throw, fallback branches for impossible states. Only validate at true system boundaries (user input, external APIs, file/network I/O).
- Hidden guard forms count too, hold them to the same bar as an `if`: optional chaining (`?.`, `?.()`) on a value guaranteed present when the code runs (a handler only reachable while its target exists), feature-detecting a browser or platform API no newer than APIs the codebase already uses unconditionally, and emptiness or length checks at a call site whose only trigger guarantees non-empty (a button rendered only when the list has items). Before writing `?.` or an early-return gate, trace who can call this and what state is possible then, and drop the check if no caller can violate it.

## File Paths

- Prefer `~` over hardcoded home directory paths whenever possible (e.g. `~/.local/bin/` instead of `/home/andrewv/.local/bin/`).

## CLAUDE.md Maintenance

- Open files with the Read tool rather than `cat`, `head` or `sed`, since only a Read tool call loads a path-scoped rule.
- Write to a CLAUDE.md, rule or skill only when the user states a preference, corrects your output, or asks you to write something down, keeping their wording as close as possible. Otherwise suggest a one-line entry at the end of the task and write it only once they say OK.
- Memory holds only machine facts (how this computer is set up and behaves), never preferences.
- Fix or delete an entry your own change made wrong, in the same change. Suggest any other fix at the end of the task.
- When a project's CLAUDE.md or rules carry counts, file lists, history or British spellings, suggest a cleanup at the end of the task and do it only once the user says OK.

## Git

- Do not proactively offer to commit.
