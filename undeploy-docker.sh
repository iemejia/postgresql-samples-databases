#!/usr/bin/env bash
# =============================================================================
# undeploy-docker.sh — Stop and remove the shared PostgreSQL Docker container
# =============================================================================
# Removes the container created by deploy-docker.sh.  By default it also
# removes the Docker image to free disk space.  Use --keep-image to skip that.
#
# Usage:
#   ./undeploy-docker.sh                          # remove container + image
#   ./undeploy-docker.sh --keep-image             # remove container only
#   CONTAINER_NAME=my-db ./undeploy-docker.sh     # custom container name
#
# Requirements: docker
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
CONTAINER_NAME="${CONTAINER_NAME:-samples-db}"
POSTGRES_IMAGE="${POSTGRES_IMAGE:-postgres:18}"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
KEEP_IMAGE=false

for arg in "$@"; do
  case "$arg" in
    --keep-image) KEEP_IMAGE=true ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --keep-image   Remove the container but keep the Docker image"
      echo "  --help, -h     Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  CONTAINER_NAME   Container name  (default: samples-db)"
      echo "  POSTGRES_IMAGE   Docker image     (default: postgres:18)"
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
warn() { echo "WARNING: $*" >&2; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
if ! command -v docker &>/dev/null; then
  die "'docker' is required but not installed."
fi

# ---------------------------------------------------------------------------
# Remove container
# ---------------------------------------------------------------------------
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  log "Stopping and removing container '${CONTAINER_NAME}'..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
  log "Container '${CONTAINER_NAME}' removed."
else
  warn "Container '${CONTAINER_NAME}' not found. Nothing to remove."
fi

# ---------------------------------------------------------------------------
# Remove image
# ---------------------------------------------------------------------------
if "$KEEP_IMAGE"; then
  log "Keeping image '${POSTGRES_IMAGE}' (--keep-image)."
else
  if docker image inspect "$POSTGRES_IMAGE" &>/dev/null; then
    log "Removing image '${POSTGRES_IMAGE}'..."
    docker rmi "$POSTGRES_IMAGE" >/dev/null
    log "Image '${POSTGRES_IMAGE}' removed."
  else
    log "Image '${POSTGRES_IMAGE}' not found locally. Nothing to remove."
  fi
fi

log "Teardown complete."
