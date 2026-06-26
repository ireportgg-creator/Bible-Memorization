//
//  Bible_MemorizationApp.swift
//  Bible Memorization
//
//  Created by 여경학 on 6/26/26.
//

import SwiftUI
import CoreData

@main
struct Bible_MemorizationApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
