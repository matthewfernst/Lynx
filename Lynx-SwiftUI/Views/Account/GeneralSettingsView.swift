//
//  GeneralSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/30/23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.colorScheme) private var systemTheme
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var selectedUnit: MeasurementSystem = .imperial
    private let availableUnits = MeasurementSystem.allCases
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Units", selection: $selectedUnit) {
                        ForEach(availableUnits, id: \.self) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedUnit) { _, newSystem in
                        profileManager.update(measurementSystemWith: newSystem)
                    }
                    .onAppear {
                        if let profileMeasurementSystem = profileManager.profile?.measurementSystem {
                            selectedUnit = profileMeasurementSystem
                        }
                    }
                } footer: {
                    Text("Units changed are local to the Lynx App only and not MountainUI.")
                }
            }
            .navigationTitle("General")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}


