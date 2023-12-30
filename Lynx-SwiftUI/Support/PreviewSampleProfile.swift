//
//  PreviewSampleProfile.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/15/23.
//

import SwiftData

#if DEBUG
@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Profile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Profile>()).isEmpty {
            modelContext.insert(Profile.debugProfile)
        }
        return container
    } catch {
        fatalError("Failed to create preview model container")
    }
}()
#endif
