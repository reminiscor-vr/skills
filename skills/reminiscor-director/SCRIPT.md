# Script, fixed facts, subjects and assets

From the creator's rough story to a script they can correct, the fixed facts every prompt respects, and the subjects and assets the shots draw on.

## 1. Intake

Take the story in the creator's own words and every file they hand over. Look at each file yourself: open the images, and read each video's and audio clip's length with `ffprobe -v error -show_entries format=duration -of csv=p=0 <file>`.

**Every file the creator attaches becomes an asset at once**, whether or not a shot uses it yet, so it is in the project, on its page and in its export, never only in the chat or a temp folder ([§ 6](#6-assets)):

- a photo that clearly shows one subject: that subject's `photo` (create the subject first);
- a sketch or reference of one subject: that subject's `reference`;
- otherwise a standalone asset (`--name <name>`) with the role that fits: `source` (a video to swap into, edit or extend), `audio`, `style` (how the film should look: manga pages, a poster, a frame from another film), `reference` (a sketch, a layout, any loose reference), `layers` (compositing layers) or `document` (a file that is no image, video or audio: a PDF, a text, an edit project).

Then say in one line what was added ("Added: rex's photo, the sketch of the office (reference), the rain sound (audio)."). When the app refuses a file, name it and say why in plain words. A zip or a folder of related files is one asset, a set ([§ 6](#6-assets)).

Done when every file is in the project and you can say, for each, what it shows and what the story needs from it.

## 2. The script, first

Sort the story into a script before anything else: scenes in order, gaps filled, written like a short screenplay. The story may be messy (scenes out of order, a gap in the middle, "figure it out"); sorting it is your job.

- **Ask only what blocks the script**: which photo is which character, something the story needs that no file shows, whether a supplied video is to be swapped into. One short question at a time, in the same message as the script so far. Mood, camera, ratio, pacing and music are yours: decide them and say what you decided. A ratio the creator then wants changed is a `project ratio` ([`SKILL.md`](SKILL.md) § Start or resume), while nothing is generated.
- Ask a subject's name only when it is spoken or shown on screen; otherwise use a plain label ("the brown dog").

**Shape**: markdown, free prose, with one fixed shape so shots can point into it. Each scene is a heading:

```markdown
## Scene 2: The envelope

Police room, night. Sharikov at the desk; the two racketeer dogs at the door.
The racketeers come in and put an envelope on the desk. Sharikov does not look up.
The phone rings.
Heard: rain on the window, the phone. The taller racketeer: "For your trouble."
```

Under each heading: where, who, what happens in order, what is heard or said. No prompts; camera words only where the story needs them.

**Scene numbers are stable ids**: a moved scene keeps its number, a removed number is never reused, a new scene gets the next unused number. Shots point at them.

Save it, and save every correction as a new version:

```bash
reminiscor-director project script <p> --set <work>/script.md
```

Show the creator the script and one line on what you decided. They correct it by chat; there is no approval step. Keep it in sync as the film changes (a reordered take, a scene dropped at the timeline).

Done when the script is saved and the creator has it in front of them.

## 3. Fixed facts

Before the first shot, write the fixed facts from the script: a short markdown list every frame and take prompt respects.

```markdown
## Look
- Black-and-white manga: heavy ink outlines, screentone shading, no colour, no grey wash.
- Faces simple and calm; eyes as dots or short strokes. Paper-white backgrounds where a place has no detail.

## Places
- police_room: desk in the middle, window behind it, door on the left.

## Positions
- Scene 2: Sharikov behind the desk, facing the door; racketeers by the door, facing him; the envelope on the desk's near edge.

## Wardrobe
- Sharikov: brown coat, no hat.

## World rules
- Exactly two racketeer dogs. All characters are dogs. 1990s: phones have no screens.

## Every take
- No look into the lens for more than 1 second.
```

Every object has exactly one position per scene, and every frame of that scene is generated from it.

**Take rules** go under `## Every take`: a rule from the creator's brief that holds for the whole film ("no look into the lens over 1 s"). Put each line word for word into every take prompt; `price` fails a take that misses one. After each take, watch the result for each rule and say when one is broken.

**The Look** comes first: how the film looks, in words a model can draw from. Write it from each style reference (line, shading, colour, faces, backgrounds) and the creator's words ("grittier", "like the poster"); with neither, from the story, and say what you chose. Its text is the style part of every prompt: put it, in its own words, into every frame, grid, sheet, plate and take prompt. Attach a style reference image to a generation only when the words can't carry a particular drawing style, and then name it on the Run card ("+ style ref manga_page@1"). A new style reference or a change to the Look is a new facts version; old work keeps the version it was made with, and you say which shots would change if redone.

```bash
reminiscor-director project facts <p> --set <work>/facts.md
```

Keep it in sync with the script: a script change that moves, adds or dresses anything changes the facts in the same turn.

## 4. When the script changes under existing shots

For each shot whose part changed, make a new version of it, which keeps its number and leaves the old one read-only:

```bash
reminiscor-director project shot revise <p> <N> --part <work>/shotN-part.md
```

Say which shots got a new version, then rework only what the change touched ([`SHOTS.md`](SHOTS.md)).

## 5. Subjects

A subject is a character, prop or place. Characters and props carry a **reference description**: a noun phrase from what their files show, written once and used word for word in every prompt the subject is in. `price` fails a prompt that drops or paraphrases it, and "word for word" is exact, capitals and full stops included: write it lowercase with no full stop, so it reads inside any sentence ("The stocky brown mongrel … sits").

```bash
reminiscor-director project subject <p> sharikov --kind character --description "stocky brown mongrel with a torn left ear and a brown coat"
```

- Names are lowercase with `_` (`sharikov`, `police_room_wide`).
- A place gets one subject per camera angle (`police_room_wide`, `police_room_desk`), since each angle has its own plate.
- People are allowed. A shot that shows a realistic human face gets the warning in its notes ([`SHOTS.md`](SHOTS.md)).

**Renaming** ("call him Rex"): the name shown changes, never the id. Refs, asset keys and old generations keep `sharikov`; the pages and `status` show "Rex".

```bash
reminiscor-director project subject <p> sharikov --rename "Rex"
```

When another subject already shows that name, the app adds a number ("Rex 2") and says so: tell the creator. The rename changes no text: it lists every text that still says the old name (the script, the fixed facts, panels' beats, reference descriptions). Edit those as ordinary changes (a new script or facts version, `shot panels`, `subject --description`), show the creator, and write the new name in specs you haven't run yet. The creator may also rename on the project page (**Rename** by the subject's name): read the name from `status` (`subjects[].title`; `name` is the id) and, after a rename, edit the texts it lists the same way.

**A dropped character** ("drop the cat, we don't need it") is discarded, never deleted:

```bash
reminiscor-director project subject <p> cat --discard        # or: discard <p> subject:cat
```

It is never refused. Its assets leave the pages and `status` with it and are refused as new inputs; takes, frames and outputs already made keep what they used. The reply names the shots that still mention it (a beat, the part, their takes or frames): edit their specs (and beats) before their next generation, since `price` fails any spec that still uses it ("subject `cat` is discarded"), and tell the creator what you changed. `--restore` (or `restore <p> subject:cat`) brings it and its assets back. The creator may do either on the project page (**discard** / **restore** by the name); `status --discarded` lists it.

## 6. Assets

Each of the creator's files becomes an asset, with the row the prompts are written from: role, what to use, what not to use, fidelity (`full-preserve`, `partial-preserve`, `attribute-transfer onto <target>`, `loose-guide`).

```bash
reminiscor-director project add <p> <file> --subject sharikov --role photo --use "coat, ear, build" --dont-use "the sofa behind him" --fidelity full-preserve
```

- Roles: `photo`, `sheet`, `plate`, `source` (a video to swap into, edit or extend), `audio`, `style` (a style reference: how the film looks; never a subject's), `reference` (a sketch or a loose reference, a subject's or standalone), `layers` (compositing layers), `document` (a file that is no media, kept as it is; never a generation input). An asset of no subject (a music file, a style reference, a loose sketch) takes `--name` instead of `--subject`.
- **One character per photo.** A photo with two characters: ask the creator to crop it.
- Refs to an asset: `asset:<subject>/<role>` is the newest version, `asset:<subject>/<role>@<v>` an exact one; a standalone one is `asset:<name>`.

**A set of related files** (compositing layers: a grout overlay, glare, tile mattes; ten sketches; anything that belongs together) is one asset, never one asset per file and never a folder outside the project. Any role but `sheet`, `plate` and `audio` can be a set. Add the zip or the folder as it is:

```bash
reminiscor-director project add <p> <work>/wall-layers.zip --name wall_layers --role layers --use "DaVinci compositing layers of the tiled wall"
```

Files of any type are kept as they are, under their paths; the project page shows the set as one card with its file list and a download of the whole set as one zip (packed when downloaded), and export and import carry it. Only its image, video and audio files can be generation inputs, each by its path: `asset:wall_layers#glare.png`. A zip whose entries would leave its folder (`../`, an absolute path, a link) is refused: say so and ask for a clean one.

### Sheets and plates

Generated like everything else ([`SKILL.md`](SKILL.md) § Every generation): price, Run card, gen. When one lands, the app adds it as the asset's next version; old frames and takes keep the version they used, new work uses the newest. Say when old work should be redone with a new look, and let the creator decide.

A **character sheet** from a photo (`turnaround_generic`):

```json
{"kind": "sheet", "asset": "sharikov/sheet",
 "inputs": {"PARM_IMG_0": "asset:sharikov/photo"}}
```

A character with no photo gets a sheet from its description (`sheet_from_text`): no inputs, the `prompt` is the reference description word for word. A prop that must hold its shape from every side (the two cars) gets one.

A **plate** is one camera angle of a place, empty of characters, at the project's ratio (`keyframe_generic`):

```json
{"kind": "plate", "asset": "police_room_wide/plate",
 "prompt": "A small police room at night, seen from the door: …",
 "inputs": {"PARM_IMG_0": ["asset:police_room/photo"]}}
```

Every frame in that angle is then an edit of its plate. A top-down map, if you need one, is derived from the plates, never invented beside them.

There is no separate approval: sheets and plates show on the project page and in the storyboards that use them. Pick which sheet or plate a shot uses from context; the creator steps in when they want ("use the other police room").

Settings for sheets, plates and frames: `{"quality": "low" | "medium" | "high"}` (the workflow's default otherwise).

**A sheet follows the project's Look by itself.** Both sheet workflows have a neutral template (four views, a calm face with the mouth closed, what the subject wears kept, nothing added) that ends with the Look from the fixed facts as a `Style:` line; `price` shows it in `prompt_as_sent`. Send no template of your own, except:

- **The character speaks** in the script: add a second face close-up with the mouth open mid-word.
- **The creator asks** for something the template can't hold: a pose, an outfit, only the head.

Then copy the template from `prompt_as_sent`, change only that, keep its `Style:` line, and send it through the settings: `prompt_turnaround_value` for `turnaround_generic`, `prompt_sheet_value` for `sheet_from_text` (keeping `[SUBJECT]`, where the description goes). Say "custom sheet prompt" on the Run card.

Price it again and check that `prompt_as_sent.text` reads as you meant.
