# Nuwora Mobile — Minimal Backend API Contract

This document is the source of truth for the local Node.js backend consumed by the iOS app.

## Transport

- Base URL for the shared Xcode launch scheme: `http://127.0.0.1:3000/v1`
- JSON keys use `camelCase`.
- IDs are UUID strings.
- Dates are UTC RFC3339 strings with milliseconds, for example `2026-08-16T20:10:00.000Z`.
- All routes except `POST /auth/anonymous` require `Authorization: Bearer <accessToken>`.
- Successful write routes return `204 No Content` unless a response body is documented.
- `clientMutationID` is an idempotency key. Repeating the same mutation for the same user must not apply it twice.

## Standard error

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Mood must be between 1 and 5",
    "requestID": "c527cf75-63fe-4c48-a166-3ab92c1fc494"
  }
}
```

Use `400` for validation, `401` for missing/expired authentication, `403` for authorization, `404` for missing records, `409` for conflicts, and `500` for unexpected failures.

## Stable enum values

- Goals: `focus`, `stress_relief`, `memory`, `resilience`
- Exercise types: `breathing`, `cognitive`, `mindfulness`, `focus`, `journaling`
- Coach personas: `zen_monk`, `peak_performer`, `neuroscientist`
- Message sender: `user`, `coach`
- Analytics periods: `week`, `month`, `three_months`
- Wearables: `apple_watch`, `oura`, `fitbit`, `whoop`
- Mood: integer `1...5`

## Endpoints

### POST `/auth/anonymous`

Request:

```json
{ "deviceID": "8D99349D-21F5-46BB-8A6B-8C87ACEE02A5" }
```

Return `200`:

```json
{
  "accessToken": "jwt",
  "user": {
    "id": "e2921d8f-263f-4e72-aad8-7d5d88ac74c8",
    "isNewUser": true
  }
}
```

Calling this route again with the same `deviceID` must return the same user.

### POST `/onboarding`

```json
{
  "name": "Maya",
  "age": 29,
  "primaryGoals": ["focus", "stress_relief"],
  "assessmentAnswers": [3, 4, 5, 2, 4],
  "connectedWearables": ["apple_watch"],
  "initialScores": {
    "overall": 72,
    "cognitive": 80,
    "biometric": 65,
    "mood": 71
  }
}
```

Return `204`. Treat a repeated call as an update.

### GET `/dashboard`

Return `200` with one object:

```json
{
  "score": {
    "id": "b1277b55-010b-4af0-b0ba-ce43dac07627",
    "date": "2026-08-16T00:00:00.000Z",
    "overallScore": 72,
    "cognitiveScore": 70,
    "biometricScore": 75,
    "moodScore": 71,
    "focusSubscore": 74,
    "calmSubscore": 69,
    "energySubscore": 73
  },
  "planPreview": [],
  "streakCount": 3,
  "currentLevel": 2,
  "xpProgress": 0.62,
  "aiInsight": "Complete one short focus session to keep your momentum.",
  "lastSyncDate": "2026-08-16T20:10:00.000Z"
}
```

`planPreview` contains up to three exercise objects in the same shape returned by `/plans/today`. `xpProgress` is in `0...1`.

### POST `/moods`

```json
{
  "mood": 4,
  "occurredAt": "2026-08-16T20:10:00.000Z",
  "clientMutationID": "721f9644-35ec-48c4-866c-36803b54ddad"
}
```

Return `204`.

### GET `/plans/today`

Return `200` with a direct JSON array:

```json
[
  {
    "id": "e4eb0b15-fc4e-4233-a3e0-54fddc9f34cf",
    "title": "Breathing Reset",
    "subtitle": "2-minute downshift",
    "type": "breathing",
    "durationSeconds": 120,
    "difficulty": 2,
    "xpReward": 60,
    "isCompleted": false
  }
]
```

### POST `/exercises/:id/complete`

```json
{
  "performance": 0.86,
  "completedAt": "2026-08-16T20:10:00.000Z",
  "clientMutationID": "f5da437c-52f1-42a9-bc6b-dae7f16b5fae"
}
```

Return `204`. Performance is `0...1`. Award XP and update streak exactly once per mutation ID.

### POST `/exercises/:id/skip`

```json
{
  "skippedAt": "2026-08-16T20:10:00.000Z",
  "clientMutationID": "5df986f6-a05c-4b92-a7b3-603a104a5294"
}
```

Return `204`.

### GET `/coach/messages?limit=100&cursor=<optional>`

Return `200` with a direct array ordered oldest to newest:

```json
[
  {
    "id": "a2e32ab8-b093-499f-ac64-f8a0d189e77d",
    "content": "Let's take one slow breath.",
    "sender": "coach",
    "timestamp": "2026-08-16T20:10:00.000Z"
  }
]
```

### POST `/coach/messages`

```json
{
  "content": "I need help focusing",
  "persona": "zen_monk",
  "clientMutationID": "f0fe67ee-3ff8-4455-b86f-72ae614391dc"
}
```

Persist both the user message and coach reply. Return `200` with the coach message object shown above. A deterministic persona-based reply is acceptable for the minimal backend; an LLM is optional.

### GET `/analytics/scores?period=week&page=<optional>`

Return `200` with a direct array of score objects using the dashboard `score` shape. Period accepts `week`, `month`, or `three_months`.

### GET `/analytics/correlations`

Return `200`:

```json
[
  {
    "id": "4a0d7df9-654e-4f9d-b2d7-44a7dfb38eee",
    "title": "Breathing -> Lower stress",
    "description": "Mood volatility decreases after breathwork sessions.",
    "strength": 0.61
  }
]
```

`strength` is in `0...1`.

### GET `/analytics/weekly-summary`

Return `200`:

```json
{ "summary": "Your consistency improved this week. Keep sessions short and frequent." }
```

### GET `/me`

Return `200`:

```json
{
  "id": "e2921d8f-263f-4e72-aad8-7d5d88ac74c8",
  "name": "Maya",
  "age": 29,
  "primaryGoals": ["Focus", "Stress Relief"],
  "joinedAt": "2026-08-16T20:10:00.000Z",
  "currentLevel": 2,
  "currentStreak": 3
}
```

Important: `primaryGoals` on this response uses the current Swift domain labels: `Focus`, `Stress Relief`, `Memory`, `Resilience`.

### GET `/me/achievements`

Return `200` with a direct array:

```json
[
  {
    "id": "3400ba6f-dc9c-48fa-8cd4-e2871ce01541",
    "title": "First Step",
    "description": "Complete your first exercise.",
    "iconName": "figure.walk",
    "unlockedAt": "2026-08-16T20:10:00.000Z"
  }
]
```

`unlockedAt` may be `null`.

### GET `/leaderboard?limit=3`

Return `200` with a direct array:

```json
[
  {
    "id": "e2921d8f-263f-4e72-aad8-7d5d88ac74c8",
    "rank": 1,
    "alias": "MindfulMaya",
    "score": 1480
  }
]
```

## Definition of done

The backend is compatible when the shared `Nuwora Mobile` Xcode scheme can run against port 3000 and complete onboarding, dashboard loading, mood logging, plan completion/skipping, coach messaging, analytics loading, profile loading, achievements, and leaderboard without changes to Swift files.
