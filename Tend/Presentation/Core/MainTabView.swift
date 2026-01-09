//
//  MainTabView.swift
//  Tend
//
//  Main tab navigation container for the app.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: Tab = .core

    enum Tab {
        case core
        case progress
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CoreView()
                .tabItem {
                    Label("Core", systemImage: selectedTab == .core ? "flame.fill" : "flame")
                }
                .tag(Tab.core)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: selectedTab == .progress ? "chart.bar.fill" : "chart.bar")
                }
                .tag(Tab.progress)
        }
        .tint(Color("AccentPrimary"))
    }
}

#Preview {
    MainTabView()
}
