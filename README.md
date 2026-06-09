# wallet-live

Rust web application for listing financial assets, registering users, and simulating asset purchases. The project combines a JSON API for asset management with a server-rendered web interface.

## What it does

- exposes an API under `/api/assets` to list, create, and update assets;
- provides a web interface with login, logout, and an assets page;
- automatically registers users on first login if the username does not exist;
- stores each user's purchases and shows their aggregated history.

## Stack

- `axum` for HTTP and routing
- `askama` for server-rendered HTML templates
- `sqlx` with PostgreSQL for persistence
- `jwt-simple` for cookie-based token authentication
- `password-auth` for password hashing and validation
- `tokio` as the async runtime

## Architecture

The application follows a simple layered structure:

- `src/main.rs`: entry point.
- `src/app.rs`: initializes tracing, loads environment variables, opens the PostgreSQL connection, and builds the router.
- `src/routes/api.rs`: JSON endpoints for assets.
- `src/routes/frontend.rs`: HTML pages, login/logout, and asset purchase flow.
- `src/auth/`: authentication extractors for regular users and admin.
- `src/repository.rs`: data access layer and SQL queries.
- `src/models.rs`: serializable structs used by the API and views.
- `src/error.rs`: application errors and HTTP response mapping.
- `templates/`: Askama views.
- `migrations/`: schema and seed data.

### Main flow

1. The app starts on port `3000`.
2. `AppState` shares the PostgreSQL pool with the routes.
3. Frontend routes use the `token` cookie to identify the authenticated user.
4. If a user tries to log in and does not exist yet, the account is created automatically.
5. API administration routes require the `Authorization` header with the admin secret currently defined in code.

## Endpoints and screens

### Frontend

- `GET /`: redirects to `/assets` or `/login`.
- `GET /login`: shows the login form.
- `POST /login`: authenticates or registers a user and creates the session cookie.
- `GET /logout`: removes the session cookie.
- `GET /assets`: shows available assets and assets owned by the user.
- `POST /assets`: records an asset purchase.

### API

- `GET /api/assets`: lists all assets.
- `POST /api/assets`: creates an asset. Requires admin.
- `PATCH /api/assets`: updates an asset. Requires admin.

## Database

The migrations create three main tables:

- `users`: registered users with hashed passwords.
- `assets`: catalog of available assets.
- `owned_assets`: purchases made by each user.

There is also a seed migration with initial assets such as Bitcoin and Ethereum.

## Running the project

### Requirements

- Rust toolchain
- PostgreSQL available locally, or Docker Compose

### Start PostgreSQL with Docker

```bash
docker compose up -d
```

The `compose.yml` file exposes PostgreSQL on `localhost:5432` with the credentials.

### Environment variable

The application expects:

```env
DATABASE_URL=postgres://postgres:postgres@localhost:5432/postgres
```

### Migrations

If you use `sqlx-cli`, you can apply migrations with:

```bash
sqlx migrate run
```

### Run the app

```bash
cargo run
```

Then open `http://localhost:3000`.

## Authentication

- User sessions use a JWT stored in an HTTP-only cookie named `token`.
- The current token expires after 10 minutes.
- The user secret and admin secret are hardcoded in the current project, so they should be moved to environment variables in a future iteration.

## Notes

- The API and frontend share the same data repository and connection pool.
- There are tests in `src/routes/api.rs` using `sqlx::test` and SQL fixtures.
- The project is suitable for learning or prototyping; before production, secrets should be externalized, validations tightened, and configuration better separated.