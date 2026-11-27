---
name: reminiscor-director
description: Runs the reminiscor-director program, which makes a film with Seedance from a creator's story and files through a local ComfyUI. Use when the creator wants to set up, start, stop, check or update the director, or to run a generation with it.
---

The director is a program on this machine. Run it only through the script in this skill's base directory:

```bash
"<base directory>/scripts/reminiscor-director" <command>
```

The first call downloads the program and runs `setup`, which installs ComfyUI, torch and ffmpeg: it takes several minutes and a few GB, so run it in the background and tell the creator. Later calls start at once.

| Command | Does |
|---|---|
| `setup` | installs or checks everything; safe to run again |
| `start` | starts ComfyUI and the local app; prints their addresses |
| `status` | what runs and where, and the last records |
| `ping` | runs one free workflow and records it: the check that everything works |
| `stop` | stops what `start` started |

`--help` on the program lists the rest. The creator's records and media stay in the program's data folder, which `status` prints.

Before a command, run `status`; when the app is down, run `start` first. When a command fails, read the log it names, and report what it says to the creator.

## Updates

When the creator asks to check for updates:

1. Run `update --check`. It installs nothing: it prints `... is the latest`, or the installed version, the latest, and the changelog sections in between.
2. When there is a newer version, show it as a question card with two buttons, Update and Not now (in Claude Code, the AskUserQuestion tool): the two versions and what is new, in the creator's language.
3. Only on Update, run `update`. It stops what runs, installs the new program, runs `setup` (it adds only what changed) and starts what was running again. The creator's records, database and media stay.
