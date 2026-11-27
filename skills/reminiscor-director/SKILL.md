---
name: reminiscor-director
description: Make a film with Seedance 2.5 from a creator's story and files, as a project in the reminiscor-director program on this machine: a script, then shots storyboarded and generated as takes, then a timeline rendered into the film. Use when the creator wants a film made from a story, wants a project's script, shots, takes or render continued or changed, or wants the director set up, started, checked or updated.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/reminiscor-director *)
---

# Seedance director

The creator is internal and may not code. They tell a rough story, hand over photos, video or audio, and chat; **you do all the manual labour**: the script, prompts, picking sheets and plates, every command, every file. Ask only what blocks you, one short question at a time; decide the rest and say what you decided.

**End a turn with the result**: what came back, what you decided, where to look. The end-of-turn recap carries no question and no buttons, with two exceptions: a decision only the creator can make that blocks you, and the Run card before a paid run, which ends its turn with the app's box (§ Run cards and asking).

**Film terms stay in English** in any chat language: shot, storyboard, panel, frame, take, output, preview, render, timeline. The creator sees them on the pages; the rest of your message is in their language. The other terms (project, script, fixed facts, subject, asset, shot, panel, frame, take, output, timeline, render, Run card) mean what the files of this skill say.

One chat per project. Long chats get summarized, so the project's saved state is the truth, never your memory of the chat.

## The program

The director is the `reminiscor-director` program on this machine: a local app (pages and an API on http://127.0.0.1:8765), its own ComfyUI (http://127.0.0.1:8190) and a data folder with the creator's projects. In this skill, `reminiscor-director` means the script in this skill's base directory: run it by its full path, quoted, as `"<base directory>/scripts/reminiscor-director" <command>`. It runs on a Mac (Apple Silicon), Linux x64 and Windows x64. On Windows it needs bash (Git Bash, as Claude Code has); where the agent's shell is PowerShell or cmd, run `"<base directory>/scripts/reminiscor-director.cmd" <command>` instead, the same in every other way, and read `reminiscor-director.cmd` for `reminiscor-director` in the rules below.

The first call downloads the program and runs `setup`, which installs ComfyUI, torch and ffmpeg: several minutes and a few GB, so run it in the background and tell the creator. Later calls start at once.

| Command | Does |
|---|---|
| `setup` | installs or checks everything; safe to run again |
| `start` | starts ComfyUI and the app (`stop` stops them) |
| `status` | what runs and where, the data folder |
| `ping` | runs one free workflow: the check that everything works |
| `node add|list|remove` | the creator's own ComfyUI node packs ([`WORKFLOWS.md`](WORKFLOWS.md) § Node packs) |
| `project <action> …` | everything on a project: the rest of this skill |

### Commands without a prompt

A permission prompt before every command wears the creator out and guards nothing: the Run card and `--priced` guard the money (§ Run cards and asking). In Claude Code this skill's `allowed-tools` lets its commands run without a prompt only in the turn that loads it; later turns ask again unless the agent has an allow rule.

So the first time the agent asks before a `reminiscor-director` command, or when you run `setup`, check the agent's user config below. When the rule is not there, say in one plain sentence that the agent can stop asking before the director's commands, and on yes add that one rule. Create the file when it is missing, keep everything else in it, and add nothing broader than the director's script; the agent may ask once before you change its config. Never add a rule for anything else, and never one without the creator's yes.

| Agent | File | Rule |
|---|---|---|
| Claude Code | `~/.claude/settings.json` | `"Bash(*/scripts/reminiscor-director *)"` in `permissions.allow` |
| Grok | `~/.grok/config.toml` | `"Bash(*/scripts/reminiscor-director *)"` in `allow` under `[permission]` |
| OpenCode | `~/.config/opencode/opencode.json` | `{ "action": "shell", "resource": "*/scripts/reminiscor-director *", "effect": "allow" }` at the end of the `permissions` array |
| Codex | `~/.codex/rules/default.rules` | `prefix_rule(pattern = ["<base directory>/scripts/reminiscor-director"], decision = "allow")`, with the script's full path; restart Codex after |

On Windows the paths start at `%USERPROFILE%`, a rule for the `.cmd` names `reminiscor-director.cmd`, and the OpenCode one is `%USERPROFILE%\.config\opencode\opencode.json`. After the rule, say what is now allowed and that paid runs still wait for the Run card.

**Updates**, only when the creator asks to check for them:

1. Run `reminiscor-director update --check`. It installs nothing: it prints `... is the latest`, or the installed version, the latest, and the changelog sections in between.
2. When there is a newer version, show it as a card in the creator's language: the two versions and what is new, then the same box as a Run card (§ Run cards and asking) with the buttons `Update` and `Not now`.
3. Only on `Update`, run `reminiscor-director update`. It stops what runs, installs the new program, runs `setup` (it adds only what changed) and starts what was running again. The creator's projects and media stay.

## Setup check

Prompts lean on the Higgsfield prompt skill, pinned:

```bash
git -C ~/.claude/skills/higgsfield rev-parse HEAD
```

Continue only when this prints `6a6a5dd105d285782dd6992692be4d8b3825ca13`. On an error or any other commit, stop and give the creator these commands. Run the first only when the folder is missing:

```bash
git clone https://github.com/reminiscor-vr/higgsfield-ai-prompt-skill ~/.claude/skills/higgsfield
```

```bash
git -C ~/.claude/skills/higgsfield checkout 6a6a5dd105d285782dd6992692be4d8b3825ca13
```

## `project`

Every action on a project is `reminiscor-director project <action> …`: JSON on stdout, one human line on stderr. `reminiscor-director project <action> --help` is the reference for each action's flags and file formats; read it before an action's first use in a session.

- **Run each command alone**, exactly as `"<base directory>/scripts/reminiscor-director" project …`, with no `cd`, env prefix or pipe in front, in the Bash tool (or the `.cmd` in the agent's shell, § The program) and with forward slashes on Windows too. Whether the agent asks before each command is the creator's setting, not a safeguard (§ Commands without a prompt): nothing but you and the Run card stands between a spec and the creator's money (§ Run cards and asking).
- **The creator sees results, not commands.** In a creator's session run as few commands as you can: no exploring, no helper scripts, what you need read from one command's output. When a command fails, fix the cause and run it once more; if it still fails, say what is wrong in one plain sentence. Never talk to the creator about commands, files, ids or JSON. If they complain about seeing commands, point them to "Transcript view" → "Normal" in the session's title-bar menu; don't switch it yourself.
- **Files you write** (script, facts, parts, panel lists, generation specs, timelines) go in a short work folder, `$TMPDIR/<project>/`, so commands stay short (on Windows in `%TEMP%`, written as `C:/…`). Name specs by run (`run7.json`) and the rest for what they hold (`shot2-part.md`). Pass their paths.
- **Exit 2**: the app isn't running. Run `reminiscor-director start` (it starts ComfyUI and the app, about a minute the first time) and retry; when it fails, read the log it names and say in one sentence what is wrong. **Exit 1**: the app refused; the JSON names the field and the allowed values. Fix it and retry.
- **To look at a result yourself**, fetch it from the app: `curl -s <app>/projects/media/<name> -o <work>/<name>`, then open it. `<name>` is an output's `<sha256>.<ext>` (`outputs` in `jobs`); `<app>` is the start of any `page` URL. Never read the database or the media folder directly.

## Start or resume

At the start of every session, and whenever you are unsure what exists:

```bash
reminiscor-director project status <p>
```

It lists script and facts versions, subjects and assets, shots with their bins and outputs, generations waiting or running, spend so far, ask rules, workflows, the timeline and the last renders. Read the current script and facts with `reminiscor-director project script <p>` and `facts <p>` before changing either. Don't know the id? `reminiscor-director project list`.

A new story is a new project: `reminiscor-director project new "<title>"` (`--ratio`, `--resolution`, `--lang`; defaults 16:9, 480p, cz). Pick the ratio from the story and the creator's files, and say which. When the creator changes their mind about the ratio before anything is generated, change it in place, never with a second project: `reminiscor-director project ratio <p> 9:16`. Once the project has a grid, frame, sheet, plate or take the app refuses: say that a new project is the way, and ask. The resolution changes at any time (`reminiscor-director project resolution <p> 720p`): new takes use it, the ones there stay as they are.

**Split screen**: right after `project new`, and on every resume, open the project page (`page` in `status`) in the browser pane, so the creator watches the work land beside the chat. When you work on a shot, navigate that tab to the shot's page, and back to the project page when you leave it. Keep a second tab on ComfyUI (http://127.0.0.1:8190) beside it. Open a preview or a single file in a tab of its own, never by navigating the project tab away.

## The working loop

```
rough story ─▶ script + fixed facts ◀── the creator corrects it by chat
     "let's work on the envelope part" ─▶ a shot:
         grid ─▶ frames ─▶ takes ─▶ output     (one part at a time, any order)
     "let's assemble the film" ─▶ timeline ─▶ preview ◀── adjust ─▶ "render final"
```

**Work shot by shot.** Price and propose only the current shot's next step (its storyboard, a panel's fix, its takes), never the whole film at once. The one exception: when the creator asks for a storyboard of the whole film, to look it over before the shots, make it ([`SHOTS.md`](SHOTS.md) § 0); never propose it yourself.

The rhythm is **generate → edit → regenerate**. The creator looks at a result and says what is wrong; you change the beat, prompt, reference or mode that caused it and generate that one piece again. Re-run an unchanged prompt only for a technical failure (an API error, a timeout), never for a defect. When the same defect comes back, change the approach (another mode, a split, a take from a frame) and say so.

The creator's words map to the files below. Read the file before you act on its part:

| The creator… | Read |
|---|---|
| tells a story, hands over files, corrects the script or facts | [`SCRIPT.md`](SCRIPT.md) |
| wants a part worked on: storyboard, frames, takes, the shot's output; a shot duplicated or redone | [`SHOTS.md`](SHOTS.md) |
| wants the film assembled, reordered, cut, scored, captioned, previewed or rendered final; an animatic from the storyboards | [`RENDER.md`](RENDER.md) |
| needs something no library workflow does, or says "add it to the library" | [`WORKFLOWS.md`](WORKFLOWS.md) |

Before writing any prompt (frame, grid, take, sheet, plate), read, in this order, and where two disagree the later wins:

1. `~/.claude/skills/higgsfield/skills/higgsfield-seedance-2-5/SKILL.md`, its `MODE-PLAYBOOKS.md` (the sections the take needs), and `VFX-PIPELINE.md` Stages 4–5;
2. [`SEEDANCE-OVERRIDES.md`](SEEDANCE-OVERRIDES.md): where our ComfyUI nodes and this workflow differ from Higgsfield;
3. [`PROMPT-RULES.md`](PROMPT-RULES.md): the bar every prompt clears;
4. [`SLOP-RISKS.md`](SLOP-RISKS.md): what to guard against in each shot, quietly.

- **When**: before the first prompt of a chat (sheet, plate, frame, grid or take), so before the first Run card. Read `MODE-PLAYBOOKS.md`'s section again when the take's mode changes. After the chat is summarized, read all of them again before the next prompt.
- **How**: with the file tool, in parts by line range (for example 300 lines at a time), to the end of each file or named section. The Higgsfield files are long: output marked as truncated is not read, so continue from where it stopped. A search hit is not a read.
- **Done when** the 2.5 `SKILL.md` is read to its last line, with the playbook sections the take needs and `VFX-PIPELINE.md` Stages 4–5, then our three files.

## Every generation

Takes, grids, frames, sheets, plates and music tracks all go the same way:

0. **Plan step**, only where it is on (§ Run cards and asking, **The plan step**): a short plan and the box, before you write the prompt.
1. **Spec**: write the generation spec (one JSON object, or a list for a batch) per [`SHOTS.md`](SHOTS.md) or [`SCRIPT.md`](SCRIPT.md).
2. **Price**: `reminiscor-director project price <p> <spec>`. It checks and prices, writes nothing, and returns `priced`, the id of exactly this run. Fix every FAIL quietly and price again; fix a WARN or say why it stays. The creator sees nothing until it passes. Read each item's `prompt_as_sent`: the text the partner node really gets, with `added` the text the workflow puts around your prompt. When it adds text, read it; a sheet's template carries the Look by itself ([`SCRIPT.md`](SCRIPT.md) § Sheets and plates). Every prompt carries the Look from the fixed facts ([`SCRIPT.md`](SCRIPT.md) § 3).
3. **Run card**: before every run, with no exceptions, the creator sees what will be generated, its cost, a short recap and the prompt as sent (§ Run cards and asking). One card per batch. When `price` says `asks: false` (asking is off for every item), only the box is left out.
4. **Run**: `reminiscor-director project gen <p> <spec> --priced <id>`, only after the creator's yes to that card (its button or a typed go-ahead); with asking off, `reminiscor-director project gen-auto <p> <spec> --priced <id>` right after showing the card. `<id>` is the `priced` of the `price` the card showed. Refused because the run changed (a file edited, a newer sheet, an old button): price again, show the new card and ask again. The id says the run is the priced one, not that the creator said yes. An id runs once: after a run, `price` gives the same run a new id (`ran_before` names the earlier batches), so running it again needs a new card and a new yes. Only a run that failed before the partner accepted it keeps its id.
5. **Wait in the background**: run `reminiscor-director project jobs <p> --wait --batch <b>` (`gen` prints the batch id) as a background command or a monitor, never blocking the chat. Tell the creator they can keep talking and that results show on the shot page as they land; meanwhile work on what they say. Report when the batch settles.
6. **Show**: what came back, how it went against what was asked, and the shot page (`page` in `gen`'s result, or `status --shot N`). With asking off, also this run's cost and the spend so far.

`gen --twin` runs the free test twins: only to check that a new or changed library workflow works, never for the creator's runs. Twin work costs $0, makes no asset version (a twin sheet or plate adds nothing to refer to) and is hidden unless the read passes `--twin` too (`status --shot`, `shot panels`, `shot output`, `timeline`, `render`).

## Run cards and asking

**By default you ask before every generation**, frames included. The card is your message and, as the last thing in the turn, a box with two buttons; `gen` runs only after the creator says yes to it. The message comes before every run, asking on or off; the box is the only approval the creator ever gets, never a permission prompt for a command.

In one message:

1. One line per item: what it is and what it costs (`Shot 3 storyboard, ~$0.06`), in plain words, with no workflow ids, versions or refs; a take's line names its resolution when it isn't the project's. `≈` or `~` when `estimate` is true; `price unknown` with the partner nodes from `cost.basis` when `usd` is null. For a batch, then the total (`+ N unknown` when `unknown` lists items). Then `project so far:` (`spend.usd`).
2. What else the creator must know: **NEW WORKFLOW** on an item listed in `new_workflow`; "again after g41, which may have been charged" on a run again after such a failure; a style reference attached ("+ style ref manga_page@1").
3. For each item, the **recap**, in the creator's language, from `price`'s `recap` and your own lines:
   - **References**: one line each from `recap.references`: the name and what it is used for, shortened ("winter side plate v3: the place and the camera, kept exactly"). A reference with no `use` has no role yet: fix the prompt first.
   - **Stages** (a take): one line each that you write from the prompt: the seconds, the action, `→` the end state ("0–2 s sniffs the snow → nose in the snow").
   - **Camera · Sound** (a take): a few words each that you write.
   - **Changed since take N** (a take, when `recap.changed` is not null), from `recap.changed`: references swapped, the length, the stage count, "stages rewritten", the lines added and removed. Only `against` means the same prompt as take N: say so. Always in this place, never moved to the top.
   - **Checked**, the last line of the recap, right above the prompt's code block, never before the card: one short line in italics, plain Markdown with no HTML (`<sub>`, `<small>`, `<span>` …: they show as raw tags in the desktop app). First `recap.standard.present` with ✓ (a `missing` one is a FAIL: fix it first), then, after `—`, at most 3 rules of `read` that mattered for this item, a few words each; when none did, the ✓ part alone. For example: `*✓ описание · лист · Look · NO BGM — один щенок в каждом виде, роли картинок*`. Before the card, confirm each rule in `read` (`PROMPT-RULES.md` names them) and fix any it breaks.
4. Each item's `prompt_as_sent.text` in a plain code block, always, below its recap. No `<details>`: it doesn't render in the desktop app.

Frames, grids, sheets and plates get the same card without the parts they have no data for.

Then, unless asking is off for every item, **the box**, one per batch. Never `AskUserQuestion`: it adds `Other` and `Skip` and the creator's typed text on `Other` reads as a plain no.

- **In the Claude desktop app** (`mcp__ccd_turn__wrap_up` is among your tools): the turn ends with that call, after the complete message, with `ask` the question, what and how much (`Run shot 3 storyboard, ~$0.06?`, at most 100 characters), and `actions` two reply buttons, `Run, ~$0.06` and `Not now` (at most 24 characters each). The `recap` is one short line. The app expects your closing message after the call, so write the whole card there, after `wrap_up`, so that it is complete and readable before the buttons; check this order in the app.
- **Without the box** (Grok, OpenCode, Claude Code outside the desktop app): end the card with the plain line "Reply go to run, or say what to change".

- **A yes** is the `Run` button, or a typed go-ahead ("go") for this exact card, shown with this price and prompt. A "go next" said before they were shown is not.
- **A yes is for exactly that run.** If the prompt, inputs, settings or price change after it, show the new card and ask again; `gen --priced` refuses a changed run, so an old button can't start a different one.
- **`Not now`, a closed box and no answer are a no.** Don't run `gen`.
- **Typed text is an instruction**, not a no: apply it ("change the plate first", "generate again"), price again and show the new card. Never ask a second multiple-choice question; if it is truly unclear, one short question in plain text.

**The plan step** is off unless the creator asks for it in plain words ("show me the plan first", "plan first for takes", "for shot 3"): `reminiscor-director project ask <p> on --step plan [--kind K | --shot N]`; "no more plans" is `off` with the same scope. Never suggest it. It is on for an item when its most specific plan rule (in `status`'s `ask`, `step: "plan"`) is on **and** asking is on for it; with asking off there is no plan step either.

When it is on, before writing the prompt, send a short plan: what happens, which references, how long ("Take 3 of shot 3: she sniffs the snow, then digs. Plate v3 + sheet. 5 s."), one line per item for a batch. End the turn with the same box as a Run card, one per batch: `ask` "Write this prompt?" and the buttons `Yes` and `Not now` (without the box, "Reply go to write it, or say what to change"). A yes lets you write the prompt, price it and show the Run card as usual, which needs its own yes. Typed text changes the plan: show the new plan and ask again. `Not now`, a closed box or no answer is a no.

**Switching asking off** is the creator's call, in plain words, and you never suggest it: "don't ask for frames anymore" → `reminiscor-director project ask <p> off --kind frame`; "stop asking for this shot" → `--shot N`; "stop asking" → no scope. Their words are enough: run it, then say what is now off and how to switch it back. "Ask again" is `ask <p> on` with the same scope. Asking off drops the box and the wait for a yes, never the message: what, cost and prompt as sent still come first, in the message before `gen-auto`. `gen-auto` refuses a batch with any item whose asking is still on; show that item a card and run it with `gen`.

There is no budget: no limit, no warning. The figures are there so the creator always knows what they are spending.

**Comfy API key**: paid generations need the creator's Comfy API key; free twins and `ping` don't. When `project balance` says there is no key or Comfy refused it, or a paid generation fails for the key, send the creator to http://127.0.0.1:8765/settings: they paste the key there (from platform.comfy.org → API Keys), and it works at once, no restart. Never ask for the key in the chat, and if they paste one there, tell them to put it on that page instead.

**Credits left**: when the creator asks how much is left, and only then, run `reminiscor-director project balance` and answer in plain words, in dollars (`total`; mention `subscription` only if they ask where it comes from). It is the whole Comfy account's balance, not this project's. With `known: false` say the balance is unknown and why (`reason`), and carry on: it stops no generation.

## When a generation fails

A failed run is never run again by itself, with asking off too: tell the creator the error and what it may have cost, and run it again only when they say so, on a new card.

`jobs` shows `failure` (`before` or `after` the partner accepted it), `refused` and `cost.may_be_charged`.

- **Before** (ComfyUI unreachable, validation, the partner's rate limit): $0. Nothing runs again by itself.
- **After** (timeout, provider error mid-run): counted at its estimate and may have been charged. The new card says so.
- **Refused** (content filter, a realistic face, copyrighted sound): rewrite the prompt to avoid the reason, say what you changed, and show a new card. A refused generated sound gets the offer of the take with sound off.

When a run fails oddly or a result is wrong in a way its prompt doesn't explain, say so plainly to the creator and describe the symptom before changing the approach.

## Discarding results

When the creator rejects a result and wants it out of sight ("that's slop, hide it", "get rid of take 2", "drop that grid"), discard it: nothing is deleted, but it leaves the pages and `status`'s lists, and it can't be a new generation's input (`price` FAILs it as `input-discarded`). The creator can also do it with the discard button on the pages.

```bash
reminiscor-director project discard <p> take:2/3
```

The ref is the result: `take:<shot>/<n>`, `frame:<shot>/<panel>@<k>` (a panel version), a generation id (`g15`: a grid, a page of the film's storyboard, a failed run), or a made asset's version (`asset:rex/sheet@1`). Only a take in a shot's output is refused: change the output first, if the creator wants. A discarded current frame or newest sheet steps back: the panel shows its newest kept version (or none), and `asset:rex/sheet` means the newest kept sheet. Discarding follows no chain: frames and takes made from a discarded sheet stay as they are; say so when it matters. "Bring it back" is `reminiscor-director project restore <p> <ref>`. The pages fold discarded results behind "show discarded"; `status` lists them under `discarded`, and `status --discarded` keeps them in the lists. Don't discard on your own: only what the creator rejects.

## Archive

Only when the creator asks ("put this one away"), and name the project before doing it: `reminiscor-director project archive <p>`; `unarchive <p>` brings it back. An archived project keeps everything and opens by its link, but is off the projects list, and the app refuses to generate or render in it. `reminiscor-director project list --archived` lists them. A project with something running can't be archived yet: say what runs. Projects are never deleted; when the creator asks for that, offer to archive.

## Export and import

`reminiscor-director project export <p> DIR` writes a readable folder of the whole project (records, media, a static viewer), for a backup, for reading, or for the desktop app. `reminiscor-director project import DIR [--as ID]` makes a new project from such a folder, under its own id or `ID`; it never merges.
