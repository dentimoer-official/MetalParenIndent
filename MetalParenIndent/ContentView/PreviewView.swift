//
//  PreviewView.swift
//  MetalParenIndent
//
//  Created by mymin on 11/17/26.
//

import SwiftUI
import AppKit

struct PreviewView: View {
    @State private var input = PreviewView.sample

    private var output: String {
        IndentEngine.format(input, indentUnit: "    ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Paste Metal code on the left. The fixed result appears on the right.")
                    .foregroundStyle(.secondary)
                HStack {
                    Text("Paste Metal code on the left. The fixed result appears on the right.")
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                CodePane(title: "Original", text: $input, isEditable: true)
                CodePane(title: "Result", text: .constant(output), isEditable: false)
            }

            HStack {
                Button("Reset Sample") { input = Self.sample }
                Spacer()
                Button("Copy Result") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(output, forType: .string)
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
        }
        .padding(20)
        .navigationTitle("Preview")
    }

    static let sample = """
    #include <metal_stdlib>
    using namespace metal;

    vertex VertexOut vertex_main(
                                 uint vertexID [[vertex_id]],
                                 constant Vertex *vertices [[buffer(0)]]
                                 ) {
        VertexOut out;
        out.position = vertices[vertexID].position;
        out.color    = vertices[vertexID].color;
        return out;
    }
    """
}

private struct CodePane: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            CodeTextView(text: $text, isEditable: isEditable)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.separator)
                )
        }
    }
}

/// Plain-text code view: monospaced, no smart quotes, no autocorrect, no wrapping.
private struct CodeTextView: NSViewRepresentable {
    @Binding var text: String
    let isEditable: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true

        let textView = scrollView.documentView as! NSTextView
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        textView.smartInsertDeleteEnabled = false
        textView.textContainerInset = NSSize(width: 6, height: 8)

        // No line wrapping for code.
        textView.isHorizontallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                  height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                                       height: CGFloat.greatestFiniteMagnitude)

        textView.string = text
        textView.delegate = context.coordinator
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.text = $text
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}
