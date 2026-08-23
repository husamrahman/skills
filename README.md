# Skills for Claude Code and Codex

My agent skills that I use in my own workflows.

These skills come from hands-on experience using agents across real projects. The collection will keep growing and evolving as those workflows develop. Use what helps. Adapt it. Make it your own.

If you want to keep up with new skills and changes to existing ones, follow along on [YouTube](https://www.youtube.com/@husamrahman77). You can also visit [AEI Agency](https://www.aei.agency/) or connect with me on [LinkedIn](https://www.linkedin.com/in/husam-rahman).

## Installation (30-second setup)

Run the skills installer:

```bash
npx skills@latest add husamrahman/skills
```

Pick the skills you want, then choose Claude Code or Codex as the target.

## Reference

### Capturing session knowledge

Carry useful context and lessons from one agent session into the next.

- [setup-vault](skills/setup-vault): Create the markdown vault used to keep project context, session notes, and reusable learnings.
- [start-session](skills/start-session): Begin a task with the most relevant context, gotchas, and handoff from previous sessions.
- [end-session](skills/end-session): Wrap up a task by recording what changed, preserving useful learnings, and shipping the work through a pull request.
