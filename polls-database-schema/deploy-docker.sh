#!/usr/bin/env bash
# =============================================================================
# deploy-docker.sh — Spin up a PostgreSQL container with the polls schema and sample data
# =============================================================================
# Uses the official postgres:17 Docker image.  The script:
#   1. Removes any previous container with the same name
#   2. Starts a new container
#   3. Waits for PostgreSQL to become ready
#   4. Creates the "poll" database
#   5. Loads the schema (tables, sequences, indexes, constraints)
#   6. Loads the sample data
#
# Usage:
#   ./deploy-docker.sh                  # uses defaults
#   POSTGRES_PASSWORD=secret POSTGRES_PORT=5433 ./deploy-docker.sh   # override
#
# Requirements: docker
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
CONTAINER_NAME="${CONTAINER_NAME:-polls-db}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DB="${POSTGRES_DB:-poll}"
POSTGRES_IMAGE="${POSTGRES_IMAGE:-postgres:18}"

# ---------------------------------------------------------------------------
# Resolve paths to SQL files (relative to this script)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="${SCRIPT_DIR}/polls-schema.sql"
DATA_FILE="${SCRIPT_DIR}/generate-data.sql"

for f in "$SCHEMA_FILE" "$DATA_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Required file not found: $f" >&2
    exit 1
  fi
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { echo "==> $*"; }

wait_for_pg() {
  local retries=30
  log "Waiting for PostgreSQL to accept connections..."
  until docker exec "$CONTAINER_NAME" \
    pg_isready -U "$POSTGRES_USER" -q 2>/dev/null; do
    retries=$((retries - 1))
    if [[ $retries -le 0 ]]; then
      echo "ERROR: PostgreSQL did not become ready in time." >&2
      exit 1
    fi
    sleep 1
  done
  log "PostgreSQL is ready."
}

run_sql() {
  local db="$1" file="$2"
  docker exec -i "$CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -d "$db" -v ON_ERROR_STOP=1 < "$file"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
log "Pulling image ${POSTGRES_IMAGE}..."
docker pull "$POSTGRES_IMAGE"

# Remove any existing container with the same name
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  log "Removing existing container '${CONTAINER_NAME}'..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

log "Starting container '${CONTAINER_NAME}' on port ${POSTGRES_PORT}..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -p "${POSTGRES_PORT}:5432" \
  "$POSTGRES_IMAGE" \
  >/dev/null

wait_for_pg

# Create the target database (ignore "already exists" errors)
log "Creating database '${POSTGRES_DB}'..."
docker exec "$CONTAINER_NAME" \
  psql -U "$POSTGRES_USER" -tc \
  "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}'" \
  | grep -q 1 \
  || docker exec "$CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${POSTGRES_DB};"

# Load schema (skip the CREATE DATABASE line already in the file)
log "Loading schema into '${POSTGRES_DB}'..."
grep -v '^CREATE DATABASE' "$SCHEMA_FILE" | \
  docker exec -i "$CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1

# Load sample data
log "Loading sample data into '${POSTGRES_DB}'..."
run_sql "$POSTGRES_DB" "$DATA_FILE"

# Print summary
log "Done!  Database '${POSTGRES_DB}' is ready."
echo ""
echo "  Container : ${CONTAINER_NAME}"
echo "  Host      : localhost:${POSTGRES_PORT}"
echo "  Database  : ${POSTGRES_DB}"
echo "  User      : ${POSTGRES_USER}"
echo "  Password  : ${POSTGRES_PASSWORD}"
echo ""
echo "Connect with:"
echo "  psql -h localhost -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
echo ""
echo "Or via Docker:"
echo "  docker exec -it ${CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
echo ""
echo "To stop and remove the container:"
echo "  docker rm -f ${CONTAINER_NAME}"
