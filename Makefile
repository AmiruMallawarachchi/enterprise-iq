.PHONY: dev dev-infra stop build test migrate shell logs clean

# ── Start everything (infra + API + worker) ──────────────
dev:
	docker compose up --build

# ── Start only infrastructure (DB + Redis + Chroma) ──────
dev-infra:
	docker compose up db redis chromadb -d

# ── Stop all containers ───────────────────────────────────
stop:
	docker compose down

# ── Rebuild images (after requirements.txt changes) ──────
build:
	docker compose build --no-cache

# ── Run database migrations ───────────────────────────────
migrate:
	docker compose exec api alembic upgrade head

# ── Show migration status ─────────────────────────────────
migrate-status:
	docker compose exec api alembic current

# ── Create a new migration ────────────────────────────────
# Usage: make migration name="add_feedback_table"
migration:
	docker compose exec api alembic revision --autogenerate -m "$(name)"

# ── Run all tests ─────────────────────────────────────────
test:
	docker compose exec api pytest tests/ -v

# ── Run tests with coverage ───────────────────────────────
test-cov:
	docker compose exec api pytest tests/ -v --cov=app --cov-report=term-missing

# ── Open a shell inside the API container ────────────────
shell:
	docker compose exec api bash

# ── Follow logs for all services ─────────────────────────
logs:
	docker compose logs -f

# ── Follow logs for one service ───────────────────────────
# Usage: make logs-api | make logs-worker
logs-api:
	docker compose logs -f api

logs-worker:
	docker compose logs -f worker

# ── Wipe all data volumes (fresh start) ──────────────────
clean:
	docker compose down -v
	@echo "⚠️  All volumes deleted. Run 'make dev-infra' to start fresh."

# ── Install backend dev dependencies locally ─────────────
install-dev:
	cd backend && pip install -r requirements-dev.txt

# ── Format code ───────────────────────────────────────────
fmt:
	cd backend && black app/ && ruff check app/ --fix

# ── Type check ────────────────────────────────────────────
typecheck:
	cd backend && mypy app/