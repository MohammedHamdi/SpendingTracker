//
//  SpendingTrackerSwiftUICoreDataLBTAApp.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 09/09/2021.
//

import SwiftUI

@main
struct SpendingTrackerSwiftUICoreDataLBTAApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            MainView()
            DeviceIdiomView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
