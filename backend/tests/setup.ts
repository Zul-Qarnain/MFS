// Vitest global setup.
//
// The CI environment variables are set in .github/workflows/backend.yml.
// For local runs, copy .env.example to .env in the backend/ folder and
// run `docker compose up -d postgres redis` first.

import 'dotenv/config';
