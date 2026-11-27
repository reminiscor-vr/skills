# Reminiscor skills

Agent skills from Reminiscor. The `reminiscor-director` skill makes a film with Seedance from a creator's story and files, through a ComfyUI on your own machine.

The skill is a thin layer: on first use it downloads the `reminiscor-director` program from this repo's [Releases](https://github.com/reminiscor-vr/skills/releases) and runs its setup, which installs ComfyUI, torch and ffmpeg (several minutes, a few GB). Your records and media stay in the program's data folder on your machine.

Supported: Mac with Apple Silicon and Linux x64. Windows comes later.

## Install

### Claude Code

```bash
claude plugin marketplace add reminiscor-vr/skills
claude plugin install reminiscor-director@reminiscor
```

Then ask Claude to set up the director, or to ping it.

## Updates

Ask Claude to check for updates: it installs the latest release when there is a newer one, then runs setup, which adds only what changed. Your records, database and media are kept. A newer plugin version also moves the program up on its next use.

## Licence

To be decided. The program's source is not in this repo.
