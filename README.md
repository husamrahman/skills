# Skills I Use

My personal collection of agent skills, pulled directly from my own workflows.

These are the skills I use in practice. I’ll keep adding to them and refining them as my workflows evolve. Take what helps, adapt it, and make it your own.

I share videos about what I’m building and how I use these skills on [YouTube](https://www.youtube.com/@husamrahman77). You can also connect with me on [LinkedIn](https://www.linkedin.com/in/husam-rahman).

## Installation

Use the skills installer and choose the skills you want to add to Claude Code or Codex:

```bash
npx skills@latest add husamrahman/skills
```

## Reference

### Capturing session knowledge

Skills for carrying useful context and lessons from one agent session into the next.

- [setup-vault](skills/setup-vault): Create the markdown vault used to keep project context, session notes, and reusable learnings.
- [start-session](skills/start-session): Begin a task with the most relevant context, gotchas, and handoff from previous sessions.
- [end-session](skills/end-session): Wrap up a task by recording what changed, preserving useful learnings, and shipping the work through a pull request.
