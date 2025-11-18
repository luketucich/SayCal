// Supabase client configuration and initialization

import Foundation
import Supabase

struct SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://stzwzlzgroycxpebzkyq.supabase.co")!,
        supabaseKey: "sb_publishable_3jmhHH_JX4KQcT-2i8MpzQ_XtTS9mWC",
        options: .init(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
