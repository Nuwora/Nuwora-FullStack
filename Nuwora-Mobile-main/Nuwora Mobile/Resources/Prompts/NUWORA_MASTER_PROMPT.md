# NUWORA Master Prompt (Sprint-Oriented)

## Goal
Build the iOS frontend for Nuwora using MVVM + reducer-light patterns, SwiftData offline-first persistence, and mock-first repositories.

## Architecture Rules
- Keep domain model names stable.
- Each feature must expose loading/empty/error states.
- Each feature root must provide `#Preview` with mock injection.
- No real backend calls in Sprint 1.

## Public Contracts
- Routing: `AppRoute`, `TabItem`, `FeatureState`.
- Repositories: `DashboardRepository`, `PlanRepository`, `CoachRepository`, `AnalyticsRepository`, `ProfileRepository`.
- Health: `HealthKitManaging` with real request API + mock fallback.
- Sync: `CacheSyncing` for reconnect-triggered background sync.
- Tokens: `DesignTokens` is the single source of visual constants.

## Quality Gate
- App launch smoke
- Tab navigation smoke
- Onboarding in/out smoke
- Offline toast smoke
- Domain-rule tests for score/xp/streak/safety logic
