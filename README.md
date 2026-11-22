# MetalParenIndent

An Xcode Source Editor Extension that fixes bracket indentation in Metal shader files.

Xcode aligns wrapped parameters under the opening parenthesis, which pushes them far to the right.
MetalParenIndent indents them by one level instead.

```metal
// Xcode default
vertex Out vertex_main(
                       uint id [[vertex_id]],
                       constant V *v [[buffer(0)]]
                       ) {

// With MetalParenIndent
vertex Out vertex_main(
    uint id [[vertex_id]],
    constant V *v [[buffer(0)]]
) {
```

## Features

- **Fix Paren Indent** — fixes bracket indentation in the current file, or only in the selected lines.
- **Block Indent Newline** — a newline command that indents one level after `(` or `[`, and moves a following `)` or `]` back to the original indent.
- Works only in `.metal` files. Other file types are left untouched.
- Brackets inside comments and string literals are ignored.
- `{ }` blocks are left as they are.
- Follows Xcode's indent width setting.

## Requirements

- macOS 27 or later
- Mac with Apple silicon
- Xcode

## Setup

1. Open MetalParenIndent once.
2. Open **System Settings → General → Login Items & Extensions**, and turn on MetalParenIndent under **Xcode Source Editor**.
3. Quit Xcode completely (⌘Q) and open it again.
4. In Xcode, open **Settings → Key Bindings**, search for `MetalParenIndent`, and assign shortcuts.

| Command | Suggested shortcut |
|---|---|
| Fix Paren Indent | ⌃⌥⌘I |
| Block Indent Newline | ⇧↩ |

You can also run the commands from **Editor → MetalParenIndent**.

## Building from Source

1. Open `MetalParenIndent.xcodeproj` in Xcode.
2. Select your own team under **Signing & Capabilities** for both targets.
3. Build and run the `MetalParenIndent` scheme.

To try the extension in a separate Xcode instance, run the `MetalParenIndentExtension` scheme and choose Xcode as the host app.

## Project Layout

```
Shared/                      Indentation engine used by both the app and the extension
MetalParenIndent/            Host app (Welcome, Setup, Preview)
MetalParenIndentExtension/   Xcode Source Editor Extension commands
```

## Privacy

MetalParenIndent does not collect any data. See [PRIVACY.md](PRIVACY.md).

## License

[MIT](LICENSE) © 2026 dentimoer
