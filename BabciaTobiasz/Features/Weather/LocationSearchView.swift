// LocationSearchView.swift
// BabciaTobiasz

import SwiftUI

struct LocationSearchView: View {
    @Bindable var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
                    }
                } else if !viewModel.searchQuery.isEmpty {
                    Text("No results found")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Button {
                        viewModel.useCurrentLocation()
                        dismiss()
                    } label: {
                        Label("Use Current Location", systemImage: "location.fill")
                    }
                }
            }
            .navigationTitle("Search Location")
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
