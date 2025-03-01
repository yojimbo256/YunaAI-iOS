//
//  YunaAIApp.swift
//  YunaAI
//
//  Created by Keith Alexander on 2/28/25.
//

import SwiftUI

@main
struct YunaAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
