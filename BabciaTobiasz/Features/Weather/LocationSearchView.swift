// LocationSearchView.swift
// BabciaTobiasz

import SwiftUI

struct LocationSearchView: View {
    @Bindable var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(style: .weather)
                
                List {
                    if let completions = viewModel.locationService?.completions, !completions.isEmpty {
                        ForEach(completions) { completion in
                            Button {
                                Task {
                                    await viewModel.selectCompletion(completion)
                                    dismiss()
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(completion.title)
                                        .dsFont(.body)
                                        .foregroundStyle(.primary)
                                    if !completion.subtitle.isEmpty {
                                        Text(completion.subtitle)
                                            .dsFont(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    } else if !viewModel.searchQuery.isEmpty {
                        Text("No results found")
                            .dsFont(.body)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.clear)
                    }
                    
                    Section {
                        Button {
                            viewModel.useCurrentLocation()
                            dismiss()
                        } label: {
                            Label {
                                Text("Use Current Location")
                                    .dsFont(.body)
                            } icon: {
                                Image(systemName: "location.fill")
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search Location")
                        .dsFont(.headline, weight: .bold)
                        .lineLimit(1)
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search for a city")
            .onChange(of: viewModel.searchQuery) { _, newValue in
                viewModel.updateSearchQuery(newValue)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
