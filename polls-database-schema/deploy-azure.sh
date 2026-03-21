#!/usr/bin/env bash
# =============================================================================
# deploy-azure.sh — Deploy the polls database to Azure Database for PostgreSQL
# =============================================================================
# Provisions an Azure Database for PostgreSQL Flexible Server using the Bicep
# template (main.bicep), then loads the polls schema and sample data.
#
# The script:
#   1. Verifies prerequisites (az CLI, psql)
#   2. Creates the Azure resource group (if it doesn't exist)
#   3. Detects your public IP for the firewall rule
#   4. Deploys main.bicep (server + database + firewall rules)
#   5. Loads the schema (polls-schema.sql)
#   6. Loads the sample data (generate-data.sql)
#
# Usage:
#   ./deploy-azure.sh                                          # interactive
#   AZURE_RESOURCE_GROUP=my-rg POSTGRES_PASSWORD='P@ss1234!' ./deploy-azure.sh
#
# Requirements: az CLI (logged in), psql
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-polls-rg}"
AZURE_LOCATION="${AZURE_LOCATION:-swedencentral}"
SERVER_NAME="${SERVER_NAME:-polls-pg-server}"
ADMIN_LOGIN="${ADMIN_LOGIN:-pgadmin}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_DB="${POSTGRES_DB:-poll}"
POSTGRES_VERSION="${POSTGRES_VERSION:-18}"
SKU_TIER="${SKU_TIER:-Burstable}"
SKU_NAME="${SKU_NAME:-Standard_B1ms}"
STORAGE_SIZE_GB="${STORAGE_SIZE_GB:-32}"
LOAD_SAMPLE_DATA="${LOAD_SAMPLE_DATA:-true}"

# ---------------------------------------------------------------------------
# Resolve paths to local files (relative to this script)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_FILE="${SCRIPT_DIR}/main.bicep"
SCHEMA_FILE="${SCRIPT_DIR}/polls-schema.sql"
DATA_FILE="${SCRIPT_DIR}/generate-data.sql"

for f in "$BICEP_FILE" "$SCHEMA_FILE" "$DATA_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Required file not found: $f" >&2
    exit 1
  fi
done

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
    ip="$(curl -s --max-time 5 "$url" 2>/dev/null | tr -d '[:space:]')" && break
  done
  echo "$ip"
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
log "Checking prerequisites..."
check_command "az"   "Install: https://learn.microsoft.com/cli/azure/install-azure-cli"
check_command "psql" "Install: https://www.postgresql.org/download/"

# Verify the user is logged in
if ! az account show &>/dev/null; then
  die "Not logged in to Azure. Run 'az login' first."
fi

# Prompt for password if not supplied
prompt_password

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
# Deploy Bicep template
# ---------------------------------------------------------------------------
log "Deploying Bicep template (this may take a few minutes)..."

DEPLOYMENT_PARAMS=(
  "serverName=${SERVER_NAME}"
  "administratorLogin=${ADMIN_LOGIN}"
  "administratorLoginPassword=${POSTGRES_PASSWORD}"
  "databaseName=${POSTGRES_DB}"
  "postgresVersion=${POSTGRES_VERSION}"
  "skuTier=${SKU_TIER}"
  "skuName=${SKU_NAME}"
  "storageSizeGB=${STORAGE_SIZE_GB}"
)

if [[ -n "$CLIENT_IP" ]]; then
  DEPLOYMENT_PARAMS+=("firewallClientIpAddress=${CLIENT_IP}")
fi

DEPLOY_OUTPUT="$(az deployment group create \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --template-file "$BICEP_FILE" \
  --parameters "${DEPLOYMENT_PARAMS[@]}" \
  --output json)"

# Extract outputs
FQDN="$(echo "$DEPLOY_OUTPUT" | az query -q "properties.outputs.fqdn.value" --output tsv 2>/dev/null || true)"
if [[ -z "$FQDN" ]]; then
  # Fallback: query the deployment outputs directly
  FQDN="$(az deployment group show \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name main \
    --query "properties.outputs.fqdn.value" \
    --output tsv 2>/dev/null || true)"
fi

if [[ -z "$FQDN" ]]; then
  # Last resort: derive FQDN from server name
  FQDN="${SERVER_NAME}.postgres.database.azure.com"
  warn "Could not read FQDN from deployment outputs. Using derived value: ${FQDN}"
fi

log "Server deployed: ${FQDN}"

# ---------------------------------------------------------------------------
# Load schema
# ---------------------------------------------------------------------------
log "Loading schema into '${POSTGRES_DB}'..."
# Skip the CREATE DATABASE line — Bicep already created the database
grep -v '^CREATE DATABASE' "$SCHEMA_FILE" | \
  PGPASSWORD="$POSTGRES_PASSWORD" psql \
    -h "$FQDN" \
    -p 5432 \
    -U "$ADMIN_LOGIN" \
    -d "$POSTGRES_DB" \
    -v ON_ERROR_STOP=1 \
    --set=sslmode=require

log "Schema loaded successfully."

# ---------------------------------------------------------------------------
# Load sample data
# ---------------------------------------------------------------------------
if [[ "$LOAD_SAMPLE_DATA" == "true" ]]; then
  log "Loading sample data into '${POSTGRES_DB}'..."
  PGPASSWORD="$POSTGRES_PASSWORD" psql \
    -h "$FQDN" \
    -p 5432 \
    -U "$ADMIN_LOGIN" \
    -d "$POSTGRES_DB" \
    -v ON_ERROR_STOP=1 \
    --set=sslmode=require \
    -f "$DATA_FILE"

  log "Sample data loaded successfully."
else
  log "Skipping sample data (LOAD_SAMPLE_DATA=${LOAD_SAMPLE_DATA})."
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log "Deployment complete!"
echo ""
echo "  Resource group : ${AZURE_RESOURCE_GROUP}"
echo "  Server FQDN    : ${FQDN}"
echo "  Port           : 5432"
echo "  Database       : ${POSTGRES_DB}"
echo "  Admin user     : ${ADMIN_LOGIN}"
echo ""
echo "Connect with:"
echo "  psql \"postgresql://${ADMIN_LOGIN}:<password>@${FQDN}:5432/${POSTGRES_DB}?sslmode=require\""
echo ""
echo "To tear down all resources:"
echo "  az group delete --name ${AZURE_RESOURCE_GROUP} --yes --no-wait"
