import Foundation
import Supabase

struct SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Config.supabaseURL)!,
        supabaseKey: Config.supabaseAnonKey,
        options: .init(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
