# Project workflows

Before any generation, know what can run it: the project's own workflows (`reminiscor-director project workflow list <p>`, each described with its inputs, outputs and what it was used for) and the library's (`workflows/CATALOG.md`). Pick from those rather than guessing nodes. A spec with no `workflow` gets the library's default for its kind and mode.

## Making one

When nothing fits, build one, for this project only:

1. **From installed nodes.** Look them up in ComfyUI's `/object_info` (`curl -s http://127.0.0.1:8190/object_info/<NodeClass>`). Core nodes and Reminiscor's shared nodes are there. When the workflow needs a node pack that isn't, install it for this creator (see **Node packs** below), then build with it.
2. **API-format JSON** with the library's conventions, so the app can bind inputs and collect outputs: a `PARM_<NAME>` node (by its `_meta.title`) for each input the spec sets (`PARM_PROMPT` for the prompt, `PARM_IMG_0` / `PARM_VIDEO_0` / `PARM_AUDIO_0` loaders for files, `PARM_DURATION`, …), `GEN_` titles on the generating nodes whose settings the spec may change, and at least one `RESULT_<KIND>` save node. Copy the shape from the nearest library workflow in `workflows/`.
3. **Add it**:

   ```bash
   reminiscor-director project workflow add <p> <work>/<name>.json --name <name> --description "<what it does, inputs, outputs>"
   ```

   The app checks it statically against `/object_info` (node classes, required inputs, link types, a `RESULT_` node) and refuses it whole, each error naming its node. Fix and add again; changed JSON becomes the next version, old generations keep theirs.
4. **Use it**: `"workflow": "<name>"` (newest) or `"<name>@<N>"` in a spec. Settings are keyed by its param spec, as for library workflows; `price` shows them.
5. **Its first run** per version is marked `new_workflow` in `price` and `gen`: put **NEW WORKFLOW** on that item of the Run card. A project workflow has no test twin.

## Node packs

The creator's own ComfyUI node packs live in their data folder, kept across updates; nothing beyond the core and Reminiscor's shared nodes is installed in advance. When a workflow needs a pack, install it, from its GitHub repo at one commit:

```bash
reminiscor-director node add <owner/repo> [--commit <sha|branch|tag>]   # default: the default branch's latest commit
reminiscor-director node list                                            # setup's nodes and the creator's, with commits
reminiscor-director node remove <name>
```

`add` fetches it, installs its Python requirements into ComfyUI's environment and pins the commit. ComfyUI loads it after a restart: `reminiscor-director stop`, then `start` (it says when one is needed). Check the node classes in `/object_info` afterwards, and tell the creator which pack was added and why. A node the creator wants made from scratch is written as a pack of its own in that folder; one that proves useful to everyone goes to `reminiscor-vr/comfy-nodes` in a PR, which the dev reviews.

## "Add it to the library"

When the creator says a project workflow proved useful, it goes to the dev for the program's library, which ships with the next release:

```bash
reminiscor-director project workflow promote <p> <name> --root $TMPDIR/<p>/library
```

It writes `workflows/<name>.json`, its param spec `workflows/parms/<name>.toml`, a stub twin `workflows/test/<name>.json` and a `CATALOG.md` entry with TODOs into that folder. Finish the twin (replace the partner nodes its `_stub` names with free core nodes, keeping every `PARM_` and `RESULT_` title) and the catalog entry. Then, when `gh repo view reminiscor-vr/seedance_director` works (the creator has access): branch from `develop`, add the files, open a PR into `develop` for the dev to review and tell the creator the link. Otherwise tell the creator the folder to send to the dev.
