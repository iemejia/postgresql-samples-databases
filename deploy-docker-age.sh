#!/usr/bin/env bash
# =============================================================================
# deploy-docker-age.sh — Deploy graph databases to an Apache AGE container
# =============================================================================
# Auto-discovers subdirectories matching *-graph/ that contain a schema.sql
# file and treats each as a graph database.  All graph databases are deployed
# into a single shared Apache AGE container (separate from the relational
# container managed by deploy-docker.sh).
#
# Each *-graph/ subdirectory can contain:
#   schema.sql       — DDL: extension setup, graph creation, vertices (required)
#   data.sql         — DML: edges / relationships (optional)
#
# The database name is derived from the subdirectory name (lowered, hyphens
# replaced with underscores).  e.g. movies-graph → movies_graph
#
# Usage:
#   ./deploy-docker-age.sh                       # deploy all graph databases
#   ./deploy-docker-age.sh movies-graph          # deploy only this one
#   POSTGRES_PASSWORD=secret ./deploy-docker-age.sh
#
# Requirements: docker
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
CONTAINER_NAME="${CONTAINER_NAME:-samples-age-db}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5433}"
POSTGRES_IMAGE="${POSTGRES_IMAGE:-apache/age:latest}"

# ---------------------------------------------------------------------------
# Resolve root directory (relative to this script)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
die()  { echo "ERROR: $*" >&2; exit 1; }

wait_for_pg() {
  local retries=30
  log "Waiting for PostgreSQL (AGE) to accept connections..."
  until docker exec "$CONTAINER_NAME" \
    pg_isready -U "$POSTGRES_USER" -q 2>/dev/null; do
    retries=$((retries - 1))
    if [[ $retries -le 0 ]]; then
      die "PostgreSQL (AGE) did not become ready in time."
    fi
    sleep 1
  done
  log "PostgreSQL (AGE) is ready."
}

# Convert a directory name to a valid PostgreSQL database name
to_db_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}

run_sql_file() {
  local db="$1" file="$2"
  docker exec -i "$CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -d "$db" -v ON_ERROR_STOP=1 < "$file"
}

# ---------------------------------------------------------------------------
# Discover graph databases (*-graph/ directories with schema.sql)
# ---------------------------------------------------------------------------
discover_databases() {
  local dirs=()
  for dir in "$SCRIPT_DIR"/*-graph/; do
    [[ -d "$dir" && -f "${dir}schema.sql" ]] && dirs+=("$(basename "$dir")")
  done

  if [[ ${#dirs[@]} -eq 0 ]]; then
    die "No *-graph/ subdirectories with a schema.sql file found in ${SCRIPT_DIR}."
  fi
  echo "${dirs[@]}"
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
if ! command -v docker &>/dev/null; then
  die "'docker' is required but not installed."
fi

# ---------------------------------------------------------------------------
# Determine which databases to deploy
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  # User specified one or more subdirectories
  TARGET_DIRS=("$@")
  for d in "${TARGET_DIRS[@]}"; do
    if [[ ! -f "${SCRIPT_DIR}/${d}/schema.sql" ]]; then
      die "No schema.sql found in subdirectory '${d}'."
    fi
  done
else
  # Auto-discover
  read -ra TARGET_DIRS <<< "$(discover_databases)"
fi

log "Graph databases to deploy: ${TARGET_DIRS[*]}"

# ---------------------------------------------------------------------------
# Start Apache AGE container
# ---------------------------------------------------------------------------
log "Pulling image ${POSTGRES_IMAGE}..."
docker pull "$POSTGRES_IMAGE"

# Remove any existing container with the same name
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  log "Removing existing container '${CONTAINER_NAME}'..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

# Check if the target port is already in use by another container
BLOCKING_CONTAINER="$(docker ps --format '{{.Names}}' --filter "publish=${POSTGRES_PORT}" | head -n1)"
if [[ -n "$BLOCKING_CONTAINER" ]]; then
  die "Port ${POSTGRES_PORT} is already allocated by container '${BLOCKING_CONTAINER}'. Stop it first with: docker rm -f ${BLOCKING_CONTAINER}"
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

# ---------------------------------------------------------------------------
# Deploy each graph database
# ---------------------------------------------------------------------------
DEPLOYED=()

for dir_name in "${TARGET_DIRS[@]}"; do
  DB_NAME="$(to_db_name "$dir_name")"
  SCHEMA_FILE="${SCRIPT_DIR}/${dir_name}/schema.sql"
  DATA_FILE="${SCRIPT_DIR}/${dir_name}/data.sql"

  log "--- Deploying graph database '${DB_NAME}' from '${dir_name}/' ---"

  # Create the database (skip if it already exists)
  log "Creating database '${DB_NAME}'..."
  docker exec "$CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -tc \
    "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" \
    | grep -q 1 \
    || docker exec "$CONTAINER_NAME" \
      psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${DB_NAME};"

  # Load schema (extension setup, graph creation, vertices)
  log "Loading schema into '${DB_NAME}'..."
  run_sql_file "$DB_NAME" "$SCHEMA_FILE"

  # Load edges / relationships if present
  if [[ -f "$DATA_FILE" ]]; then
    log "Loading graph data (edges) into '${DB_NAME}'..."
    run_sql_file "$DB_NAME" "$DATA_FILE"
  else
    log "No data.sql found for '${dir_name}/' — skipping edge data."
  fi

  DEPLOYED+=("$DB_NAME")
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log "Done!  ${#DEPLOYED[@]} graph database(s) deployed."
echo ""
echo "  Container : ${CONTAINER_NAME}"
echo "  Host      : localhost:${POSTGRES_PORT}"
echo "  User      : ${POSTGRES_USER}"
echo "  Password  : ${POSTGRES_PASSWORD}"
echo "  Image     : ${POSTGRES_IMAGE}"
echo ""
echo "  Graph databases:"
for db in "${DEPLOYED[@]}"; do
  echo "    - ${db}"
done
echo ""
echo "Connect with:"
echo "  psql -h localhost -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d <database>"
echo ""
echo "Or via Docker:"
echo "  docker exec -it ${CONTAINER_NAME} psql -U ${POSTGRES_USER} -d <database>"
echo ""
echo "Example Cypher query (requires per-session AGE setup):"
echo "  LOAD 'age';"
echo "  SET search_path = ag_catalog, \"\\\$user\", public;"
echo "  SELECT * FROM cypher('movies', \$\$ MATCH (m:Movie) RETURN m.title LIMIT 5 \$\$) AS (title agtype);"
echo ""
echo "To stop and remove the container:"
echo "  docker rm -f ${CONTAINER_NAME}"
