# Shots: panels → grid → frame fixes → takes → output

A shot is a bin for one part of the script, made when the creator says "let's work on this part". It holds a storyboard (grids, panels and their frame versions), takes and an output. Work happens one shot at a time, in any order. Shots are numbered in the order they are made, and a number is never reused; call them by number and title ("shot 2, the envelope").

Every generation below goes through [`SKILL.md`](SKILL.md) § Every generation: price, Run card, gen, wait, show with the shot page. Every prompt clears [`PROMPT-RULES.md`](PROMPT-RULES.md), and every shot's beats are checked against [`SLOP-RISKS.md`](SLOP-RISKS.md).

## 0. A storyboard of the whole film (only when asked)

When the creator asks to see the whole film as a storyboard before working shot by shot, draw it from the script and the fixed facts, with no shot: a grid with `film_page` instead of `shot`, one panel per beat of the whole film, in the film's Look, through price, Run card and gen like any grid. It is only for looking over: it fills no panel, and shots storyboard themselves as in § 2.

```json
{"kind": "grid", "film_page": 1, "grid": {"rows": 3, "cols": 3},
 "prompt": "…", "inputs": {"PARM_IMG_0": ["asset:sharikov/sheet", "asset:police_room_wide/plate"]}}
```

A grid holds at most nine beats; more beats take more pages (`film_page` 2, 3, …), read in order, all on one Run card. Redrawing a page is another grid with the same `film_page`: it becomes that page's current version, and the old one stays. The pages show on the project page, above the shots, and `status` lists them under `film_storyboard`.

## 1. Make the shot

The fixed facts exist before the first shot ([`SCRIPT.md`](SCRIPT.md) § 3). Copy the stretch of the script the part covers, word for word, into a file, and:

```bash
reminiscor-director project shot new <p> --title "the envelope" --part <work>/shot2-part.md
```

The app finds its scenes from the `## Scene` headings in the stretch, or the one scene whose text holds it; `--scene N` adds one. The result carries the shot's number and its `page`.

Check the beats against [`SLOP-RISKS.md`](SLOP-RISKS.md) now: the guards go into every frame and take prompt of this shot.

## 2. Panels and the grid

**Beats**: split the part into beats, one panel per beat. Propose the count from the story ("four panels: they come in, the envelope, he doesn't look up, the phone"); the creator decides. There is no frames-per-second rule. Add one panel per beat, in order:

```bash
reminiscor-director project shot panels <p> 2 --add "The racketeers come in through the door." --add "The taller one puts the envelope on the desk's near edge." --add "Sharikov keeps writing; he does not look up." --add "The phone on the desk rings."
```

Panels come and go only on purpose: `--add BEAT` (or `shot fill --add`, below) adds one, `--drop N` takes one off the storyboard (refused only while a frame of it is waiting or running). Its pictures, and the takes that used them, stay; its number is never used again.

**Position and number**: with the creator, "panel 4" is always the position, the fourth on the shot page, which counts 1, 2, 3… without gaps. Commands, specs and refs (`--drop`, `--order`, `[N]` in a FILE, `--map`'s panel, `--empty`, a frame's `panel`, `frame:2/5`) take the permanent number, which never changes or comes back. They differ after a drop or a reorder: `status --shot` gives each panel's `pos` and `n` (its summary line shows `4[5]`: the 4th, number 5). Translate every time, and say positions to the creator.

A panels FILE edits panels by number (`- [2] new beat`, `- [2@1]` to make version 1 current); every line names its panel, so a list you type can't renumber or lose one. **Reorder** by naming every panel in the order wanted: `shot panels <p> 2 --order 1 3 2 4`, or a FILE that names them all (which can edit beats in the same write). Pictures, versions and beats move with their panel; never refill panels or retype beats to move them.

With no panels at all, the shot's first grid makes one per cell.

**Grid**: one image holding every panel, the shot's cheap preview. Its shape `{rows, cols}` is at most 3×3, panels counted row by row; more than nine beats take a second grid. Pick the smallest shape that holds the beats and that `price` passes without a `grid-crop` WARN (a shape the image node can't draw at that ratio, centre-cropped). At a wide ratio stack the panels: two beats 2×1, three 3×1, four 2×2, five or six 2×3; at a tall ratio lay them side by side (1×2, 1×3). Say the reading order in the prompt.

```json
{"kind": "grid", "shot": 2, "grid": {"rows": 2, "cols": 2},
 "prompt": "…", "inputs": {"PARM_IMG_0": ["asset:sharikov/sheet", "asset:police_room_wide/plate"]},
 "settings": {"quality": "medium"}}
```

The grid is drawn in the film's Look (the fixed facts), at full quality when its panels are to become the frames. Each cell is the project's ratio, so its crop is good enough for takes (a 3×3 grid at 16:9 gives 1280×720 cells).

**The first grid fills the panels**: when the shot's first grid lands, cell k's crop becomes panel k's first frame, at no cost. Cells past the last panel are left over. Show the shot page.

## 3. Fix each panel

The creator corrects panels one at a time ("panel 3: the envelope is on the desk, not in his paw"). Fix that panel with a **frame edit** of its current frame: a `frame` that names its shot and panel and takes `frame:<shot>/<panel>` as the first input, then the sheets and plates, with a prompt that keeps everything and changes only what was wrong.

```json
{"kind": "frame", "shot": 2, "panel": 3,
 "prompt": "@Image 1 is the frame. Keep everything: the place, the characters, the camera, the framing and the drawing. Change only the envelope: it lies flat on the desk's near edge, not in the paw. …",
 "inputs": {"PARM_IMG_0": ["frame:2/3", "asset:sharikov/sheet", "asset:police_room_wide/plate"]}}
```

- Each fix lands as the panel's next version, which becomes current; the shot page says which version it edited. Old versions stay; `- [3@1]` in a panels FILE makes version 1 current again.
- Change the beat too when the story moved (`- [3] new beat`).
- Fix only the panels the creator names. There is no full-size redraw of every panel.

**A new grid** is how to start a shot's storyboard over (the idea changed). A later grid fills nothing by itself: show it, and fill only what the creator names:

```bash
reminiscor-director project shot fill <p> 2 --grid g15 --all
```

`--all` puts cell k into the k-th panel; `--map 7:2` puts cell 7 into panel 2 (any cell into any panel); `--add 5 6` makes cells 5 and 6 new panels, only when asked. A filled crop is the panel's new current version; old ones stay.

**A rejected cell**: when the creator approves a grid but rejects a cell ("good, but not the third"), fill the others and empty that cell's panel in one call, so no old picture stays in it: `shot fill <p> 2 --grid g15 --map 1:1 2:2 4:4 --empty 3`. An empty panel keeps its beat and versions and shows "no picture". Only rejected cells empty a panel: filling one named panel ("use cell 7 for panel 2") leaves the others as they are. After a partial fill, name the panels left out. `- [3@none]` in a panels FILE empties a panel at any other time.

**Back to a take's storyboard** ("restore the storyboard from take 3"): free, nothing is generated.

```bash
reminiscor-director project shot restore <p> 2 --take 3
```

The take's frames become the panels, in its order. A panel still there keeps its number and beat and gets that picture; the panels that weren't in the take are dropped, so tell the creator which (by position, as they were). A dropped panel comes back as a new one with a new beat: the app refuses and names those pictures until you give a `--beat "…"` for each, in order. Look at each picture and write its beat from it and the take's prompt.

Refs: `frame:<shot>/<panel>` is the current frame (refused on an empty panel and on a dropped one), `@<k>` its k-th version, `@g<n>` that generation (both also of a dropped panel: to make a take that used one again, name the version the take records, `frame:2/4@1`); `panel:<grid id>#<k>` is cell k of a done grid.

## 4. Takes

A take is one video generation in the shot, made from the whole storyboard, a few frames, one frame, or none. Propose the mode, name it on the Run card, and write the prompt by [`PROMPT-RULES.md`](PROMPT-RULES.md) and its playbook section.

Where a beat needs no motion, a **still take** (one panel held, with an optional zoom or pan, made by the app for free) can stay in the output: [`RENDER.md`](RENDER.md) § 0.

| The take is made from… | Mode | Workflow and inputs |
|---|---|---|
| a start frame and an end frame of one continuous motion (the car chase) | `first-last frame` | `seedance_flf`: `PARM_FIRST_FRAME`, `PARM_LAST_FRAME`; nothing else |
| frames across jump cuts, or frames that need sheets and plates alongside | `reference` | `seedance_ref`: `PARM_IMG_0` frames first in story order, one per place, then sheets, plates, photos |
| one frame | `first-last frame` with only `PARM_FIRST_FRAME`, or `reference` with "@Image 1 is the first frame" | as above |
| the whole storyboard | `reference` | `seedance_ref`: `PARM_IMG_0` the frames in panel order, one per place (no ref names a whole grid; its panels go in as `panel:` refs if no frames exist yet) |
| **explicitly** asked: frames as keyframes | `reference`, frames as keyframes | `seedance_ref`: `PARM_IMG_0` the frames in order, then sheets, plates, photos; the Run card says "keyframes" |
| sheets, plates and photos, no frames | `reference` | `seedance_ref` |
| a description only | `text` | `seedance_t2v`, no inputs |
| a creator's video whose subject is **swapped**, keeping its performance | `swap` | `seedance_ref`: `PARM_VIDEO_0` the source, length = the source's |
| **explicitly** asked: a scoped change inside a video | `edit` | `seedance_ref`: the source; keeps its length |
| **explicitly** asked: a continuation of a video (often an earlier take) | `extend` | `seedance_ref`: `PARM_VIDEO_0` `take:<shot>/<n>` or the source |

```json
{"kind": "take", "shot": 2, "mode": "reference",
 "prompt": "@Image 1 is a reference for the opening beat: the racketeers' staging at the door, the police room and the drawing. @Image 2 is a reference for … Follow the beats in this order. …",
 "inputs": {"PARM_IMG_0": ["frame:2/1", "frame:2/3", "asset:sharikov/sheet", "asset:police_room_wide/plate"]},
 "settings": {"duration": 6, "sound": true}}
```

- `settings`: `duration` in whole seconds, 4–30; `sound` true or false. Ratio and resolution come from the project; a take may set its own `resolution` (480p, 720p, 1080p).
- A first-last frame take carries only frames, so list its characters in `"subjects": ["sharikov"]` for the description check ([`PROMPT-RULES.md`](PROMPT-RULES.md)).
- Inputs keyed by loader title, in slot order: a list on `PARM_IMG_0` numbers `@Image 1, 2, …` in that order.
- **Split by job, not by length**: physics and performance, action and dialogue, or a beat that needs room go in separate takes, even when they would fit in one. Over 15 s, `price` warns; takes are short.
- A beat shorter than 4 s is generated at 4 s and trimmed in the output.
- **Panels are references by default**: they give a take its look, place, staging and order. Keyframes only when the creator asks for them. The wording of both is in [`PROMPT-RULES.md`](PROMPT-RULES.md) § Frames in a take.
- **One panel per place**: when several panels show the same view of a place, pass the one that shows it best and describe the other beats in words. Each panel draws the clouds, steps and furniture anew, so two of one view pull the background apart.
- **The creator's words carry over**: how they asked for images to be used ("references only", "panel 1 is the first frame") holds for every later take of the shot until they say otherwise. Write it in the shot's notes when they say it, and read the notes before each take's spec.
- Panels as references and first-last frame are both little tried on our films. Write in the shot's notes which held better.

**After each take**: look through the whole of it, the background as well as the subject: what stands in each place keeps its shape, count and position from start to end, with no crossfade or redraw between beats. Say what you found, and that the background holds only after looking at it; then show the take with the shot page. When the creator names a defect, find what caused it and change that (the stage's wording, a guard from [`SLOP-RISKS.md`](SLOP-RISKS.md), a frame, a reference, the mode), then make the next take on a new card. The same defect twice: change the approach and say so.

**A take again, sharper** ("take 3 is the one, in 1080p"): the same take at another resolution, with nothing else changed, even when a newer sheet or workflow exists or a panel it used was dropped. No spec file:

```bash
reminiscor-director project price <p> --again take:2/3 --resolution 1080p
```

Then the card, and `gen <p> --again take:2/3 --resolution 1080p --priced <id>`. Say on the card that the motion may differ: it is a new generation. It lands as a new take marked "from take 3"; the old one stays, and the shot's output doesn't change by itself. When the original is in the output, show both, ask before swapping, and check the cut points: the moments may have moved.

**A finished video as a take** ("here's my cut of shot 3"): when the creator attaches a video and says which shot it is for, add it at once, with no Run card: it runs nothing and costs $0.

```bash
reminiscor-director project take add <p> 3 ~/Downloads/cut.mp4 [--name cut] [--output]
```

The file becomes a standalone `source` asset (`cut@1`; an asset ref like `asset:cut@1` is used as it is) and the shot's next take, done, marked "added" on the page and in `status`. It may be any length; a video off the project's ratio is refused, naming both sizes. Add `--output` only when the creator says it is the shot's output; ask which shot when it isn't clear. A corrected cut is `take add` again: the asset's next version and a new take. An added take can't be run again (`--again`) or restored from (`shot restore`): nothing ran. A project workflow that calls no partner (a local edit) has no take-length limit at `price`.

## 5. Output

The creator picks; you may propose. Their words map to items:

| The creator says | Items |
|---|---|
| "take 5 and 6 are the output" | `5 6` |
| "take 2, then the last 2 s of take 1" (take 1 is 6 s) | `2 1[4.0-]` |
| "cut 4 s from the start of take 3" | `3[4.0-]` |
| "cut take 4 in half, second half first" | `4[3.0-] 4[-3.0]` |

```bash
reminiscor-director project shot output <p> 2 2 '1[4.0-]'
```

In and out points are seconds within the take; a take may appear twice. No items clears it. Choosing the output is the creator's approval of the shot.

The creator may also set it on the shot page: each take card's **Use as output** puts that take in as the whole output, first, or after an item, with in and out points (or "from player"). Read the output from `status --shot N` before you speak of it, and don't ask again for what they set there. Reordering and removing items stay in chat. To watch just this shot's output: `reminiscor-director project render <p> --preview --shot 2`.

## 6. Notes

`reminiscor-director project shot notes <p> 2 "<text>"` replaces the shot's notes. They hold what the creator must know and you could not fix, and what later takes need: a slop risk you could not guard, the realistic-face warning ("ByteDance may refuse a realistic human face without its identity check"), which mode held better, and how the creator wants images used in takes (§ 4). The command replaces them all, so carry over the lines that still hold. Problems you fixed stay out.

## 7. Duplicates and new versions

- **"Try this shot another way"**: `reminiscor-director project shot dup <p> 2 [--title T]`. A new number sharing the original's frames, takes and output; new work in it is its own.
- **The script changed under it**: `reminiscor-director project shot revise <p> 2 --part <file>`. Same number, the old version read-only and out of the pool. Then rework what the change touched.

`reminiscor-director project status <p> --shot 2` shows one shot in full: part, panels with every frame version, grids, takes, output, notes, and its `page`.
