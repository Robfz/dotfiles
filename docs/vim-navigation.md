# Vim Navigation Guide

> This guide uses the custom `ijkl` movement mapping defined in `.vimrc`:
> `i` = Up, `j` = Left, `k` = Down, `l` = Right (with `h` remapped to insert mode).

## Counted Motions

Prefix any movement with a number to repeat it:

| Command | Action                |
|---------|-----------------------|
| `5k`    | Move 5 lines down     |
| `5i`    | Move 5 lines up       |
| `5j`    | Move 5 characters left  |
| `5l`    | Move 5 characters right |

Tip: with `relativenumber` enabled, you can read the exact count directly from the gutter.

## Word Motions

| Command | Action                            |
|---------|-----------------------------------|
| `w`     | Jump to start of next word        |
| `b`     | Jump back to start of previous word |
| `e`     | Jump to end of current/next word  |
| `3w`    | Jump 3 words forward              |

## Line Motions

| Command | Action                              |
|---------|-------------------------------------|
| `0`     | Jump to beginning of line           |
| `$`     | Jump to end of line                 |
| `^`     | Jump to first non-blank character   |

## Screen and File Motions

| Command        | Action                          |
|----------------|---------------------------------|
| `gg`           | Go to first line of file        |
| `G`            | Go to last line of file         |
| `12G` / `12gg` | Go to line 12                  |
| `H`            | Jump to top of screen           |
| `M`            | Jump to middle of screen        |
| `L`            | Jump to bottom of screen        |
| `Ctrl+u`       | Scroll half-page up             |
| `Ctrl+d`       | Scroll half-page down           |
| `Ctrl+b`       | Scroll full page up             |
| `Ctrl+f`       | Scroll full page down           |

## Search as Navigation

| Command    | Action                                  |
|------------|-----------------------------------------|
| `f(`       | Jump to next `(` on current line        |
| `F(`       | Jump back to previous `(` on current line |
| `/pattern` | Search forward for pattern              |
| `n`        | Repeat last search (same direction)     |
| `N`        | Repeat last search (reverse direction)  |

## Combining Motions with Operators

The general pattern is: **operator + [count] + motion**

### Operators

| Operator | Action                        |
|----------|-------------------------------|
| `d`      | Delete                        |
| `y`      | Yank (copy)                   |
| `c`      | Change (delete + insert mode) |

### Examples

| Command | Action                               |
|---------|--------------------------------------|
| `d5k`   | Delete 5 lines down                  |
| `dw`    | Delete a word                        |
| `d$`    | Delete to end of line                |
| `y3w`   | Yank (copy) 3 words                 |
| `c$`    | Change to end of line                |
| `di(`   | Delete everything inside parentheses |
| `ci"`   | Change everything inside quotes      |
