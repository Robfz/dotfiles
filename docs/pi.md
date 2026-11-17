# Pi coding agent — version-manager-independent install

Pi (`@earendil-works/pi-coding-agent`) is a node-only CLI whose launcher uses
`#!/usr/bin/env node`. Since mise (or asdf) puts a cwd-dependent `node` first
in `PATH`, a normal global install would run pi on whatever node each folder
pins — and fail entirely in folders with no node pinned. This setup decouples
pi from the version manager completely.

## How it works

Three pieces, all applied by `install.sh` (macOS only, requires homebrew node):

1. **Install**: pi is npm-installed globally using homebrew's node/npm into
   `/opt/homebrew/lib/node_modules`. The install command prefixes `PATH` with
   `/opt/homebrew/bin` because npm's own shebang would otherwise resolve node
   through the mise/asdf shim.

2. **Wrapper** (`bin/pi` → `~/.local/bin/pi`): runs pi's entry point with
   `/opt/homebrew/bin/node` directly, bypassing shebang/PATH resolution.
   `zsh/zshrc` defines a `pi` shell function that calls this wrapper.
   Prepending `~/.local/bin` to PATH is *not* enough on its own: mise's hook
   rebuilds PATH on every directory change and puts its tool paths (e.g.
   `~/.local/share/mise/installs/node/<ver>/bin`, shims) back in front. A shell
   function takes precedence over any PATH lookup, so the wrapper always wins —
   over the `pi` symlink npm drops in `/opt/homebrew/bin` (harmless, leave it;
   npm recreates it on update) and over any copy accidentally installed into a
   mise node (see Gotchas).

3. **npm wrapper for pi** (`bin/pi-npm` → `~/.local/bin/pi-npm`, wired via
   `npmCommand` in `~/.pi/agent/settings.json`): pi spawns npm for
   `pi update self` and for extension installs. Two failure modes without this:
   bare `npm` from PATH hits the mise/asdf shim directly, and even with a
   working npm, its lifecycle scripts (`sh -c node ...`) resolve node through
   PATH — npm does not put its own node first — so postinstalls (e.g.
   protobufjs) fail when no node is pinned. `pi-npm` runs homebrew's npm via
   its JS entry point *and* prepends `/opt/homebrew/bin` to PATH for that
   process only, so lifecycle scripts get the same node. The PATH change
   doesn't leak into pi itself or its bash sessions:

   ```json
   "npmCommand": ["/Users/roberto/.local/bin/pi-npm"]
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
  of any mise/`.tool-versions` pin. Subprocesses pi spawns (bash tool, etc.)
  still see the normal PATH, so mise resolution inside pi sessions is
  unaffected.
- Never `npm install -g` pi under a mise node. It leaves a stale copy in that
  node's `bin` plus a `mise/shims/pi` shim. The shell function still wins in
  interactive zsh, but non-interactive callers that resolve `pi` via PATH would
  pick it up. Check with `which -a pi` and remove it with
  `mise exec node@<ver> -- npm uninstall -g @earendil-works/pi-coding-agent && mise reshim`.
- The `pi` function only exists in interactive zsh. Scripts and other tools
  that launch `pi` should call `~/.local/bin/pi` explicitly.
- Node runtime flags (e.g. `--inspect`) can't be passed through the wrapper;
  insert them before the script path in `bin/pi` if ever needed for debugging.
- The package lives under the `@earendil-works` npm scope; the old
  `@mariozechner/pi-coding-agent` scope is abandoned (frozen at 0.73.1).
