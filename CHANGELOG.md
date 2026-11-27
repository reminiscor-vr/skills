# Changelog

## 0.1.3 — 2026-11-27

- A page for your Comfy API key, at http://127.0.0.1:8765/settings: paste it there and paid generations work at once. The projects page reminds you while there is none.
- Setup no longer fails on a clean Mac with `CERTIFICATE_VERIFY_FAILED` while downloading ComfyUI.

## 0.1.2 — 2026-11-27

- The plugin's skill is the whole director: Claude makes films with it, from a story to the rendered film.
- Setup installs Reminiscor's shared ComfyUI nodes.
- Claude installs the ComfyUI node packs a workflow needs, from GitHub at a fixed commit (`reminiscor-director node add`), into your data folder: updates keep them.
- The director runs in the program: projects, shots, generations and renders with `reminiscor-director project`, and their pages at http://127.0.0.1:8765/projects.

## 0.1.1 — 2026-11-27

- New versions are built and published automatically.

## 0.1.0 — 2026-11-27

- First release for Mac: `setup` installs ComfyUI and ffmpeg, `start` / `stop` / `status`, and `ping` checks that everything works.
