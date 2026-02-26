import SwiftUI

@main
struct PathFindMobileApp: App {
  @State private var authStore = AuthStore()

  var body: some Scene {
    WindowGroup {
      Group {
        if authStore.isAuthenticated {
          MainTabView()
        } else {
          SetupView()
        }
      }
      .environment(authStore)
      .preferredColorScheme(.dark)
    }
  }
}
