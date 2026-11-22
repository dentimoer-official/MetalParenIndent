//
//  WelcomeView.swift
//  MetalParenIntdent
//
//  Created by mymin on 11/17/26.
//

import SwiftUI
import AppKit

struct WelcomeView: View {
    @Binding var selection: SidebarItem?

    private let before = """
    vertex Out vertex_main(
                           uint id [[vertex_id]],
                           constant V *v [[buffer(0)]]
                           ) {
    """

    private let after = """
    vertex Out vertex_main(
        uint id [[vertex_id]],
        constant V *v [[buffer(0)]]
    ) {
    """

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .frame(width: 96, height: 96)

                VStack(spacing: 6) {
                    Text("Welcome to MetalParenIndent")
                        .font(.largeTitle.bold())
                    Text("Clean bracket indentation for Metal shaders in Xcode.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                HStack(alignment: .top, spacing: 16) {
                    SnippetCard(title: "Xcode default", code: before)
                    SnippetCard(title: "With MetalParenIndent", code: after)
                }
                .frame(maxWidth: 720)

                Text("Xcode aligns wrapped parameters under the opening parenthesis, which pushes them far to the right. MetalParenIndent indents them by one level instead.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Button("Set Up") { selection = .setup }
                        .buttonStyle(.borderedProminent)
                    Button("Try It") { selection = .preview }
                }
                .controlSize(.large)

                Text("Use the sidebar to set up the extension or try it on your own code.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Welcome")
    }
}

private struct SnippetCard: View {
    let title: LocalizedStringKey
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                Text(verbatim: code)
                    .font(.system(.footnote, design: .monospaced))
                    .fixedSize()
                    .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
    }
}
