## Iraqi Exam Prep Backend

TypeScript + Express + Prisma backend tailored for the Iraqi Exam Prep Flutter app. It mirrors every client workflow (auth, activation, subject gating, exam runs, result delivery) with clean layered architecture, strong validation, security hardening, and production-ready tooling.

### Stack & Architecture
- **Language/Runtime:** Node.js 20, TypeScript, ts-node-dev (dev), compiled output under `dist/`.
- **Framework:** Express with feature modules (`modules/*`) split into controllers → services → Prisma repositories.
- **Database:** PostgreSQL via Prisma ORM (see `prisma/schema.prisma`). SQL fits the relational domain (users ↔ attempts ↔ results) and is battle-tested for reporting and transactions. Prisma handles migrations and type-safe queries.
- **Auth:** JWT (access + refresh). Access tokens power API calls (`Authorization: Bearer <token>`), refresh tokens are hashed and persisted for rotation.
- **Security:** Helmet, CORS allow list, compression, central rate limiters, auth-specific limiter, bcrypt hashing, request validation (Zod), centralized error handling, Prisma-level injection safety, and extensive logging via Pino + Morgan + custom request logger.
- **Scalability:** Stateless HTTP workers, connection pooling, background job scaffolding (`jobs/`, `queues/`), seed script support, and Docker-based deployment. Observability wired through Pino logs and structured auditing.

### Project Layout
```
src/
  app.ts                # Express app + middleware
  server.ts             # Bootstrap & graceful shutdown
  config/               # env + logger
  middlewares/          # auth, rate limit, validation, error handler, logging
  utils/                # jwt/password helpers, response helpers, AppError, subject normalization
  modules/
    shared/prisma.ts    # Prisma singleton
    auth/               # DTOs, controllers, services, routes
    activation/         # Activation code validation + status
    exams/              # Question retrieval, grading, result listing
  docs/                 # Reserved for API specs/diagrams
prisma/
  schema.prisma         # Database schema (users, activation codes, questions, attempts, results…)
  migrations/           # Generated via Prisma migrate
```

### Database Schema Snapshot
| Table | Highlights |
|-------|------------|
| `User` | `id`, `email`, `passwordHash`, `name`, `phone`, `role (ADMIN/STUDENT)`, `isPremium`, `premiumUntil`, `unlockedSubjects` (`Subject[]`), `freeAttempts` JSON, timestamps. |
| `ActivationCode` | Unique `code`, `subjects` array, `unlockAll`, `maxUses`, `uses`, `expiresAt`, `status`, relations to creator/redeemer. |
| `ExamQuestion` | `subject`, `questionText`, `options` (text[]), `correctAnswer` index, `explanation`, `difficulty`, `isActive`. |
| `ExamAttempt` | `userId`, `subject`, raw `answers` JSON, free-attempt flag, timestamps. |
| `ExamResult` | Stats + pass/fail computed from attempt, linked via `attemptId`. |
| `RefreshToken` | Hashed token, device metadata, expiry, revoked flag. |
| `AuditLog` | Actor, action, payload for future admin observability. |

> **ERD:** User 1—* ExamAttempt 1—1 ExamResult, User 1—* RefreshToken, User 1—* ActivationCode (creator) plus redemption link, Questions referenced per subject, Activation codes unlock Premium/subjects.

### API Surface
All endpoints are versioned under `/api/v1`.

| Method | Endpoint | Description | Notes |
|--------|----------|-------------|-------|
| POST | `/auth/register` | Create student, hash password, unlock Arabic subject, issue tokens | Body `{ name, email, password, phone? }` |
| POST | `/auth/login` | Authenticate & return `{ token, refreshToken, user }` | Rate limited |
| POST | `/auth/refresh` | Swap refresh token for new access/refresh pair | Revokes used token |
| GET | `/auth/me` | Returns current user profile | Requires bearer token |
| POST | `/auth/logout` | Revokes refresh token (best-effort) | Body `{ refreshToken }` |
| GET | `/activation/status` | Returns `{ isPremium, unlockedSubjects, premiumUntil }` | Auth required |
| POST | `/activation/validate` | Redeems activation code, sets premium/unlocks subjects | Body `{ code }` |
| GET | `/exams/:subject/questions` | Fetches 50 active questions for subject | Guards premium access |
| POST | `/exams/:subject/submit` | Grades answers, persists attempt+result | Body `{ answers: { [questionId]: optionIndex } }` |
| GET | `/exams/results/list?limit=10` | Lists latest results for dashboard | Auth required |
| POST | `/admin/questions` | Create a question for any subject | ADMIN only, validates options + correct answer |
| GET | `/admin/questions?subject=ARABIC&limit=25` | List latest questions (optional subject filter) | ADMIN only |
| GET | `/healthz` | Simple health probe | No auth |

**JSON response format**
```jsonc
// Success wrapper
{
  "success": true,
  "data": { ... },
  "meta": { "count": 50 }
}

// Error wrapper
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Password must be at least 6 characters",
    "details": [...]
  }
}
```

### Frontend Integration Notes
1. **Base URL:** Update `AppConstants.baseUrl` in Flutter to match your deployment (e.g., `https://api.example.com/api/v1`). All mobile requests already match backend routes (`/auth/login`, `/activation/status`, `/exams/:subject/questions` …).
2. **Headers:** Continue passing bearer token via `Authorization`. The backend injects tokens in `DioClient` through secure storage.
3. **Activation flow:** After `POST /activation/validate`, call `/auth/me` or reuse the response to refresh `AuthBloc` so `user.isPremium` updates UI cards.
4. **Exam flow:** Submit payload matches Flutter’s `Map<String, int>`. The backend returns `result` with `score`, `totalQuestions`, `percentage`, mirroring what `ExamResultPage` expects.
5. **Error handling:** Use Dio’s `DioException` data (`error.response?.data['error']['message']`) to show toasts. The backend always includes friendly `message` text.
6. **Admin tools:** `/admin/questions` endpoints now let staff seed/maintain the exam bank. The Flutter admin panel consumes the same APIs.

### Environment Variables
| Variable | Description |
|----------|-------------|
| `PORT` | HTTP port (default 3000) |
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_ACCESS_SECRET` | Access token HMAC secret |
| `JWT_REFRESH_SECRET` | Refresh token secret |
| `ACCESS_TOKEN_TTL` | Access token lifetime (e.g., `15m`) |
| `REFRESH_TOKEN_TTL` | Refresh token lifetime (`14d`) |
| `BCRYPT_SALT_ROUNDS` | Password hashing cost (integer) |
| `RATE_LIMIT_WINDOW` | Global limiter window in ms |
| `RATE_LIMIT_MAX` | Max requests per window |
| `CLIENT_BASE_URL` | Allowed origins (comma-separated) |
| `ADMIN_EMAIL` | Default admin username (seed script) |
| `ADMIN_PASSWORD` | Default admin password (seed script) |
| `ADMIN_NAME` | Display name for seeded admin |

### Local Development
```bash
pnpm install           # or npm install
npx prisma migrate dev # apply migrations (configure DATABASE_URL first)
npm run dev            # start ts-node-dev server
```

### Admin account bootstrap
Run the helper once after configuring your `.env`:
```bash
npm run seed:admin
```
The script will create (or promote) the user defined by `ADMIN_EMAIL`, `ADMIN_PASSWORD`, and `ADMIN_NAME`, assign the ADMIN role, unlock every subject, and print the credentials in the console. Use this account to access `/api/v1/admin/*` endpoints or the Flutter admin dashboard.

### Testing & Linting
```bash
npm run lint
npm run build          # tsc compile check
# add Jest tests under tests/ (scaffold ready)
```

### Docker Deployment
1. Set environment variables (or mount `.env`) for API container.
2. Sample `docker-compose.yml` to run API + Postgres:
```yaml
version: "3.9"
services:
  api:
    build: .
    ports:
      - "${PORT:-3000}:3000"
    env_file: .env
    depends_on:
      - db
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: iraqi_exam_prep
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```
3. `npm run build && docker build -t iraqi-exam-api .`
4. Run migrations inside the container: `docker compose exec api npx prisma migrate deploy`.
5. Use a process manager (PM2/systemd) or container orchestrator (ECS/K8s) in production. Configure HTTPS (NGINX/ALB) and point Flutter base URL accordingly.

### Deployment Checklist
- [ ] Set secrets in production (.env, secret manager, or orchestrator).
- [ ] Run `npx prisma migrate deploy` & `npx prisma db seed` (seed script forthcoming) to load baseline exam questions + activation codes.
- [ ] Configure monitoring/alerting (Pino logs → ELK/Datadog, health check to uptime monitor).
- [ ] Enforce TLS, WAF/Firewall rules, and database backups (pgBackRest or managed service snapshots).
- [ ] Schedule background jobs for activation expiry notifications or reporting (hooks already scaffolded under `jobs/` and `queues/`).

### API Usage Examples
```bash
# Register
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Sara","email":"sara@example.com","password":"Secret123","phone":"+964"}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sara@example.com","password":"Secret123"}'

# Fetch questions
curl http://localhost:3000/api/v1/exams/english/questions \
  -H "Authorization: Bearer <token>"

# Submit exam
curl -X POST http://localhost:3000/api/v1/exams/english/submit \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"answers":{"q1":2,"q2":0,"q3":1}}'

# Validate activation code
curl -X POST http://localhost:3000/api/v1/activation/validate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"code":"VIP-2025"}'
```

### Future Work
- Build admin dashboards (question CRUD, activation code issue, analytics) using `requireRole([Role.ADMIN])`.
- Add BullMQ workers for scheduled reminders, Telegram/SMS notifications, and data aggregation.
- Implement websocket or SSE channel for real-time exam monitoring if needed.
- Expand automated tests (unit + integration with Supertest) before production rollout.

---
Questions or deployment blockers? Open an issue or ping the backend team—this repo is ready to power the Flutter experience end-to-end.
