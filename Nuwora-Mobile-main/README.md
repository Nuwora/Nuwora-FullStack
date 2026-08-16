<p align="center">
  <img src="docs/assets/nuwora-banner.png" alt="Nuwora banner" width="100%" />
</p>

<h1 align="center">Nuwora Mobile</h1>
<p align="center"><strong>AI-powered mental resilience and cognitive fitness experience for iOS.</strong></p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift" />
  <img src="https://img.shields.io/badge/iOS-17%2B-0A84FF?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 17+" />
  <img src="https://img.shields.io/badge/SwiftUI-Declarative_UI-0A84FF?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/SwiftData-Local_First-5E5CE6?style=for-the-badge&logo=apple&logoColor=white" alt="SwiftData" />
  <img src="https://img.shields.io/badge/MVVM-Frontend_Architecture-34A853?style=for-the-badge" alt="MVVM" />
  <img src="https://img.shields.io/badge/HealthKit-Planned_Integration-2C2C2E?style=for-the-badge&logo=apple&logoColor=white" alt="HealthKit planned" />
  <img src="https://img.shields.io/badge/CoreML-Planned_Integration-111111?style=for-the-badge&logo=apple&logoColor=white" alt="CoreML planned" />
</p>

## Overview
Nuwora Mobile is a frontend-first iOS app designed as a daily Mind Gym. It helps users train focus, regulate stress, and build cognitive resilience through a premium, dark, high-contrast UI with guided flows.

This repository currently focuses on product experience and interface quality:
- Polished SwiftUI screens with a shared design system
- Persona-based AI Coach chat experience
- Daily score, monitoring cards, and guided action prompts
- Trend and insight storytelling with visual hierarchy
- Fast local iteration using mock repositories

## Key Experience Highlights
- Three coach personas with clear visual identity: `Zen Monk` (calm grounding), `Peak Performer` (high-energy focus), `Neuroscientist` (analytical clarity)
- Dark and light mode home experience with consistent layout hierarchy
- Real-time monitoring cards (HRV, focus, distraction signals) for quick status scanning
- Weekly insight summaries and trend graph storytelling for behavior feedback loops
- Gamified profile layer (streaks, achievements, leaderboard) to reinforce consistency
- Lightweight, responsive transitions and loading states for a smooth UI feel

## Screenshots

### Home Screen: Dark vs Light
<p align="center">
  <img src="docs/assets/home-dark.png" alt="Nuwora Home screen dark mode" width="45%" />
  <img src="docs/assets/home-light.png" alt="Nuwora Home screen light mode" width="45%" />
</p>

### AI Coach Personas
<p align="center">
  <img src="docs/assets/coach-zen.png" alt="Zen Monk coach persona screen" width="30%" />
  <img src="docs/assets/coach-peak-performer.png" alt="Peak Performer coach persona screen" width="30%" />
  <img src="docs/assets/coach-neuroscientist.png" alt="Neuroscientist coach persona screen" width="30%" />
</p>

### Additional Screens
<p align="center">
  <img src="docs/assets/insights-screen.png" alt="Nuwora Insights screen" width="45%" />
  <img src="docs/assets/profile-screen.png" alt="Nuwora Profile screen" width="45%" />
</p>

## Frontend Architecture
The app is organized with a clean, UI-first MVVM structure. Data access is protocol-driven so UI flows are stable while backend integrations are still in progress.

```mermaid
flowchart LR
    A["SwiftUI Screens"] --> B["Feature ViewModels (@Observable)"]
    B --> C["Domain Models"]
    B --> D["Repository Protocols"]
    D --> E["Mock Repositories"]
    D --> F["HTTP Remote Data Sources"]
    B --> G["Core Theme + Reusable Components"]
    F --> H["Node.js REST API"]
    D -. "Cache foundation" .-> I["SwiftData Schema"]
```

### Core UI Components
- `NCard`: Shared surface container with border, glow accents, and consistent corner radius for feature blocks
- `NButton`: Unified primary/secondary/ghost button styles aligned with Nuwora visual language
- `NScoreGauge`: Circular mind-score presentation used for high-visibility daily status
- `NProgressRing`: Reusable progress primitive powering score and completion visuals
- `NSkeletonView`: Loading placeholder system for graceful data wait states
- `NToast`: Non-blocking feedback component for info/warning/success events
- `NSceneBackground`: Adaptive layered background system per app scene/tab context
- `MainTabView`: Persistent tab navigation shell with custom styling behavior across sections

### Notable Product Mechanics (Frontend)
- Persona-driven chat theming dynamically recolors coach context and conversation surfaces
- Prompt chips provide low-friction conversation starters inside coach flow
- Safety keyword banner support for sensitive user intent patterns
- Local-first mock data architecture to keep UI development deterministic and fast
- Feature-level `@Observable` view models for predictable screen state and rendering

### Project Layers
- `App/`: App entry, navigation shell, app-level state
- `Features/`: Screen modules (`Home`, `Coach`, `Plan`, `Insights`, `Profile`, `Onboarding`)
- `Components/`: Shared UI building blocks (`NCard`, `NButton`, gauges, skeletons, etc.)
- `Core/`: Theme tokens, background system, utilities
- `Data/`: Models, repositories, mock providers, local persistence setup

## Current Scope
This codebase is currently **frontend-focused**:
- Primary focus is UI, interaction quality, and architecture foundations
- API/LLM production wiring is intentionally not part of this phase
- Mock and local data paths keep iteration fast and deterministic
- The shared Xcode scheme enables `NUWORA_APP_ENV=staging-ready` and connects real repository adapters to `http://127.0.0.1:3000/v1`
- Anonymous API sessions are created automatically and the access token is stored in Keychain
- The exact backend contract is documented in `docs/backend_api_contract.md`

## Run Locally
1. Open `Nuwora Mobile.xcodeproj` in Xcode.
2. Select scheme `Nuwora Mobile`.
3. Run on an iOS Simulator.

The shared scheme expects the local backend at `http://127.0.0.1:3000/v1`. To temporarily run only mock data, disable the `NUWORA_APP_ENV` environment variable in the scheme or set it to `mock`.

Backend handoff:

- API contract: `docs/backend_api_contract.md`
- Claude Code implementation prompt: `docs/CLAUDE_CODE_BACKEND_PROMPT.md`

Build check:

```bash
xcodebuild -project "Nuwora Mobile.xcodeproj" -scheme "Nuwora Mobile" -destination "generic/platform=iOS" build
```

Sandbox-safe local build command:

```bash
./scripts/local_build.sh
```

Sandbox-safe local tests command:

```bash
./scripts/local_test.sh
```

Optional simulator override:

```bash
NUWORA_TEST_DESTINATION="platform=iOS Simulator,name=iPhone 17" ./scripts/local_test.sh
```

## Known Local CI Limitation
- In some local/sandbox environments, `CoreSimulatorService` may be unavailable, which can break simulator-only steps like asset compilation for `iphonesimulator`.
- Use `./scripts/local_build.sh` to validate non-simulator compile paths with local `DerivedData`.
- If simulator runtimes are unavailable, treat simulator smoke tests as blocked by environment and run them as soon as runtime services recover.
- Use `docs/qa_smoke_checklist.md` as the manual regression checklist once simulator services recover.

## Product Direction
- Expand coach intelligence with production AI services
- Connect wearables and behavioral signals via HealthKit
- Add adaptive recommendations based on longitudinal trends
- Keep elevating visual craft across every user flow

---

<p align="center">
  <img src="docs/assets/nuwora-logo.png" alt="Nuwora logo" width="96" />
</p>
<p align="center"><strong>Train calm. Build focus. Stay resilient.</strong><br/>Nuwora is your daily practice space for a stronger mind.</p>
