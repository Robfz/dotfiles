# Pi coding agent — asdf-independent install

Pi (`@earendil-works/pi-coding-agent`) is a node-only CLI whose launcher uses
`#!/usr/bin/env node`. Since asdf shims sit first in `PATH`, a normal global
install would run pi on whatever node each folder pins — and fail entirely in
folders with no node pinned. This setup decouples pi from asdf completely.

## How it works

Three pieces, all applied by `install.sh` (macOS only, requires homebrew node):

1. **Install**: pi is npm-installed globally using homebrew's node/npm into
   `/opt/homebrew/lib/node_modules`. The install command prefixes `PATH` with
   `/opt/homebrew/bin` because npm's own shebang would otherwise resolve node
   through the asdf shim.

2. **Wrapper** (`bin/pi` → `~/.local/bin/pi`): runs pi's entry point with
   `/opt/homebrew/bin/node` directly, bypassing shebang/PATH resolution.
   `~/.local/bin` is prepended after the asdf shims in `zsh/zshrc`, so the
   wrapper always wins — including over the `pi` symlink npm drops in
   `/opt/homebrew/bin` (harmless, leave it; npm recreates it on update).

3. **Self-update setting** (`npmCommand` in `~/.pi/agent/settings.json`):
   `pi update self` spawns bare `npm` from PATH, which hits the asdf shim and
   fails in folders without a pinned node. The setting makes pi run homebrew's
   npm via its JS entry point instead:

   ```json
   "npmCommand": ["/opt/homebrew/bin/node", "/opt/homebrew/lib/node_modules/npm/bin/npm-cli.js"]
   ```

   Note: the sibling pi-extensions repo's `apply-settings.sh` also manages
   `~/.pi/agent/settings.json`; if it ever rewrites the file wholesale, re-run
   `install.sh` (its pi section runs after the pi-extensions block, so the
   setting is reapplied).

## Updating pi

`pi update self` works from any directory (thanks to piece 3), updates the
package in place under `/opt/homebrew/lib/node_modules`, and the wrapper needs
no re-copy. Re-running `install.sh` also updates it.

## Gotchas

- Pi runs on homebrew's node (kept current by `brew upgrade node`), regardless
  of any `.tool-versions`. Subprocesses pi spawns (bash tool, etc.) still see
  the normal PATH, so asdf resolution inside pi sessions is unaffected.
- Node runtime flags (e.g. `--inspect`) can't be passed through the wrapper;
  insert them before the script path in `bin/pi` if ever needed for debugging.
- The package lives under the `@earendil-works` npm scope; the old
  `@mariozechner/pi-coding-agent` scope is abandoned (frozen at 0.73.1).
