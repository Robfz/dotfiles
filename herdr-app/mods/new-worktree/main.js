// Opens the shipped worktree dialog for the focused space, so a key can do
// what the + menu's "New worktree…" does: `mod.open:new-worktree`.
// keys.json can't pass props to a mod, hence this one-shot launcher popup.

import { View, div } from "gpui-kit";
import { checking, closeOverlay, focused, openOverlay, props } from "herdr";

export default class NewWorktree extends View {
  init() {
    if (checking()) return;
    const f = focused();
    if (f?.space) {
      openOverlay({ mod: "worktree", kind: "dialog", width: 460, height: 280,
        props: { space: f.space, folder: f.cwd ?? undefined, action: "new" } });
    }
    closeOverlay(props().overlay);
  }

  render() {
    return div();
  }
}
