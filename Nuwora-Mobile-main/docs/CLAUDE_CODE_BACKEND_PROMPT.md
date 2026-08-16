# Claude Code prompt — Nuwora minimal Node.js backend

Copy everything below into Claude Code from the repository root.

---

You are implementing the minimal production-shaped Node.js backend for the existing Nuwora iOS application in this repository.

First inspect the repository, especially:

- `docs/backend_api_contract.md` — this is the source of truth and must be followed exactly.
- `Nuwora Mobile/Core/Network/`
- `Nuwora Mobile/Data/Remote/HTTPRemoteDataSources.swift`
- DTO definitions in `Nuwora Mobile/Data/Repositories/Repositories.swift`

Create the backend in a new top-level `backend/` directory. Do not modify the Swift API contract or Swift files. The iOS shared scheme already targets `http://127.0.0.1:3000/v1`.

Requirements:

1. Use Node.js with TypeScript and a conventional modular REST architecture. Choose a maintained framework you can implement reliably. Use PostgreSQL and an ORM with migrations. Provide Docker Compose for the API and database.
2. Implement every endpoint, request, response, enum, HTTP status and date rule from `docs/backend_api_contract.md` exactly. Do not wrap array responses in `{ data: ... }` because Swift expects direct arrays.
3. Implement anonymous device authentication:
   - `POST /v1/auth/anonymous`
   - same `deviceID` always resolves to the same user
   - return a signed JWT access token
   - protect every other endpoint with Bearer JWT middleware
4. Implement idempotent writes using `(userID, clientMutationID)` uniqueness for mood, complete, skip and coach message mutations. A retry must not duplicate XP, streaks or messages.
5. Create migrations/models for users, auth/device identity, onboarding assessments, exercises, daily user exercises, mood entries, mind fitness scores, chat messages, achievements, user achievements and processed mutations. The leaderboard may be derived from user XP.
6. Seed deterministic demo data:
   - at least five exercises covering valid exercise types
   - at least four achievements
   - enough score history for week/month/three-month charts
   - safe leaderboard aliases
7. Business rules for the minimal version:
   - completing an exercise awards its XP once
   - level is `1 + floor(xp / 500)`
   - streak increases when at least one exercise is completed on a new consecutive UTC day
   - today plan returns 3–5 exercises
   - dashboard composes the latest score, up to three plan exercises, streak, level and XP progress
   - analytics may be deterministic calculations from stored data
   - coach may return a deterministic safe response based on persona; keep the service behind an interface so an LLM provider can be added later
8. Validate all input. Use the standard error body from the contract, always include a generated `requestID`, never expose stack traces, secrets or database details.
9. Add CORS for local development, structured request logging with request IDs, a `/health` endpoint outside `/v1`, graceful shutdown and environment validation.
10. Add `.env.example` containing only placeholders. Never commit secrets. Required variables should include database URL, JWT secret, API port and Node environment.
11. Add automated tests:
    - unit tests for XP, level, streak and idempotency rules
    - integration tests for every endpoint
    - authentication and validation failure tests
    - contract assertions for exact JSON field names and direct-array responses
12. Add `backend/README.md` with exact one-command startup instructions, migrations, seed, test and reset commands. The desired developer experience is:

```bash
cd backend
docker compose up --build
```

After startup, the API must listen at `http://127.0.0.1:3000`, PostgreSQL must be healthy before the API starts, migrations and idempotent seed data must run automatically, and the iOS developer should only need to press Run in Xcode.

Implementation workflow:

- Inspect before editing.
- Write a short plan.
- Implement the backend completely; do not stop after scaffolding.
- Run formatting, linting, type checking, unit tests and integration tests.
- Start Docker Compose and verify `/health` plus the full happy path with real HTTP calls: anonymous auth, onboarding, dashboard, mood, plan, complete, skip, coach, analytics, profile, achievements and leaderboard.
- Fix all failures you encounter.
- At the end report the created architecture, commands run, test results, API URL and any remaining limitations.

Do not add subscriptions, Apple Sign In, HealthKit ingestion, corporate dashboard, Slack/Teams, push notifications, microservices or a real LLM in this task. They are explicitly outside the minimal backend scope.

---
