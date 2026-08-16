# Sprint 1 - MVP Skeleton Prompt

## Scope
- SwiftData migration from CoreData template.
- App shell: onboarding + custom tab navigation.
- Tier 1 components: `NCard`, `NButton`, `NProgressRing`, `NScoreGauge`, `NTabBar`, `NToast`, `NSkeletonView`.
- Feature root views: Dashboard, Plan, Coach, Insights, Profile, Settings.
- Mock data provider + repository protocol wiring.
- HealthKit contract and mock manager.

## Out of Scope
- Full animation polish and all Tier 2 components.
- Real API integration.
- Production chart analytics models beyond mocks.

## Definition of Done
- Compiles for iOS 17+
- Root flows are navigable
- Offline toast shown when disconnected
- Formula utilities implemented:
  - `MindFitnessCalculator`
  - `XPFormula`
  - `StreakPolicy`
  - `SafetyKeywordDetector`
- Every root feature has a functional preview
