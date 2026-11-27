# Seedance overrides

The `higgsfield` skill writes for Higgsfield's platform. Our takes run on Seedance 2.5 through local ComfyUI nodes, and our work goes grid → frames → takes in a project; where the two differ, this file wins. Its prompt grammar (reference roles with exclusions, fidelity grades, stages and end states, keyframe role sentences, bracket audio syntax) carries over unchanged.

## What our nodes take

- **Model**: Seedance 2.5 only, for video. Frames, grids, plates and sheets are GPT Image (`keyframe_generic`, `turnaround_generic`, `sheet_from_text`).
- **Length**: 4–30 s per take, in whole seconds.
- **Resolution**: 480p, 720p and 1080p, set by the project.
- **Ratio**: the project's: `16:9`, `9:16`, `4:3`, `3:4`, `1:1` or `21:9`. Higgsfield's `auto` / our `adaptive` is not a project ratio.
- **References** (the Reference V2 node), per take:
  - up to 30 images;
  - up to 10 videos, 30 s combined, each at least 1.8 s;
  - up to 10 audio clips, 30 s combined, each at least 1.8 s.
- **Handles**: `@Image N`, `@Video N`, `@Audio N`, with a capital and a space, numbered per media in the take's slot order. Named asset tags (`@size-ref`) and the spaceless `@video1` do not exist here.

## Modes

- **First-last frame** is its own node and workflow (`seedance_flf`), where Higgsfield runs it inside `omni_reference` with `start_image` / `end_image`. It takes the first frame, optionally the last, and no other reference; the take follows the first frame's own aspect.
- **Frame rules**: every frame and grid panel is at the project's ratio (the app sizes and crops them), so the first and last frames always share an aspect and nothing stretches. A frame from outside the app must match before it goes in.
- **Reference mode with frames** uses panels as references for look, place, staging and order ([`SHOTS.md`](SHOTS.md) § 4); Higgsfield's keyframe form is for when the creator asks for it. Frames go to `seedance_ref`'s images first in slot order, then sheets, plates and photos, each frame with its own role sentence ([`PROMPT-RULES.md`](PROMPT-RULES.md)). Both this and first-last frame are normal paths, not only on explicit request.
- **Storyboard grids** are the shot's first frames: the app crops each cell into its panel, and each panel is then fixed by a frame edit. A take uses frames (or panel crops) as references, never the whole grid as one image; Higgsfield's grid-as-reference template and its panel-to-timestamp mapping have no place here.
- **Extend** has no `extension_mode` parameter. Write the direction in the prompt: "extend forward", "extend backward" or "continue". The run returns only the new segment.
- **Edit** keeps the source's length and ratio, and bills the whole source. The source is 4–30 s.
- **Swap** is a `reference` take with the source video attached, at the source's length.
- **Music**: every take's audio ends with `NO BGM` (the open `NO BGM` / `No music.` question is settled here); music is a track laid at render.

## Parts of `higgsfield` to skip

Use its Seedance 2.5 prompt craft and nothing else. These parts describe Higgsfield's platform or another workflow and have no counterpart here:

- the Seedance 2.0 and 4K routes;
- the Higgsfield CLI and MCP routes, its parameter table, `start_image` / `end_image` and `extension_mode`;
- its asset-model routing (Soul, Nano Banana and the rest of `VFX-PIPELINE.md` Stages 1–3): our sheets, plates and frames come from the library workflows;
- the four-batch rule's batching: we never re-run an unchanged prompt for a defect, so the first repeat of a defect already means "change the prompt or the approach";
- blockout renders of 3D previz: projects have no 3D sets yet (only the coarse-blockout wording for a creator's motion video, in [`PROMPT-RULES.md`](PROMPT-RULES.md));
- its memory and ledger;
- its `workspace/` deliverables: our deliverable is the project.

Read the pinned copy at `~/.claude/skills/higgsfield`. The synced `anthropic-skills:higgsfield-seedance-2-5` is a stale, partial copy of it.
