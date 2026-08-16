import SwiftUI

extension CoachPersona {
    var accentColor: Color {
        switch self {
        case .aria: return .coachZenMonk
        case .max: return .coachPeakPerformer
        case .zen: return .coachNeuroscientist
        }
    }

    var surfaceColor: Color {
        switch self {
        case .aria: return .coachZenMonkSurface
        case .max: return .coachPeakPerformerSurface
        case .zen: return .coachNeuroscientistSurface
        }
    }

    var selectionGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.32), accentColor.opacity(0.14)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var ringColor: Color {
        accentColor.opacity(0.42)
    }

    var sendButtonColor: Color {
        accentColor
    }
}

extension ExerciseType {
    var color: Color {
        switch self {
        case .breathing: return .colorTeal
        case .cognitive: return .colorPurple
        case .mindfulness: return .colorGreen
        case .focus: return .colorTeal
        case .journaling: return .colorPurple
        }
    }
}

extension MoodOption {
    var color: Color {
        switch self {
        case .awful: return .colorRose
        case .bad: return .colorAmber
        case .neutral: return .gray
        case .good: return .colorTeal
        case .great: return .colorGreen
        }
    }
}
