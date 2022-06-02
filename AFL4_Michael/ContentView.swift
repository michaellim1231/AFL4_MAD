//
//  ContentView.swift
//  AFL4_Michael
//
//  Created by Michael on 02/06/22.
//

import SwiftUI

struct ContentView: View {
    @State var shouldShowOnboarding: Bool = true

    var body: some View {
        NavigationView{
            VStack {
                Text("Main Home")
            }
            .navigationTitle("All Tasks")
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: { OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)

        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
