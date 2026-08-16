process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-only-secret-do-not-use-in-production-env';
process.env.JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1h';
process.env.PORT = process.env.PORT || '3001';
process.env.CORS_ORIGINS = process.env.CORS_ORIGINS || 'http://localhost:3000';
// Integration tests run against a dedicated Postgres schema so they never
// touch data used by local `npm run dev` or Docker Compose.
process.env.DATABASE_URL =
  process.env.TEST_DATABASE_URL ||
  'postgresql://nuwora:nuwora@localhost:5432/nuwora?schema=nuwora_test';
