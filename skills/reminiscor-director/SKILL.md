---
name: reminiscor-director
description: Runs the reminiscor-director program, which makes a film with Seedance from a creator's story and files through a local ComfyUI. Use when the creator wants to set up, start, stop or check the director, or to run a generation with it.
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
