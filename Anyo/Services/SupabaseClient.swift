import Foundation
import Supabase

enum SupabaseConfig {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "https://dpzagqbkbsxemsjfnvhj.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwemFncWJrYnN4ZW1zamZudmhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMDk5MTIsImV4cCI6MjA4ODg4NTkxMn0.07Uq_7g-v-t5yJpm5ypkD2LVYvlBJuNM6h0seto9MsA"
    )
}
