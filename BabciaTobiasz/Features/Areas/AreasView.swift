// AreasView.swift
// BabciaTobiasz

import SwiftUI

/// Areas screen uses the Weather layout with a hero image card in place of the weather card.
struct AreasView: View {
    @Bindable var viewModel: WeatherViewModel

    var body: some View {
        WeatherView(
            viewModel: viewModel,
            title: "Areas",
            headerCardBuilder: { _ in
                AnyView(AreasHeroCard())
            }
        )
    }
}

private struct AreasHeroCard: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView(padding: 0) {
            Image("DreamRoom_Test_1200x1600")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: theme.grid.heroCardHeight)
                .clipped()
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}

#Preview {
    AreasView(viewModel: WeatherViewModel())
        .environment(AppDependencies())
}
