# Nuwora Backend

Minimal Node.js/TypeScript backend for the Nuwora iOS app. Implements the API
contract in [`../Nuwora-Mobile-main/docs/backend_api_contract.md`](../Nuwora-Mobile-main/docs/backend_api_contract.md)
exactly: same JSON field names, same enums, same HTTP statuses, same date
format, and direct JSON arrays (never `{ "data": [...] }`).

Stack: Express 4 + TypeScript, PostgreSQL via Prisma ORM (schema + migrations),
Zod validation, JWT bearer auth, Pino structured logging, Vitest + Supertest.

## Authentication

Three ways to get a bearer token, all returning the same shape
(`{ accessToken, user: { id, isNewUser } }`):

- `POST /v1/auth/anonymous` — `{ deviceID }` (from the original contract; same
  device always resolves to the same user)
- `POST /v1/auth/register` — `{ email, password }` (password min 8 chars);
  `409 CONFLICT` if the email is already registered
- `POST /v1/auth/login` — `{ email, password }`; `401 UNAUTHORIZED` with a
  generic "Invalid email or password." message for both a wrong password and
  an unknown email (no user-enumeration leak), using a timing-safe dummy hash
  comparison either way

`register`/`login` are additive — outside `docs/backend_api_contract.md`,
which only specifies anonymous device auth — but reuse the same JWT format,
error envelope, and validation conventions as the rest of the API. Passwords
are hashed with bcrypt (`bcryptjs`, 10 salt rounds), never stored or logged
in plaintext.

Every newly created account (anonymous or registered) gets two welcome
messages seeded into its coach chat history, so the Coach tab is never empty
on first open.

## Quick start (Docker Compose — recommended)

```bash
cd backend
docker compose up --build
```

This builds the API image, starts PostgreSQL, waits for Postgres to report
healthy, then automatically runs database migrations and the idempotent seed
before starting the API. Once it's up:

- API: `http://127.0.0.1:3000` (routes under `http://127.0.0.1:3000/v1`, matching the Xcode scheme)
- Health check: `http://127.0.0.1:3000/health`

Press Run in Xcode — no further setup needed. Stop everything with
`docker compose down` (add `-v` to also delete the Postgres volume).

## Local (non-Docker) development

Requires Node.js 20+ and a running PostgreSQL instance.

```bash
cd backend
npm install
cp .env.example .env          # edit DATABASE_URL/JWT_SECRET if needed
npm run prisma:migrate:dev    # creates/updates tables
npm run seed                  # idempotent demo data
npm run dev                   # tsx watch, listens on $PORT (default 3000)
```

## Migrations

```bash
npm run prisma:migrate:dev --name <change_description>   # create + apply a new migration (dev)
npm run prisma:migrate:deploy                             # apply pending migrations (prod/CI, no prompts)
npm run prisma:studio                                      # browse the database
```

## Seed data

```bash
npm run seed
```

Idempotent — safe to run repeatedly. Seeds:

- 5 exercises covering all 5 exercise types (`breathing`, `cognitive`, `mindfulness`, `focus`, `journaling`)
- 4 achievements (`First Step`, `Streak Starter`, `Mood Tracker`, `Level Up`)
- 6 demo leaderboard users with safe, non-identifying aliases (e.g. `ZenFalcon`)
- 90 days of `MindFitnessScore` history for one demo user, covering the `week`/`month`/`three_months` analytics periods

## Tests

```bash
npm run test:unit          # pure logic: XP/level, streak, idempotency, coach responses, aliases — no DB
npm run test:integration   # full HTTP flow against every endpoint — requires PostgreSQL
npm test                   # unit, then integration
```

Integration tests run against a dedicated Postgres **schema** (`nuwora_test`)
on the same server as your dev database, so they never touch `dev` data. They
default to `postgresql://nuwora:nuwora@localhost:5432/nuwora?schema=nuwora_test`;
override with `TEST_DATABASE_URL` if your Postgres runs elsewhere. The
simplest way to get a Postgres instance for tests is the one already defined
in `docker-compose.yml`:

```bash
docker compose up -d postgres
npm run test:integration
```

Integration tests cover every endpoint, auth/validation failure cases,
idempotency (mood, exercise complete/skip, coach messages), and contract
assertions (exact JSON field names, direct-array responses for list
endpoints).

## Code quality

```bash
npm run typecheck
npm run lint
npm run format        # write
npm run format:check  # CI-friendly check
```

## Reset the database

```bash
npm run db:reset       # local: drops, recreates, migrates, and reseeds (prisma migrate reset)
```

For Docker Compose, to fully reset (including the Postgres volume):

```bash
docker compose down -v
docker compose up --build
```

## Logs (Docker Compose)

```bash
docker compose logs -f api          # follow API logs (structured JSON, one line per request)
docker compose logs -f postgres     # follow Postgres logs
docker compose logs --tail=100 api  # last 100 lines
```

## Environment variables

See [`.env.example`](.env.example). Required: `DATABASE_URL`, `JWT_SECRET`
(min 16 characters), `PORT`, `JWT_EXPIRES_IN`, `CORS_ORIGINS`. The process
exits at startup with a descriptive error if any are missing or invalid —
never falls back to defaults for secrets. Docker Compose sets its own values
directly in `docker-compose.yml`, so `.env` is only used for local
(non-Docker) development.

## Architecture

```
src/
  app.ts, index.ts        Express app assembly, graceful shutdown
  env.ts                  Zod-validated environment config
  logger.ts                Pino structured logger
  lib/                     prisma client, JWT signing/verification, AppError, idempotency helper
  middleware/               request ID, bearer auth, zod validation, error handler
  domain/                   pure business rules: xp/level, streak, achievements, coach persona
                             responses (behind a CoachResponder interface — swap in an LLM later
                             without touching routes), leaderboard aliases, dates
  modules/<feature>/        one module per API area (auth, onboarding, dashboard, moods, plans,
                             exercises, coach, analytics, me, leaderboard), each with
                             router.ts + service.ts (+ schema.ts for Zod validation)
prisma/
  schema.prisma            Data model + migrations
  seedCatalog.ts            Shared exercise/achievement seed data (used by seed.ts and tests)
  seed.ts                   Idempotent seed script
tests/
  unit/                     Pure-function tests (no DB)
  integration/               Full HTTP endpoint tests via Supertest (requires PostgreSQL)
```

### Idempotency

Mood check-ins, exercise complete/skip, and coach messages all take a
`clientMutationID`. Each is wrapped in `withIdempotency()`
(`src/lib/idempotency.ts`), which records `(userId, clientMutationID)` in a
`processed_mutations` table inside the same transaction as the mutation's
side effects. A repeated call with the same id short-circuits and replays the
first result — XP, streaks, and chat messages are never duplicated.

### Business rules

- `level = 1 + floor(xp / 500)`
- Streak increments only on the first exercise completed on a new
  consecutive UTC calendar day; same-day repeats are a no-op; a gap resets
  the streak to 1.
- `GET /plans/today` returns 3–5 exercises (the full seeded catalog),
  generated once per UTC day and stable across repeated calls.
- `GET /dashboard` composes the latest `MindFitnessScore`, the first three
  plan items, streak, level, and XP progress in one response.
- Achievements unlock automatically after mood logs and exercise
  completions based on stored stats (completed-exercise count, streak,
  mood-entry count, level).

## Known limitations

- No subscriptions, Sign in with Apple, HealthKit ingestion, corporate
  dashboard, Slack/Teams integration, push notifications, microservices, or
  real LLM — out of scope per the task.
- Coach replies are deterministic (persona-keyed phrase pools), not an LLM;
  `CoachResponder` is an interface specifically so a real provider can be
  substituted later without touching routes.
- Correlation insights (`/analytics/correlations`) are a fixed, deterministic
  set rather than computed from live mood/exercise correlation — acceptable
  for the minimal contract, which only requires deterministic values in
  `0...1`.
- JWT access tokens do not support refresh; a fresh token is minted every
  time `POST /auth/anonymous` is called for a known device, so the iOS
  client's automatic reauthentication-on-401 flow is what keeps sessions
  alive long-term.
