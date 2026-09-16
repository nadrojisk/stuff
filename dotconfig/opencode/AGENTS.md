# Global Instructions

## Obsidian Note-Taking

You have access to a `note-taker` subagent that writes to the user's Obsidian vault.

**Proactively delegate to `note-taker` when:**
- The user says anything like "save this", "take a note", "write this down", "remember this", "add to my vault", or "note that"
- A session surfaces a concrete, reusable fact: a command invocation, a config pattern, a tool behavior, a debugging technique, a security finding, a code pattern worth preserving
- The user explicitly asks you to document something

**Do not ask for permission** — just delegate to the `note-taker` subagent immediately when any of the above applies. After it finishes, briefly mention the file path it wrote.

**When delegating to `note-taker`**, always include explicit instructions to:
- Check and update parent index/MOC pages up the directory tree for every file written
- Create missing index files if sibling notes exist in that folder

**Do not delegate for:**
- Ephemeral session context (e.g., the current state of a file you're editing)
- Things the user will clearly remember or that are already well-documented
- Every single message — only when genuinely worth persisting
