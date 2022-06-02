//
//  AFL4_MichaelApp.swift
//  AFL4_Michael
//
//  Created by Michael on 02/06/22.
//

import SwiftUI

@main
struct AFL4_MichaelApp: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
