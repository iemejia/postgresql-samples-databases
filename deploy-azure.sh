#!/usr/bin/env bash
# =============================================================================
# deploy-azure.sh — Deploy all sample databases to Azure Database for PostgreSQL
# =============================================================================
# Provisions an Azure Database for PostgreSQL Flexible Server using the Bicep
# template (main.bicep), then auto-discovers subdirectories containing a
# schema.sql file and loads each as a separate database on the same server.
#
# Each subdirectory can contain:
#   schema.sql       — DDL (required; the CREATE DATABASE line is skipped)
#   data.sql         — DML / sample data (optional)
#
# The database name is derived from the subdirectory name (lowered, hyphens
# replaced with underscores).
#
# Usage:
#   ./deploy-azure.sh                                          # interactive
#   ./deploy-azure.sh polls                    # single db
#   AZURE_RESOURCE_GROUP=my-rg POSTGRES_PASSWORD='P@ss1234!' ./deploy-azure.sh
#
# Requirements: az CLI (logged in), psql
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-postgresql-samples-rg}"
AZURE_LOCATION="${AZURE_LOCATION:-swedencentral}"
SERVER_NAME="${SERVER_NAME:-samples-pg-server}"
ADMIN_LOGIN="${ADMIN_LOGIN:-pgadmin}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_VERSION="${POSTGRES_VERSION:-18}"
SKU_TIER="${SKU_TIER:-Burstable}"
SKU_NAME="${SKU_NAME:-Standard_B1ms}"
STORAGE_SIZE_GB="${STORAGE_SIZE_GB:-32}"
LOAD_SAMPLE_DATA="${LOAD_SAMPLE_DATA:-true}"

# ---------------------------------------------------------------------------
# Resolve paths (relative to this script)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_FILE="${SCRIPT_DIR}/main.bicep"

if [[ ! -f "$BICEP_FILE" ]]; then
  echo "ERROR: Required file not found: $BICEP_FILE" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
die()  { echo "ERROR: $*" >&2; exit 1; }

check_command() {
  if ! command -v "$1" &>/dev/null; then
    die "'$1' is required but not installed. $2"
  fi
}

prompt_password() {
  while [[ -z "${POSTGRES_PASSWORD}" ]]; do
    echo -n "Enter administrator password (min 8 chars, uppercase+lowercase+number/symbol): "
    read -rs POSTGRES_PASSWORD
    echo
    if [[ ${#POSTGRES_PASSWORD} -lt 8 ]]; then
      warn "Password must be at least 8 characters."
      POSTGRES_PASSWORD=""
    fi
  done
}

detect_public_ip() {
  local ip=""
  for url in "https://api.ipify.org" "https://ifconfig.me/ip" "https://checkip.amazonaws.com"; do
    ip="$(curl -s --max-time 5 "$url" 2>/dev/null | tr -d '[:space:]')"
    [[ -n "$ip" ]] && break
  done
  echo "$ip"
}

# Convert a directory name to a valid PostgreSQL database name
to_db_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}

# ---------------------------------------------------------------------------
# Discover databases
# ---------------------------------------------------------------------------
discover_databases() {
  local dirs=()
  for dir in "$SCRIPT_DIR"/*/; do
    local name
    name="$(basename "$dir")"
    # Skip *-graph/ directories — those are graph databases handled separately
    [[ "$name" == *-graph ]] && continue
    [[ -f "${dir}schema.sql" ]] && dirs+=("$name")
  done

  if [[ ${#dirs[@]} -eq 0 ]]; then
    die "No subdirectories with a schema.sql file found in ${SCRIPT_DIR}."
  fi
  echo "${dirs[@]}"
}

discover_graph_databases() {
  local dirs=()
  for dir in "$SCRIPT_DIR"/*-graph/; do
    [[ -d "$dir" && -f "${dir}schema.sql" ]] && dirs+=("$(basename "$dir")")
  done
  echo "${dirs[@]}"
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
log "Checking prerequisites..."
check_command "az"   "Install: https://learn.microsoft.com/cli/azure/install-azure-cli"
check_command "psql" "Install: https://www.postgresql.org/download/"

if ! az account show &>/dev/null; then
  die "Not logged in to Azure. Run 'az login' first."
fi

prompt_password

# ---------------------------------------------------------------------------
# Determine which databases to deploy
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  TARGET_DIRS=("$@")
  for d in "${TARGET_DIRS[@]}"; do
    if [[ ! -f "${SCRIPT_DIR}/${d}/schema.sql" ]]; then
      die "No schema.sql found in subdirectory '${d}'."
    fi
  done
else
  read -ra TARGET_DIRS <<< "$(discover_databases)"
fi

log "Databases to deploy: ${TARGET_DIRS[*]}"

# Build a comma-separated list of database names for the Bicep template
# (The first database is passed as the main databaseName parameter; extras
#  are created via psql after the server is up.)
FIRST_DB_NAME="$(to_db_name "${TARGET_DIRS[0]}")"

# ---------------------------------------------------------------------------
# Detect public IP for firewall rule
# ---------------------------------------------------------------------------
log "Detecting your public IP address..."
CLIENT_IP="$(detect_public_ip)"
if [[ -n "$CLIENT_IP" ]]; then
  log "Detected public IP: ${CLIENT_IP}"
else
  warn "Could not detect public IP. The client firewall rule will be skipped."
  warn "You can add your IP later with:"
  warn "  az postgres flexible-server firewall-rule create \\"
  warn "    --resource-group ${AZURE_RESOURCE_GROUP} --name ${SERVER_NAME} \\"
  warn "    --rule-name AllowClientIp --start-ip-address <IP> --end-ip-address <IP>"
fi

# ---------------------------------------------------------------------------
# Create resource group
# ---------------------------------------------------------------------------
log "Ensuring resource group '${AZURE_RESOURCE_GROUP}' exists in '${AZURE_LOCATION}'..."
az group create \
  --name "$AZURE_RESOURCE_GROUP" \
  --location "$AZURE_LOCATION" \
  --output none

# ---------------------------------------------------------------------------
# Deploy Bicep template (server + first database + firewall rules)
# ---------------------------------------------------------------------------
log "Deploying Bicep template (this may take a few minutes)..."

DEPLOYMENT_PARAMS=(
  "serverName=${SERVER_NAME}"
  "administratorLogin=${ADMIN_LOGIN}"
  "administratorLoginPassword=${POSTGRES_PASSWORD}"
  "databaseName=${FIRST_DB_NAME}"
  "postgresVersion=${POSTGRES_VERSION}"
  "skuTier=${SKU_TIER}"
  "skuName=${SKU_NAME}"
  "storageSizeGB=${STORAGE_SIZE_GB}"
)

if [[ -n "$CLIENT_IP" ]]; then
  DEPLOYMENT_PARAMS+=("firewallClientIpAddress=${CLIENT_IP}")
fi

FQDN="$(az deployment group create \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --template-file "$BICEP_FILE" \
  --parameters "${DEPLOYMENT_PARAMS[@]}" \
  --query "properties.outputs.fqdn.value" \
  --output tsv 2>/dev/null || true)"

# Fallback: query the deployment directly if the inline extraction failed
if [[ -z "$FQDN" ]]; then
  FQDN="$(az deployment group show \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name main \
    --query "properties.outputs.fqdn.value" \
    --output tsv 2>/dev/null || true)"
fi

if [[ -z "$FQDN" ]]; then
  FQDN="${SERVER_NAME}.postgres.database.azure.com"
  warn "Could not read FQDN from deployment outputs. Using derived value: ${FQDN}"
fi

log "Server deployed: ${FQDN}"

# ---------------------------------------------------------------------------
# Deploy each database
# ---------------------------------------------------------------------------
DEPLOYED=()

for dir_name in "${TARGET_DIRS[@]}"; do
  DB_NAME="$(to_db_name "$dir_name")"
  SCHEMA_FILE="${SCRIPT_DIR}/${dir_name}/schema.sql"
  DATA_FILE="${SCRIPT_DIR}/${dir_name}/data.sql"

  log "--- Deploying database '${DB_NAME}' from '${dir_name}/' ---"

  # Create database if it wasn't created by the Bicep template
  if [[ "$DB_NAME" != "$FIRST_DB_NAME" ]]; then
    log "Creating database '${DB_NAME}'..."
    PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
      -h "$FQDN" -p 5432 -U "$ADMIN_LOGIN" \
      -c "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true
  fi

  # Load schema (skip any CREATE DATABASE lines)
  log "Loading schema into '${DB_NAME}'..."
  grep -vi '^CREATE DATABASE' "$SCHEMA_FILE" | \
    PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
      -h "$FQDN" \
      -p 5432 \
      -U "$ADMIN_LOGIN" \
      -d "$DB_NAME" \
      -v ON_ERROR_STOP=1

  # Load sample data if present and enabled
  if [[ "$LOAD_SAMPLE_DATA" == "true" ]] && [[ -f "$DATA_FILE" ]]; then
    log "Loading sample data into '${DB_NAME}'..."
    PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
      -h "$FQDN" \
      -p 5432 \
      -U "$ADMIN_LOGIN" \
      -d "$DB_NAME" \
      -v ON_ERROR_STOP=1 \
      -f "$DATA_FILE"
  elif [[ ! -f "$DATA_FILE" ]]; then
    log "No data.sql found for '${dir_name}/' — skipping sample data."
  else
    log "Skipping sample data (LOAD_SAMPLE_DATA=${LOAD_SAMPLE_DATA})."
  fi

  DEPLOYED+=("$DB_NAME")
done

# ---------------------------------------------------------------------------
# Deploy graph databases (Apache AGE)
# ---------------------------------------------------------------------------
read -ra GRAPH_DIRS <<< "$(discover_graph_databases)"

if [[ ${#GRAPH_DIRS[@]} -gt 0 && -n "${GRAPH_DIRS[0]}" ]]; then
  log "Graph databases discovered: ${GRAPH_DIRS[*]}"
  log "Enabling Apache AGE extension on the server..."

  # Enable the age extension in Azure server parameters
  az postgres flexible-server parameter set \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --server-name "$SERVER_NAME" \
    --name azure.extensions \
    --value age \
    --output none

  az postgres flexible-server parameter set \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --server-name "$SERVER_NAME" \
    --name shared_preload_libraries \
    --value age \
    --output none

  log "Restarting server to apply shared_preload_libraries change..."
  az postgres flexible-server restart \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$SERVER_NAME" \
    --output none

  # Wait for server to come back up
  log "Waiting for server to restart..."
  sleep 30
  retries=20
  while ! PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
    -h "$FQDN" -p 5432 -U "$ADMIN_LOGIN" -c "SELECT 1;" &>/dev/null; do
    retries=$((retries - 1))
    if [[ $retries -le 0 ]]; then
      die "Server did not become ready after restart."
    fi
    sleep 5
  done

  for dir_name in "${GRAPH_DIRS[@]}"; do
    DB_NAME="$(to_db_name "$dir_name")"
    SCHEMA_FILE="${SCRIPT_DIR}/${dir_name}/schema.sql"
    DATA_FILE="${SCRIPT_DIR}/${dir_name}/data.sql"

    log "--- Deploying graph database '${DB_NAME}' from '${dir_name}/' ---"

    # Create database
    log "Creating database '${DB_NAME}'..."
    PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
      -h "$FQDN" -p 5432 -U "$ADMIN_LOGIN" \
      -c "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true

    # Load schema (vertices)
    log "Loading graph schema into '${DB_NAME}'..."
    PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
      -h "$FQDN" \
      -p 5432 \
      -U "$ADMIN_LOGIN" \
      -d "$DB_NAME" \
      -v ON_ERROR_STOP=1 \
      -f "$SCHEMA_FILE"

    # Load edges if present
    if [[ -f "$DATA_FILE" ]]; then
      log "Loading graph data (edges) into '${DB_NAME}'..."
      PGPASSWORD="$POSTGRES_PASSWORD" PGSSLMODE=require psql \
        -h "$FQDN" \
        -p 5432 \
        -U "$ADMIN_LOGIN" \
        -d "$DB_NAME" \
        -v ON_ERROR_STOP=1 \
        -f "$DATA_FILE"
    fi

    DEPLOYED+=("$DB_NAME")
  done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log "Deployment complete!  ${#DEPLOYED[@]} database(s) deployed."
echo ""
echo "  Resource group : ${AZURE_RESOURCE_GROUP}"
echo "  Server FQDN    : ${FQDN}"
echo "  Port           : 5432"
echo "  Admin user     : ${ADMIN_LOGIN}"
echo ""
echo "  Databases:"
for db in "${DEPLOYED[@]}"; do
  echo "    - ${db}"
done
echo ""
echo "Connect with:"
echo "  psql \"postgresql://${ADMIN_LOGIN}:<password>@${FQDN}:5432/<database>?sslmode=require\""
echo ""
echo "To tear down all resources:"
echo "  az group delete --name ${AZURE_RESOURCE_GROUP} --yes --no-wait"
