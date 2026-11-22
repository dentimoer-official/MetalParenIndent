//
//  BlockIndentNewlineCommand.swift
//  MetalParenIndent
//
//  Created by mymin on 11/17/26.
//

import Foundation
import XcodeKit

final class BlockIndentNewlineCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer
        let lines = IndentCore.lines(of: buffer)
        let tab = buffer.tabWidth
        let unit = IndentCore.indentUnit(for: buffer)

        guard let sel = buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(nil)
            return
        }

        // Empty file, or cursor past the last line.
        if lines.isEmpty || sel.start.line >= lines.count {
            buffer.lines.add("\n")
            setCursor(buffer, line: buffer.lines.count, column: 0)
            completionHandler(nil)
            return
        }

        let startLine = sel.start.line
        let endLine = min(sel.end.line, lines.count - 1)

        let firstLine = lines[startLine]
        let lastLine = lines[endLine]

        let startIdx = IndentCore.charIndex(forColumn: sel.start.column, in: firstLine, tabWidth: tab)
        let endIdx = sel.end.line >= lines.count
            ? lastLine.count
            : IndentCore.charIndex(forColumn: sel.end.column, in: lastLine, tabWidth: tab)

        // A non-empty selection is replaced by the newline (same as a normal Return).
        let before = String(firstLine.prefix(startIdx))
        let after = String(lastLine.dropFirst(endIdx))
        let afterTrimmed = String(after.drop(while: { $0 == " " || $0 == "\t" }))

        let baseIndent = IndentEngine.leadingWhitespace(firstLine)
        let context = IndentCore.isMetal(buffer)
            ? IndentEngine.newlineContext(linesAbove: lines[0..<startLine],
                                          before: before,
                                          after: after)
            : (opensBlock: false, closesNext: false)

        var newLines: [String]
        var cursorText: String   // Text before the cursor on the line where it ends up.

        if context.opensBlock && context.closesNext {
            // foo(|)  →  foo(
            //               |
            //            )
            let inner = baseIndent + unit
            newLines = [before, inner, baseIndent + afterTrimmed]
            cursorText = inner
        } else if context.opensBlock {
            let inner = baseIndent + unit
            newLines = [before, inner + afterTrimmed]
            cursorText = inner
        } else {
            newLines = [before, baseIndent + afterTrimmed]
            cursorText = baseIndent
        }

        // Replace the original lines, keeping the last line's original line ending.
        let lastRaw = buffer.lines[endLine] as! String
        let lastSuffix = IndentCore.newlineSuffix(of: lastRaw)

        buffer.lines.removeObjects(in: NSRange(location: startLine,
                                               length: endLine - startLine + 1))
        for (i, line) in newLines.enumerated() {
            let suffix = (i == newLines.count - 1) ? lastSuffix : "\n"
            buffer.lines.insert(line + suffix, at: startLine + i)
        }

        setCursor(buffer,
                  line: startLine + 1,
                  column: IndentCore.column(forCharIndex: cursorText.count,
                                            in: cursorText,
                                            tabWidth: tab))
        completionHandler(nil)
    }

    private func setCursor(_ buffer: XCSourceTextBuffer, line: Int, column: Int) {
        let pos = XCSourceTextPosition(line: line, column: column)
        buffer.selections.removeAllObjects()
        buffer.selections.add(XCSourceTextRange(start: pos, end: pos))
    }
}
