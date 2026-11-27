# Prompt rules

The bar: a prompt reaches a Run card only when every rule here holds. Fix a broken rule quietly.

The rules marked ✓ are counted by `price`, which names the rule in each finding (`[rule-name]` below); `gen` refuses a FAIL. The unmarked ones need reading, and they are where your critique spends its attention: `price` returns those that apply to the item as `read`, and you confirm each before the Run card. The prompt craft itself (formula, role sentences, stages, bracket audio) is the `higgsfield` skill's, read first ([`SKILL.md`](SKILL.md) § The working loop); [`SEEDANCE-OVERRIDES.md`](SEEDANCE-OVERRIDES.md) wins over it, and this file over both.

## Every take

**Limits**

- ✓ 4–30 s, whole seconds; WARN over 15 s `[length]`.
- ✓ References inside the node's limits: 30 images, 10 videos and 10 audio clips, 30 s combined per media, each clip at least 1.8 s `[reference-count]` `[reference-length]`. Frames and sheets count as images.
- ✓ What each mode takes: `text` nothing; `reference` at least one reference; `first-last frame` one or two frames and nothing else; `swap`, `edit`, `extend` a video `[mode-references]`. A swap's or edit's source is 4–30 s; pad a shorter one by freezing its last frame `[source-length]`.

**Handles and roles**

- ✓ Handles are `@Image N`, `@Video N`, `@Audio N`, with a capital and a space `[handle-format]`, numbered per media in slot order: every slot has its handle and every handle a slot (first-last frame exempt) `[handle-numbering]`.
- ✓ Every handle opens a sentence that gives its role, and says what not to use as well as what to use `[role-sentence]`. A handle is never the subject of a stage line `[handle-as-subject]`.
- A role names the asset's fidelity grade. Action lines name the character plus one visible marker ("the brown dog with the torn ear sits") `[role-detail]`.
- Several views of one subject say they are one subject. `[one-subject-views]`
- ✓ **A character sheet's role sentence excludes its staging**: "Do not take the grey backdrop, the panel borders or the multi-view layout." Otherwise the studio grey renders as the set. `[sheet-exclusion]`
- A take lists only the references whose subject is in it: an absent subject's handle forces it into frame. `[references-in-shot]`

**Frames in a take** (the form follows the take's mode, [`SHOTS.md`](SHOTS.md) § 4)

- One role sentence per frame, never merged. `[one-role-per-frame]`
- **Panels as references**, the default: each role sentence says which beat the panel is for and what it supplies: "@Image 2 is a reference for the beat at the desk: the place, the staging, the light and the drawing style." Then the order in words ("The beats follow in this order: …"). The stages carry the time; the images carry no seconds. `[panels-as-references]`
- **What keeps its shape**: name the things a place must hold through the take in `[Maintain Consistency]`: "the clouds, the ring and the five lower steps keep their shape, number and position". `[keeps-its-shape]`
- **A first or last frame**, when the take starts or ends on a frame exactly: "@Image 1 is the first frame. It defines the opening composition, subject position, pose, prop state, scene and camera direction." The last frame likewise. `[first-last-frame-roles]`
- **Keyframes**, only when the creator asks: open with "Use @Image 1 through @Image N as keyframes in this order", then the key state each one represents. Keyframes fix stage order and key states, not every frame between them. `[keyframes]`
- Frames come first in slot order, then sheets, plates and photos. Each supplementary reference names the one attribute it supplies; with a first frame it also repeats "Do not change the first-frame composition defined by @Image 1". `[slot-order]`
- A first-last frame take describes one continuous action: "The video begins naturally from the first frame and reaches the last frame after the continuous action." `[continuous-action]`
- A panel's frame is a grid crop until it is fixed, drawn in the film's Look: a take uses it like any frame. Fix a defect in it by a frame edit ([`SHOTS.md`](SHOTS.md) § 3) before a take uses it. `[panel-frame]`
- Takes inherit from the storyboard's frames: order, staging, place and the Look. `[inherit-storyboard]`

**Stages and time**

- Every stage carries one primary change and ends in a visible end state; with panels as references, the stages follow the panels' order. With keyframes or a last frame, the last one is the end state. `[stage-end-state]`
- ✓ Stage time ranges (`[Stage 1] 0-3 seconds`) start at 0, run consecutively and end at the take's length `[time-ranges]`. Write any other duration as one number ("holds for 2 seconds"), since every `A-B seconds` reads as a range.
- ✓ A `[Maintain Consistency]` block when the take has two or more stages or two or more characters `[maintain-consistency]`. Consistency across takes comes from descriptions, sheets and plates.

**Words**

- ✓ Each subject's reference description appears word for word in every prompt it is in `[description]`. The check sees only subjects that come in through an asset; frames and panels carry none. List every character and prop in the take or frame that has no asset input (a text take's, or one shown only in frames) in the spec's `subjects`, so the check sees it.
- ✓ The content filter: no age words, real people's names, brands or franchises, violence verbs or weapon names `[age-marker]` `[real-person-name]` `[brand-ip]` `[violence-verb]` `[weapon-noun]`. Describe people by role, clothing and action.
- Ratio and resolution come from the project, never the prompt. `[ratio-from-project]`
- ✓ Each take rule (a line of the fixed facts' `## Every take`) appears word for word in every take prompt `[take-rule]`. After the take, watch the result for it.
- The Look is in every prompt in its own words: its style, not a copy of the whole section `[look]`.
- Every prompt respects the fixed facts: positions, wardrobe, counts, world rules. `[fixed-facts]`
- No director's or film's name for a style: describe its visible traits. `[no-style-names]`

**Sound**

- ✓ A take with sound on ends its audio line with its diegetic sounds, then `NO BGM` `[no-bgm]`: `Audio: rain on the window, a phone ringing, paper sliding on wood. NO BGM`. Music is a track laid at render, so this holds for every take. Never put the suppression in the `()` music bracket.
- Speech lives only in the audio line, in `{}`, with its language and speaker stated before it. Readable subtext in the action ("a look that says 'you too?'") comes back spoken: write the visible behaviour instead. `[speech-in-audio]`

**Modes that need the creator's word**

- Edit and extend only when the creator explicitly asks. An extend's prompt states its direction: "extend forward", "extend backward" or "continue". `[edit-extend-asked]`
- A swap asks only for actions the source contains, carries the performance clause (the new subject "takes the original's place and inherits its exact performance frame by frame") and the integration clause (grain, motion blur, focus and colour match @Video 1). For a missing action, propose a separate take started from a still of the source. `[swap-clauses]`
- A creator's video used only for camera or motion (not swapped) is a coarse blockout: "@Video 1 provides only <motion paths, camera movement, cuts>. Do not use its appearance, materials or scene." Map each moving thing in it to its subject, and say which seconds it covers if it is for part of the take only. `[blockout-video]`

**Notes**: when a take shows a realistic human face, its shot's notes carry the warning ([`SHOTS.md`](SHOTS.md) § 6).

## Frames, grids, sheets and plates

- ✓ The content filter and the descriptions word for word, as for takes: frames go to Seedance as inputs, and the image model has its own filter.
- A frame in a place's camera angle is an edit of its plate: "Keep the place, every object, the camera and the framing; add only …". A continuing beat is an edit of the previous frame, in the same words. `[plate-edit]`
- Positions come from the fixed facts. Text cannot hold geometry: place things relative to the plate's visible objects ("on the desk's near edge, left of the lamp"), never in metres. `[positions-relative]`
- Each reference image gets its role, as in a take: the frame being fixed "Keep everything; change only …", the sheet "for this character's look; not its grey backdrop or layout", the plate "the place and camera", a style reference "for the drawing style only; none of its content". `[reference-roles]`
- ✓ Frames are at the project's ratio `[frame-ratio]`, and a first-last frame take's two frames share an aspect `[frame-aspect]`. The app sizes frames and grids itself; a frame from anywhere else must match.
- **A grid** asks for N unlabelled panels in a rows × cols grid, read left to right, top to bottom, each at the project's ratio and all exactly the same size, straight thin gutters, the same characters per their sheets, in the film's own look; no panel numbers, captions or text that could leak into frames. `[grid-panels]`
- A sheet's or plate's prompt names one subject. A plate is empty of characters. `[one-subject]`
