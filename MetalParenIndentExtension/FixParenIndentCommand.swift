//
//  FixParenIndentCommand.swift
//  MetalParenIntdent
//
//  Created by mymin on 11/17/26.
//

import Foundation
import XcodeKit

final class FixParenIndentCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer

        // Metal files only; do nothing anywhere else.
        guard IndentCore.isMetal(buffer) else {
            completionHandler(nil)
            return
        }

        let lines = IndentCore.lines(of: buffer)
        guard !lines.isEmpty else {
            completionHandler(nil)
            return
        }

        // With a selection, only the selected lines; otherwise the whole file.
        var range: ClosedRange<Int>? = nil
        if let sel = buffer.selections.firstObject as? XCSourceTextRange,
           !(sel.start.line == sel.end.line && sel.start.column == sel.end.column) {
            let lo = min(sel.start.line, lines.count - 1)
            var hi = min(sel.end.line, lines.count - 1)
            // A full-line selection ends at column 0 of the next line; exclude that line.
            if sel.end.column == 0 && hi > lo { hi -= 1 }
            range = lo...hi
        }

        let fixed = IndentEngine.fixParenIndent(lines: lines,
                                                range: range,
                                                indentUnit: IndentCore.indentUnit(for: buffer))

        // Record per-line indent changes so the cursor can be adjusted.
        var leadChange: [Int: (old: Int, new: Int)] = [:]
        let tab = buffer.tabWidth

        for i in 0..<lines.count where fixed[i] != lines[i] {
            let raw = buffer.lines[i] as! String
            buffer.lines[i] = fixed[i] + IndentCore.newlineSuffix(of: raw)

            let oldLead = IndentEngine.leadingWhitespace(lines[i])
            let newLead = IndentEngine.leadingWhitespace(fixed[i])
            leadChange[i] = (
                IndentCore.column(forCharIndex: oldLead.count, in: lines[i], tabWidth: tab),
                IndentCore.column(forCharIndex: newLead.count, in: fixed[i], tabWidth: tab)
            )
        }

        // Move selections / cursor to follow the new indentation.
        func adjust(_ pos: XCSourceTextPosition) -> XCSourceTextPosition {
            guard let change = leadChange[pos.line] else { return pos }
            let column = pos.column >= change.old
                ? pos.column + (change.new - change.old)
                : min(pos.column, change.new)
            return XCSourceTextPosition(line: pos.line, column: max(0, column))
        }

        let oldSelections = buffer.selections.compactMap { $0 as? XCSourceTextRange }
        if !leadChange.isEmpty && !oldSelections.isEmpty {
            buffer.selections.removeAllObjects()
            for sel in oldSelections {
                buffer.selections.add(XCSourceTextRange(start: adjust(sel.start),
                                                        end: adjust(sel.end)))
            }
        }

        completionHandler(nil)
    }
}
