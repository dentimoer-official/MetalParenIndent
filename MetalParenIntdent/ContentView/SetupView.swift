//
//  SetupView.swift
//  MetalParenIntdent
//
//  Created by mymin on 11/17/26.
//

import SwiftUI
import AppKit

struct SetupView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                StepRow(number: 1,
                        title: "Enable the Extension",
                        detail: "Turn on MetalParenIndent under Xcode Source Editor in System Settings.") {
                    Button("Open System Settings", action: openExtensionSettings)
                }

                StepRow(number: 2,
                        title: "Restart Xcode",
                        detail: "Quit Xcode completely (⌘Q) and open it again so it loads the extension.") {
                    EmptyView()
                }

                StepRow(number: 3,
                        title: "Assign Shortcuts",
                        detail: "In Xcode, open Settings → Key Bindings and search for \"MetalParenIndent\".") {
                    VStack(alignment: .leading, spacing: 12) {
                        CommandRow(name: "Fix Paren Indent",
                                   detail: "Fixes bracket indentation in the current file or selection. Suggested: ⌃⌥⌘I")
                        CommandRow(name: "Block Indent Newline",
                                   detail: "Inserts a newline with block indentation after ( or [. Suggested: ⇧↩")
                    }
                }

                StepRow(number: 4,
                        title: "Use It",
                        detail: "Open a .metal file and choose Editor → MetalParenIndent, or press your shortcut. Other file types are left untouched.") {
                    EmptyView()
                }
            }
            .padding(32)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Setup")
    }

    private func openExtensionSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
            "x-apple.systempreferences:com.apple.ExtensionsPreferences",
        ]
        for string in candidates {
            if let url = URL(string: string), NSWorkspace.shared.open(url) {
                return
            }
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
    }
}

private struct StepRow<Content: View>: View {
    let number: Int
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(verbatim: "\(number)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.tint.opacity(0.15)))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                content
                    .padding(.top, 4)
            }
        }
    }
}

private struct CommandRow: View {
    let name: String
    let detail: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: name)
                .font(.body.monospaced().weight(.semibold))
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
