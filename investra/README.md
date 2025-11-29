# Investra - Local Docker Runbook

This Rails app is containerized with Docker Compose. Follow the steps below to bring up the API and its MySQL database locally.

## Prerequisites
- Docker Desktop (or Docker Engine) with the Compose plugin
- Ports 3000 (Rails) and 3307 (MySQL) free on your host
- Run all commands from `investra/`

## One-time build and start
```bash
docker compose up --build
```
- The `web` container installs gems (`bundle install`), prepares the test DB, and starts Rails on port 3000.
- The `db` container seeds MySQL with an `investra` user via `docker-init.sql` and exposes 3307 on your host.
- Logs stream in the foreground. Stop with `Ctrl+C`.

To start in the background:
```bash
docker compose up -d
docker compose logs -f web
```

## Access
- Rails app: http://localhost:3000
- MySQL: host `127.0.0.1`, port `3307`, user `investra`, password `investra`, root password `root`
- Default DB names: `investra_development` (initialized by MySQL) and `investra_test` (used by `db:test:prepare` when the web container boots)

## Default admin (dev/test only)
- Email: `admin@example.com`
- Password: `password`
- Auto-created on boot in development/test via `config/initializers/default_admin.rb`; use it to log in at `/login` and access `/companies`.

## Useful commands
- Stop and clean containers (keep volumes): `docker compose down`
- Reset DB data: `docker compose down -v`
- Run Rails/RSpec inside the app container: `docker compose run --rm web bundle exec rspec`
- Check DB health: `docker compose exec db mysql -uroot -proot -e "SHOW DATABASES;"`

## Market data configuration
- Set `MASSIVE_API_KEY` to use Massive for live quotes. Requests authenticate with `Authorization: Bearer <key>` per the Massive REST Quickstart. Without it, the app falls back to Yahoo Finance.
- Optionally override the base URL (defaults to `https://api.polygon.io`) with `MASSIVE_API_BASE` if your account uses a different Massive endpoint.
- Example for Compose: `MASSIVE_API_KEY=your_key_here docker compose up --build`

## Running tests in Docker
- RSpec (all): `docker compose run --rm web bundle exec rspec`
- Cucumber (all): `docker compose run --rm web bundle exec cucumber`
- Single feature: `docker compose run --rm web bundle exec cucumber features/company_management.feature`
- Note: commands run against the `test` environment/database inside the containers.

## Troubleshooting
- If the web container waits for DB, ensure port 3307 is free and try `docker compose down -v && docker compose up --build`.
- If you change gems, rebuild the image: `docker compose build web`.
