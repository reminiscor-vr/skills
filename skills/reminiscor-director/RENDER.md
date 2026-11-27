# Timeline and render

The creator says it in plain words: "let's assemble the film", "let's render". "Timeline" is our word, not theirs. Rendering is free: preview as often as it helps.

**Don't rebuild or show the whole cut unasked.** When a shot gets an output, add it to the saved timeline quietly (an entry in its place by the script) and say so in one line; render a preview only when the creator asks, or a one-shot preview (`--shot N`) for the shot you worked on.

## 0. A free animatic first

When every shot has its storyboard and no take is paid for yet, offer an **animatic** once: each shot's panels as still takes, assembled into a preview, to check pacing, voice-over and music before any money is spent. It costs nothing. If the creator says no, go to the takes ([`SHOTS.md`](SHOTS.md) § 4).

A still take is a take the app's ffmpeg makes from one picture, held for `--seconds` (3 by default), with an optional move. Make one batch per shot, one still take per panel with a picture, in the storyboard's order:

```bash
reminiscor-director project take still <p> N --panels [--seconds S] [--zoom A B] [--center x,y x,y] [--ease in-out]
```

It prints the Run card's figures (`$0.00`) and a `priced` id; show the card and ask as for any generation ([`SKILL.md`](SKILL.md) § Run cards and asking), then queue it with the same arguments and `--priced ID`, and wait with `jobs <p> --batch B --wait`. `--from REF` makes one still take from one picture (`frame:2/1`, `panel:g12#4`, `asset:…`).

Pick the numbers yourself, per take, from what the beat needs, and never write ffmpeg:

| The beat | Settings |
|---|---|
| a held moment, a title | no move (the defaults) |
| tension, a push in | `--zoom 1 1.08` |
| a reveal, a pull out | `--zoom 1.1 1` |
| a look across the picture | `--zoom 1.2 1.2 --center 0.4,0.5 0.6,0.5` (the centre stays inside the picture: at zoom z, from 1/(2z) to 1 − 1/(2z)) |
| a quiet drift | `--zoom 1 1.04 --center 0.5,0.5 0.52,0.49 --ease in-out` |

Give each panel's beat its time with `--seconds`; split a shot into several `take still --from` calls when its panels need different lengths or moves. Then propose each shot's output as its still takes in order (`shot output <p> N 1 2 3`), and the creator approves. Propose and save the timeline (§ 1) and render a preview: that is the animatic. Captions (§ 2) and tracks work on it as on the film.

**Going to film** is an output change: a generated take replaces a shot's still takes where motion is needed; shots that work as stills may stay. The timeline keeps its entries.

## 1. Propose

```bash
reminiscor-director project timeline <p> --propose > <work>/timeline.json
```

Shots in script order (by their part's first scene), each with `sound` `mix` and its own effects, the saved list's effects in their places and the saved tracks kept; a first proposal ends with `mix_tracks` and `watermark`. It saves nothing. Shots with no output are left off and named in `left_off`: tell the creator which, and why.

Save it and render a preview:

```bash
reminiscor-director project timeline <p> --set <work>/timeline.json
```

```bash
reminiscor-director project render <p> --preview
```

`render` waits and prints the film's path and `page` (the project page at that render). Link the page. Done when the creator has the preview.

## 2. Adjust, preview again

Edit the timeline JSON (`reminiscor-director project timeline --help` has the format), `--set` it, preview again.

The timeline is **one list** of entries (shots) and **effects**, read from top to bottom. **An effect on the list acts on everything above it; inside an entry's `effects`, on that entry only.** Effects: `caption`, `fade_in`, `fade_out`, `titles` (cards with time of their own), `watermark` (finals only) and `mix_tracks` (where the tracks come in; one, after the last entry by default). Nothing is added by itself. Effects aren't entries: anchors count shots only.

Their words map to:

| The creator says | Change |
|---|---|
| "put shot 3 before shot 2", "play shot 1 twice" | reorder or repeat the entries |
| "drop the second shot" | `{"shot": 2, "bypass": true}`: it keeps its place and output, the render skips it, its own effects with it |
| "cut the last 3 s of the chase" | the chase shot's **output** (`shot output`, [`SHOTS.md`](SHOTS.md) § 5), not the timeline |
| "only the music under the chase" | the entry's `sound`: `alone` (tracks silent under it) or `mute` (its own sound off); `mix` is the default |
| "put «Порядок» from the chase to the end", "music from 0:12 for 40 seconds" | a track (below) |
| "write STEP 1 · KEY over the second shot", "a caption under the chase" | inside that entry: `{"shot": 2, "effects": [{"caption": {"text": "STEP 1 · KEY", "sub": "…"}}]}`; `sub` (a smaller second line) is optional |
| "fade between shots 2 and 3" | `{"fade_out": {"seconds": 1}}` on the list right after shot 2, and `{"fade_in": {"seconds": 1}}` inside shot 3's `effects` |
| "fade in at the start" | `{"fade_in": {…}}` inside the first entry (on the list it does the same: the start of everything above it is the film's start) |
| "fade out at the end", "end on black" | `{"fade_out": {"seconds": 2}}` (2 when they give none) on the list after the last entry. Below `mix_tracks` it fades the music too; above it, the music plays on |
| "title cards at the end" | `{"titles": {"text1": "…", "text2": "…"}}` (`text2` optional) after the end's fade |
| "a card after the second shot", "an intro card" | `{"titles": {"text1": "Two years later"}}` on the list right after shot 2, or first on the list. The shots after it start later; anchored tracks follow their shot |
| "keep the watermark over the fade" | `watermark` **below** the `fade_out` (the usual end: `… mix_tracks, fade_out, titles, watermark`) |
| "no watermark on the last shot" | `watermark` on the list right **above** the last entry |
| "no watermark" | remove `watermark` |

After a change to the effects, **say the order back in plain words**, top to bottom: "shot 1, shot 2 fading to black, a card «Two years later», shot 3 fading in, the music, the end fades, the watermark over all of it". If `timeline` prints a warning (two watermarks over one part), say it and fix it.

Previews skip the watermark, and title cards with no shot after them; the final draws everything.

**Tracks**: an audio asset placed by `start` and `end`, `start` and `length_s`, or `start` alone (to `mix_tracks`: the end of everything above it). A bound is seconds, or an anchor to an entry (`{"entry": 3, "edge": "start"}`, entries counted from 1, bypassed ones too), so reordering keeps the creator's intent: prefer anchors whenever the creator names a shot. `gain_db` and `fade_in_s` / `fade_out_s` default to 0 dB and 1 s. Tracks may overlap.

- A creator's music file: `reminiscor-director project add <p> <file> --name poryadok --role audio`, then `"asset": "poryadok"`.
- A source video's own sound ("keep the sound of my clip under it"): the video asset itself as the track's `asset`, with no ffmpeg by hand. `from_s` is the second of the file its sound starts at, for a film that uses only part of the clip (it works for music files too). For a continuous original sound set `fade_in_s` and `fade_out_s` to 0.
- Generated music: a `track` generation on a Run card ([`SKILL.md`](SKILL.md) § Every generation): `{"kind": "track", "asset": "chase_theme", "prompt": "…", "settings": {"duration": 40}}` (`gen_music.v1`). The track lands as the asset's next version.

Takes carry their own diegetic sound with `NO BGM`; music comes only from tracks.

## 3. Final

"Render final" is the end; there is no separate sign-off.

```bash
reminiscor-director project render <p> --final
```

The final is at the project's resolution (short side at least 1080, 24 fps) with every effect on the list, title cards and watermark included. Give the creator the film's path and the page.

`reminiscor-director project renders <p>` lists renders; `renders <p> r7` shows one with its ffmpeg command. A failed render's `error` holds ffmpeg's last lines: fix the timeline or an output and render again.
