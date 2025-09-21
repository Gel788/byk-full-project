import SwiftUI

struct ProfileView_Simple: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var userDataService: UserDataService
    
    private var currentUser: User? {
        authService.currentUser ?? userDataService.getCurrentUser()
    }
    
    var body: some View {
        Group {
            if !authService.isAuthenticated {
                AuthView()
                    .environmentObject(authService)
            } else {
                NavigationView {
                    ProfileView_Optimized()
                        .environmentObject(userDataService)
                }
            }
        }
    }
}

#Preview {
    ProfileView_Simple()
        .environmentObject(AuthService())
        .environmentObject(UserDataService())
}
