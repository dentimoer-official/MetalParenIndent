//
//  IndentCore.swift
//  MetalParenIndent
//
//  Created by mymin on 11/17/26.
//

import Foundation
import XcodeKit

enum IndentCore {

    /// True for Metal shader sources (.metal). Matches any UTI containing "metal".
    static func isMetal(_ buffer: XCSourceTextBuffer) -> Bool {
        buffer.contentUTI.lowercased().contains("metal")
    }

    static func indentUnit(for buffer: XCSourceTextBuffer) -> String {
        buffer.usesTabsForIndentation
            ? "\t"
            : String(repeating: " ", count: buffer.indentationWidth)
    }

    /// Buffer lines without trailing newline characters.
    static func lines(of buffer: XCSourceTextBuffer) -> [String] {
        (0..<buffer.lines.count).map { stripNewline(buffer.lines[$0] as! String) }
    }

    static func stripNewline(_ s: String) -> String {
        var s = s
        while s.hasSuffix("\n") || s.hasSuffix("\r") { s.removeLast() }
        return s
    }

    static func newlineSuffix(of s: String) -> String {
        if s.hasSuffix("\r\n") { return "\r\n" }
        if s.hasSuffix("\n") { return "\n" }
        return ""
    }

    // Xcode columns count a tab as tabWidth columns; convert to character offsets.
    // (Identical when indenting with spaces.)
    static func charIndex(forColumn column: Int, in line: String, tabWidth: Int) -> Int {
        var col = 0
        var idx = 0
        for ch in line {
            if col >= column { break }
            col += (ch == "\t") ? max(tabWidth, 1) : 1
            idx += 1
        }
        return idx
    }

    static func column(forCharIndex index: Int, in line: String, tabWidth: Int) -> Int {
        var col = 0
        for ch in line.prefix(index) {
            col += (ch == "\t") ? max(tabWidth, 1) : 1
        }
        return col
    }
}
