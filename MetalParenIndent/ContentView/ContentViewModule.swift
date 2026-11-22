//
//  ContentViewModule.swift
//  MetalParenIndent
//
//  Created by mymin on 11/17/26.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case welcome
    case setup
    case preview

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .welcome: "Welcome"
        case .setup: "Setup"
        case .preview: "Preview"
        }
    }

    var systemImage: String {
        switch self {
        case .welcome: "hand.wave"
        case .setup: "gearshape"
        case .preview: "text.alignleft"
        }
    }
}

struct ContentView: View {
    @State private var selection: SidebarItem? = .welcome

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.systemImage)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
        } detail: {
            switch selection ?? .welcome {
            case .welcome:
                WelcomeView(selection: $selection)
            case .setup:
                SetupView()
            case .preview:
                PreviewView()
            }
        }
    }
}
