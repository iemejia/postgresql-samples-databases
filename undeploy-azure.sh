#!/usr/bin/env bash
# =============================================================================
# undeploy-azure.sh — Remove the sample database resources from Azure
# =============================================================================
# Deletes the Azure resources provisioned by deploy-azure.sh / main.bicep.
#
# By default, deletes the entire resource group (server, databases, firewall
# rules, and the group itself).  Use --server-only to remove just the
# PostgreSQL Flexible Server while keeping the resource group.
#
# Usage:
#   ./undeploy-azure.sh                        # delete resource group
#   ./undeploy-azure.sh --server-only          # delete server only
#   AZURE_RESOURCE_GROUP=my-rg ./undeploy-azure.sh
#
# Requirements: az CLI (logged in)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-postgresql-samples-rg}"
SERVER_NAME="${SERVER_NAME:-samples-pg-server}"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
SERVER_ONLY=false
NO_WAIT=false

for arg in "$@"; do
  case "$arg" in
    --server-only) SERVER_ONLY=true ;;
    --no-wait)     NO_WAIT=true ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --server-only  Delete only the PostgreSQL server (keep the resource group)"
      echo "  --no-wait      Return immediately without waiting for deletion to finish"
      echo "  --help, -h     Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  AZURE_RESOURCE_GROUP  Resource group name  (default: postgresql-samples-rg)"
      echo "  SERVER_NAME           Server name          (default: samples-pg-server)"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (use --help for usage)" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "==> $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

check_command() {
  if ! command -v "$1" &>/dev/null; then
    die "'$1' is required but not installed. $2"
  fi
}

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
log "Checking prerequisites..."
check_command "az" "Install: https://learn.microsoft.com/cli/azure/install-azure-cli"

if ! az account show &>/dev/null; then
  die "Not logged in to Azure. Run 'az login' first."
fi

# ---------------------------------------------------------------------------
# Verify the target exists before deleting
# ---------------------------------------------------------------------------
if "$SERVER_ONLY"; then
  # --- Delete server only ---------------------------------------------------
  log "Checking if server '${SERVER_NAME}' exists in resource group '${AZURE_RESOURCE_GROUP}'..."
  if ! az postgres flexible-server show \
      --resource-group "$AZURE_RESOURCE_GROUP" \
      --name "$SERVER_NAME" \
      --output none 2>/dev/null; then
    die "Server '${SERVER_NAME}' not found in resource group '${AZURE_RESOURCE_GROUP}'."
  fi

  log "Deleting PostgreSQL Flexible Server '${SERVER_NAME}'..."
  log "This will remove the server, all its databases, and firewall rules."
  az postgres flexible-server delete \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$SERVER_NAME" \
    --yes

  log "Server '${SERVER_NAME}' deleted. Resource group '${AZURE_RESOURCE_GROUP}' was kept."
else
  # --- Delete entire resource group -----------------------------------------
  log "Checking if resource group '${AZURE_RESOURCE_GROUP}' exists..."
  if ! az group show --name "$AZURE_RESOURCE_GROUP" --output none 2>/dev/null; then
    die "Resource group '${AZURE_RESOURCE_GROUP}' not found."
  fi

  log "Deleting resource group '${AZURE_RESOURCE_GROUP}' and ALL resources inside it..."

  DELETE_ARGS=(
    --name "$AZURE_RESOURCE_GROUP"
    --yes
  )
  if "$NO_WAIT"; then
    DELETE_ARGS+=(--no-wait)
  fi

  az group delete "${DELETE_ARGS[@]}"

  if "$NO_WAIT"; then
    log "Deletion started in the background. It may take a few minutes to complete."
    log "Check status with: az group show --name ${AZURE_RESOURCE_GROUP} --output table"
  else
    log "Resource group '${AZURE_RESOURCE_GROUP}' deleted."
  fi
fi

log "Teardown complete."
