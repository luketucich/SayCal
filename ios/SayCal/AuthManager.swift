import Foundation
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    
    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user
                self.isLoading = false
                
                if let session = state.session {
                    print("User authenticated: \(session.user.id)")
                } else {
                    print("User not authenticated")
                }
            }
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            print("Sign out successful")
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
}
