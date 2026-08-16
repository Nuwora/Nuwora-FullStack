import Foundation

enum StreakPolicy {
    static func nextStreak(previousStreak: Int, lastActivity: Date?, currentDate: Date = .now) -> Int {
        guard let lastActivity else { return max(1, previousStreak) }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastActivity), to: Calendar.current.startOfDay(for: currentDate)).day ?? 0
        if days <= 1 {
            return previousStreak + 1
        }
        return days >= 2 ? 1 : previousStreak
    }
}
