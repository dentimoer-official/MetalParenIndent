//
//  IndentEngine.swift
//  MetalParenIndent
//
//  Created by mymin on 11/17/26.
//

import Foundation

// MARK: - Brackets

enum Bracket: Character {
    case paren = "("
    case square = "["
    case curly = "{"

    init?(closer: Character) {
        switch closer {
        case ")": self = .paren
        case "]": self = .square
        case "}": self = .curly
        default: return nil
        }
    }

    /// Whether block indentation applies to this bracket ({ } is left to Xcode / the user).
    var usesBlockIndent: Bool { self != .curly }
}

// MARK: - Line scanner

struct LineScan {
    /// Brackets outside comments and literals, in order of appearance.
    var brackets: [Character] = []
    /// First / last character that is not whitespace or comment.
    var firstSignificant: Character?
    var lastSignificant: Character?
}

struct LineScanner {
    /// True while a /* ... */ comment spans multiple lines.
    var inBlockComment = false

    mutating func scan(_ line: String) -> LineScan {
        let chars = Array(line)
        var result = LineScan()
        var quote: Character? = nil
        var i = 0

        func mark(_ c: Character) {
            if result.firstSignificant == nil { result.firstSignificant = c }
            result.lastSignificant = c
        }

        while i < chars.count {
            let c = chars[i]
            let next: Character? = i + 1 < chars.count ? chars[i + 1] : nil

            if inBlockComment {
                if c == "*" && next == "/" {
                    inBlockComment = false
                    i += 2
                } else {
                    i += 1
                }
                continue
            }

            if let q = quote {
                if c == "\\" {
                    i += 2
                    continue
                }
                if c == q {
                    quote = nil
                    mark(c)
                }
                i += 1
                continue
            }

            if c == "/" && next == "/" { break }
            if c == "/" && next == "*" {
                inBlockComment = true
                i += 2
                continue
            }
            if c == "\"" || c == "'" {
                quote = c
                mark(c)
                i += 1
                continue
            }
            if c == " " || c == "\t" || c == "\r" {
                i += 1
                continue
            }

            mark(c)
            if "([{)]}".contains(c) { result.brackets.append(c) }
            i += 1
        }
        return result
    }
}

// MARK: - Engine

enum IndentEngine {

    static func leadingWhitespace(_ s: String) -> String {
        String(s.prefix(while: { $0 == " " || $0 == "\t" }))
    }

    private struct Frame {
        let bracket: Bracket
        let base: String
        var isBlock: Bool
    }

    /// Takes lines (without newlines) and returns them with bracket indentation fixed.
    /// If `range` is given, only those lines are changed; the rest are read for context.
    static func fixParenIndent(lines: [String],
                               range: ClosedRange<Int>?,
                               indentUnit: String) -> [String] {
        var scanner = LineScanner()
        var stack: [Frame] = []
        var out = lines

        for (idx, line) in lines.enumerated() {
            let lead = leadingWhitespace(line)
            let body = String(line.dropFirst(lead.count))
            let startsInComment = scanner.inBlockComment
            let scan = scanner.scan(body)

            var newLead = lead
            let isBlankLine = body.isEmpty && lead.isEmpty
            if !startsInComment, !isBlankLine,
               let top = stack.last, top.isBlock, top.bracket.usesBlockIndent {
                if let first = scan.firstSignificant, let closing = Bracket(closer: first) {
                    // Line starts with a closer: same kind goes back to the base, otherwise untouched.
                    if closing == top.bracket { newLead = top.base }
                } else {
                    // Content lines and whitespace-only lines go one level in.
                    newLead = top.base + indentUnit
                }
            }

            if let range, !range.contains(idx) { newLead = lead }
            out[idx] = newLead + body

            // Update the bracket stack.
            for c in scan.brackets {
                if let open = Bracket(rawValue: c) {
                    stack.append(Frame(bracket: open, base: newLead, isBlock: false))
                } else if let close = Bracket(closer: c),
                          let i = stack.lastIndex(where: { $0.bracket == close }) {
                    stack.removeSubrange(i...)
                }
            }

            // A line ending with an opener makes that bracket a block-indent target.
            if let last = scan.lastSignificant,
               let open = Bracket(rawValue: last),
               stack.last?.bracket == open {
                stack[stack.count - 1].isBlock = true
            }
        }
        return out
    }

    /// Fixes a whole piece of text. Used by the app's preview.
    static func format(_ text: String, indentUnit: String) -> String {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        return fixParenIndent(lines: lines, range: nil, indentUnit: indentUnit)
            .joined(separator: "\n")
    }

    /// Whether the text before the cursor ends with an opener,
    /// and whether the text after the cursor starts with a closer.
    static func newlineContext(linesAbove: ArraySlice<String>,
                               before: String,
                               after: String) -> (opensBlock: Bool, closesNext: Bool) {
        var scanner = LineScanner()
        for line in linesAbove { _ = scanner.scan(line) }
        let scanBefore = scanner.scan(before)
        if scanner.inBlockComment { return (false, false) }

        let opens = scanBefore.lastSignificant.flatMap { Bracket(rawValue: $0) } != nil
        let afterTrimmed = after.drop(while: { $0 == " " || $0 == "\t" })
        let closes = afterTrimmed.first.flatMap { Bracket(closer: $0) } != nil
        return (opens, closes)
    }
}
