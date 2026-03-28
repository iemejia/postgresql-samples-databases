#!/usr/bin/env bash
# =============================================================================
# generate-and-load.sh — Build TPC-H dbgen, generate data, and load into PostgreSQL
# =============================================================================
# This script clones the tpch-kit repository, compiles dbgen, generates TPC-H
# data at the requested scale factor, creates the database schema (8 tables with
# primary keys, foreign keys, and indexes), and bulk-loads the generated data
# using COPY.
#
# The TPC-H schema and sample data are generated at runtime — nothing is
# committed to this repository.  This avoids redistributing TPC-H materials
# directly (see "Licensing" below).
#
# Usage:
#   ./generate-and-load.sh                          # SF=0.01 (~10 MB), local Docker
#   ./generate-and-load.sh --scale-factor 1         # SF=1   (~1 GB)
#   ./generate-and-load.sh --scale-factor 10        # SF=10  (~10 GB)
#   ./generate-and-load.sh --host myserver --port 5432 --user pgadmin --dbname tpch
#
# Requirements: git, gcc, make, psql
#
# Licensing:
#   The TPC-H specification and dbgen source code are copyrighted by the
#   Transaction Processing Performance Council (TPC).  This script downloads
#   and compiles dbgen at runtime from a public GitHub mirror; no TPC materials
#   are stored in this repository.  The generated data is synthetic and created
#   locally on your machine.  See https://www.tpc.org/ for TPC licensing terms.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults (override via flags or environment variables)
# ---------------------------------------------------------------------------
SCALE_FACTOR="${SCALE_FACTOR:-0.01}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-tpch}"
DB_PASSWORD="${DB_PASSWORD:-}"
TPCH_KIT_REPO="${TPCH_KIT_REPO:-https://github.com/gregrahn/tpch-kit.git}"
CLEANUP="${CLEANUP:-true}"

# ---------------------------------------------------------------------------
# Resolve directories
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/.tpch-work"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
die()  { echo "ERROR: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: generate-and-load.sh [OPTIONS]

Options:
  -s, --scale-factor <n>   TPC-H scale factor (default: 0.01)
                            Common values: 0.01, 0.1, 1, 10, 100
  -h, --host <host>        PostgreSQL host (default: localhost)
  -p, --port <port>        PostgreSQL port (default: 5432)
  -U, --user <user>        PostgreSQL user (default: postgres)
  -d, --dbname <name>      Target database name (default: tpch)
  -W, --password <pass>    PostgreSQL password (or set DB_PASSWORD / PGPASSWORD)
      --no-cleanup          Keep the tpch-kit clone and generated .tbl files
      --help                Show this help message

Environment variables:
  SCALE_FACTOR, DB_HOST, DB_PORT, DB_USER, DB_NAME, DB_PASSWORD,
  PGPASSWORD, PGSSLMODE, TPCH_KIT_REPO, CLEANUP

Examples:
  # Quick local test with Docker (tiny dataset)
  ./generate-and-load.sh

  # 1 GB dataset against a remote server
  ./generate-and-load.sh -s 1 -h myserver.postgres.database.azure.com -U pgadmin -W 'P@ss!'

  # 10 GB dataset, keep generated files for inspection
  ./generate-and-load.sh -s 10 --no-cleanup
EOF
  exit 0
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--scale-factor)  SCALE_FACTOR="$2"; shift 2 ;;
    -h|--host)          DB_HOST="$2";      shift 2 ;;
    -p|--port)          DB_PORT="$2";      shift 2 ;;
    -U|--user)          DB_USER="$2";      shift 2 ;;
    -d|--dbname)        DB_NAME="$2";      shift 2 ;;
    -W|--password)      DB_PASSWORD="$2";  shift 2 ;;
    --no-cleanup)       CLEANUP="false";   shift   ;;
    --help)             usage                      ;;
    *)                  die "Unknown option: $1 (use --help for usage)" ;;
  esac
done

# Export password for psql (PGPASSWORD takes precedence if already set)
if [[ -n "$DB_PASSWORD" ]]; then
  export PGPASSWORD="$DB_PASSWORD"
fi

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
for cmd in git gcc make psql; do
  if ! command -v "$cmd" &>/dev/null; then
    die "'${cmd}' is required but not installed."
  fi
done

# ---------------------------------------------------------------------------
# psql wrapper — applies common connection options
# ---------------------------------------------------------------------------
run_psql() {
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -v ON_ERROR_STOP=1 "$@"
}

# ---------------------------------------------------------------------------
# Step 1: Clone and build tpch-kit
# ---------------------------------------------------------------------------
log "Scale factor: ${SCALE_FACTOR}"

if [[ -d "${WORK_DIR}/tpch-kit/dbgen/dbgen" ]]; then
  log "dbgen binary already exists — skipping build."
else
  log "Cloning tpch-kit..."
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  git clone --depth 1 "$TPCH_KIT_REPO" "${WORK_DIR}/tpch-kit"

  log "Building dbgen (MACHINE=LINUX, DATABASE=POSTGRESQL)..."
  make -C "${WORK_DIR}/tpch-kit/dbgen" \
    MACHINE=LINUX \
    DATABASE=POSTGRESQL \
    CC=gcc
fi

DBGEN_DIR="${WORK_DIR}/tpch-kit/dbgen"
DBGEN="${DBGEN_DIR}/dbgen"

if [[ ! -x "$DBGEN" ]]; then
  die "dbgen binary not found at ${DBGEN} — build may have failed."
fi

# ---------------------------------------------------------------------------
# Step 2: Generate TPC-H data
# ---------------------------------------------------------------------------
DATA_DIR="${WORK_DIR}/data"
mkdir -p "$DATA_DIR"

log "Generating TPC-H data at scale factor ${SCALE_FACTOR}..."
(
  cd "$DBGEN_DIR"
  ./dbgen -f -s "$SCALE_FACTOR" -v
  # Move generated .tbl files to the data directory
  mv -f ./*.tbl "$DATA_DIR/" 2>/dev/null || true
)

# Verify all 8 tables were generated
EXPECTED_TABLES=(region nation part supplier partsupp customer orders lineitem)
for tbl in "${EXPECTED_TABLES[@]}"; do
  if [[ ! -f "${DATA_DIR}/${tbl}.tbl" ]]; then
    die "Expected file ${tbl}.tbl was not generated."
  fi
done

log "Data generated in ${DATA_DIR}/"
for tbl in "${EXPECTED_TABLES[@]}"; do
  SIZE=$(du -h "${DATA_DIR}/${tbl}.tbl" | cut -f1)
  ROWS=$(wc -l < "${DATA_DIR}/${tbl}.tbl")
  echo "    ${tbl}.tbl  ${SIZE}  (${ROWS} rows)"
done

# ---------------------------------------------------------------------------
# Step 3: Create database
# ---------------------------------------------------------------------------
log "Creating database '${DB_NAME}' (if it does not exist)..."
run_psql -d postgres -tc \
  "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" \
  | grep -q 1 \
  || run_psql -d postgres -c "CREATE DATABASE ${DB_NAME};"

# ---------------------------------------------------------------------------
# Step 4: Create schema (tables without constraints for fast loading)
# ---------------------------------------------------------------------------
log "Creating TPC-H tables..."
run_psql -d "$DB_NAME" <<'SQL'
-- ============================================================
-- TPC-H Schema for PostgreSQL
-- Based on TPC-H Tools v3.0.1 (dss.ddl)
-- ============================================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS lineitem CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS partsupp CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS part CASCADE;
DROP TABLE IF EXISTS nation CASCADE;
DROP TABLE IF EXISTS region CASCADE;

CREATE TABLE region (
    r_regionkey  INTEGER      NOT NULL,
    r_name       CHAR(25)     NOT NULL,
    r_comment    VARCHAR(152)
);

CREATE TABLE nation (
    n_nationkey  INTEGER      NOT NULL,
    n_name       CHAR(25)     NOT NULL,
    n_regionkey  INTEGER      NOT NULL,
    n_comment    VARCHAR(152)
);

CREATE TABLE part (
    p_partkey     INTEGER        NOT NULL,
    p_name        VARCHAR(55)    NOT NULL,
    p_mfgr        CHAR(25)       NOT NULL,
    p_brand       CHAR(10)       NOT NULL,
    p_type        VARCHAR(25)    NOT NULL,
    p_size        INTEGER        NOT NULL,
    p_container   CHAR(10)       NOT NULL,
    p_retailprice NUMERIC(15,2)  NOT NULL,
    p_comment     VARCHAR(23)    NOT NULL
);

CREATE TABLE supplier (
    s_suppkey   INTEGER        NOT NULL,
    s_name      CHAR(25)       NOT NULL,
    s_address   VARCHAR(40)    NOT NULL,
    s_nationkey INTEGER        NOT NULL,
    s_phone     CHAR(15)       NOT NULL,
    s_acctbal   NUMERIC(15,2)  NOT NULL,
    s_comment   VARCHAR(101)   NOT NULL
);

CREATE TABLE partsupp (
    ps_partkey    INTEGER        NOT NULL,
    ps_suppkey    INTEGER        NOT NULL,
    ps_availqty   INTEGER        NOT NULL,
    ps_supplycost NUMERIC(15,2)  NOT NULL,
    ps_comment    VARCHAR(199)   NOT NULL
);

CREATE TABLE customer (
    c_custkey    INTEGER        NOT NULL,
    c_name       VARCHAR(25)    NOT NULL,
    c_address    VARCHAR(40)    NOT NULL,
    c_nationkey  INTEGER        NOT NULL,
    c_phone      CHAR(15)       NOT NULL,
    c_acctbal    NUMERIC(15,2)  NOT NULL,
    c_mktsegment CHAR(10)       NOT NULL,
    c_comment    VARCHAR(117)   NOT NULL
);

CREATE TABLE orders (
    o_orderkey      INTEGER        NOT NULL,
    o_custkey       INTEGER        NOT NULL,
    o_orderstatus   CHAR(1)        NOT NULL,
    o_totalprice    NUMERIC(15,2)  NOT NULL,
    o_orderdate     DATE           NOT NULL,
    o_orderpriority CHAR(15)       NOT NULL,
    o_clerk         CHAR(15)       NOT NULL,
    o_shippriority  INTEGER        NOT NULL,
    o_comment       VARCHAR(79)    NOT NULL
);

CREATE TABLE lineitem (
    l_orderkey      INTEGER        NOT NULL,
    l_partkey       INTEGER        NOT NULL,
    l_suppkey       INTEGER        NOT NULL,
    l_linenumber    INTEGER        NOT NULL,
    l_quantity      NUMERIC(15,2)  NOT NULL,
    l_extendedprice NUMERIC(15,2)  NOT NULL,
    l_discount      NUMERIC(15,2)  NOT NULL,
    l_tax           NUMERIC(15,2)  NOT NULL,
    l_returnflag    CHAR(1)        NOT NULL,
    l_linestatus    CHAR(1)        NOT NULL,
    l_shipdate      DATE           NOT NULL,
    l_commitdate    DATE           NOT NULL,
    l_receiptdate   DATE           NOT NULL,
    l_shipinstruct  CHAR(25)       NOT NULL,
    l_shipmode      CHAR(10)       NOT NULL,
    l_comment       VARCHAR(44)    NOT NULL
);
SQL

# ---------------------------------------------------------------------------
# Step 5: Load data using COPY
# ---------------------------------------------------------------------------
# The gregrahn/tpch-kit fork removes the trailing pipe delimiter, so we can
# use standard COPY with pipe as the delimiter.
#
# Load order respects foreign key constraints (though constraints are added
# after loading for performance).

LOAD_ORDER=(region nation part supplier customer partsupp orders lineitem)

log "Loading TPC-H data into '${DB_NAME}'..."
for tbl in "${LOAD_ORDER[@]}"; do
  FILE="${DATA_DIR}/${tbl}.tbl"
  ROWS=$(wc -l < "$FILE")
  log "  Loading ${tbl} (${ROWS} rows)..."
  run_psql -d "$DB_NAME" -c "\\copy ${tbl} FROM '${FILE}' WITH (DELIMITER '|')"
done

# ---------------------------------------------------------------------------
# Step 6: Add primary keys
# ---------------------------------------------------------------------------
log "Adding primary keys..."
run_psql -d "$DB_NAME" <<'SQL'
ALTER TABLE region   ADD PRIMARY KEY (r_regionkey);
ALTER TABLE nation   ADD PRIMARY KEY (n_nationkey);
ALTER TABLE part     ADD PRIMARY KEY (p_partkey);
ALTER TABLE supplier ADD PRIMARY KEY (s_suppkey);
ALTER TABLE partsupp ADD PRIMARY KEY (ps_partkey, ps_suppkey);
ALTER TABLE customer ADD PRIMARY KEY (c_custkey);
ALTER TABLE orders   ADD PRIMARY KEY (o_orderkey);
ALTER TABLE lineitem ADD PRIMARY KEY (l_orderkey, l_linenumber);
SQL

# ---------------------------------------------------------------------------
# Step 7: Add foreign keys
# ---------------------------------------------------------------------------
log "Adding foreign keys..."
run_psql -d "$DB_NAME" <<'SQL'
ALTER TABLE nation ADD CONSTRAINT nation_fk_region
    FOREIGN KEY (n_regionkey) REFERENCES region (r_regionkey);

ALTER TABLE supplier ADD CONSTRAINT supplier_fk_nation
    FOREIGN KEY (s_nationkey) REFERENCES nation (n_nationkey);

ALTER TABLE customer ADD CONSTRAINT customer_fk_nation
    FOREIGN KEY (c_nationkey) REFERENCES nation (n_nationkey);

ALTER TABLE partsupp ADD CONSTRAINT partsupp_fk_supplier
    FOREIGN KEY (ps_suppkey) REFERENCES supplier (s_suppkey);

ALTER TABLE partsupp ADD CONSTRAINT partsupp_fk_part
    FOREIGN KEY (ps_partkey) REFERENCES part (p_partkey);

ALTER TABLE orders ADD CONSTRAINT orders_fk_customer
    FOREIGN KEY (o_custkey) REFERENCES customer (c_custkey);

ALTER TABLE lineitem ADD CONSTRAINT lineitem_fk_orders
    FOREIGN KEY (l_orderkey) REFERENCES orders (o_orderkey);

ALTER TABLE lineitem ADD CONSTRAINT lineitem_fk_partsupp
    FOREIGN KEY (l_partkey, l_suppkey) REFERENCES partsupp (ps_partkey, ps_suppkey);
SQL

# ---------------------------------------------------------------------------
# Step 8: Create indexes (for TPC-H query performance)
# ---------------------------------------------------------------------------
log "Creating indexes..."
run_psql -d "$DB_NAME" <<'SQL'
CREATE INDEX idx_nation_regionkey       ON nation   (n_regionkey);
CREATE INDEX idx_supplier_nationkey     ON supplier (s_nationkey);
CREATE INDEX idx_customer_nationkey     ON customer (c_nationkey);
CREATE INDEX idx_partsupp_suppkey       ON partsupp (ps_suppkey);
CREATE INDEX idx_partsupp_partkey       ON partsupp (ps_partkey);
CREATE INDEX idx_orders_custkey         ON orders   (o_custkey);
CREATE INDEX idx_orders_orderdate       ON orders   (o_orderdate);
CREATE INDEX idx_lineitem_orderkey      ON lineitem (l_orderkey);
CREATE INDEX idx_lineitem_part_supp     ON lineitem (l_partkey, l_suppkey);
CREATE INDEX idx_lineitem_shipdate      ON lineitem (l_shipdate);
CREATE INDEX idx_lineitem_commitdate    ON lineitem (l_commitdate);
CREATE INDEX idx_lineitem_receiptdate   ON lineitem (l_receiptdate);
CREATE INDEX idx_lineitem_returnflag    ON lineitem (l_returnflag);
SQL

# ---------------------------------------------------------------------------
# Step 9: Analyze tables for query planner statistics
# ---------------------------------------------------------------------------
log "Running ANALYZE on all tables..."
run_psql -d "$DB_NAME" -c "ANALYZE;"

# ---------------------------------------------------------------------------
# Step 10: Verify row counts
# ---------------------------------------------------------------------------
log "Verifying row counts..."
run_psql -d "$DB_NAME" --tuples-only --no-align <<'SQL'
SELECT 'region    : ' || count(*) FROM region
UNION ALL SELECT 'nation    : ' || count(*) FROM nation
UNION ALL SELECT 'part      : ' || count(*) FROM part
UNION ALL SELECT 'supplier  : ' || count(*) FROM supplier
UNION ALL SELECT 'partsupp  : ' || count(*) FROM partsupp
UNION ALL SELECT 'customer  : ' || count(*) FROM customer
UNION ALL SELECT 'orders    : ' || count(*) FROM orders
UNION ALL SELECT 'lineitem  : ' || count(*) FROM lineitem;
SQL

# ---------------------------------------------------------------------------
# Step 11: Cleanup (optional)
# ---------------------------------------------------------------------------
if [[ "$CLEANUP" == "true" ]]; then
  log "Cleaning up working directory..."
  rm -rf "$WORK_DIR"
else
  log "Keeping working directory at ${WORK_DIR}"
  log "  dbgen binary : ${DBGEN}"
  log "  data files   : ${DATA_DIR}/"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
log "TPC-H database '${DB_NAME}' loaded successfully (scale factor ${SCALE_FACTOR})."
echo ""
echo "  Host     : ${DB_HOST}:${DB_PORT}"
echo "  User     : ${DB_USER}"
echo "  Database : ${DB_NAME}"
echo "  Scale    : ${SCALE_FACTOR} (~$(echo "${SCALE_FACTOR}" | awk '{printf "%.0f", $1 * 1024}') MB)"
echo "  Tables   : region, nation, part, supplier, partsupp, customer, orders, lineitem"
echo ""
echo "Connect with:"
echo "  psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"
echo ""
echo "Sample query (Q1 — Pricing Summary Report):"
echo "  SELECT l_returnflag, l_linestatus,"
echo "         sum(l_quantity)      AS sum_qty,"
echo "         sum(l_extendedprice) AS sum_base_price,"
echo "         avg(l_discount)      AS avg_disc,"
echo "         count(*)             AS count_order"
echo "    FROM lineitem"
echo "   WHERE l_shipdate <= DATE '1998-12-01' - INTERVAL '90 day'"
echo "   GROUP BY l_returnflag, l_linestatus"
echo "   ORDER BY l_returnflag, l_linestatus;"
