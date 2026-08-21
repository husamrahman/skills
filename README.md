# skills

Open-source skills for coding agents: Claude Code, Codex, and friends.

A skill is a small, self-contained instruction set that teaches your agent to run one workflow the same way every time. Drop them in, call them by name, and stop re-explaining yourself.

Skills here are tool-neutral. Every skill ships a `SKILL.md` (the workflow the agent reads) plus an `agents/openai.yaml` adapter, so the same skill works in both Claude Code and Codex.

## The idea: a knowledge loop

`start-session` and `end-session` are a pair. Every session ends by writing its learnings (a summary, gotchas, evals with testable criteria, decisions, what got done) into a markdown knowledge vault, and every session starts by reading the relevant ones back. Your agent stops repeating the mistakes it already made once.

The vault is just a folder of `.md` files on your computer - searched directly, no database or index. New to this? Run `setup-vault` first and you have one in a second. No Obsidian, no account.

## Skills

| Skill | What it does |
|-------|--------------|
| [setup-vault](skills/setup-vault) | Create the markdown vault folder the session skills read and write, and record where it lives so they can find it on any OS. Run this once first. No Obsidian required. |
| [start-session](skills/start-session) | Read the project note and search your vault for gotchas, evals, and the last handoff, surface what applies, then open an isolated git worktree. |
| [end-session](skills/end-session) | Log the session in clear sections (summary, changes, decisions, gotchas, evals, next steps, handoff), turn learnings into evals with testable criteria, promote reusable gotchas, then commit, push, and open a PR. |

## Quickstart

New to this? The order is: install `setup-vault`, run it once to create your vault, then install `start-session` and `end-session` and use them per task.

### Claude Code

Copy a skill folder into your skills directory:

```bash
# just this project
mkdir -p .claude/skills
cp -r skills/start-session .claude/skills/

# or every project (user-scoped)
cp -r skills/start-session ~/.claude/skills/
```

Then call it:

```
/start-session
```

### Codex

Copy the same folder into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills
cp -r skills/start-session ~/.codex/skills/
```

Codex reads `SKILL.md` for the workflow and `agents/openai.yaml` for how to surface it.

## Where's the vault, and how do the skills find it?

`setup-vault` creates the vault (default `~/vault`) and writes its absolute path into a one-line pointer file, `~/.agent-vault`. `start-session` and `end-session` resolve the vault in this order:

1. A `VAULT` environment variable, if you set one.
2. The `~/.agent-vault` pointer file.
3. The `~/vault` default.

A plain pointer file is used on purpose instead of an environment variable or a symlink: it works identically on Windows, macOS, and Linux, needs no admin rights or shell-profile edits, and survives being copied between machines.

## How a skill is structured

```text
skills/<name>/
  SKILL.md            the workflow: name + description frontmatter, then steps
  agents/openai.yaml  Codex adapter: display name, short description, default prompt
  README.md           a walkthrough of the skill for humans
```

Same skill, two front doors: one file the agent reads, one adapter that makes it feel native in Codex.

## Testing

Every skill is verified in isolation by a dependency-free harness (`bash` + `git`, nothing to install). Each suite runs in a throwaway `HOME` and git repo and asserts the skill's real side effects; a structural lint covers every skill automatically.

```bash
bash tests/run.sh
```

Adding a skill? See [tests/README.md](tests/README.md) for the one-file recipe. CI runs this on every push and PR.

## License

MIT, see [LICENSE](LICENSE). Use them, fork them, make them yours.
