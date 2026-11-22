//
//  SourceEditorExtension.swift
//  MetalParenIndentExtension
//
//  Created by mymin on 11/17/26.
//

import Foundation
import XcodeKit

final class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
        let prefix = Bundle.main.bundleIdentifier ?? "MetalParenIndent"; return [
            [
                .identifierKey: "\(prefix).FixParenIndent",
                .classNameKey: NSStringFromClass(FixParenIndentCommand.self),
                .nameKey: "Fix Paren Indent",
            ],
            [
                .identifierKey: "\(prefix).BlockIndentNewline",
                .classNameKey: NSStringFromClass(BlockIndentNewlineCommand.self),
                .nameKey: "Block Indent Newline",
            ],
        ]
    }
}
