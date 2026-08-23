# Skills

This is my personal collection of skills—the ones I use in my own agent workflows. I’ll keep adding to and refining the collection as those workflows evolve.

I often share videos about what I’m building and how I use these skills on [YouTube](https://www.youtube.com/@husamrahman77).

You can also connect with me on [LinkedIn](https://www.linkedin.com/in/husam-rahman).

## Skill catalog

### Capturing session knowledge

- [setup-vault](skills/setup-vault) — Create the markdown vault used to keep project context, session notes, and reusable learnings.
- [start-session](skills/start-session) — Begin a task with the most relevant context, gotchas, and handoff from previous sessions.
- [end-session](skills/end-session) — Wrap up a task by recording what changed, preserving useful learnings, and shipping the work through a pull request.

## Installation

Clone the repository first:

```bash
git clone https://github.com/husamrahman/skills.git
cd skills
```

### Claude Code

Install every skill for your user:

```bash
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

To install them for only one project, copy the skill folders into that project’s `.claude/skills/` directory instead.

### Codex

```bash
mkdir -p ~/.codex/skills
cp -r skills/* ~/.codex/skills/
```

### Other agents

Each skill is self-contained in its own folder and includes a `SKILL.md` file. For other skill-compatible agents, copy the folders you want from `skills/` into the directory where your agent loads skills.
