# Reminiscor skills

Agent skills from Reminiscor. The `reminiscor-director` skill makes a film with Seedance from a creator's story and files, through a ComfyUI on your own machine.

The skill is a thin layer: on first use it downloads the `reminiscor-director` program from this repo's [Releases](https://github.com/reminiscor-vr/skills/releases) and runs its setup, which installs ComfyUI, torch and ffmpeg (several minutes, a few GB). Your records and media stay in the program's data folder on your machine.

Supported: Mac with Apple Silicon, Linux x64 (glibc 2.35 or newer, as Ubuntu 22.04) and Windows 10/11 x64. On Windows the agent runs the skill's script in Git Bash, which Claude Code needs anyway; agents whose shell is PowerShell use `scripts/reminiscor-director.cmd` next to it. No admin rights are needed. With an NVIDIA GPU, setup installs the CUDA build of torch, otherwise the CPU one.

## Install

### Claude Code

```bash
claude plugin marketplace add reminiscor-vr/skills
claude plugin install reminiscor-director@reminiscor
```

Then ask Claude to set up the director, or to ping it.

### Codex, OpenCode and Grok

All three load skills from `~/.agents/skills`. Clone this repo once and link the skill there:

```bash
git clone https://github.com/reminiscor-vr/skills ~/.local/share/reminiscor-skills
```

```bash
mkdir -p ~/.agents/skills && ln -s ~/.local/share/reminiscor-skills/skills/reminiscor-director ~/.agents/skills/reminiscor-director
```

On Windows, in cmd (a junction needs no admin rights):

```bat
git clone https://github.com/reminiscor-vr/skills %LOCALAPPDATA%\reminiscor-skills
mkdir %USERPROFILE%\.agents\skills
mklink /J %USERPROFILE%\.agents\skills\reminiscor-director %LOCALAPPDATA%\reminiscor-skills\skills\reminiscor-director
```

Restart the agent, then ask it to set up the director, or to ping it.

Grok also reads Claude Code's plugins. If the plugin is already installed in Claude Code and Grok lists `reminiscor-director` among its skills, skip the link.

### Permission prompts

The first time the agent asks before running a director command, it offers to stop asking. On your yes it adds one allow rule to its own settings, for the director's script and nothing else. Paid generations still wait for your yes on the Run card.

## Updates

Ask the agent to check for updates: it installs the latest release when there is a newer one, then runs setup, which adds only what changed. Your records, database and media are kept. A newer plugin version also moves the program up on its next use.

Outside Claude Code the skill itself is updated by pulling the clone:

```bash
git -C ~/.local/share/reminiscor-skills pull
```

## Licence

To be decided. The program's source is not in this repo.
