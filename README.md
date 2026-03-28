# Sample Databases for Azure Database for PostgreSQL Flexible Server

A collection of sample PostgreSQL databases, each in its own subdirectory.
The root-level deployment scripts auto-discover every subdirectory that follows
the standard convention and deploy them all into a single shared PostgreSQL
instance — either a local Docker container or an Azure Database for PostgreSQL
Flexible Server.

## Available Databases

### Relational Databases

| Directory | Description |
| --- | --- |
| [polls](./polls) | Lightweight polls / survey application (DDL + sample data) |
| [adventureworks](./adventureworks) | AdventureWorks OLTP — 68 tables, 90 FKs, and 89 views across 10 schemas (converted from SQL Server) |
| [dvdrental](./dvdrental) | DVD Rental store (Pagila) — 15 tables with partitioned payments, 7 views, triggers, and functions |
| [tpch](./tpch) | TPC-H decision-support benchmark — 8 tables generated at any scale factor via dbgen (data is generated at runtime, not committed) |

### Graph Databases (Apache AGE)

| Directory | Description |
| --- | --- |
| [movies-graph](./movies-graph) | Movie Graph — 38 movies, 133 people, and ~253 relationships (ACTED_IN, DIRECTED, PRODUCED, WROTE, REVIEWED, FOLLOWS) using Apache AGE |

> **Note:** Relational databases (subdirectories without a `-graph` suffix) are
> deployed by `deploy-docker.sh`.  Graph databases (`*-graph/` directories) are
> deployed by `deploy-docker-age.sh` into a separate Apache AGE container.
> The TPC-H database uses its own `generate-and-load.sh` script (data is
> generated at runtime, not committed to the repository).
> See [Adding a New Database](#adding-a-new-database) for the convention.

**You can use the runtime of your choice (Python, PHP, .NET, Node.js, etc.) to
build using these samples.** This repository only contains database schemas and
sample data — it does not contain application code.

---

## Quick Start (Docker)

The only prerequisite is **[Docker](https://docs.docker.com/get-docker/)**.

```bash
chmod +x deploy-docker.sh
./deploy-docker.sh
```

This will:

1. Pull the official `postgres` image (the `latest` tag).
2. Start a container named `samples-db`.
3. Scan every subdirectory for a `schema.sql` file.
4. For each discovered database — create the database, load the schema, and
   (if present) load `data.sql` with sample data.

Once complete the script prints connection details:

```
  Container : samples-db
  Host      : localhost:5432
  User      : postgres
  Password  : postgres

  Databases:
    - adventureworks
    - dvdrental
    - polls
```

### Deploying a single database

Pass one or more subdirectory names to deploy only those:

```bash
./deploy-docker.sh polls
```

### Connecting

```bash
# Via local psql client (replace <database> with the database name)
psql -h localhost -p 5432 -U postgres -d <database>

# Via Docker
docker exec -it samples-db psql -U postgres -d <database>
```

### Stopping

Remove the container (and optionally the image) with the undeploy script:

```bash
chmod +x undeploy-docker.sh

# Remove container and image
./undeploy-docker.sh

# Remove container but keep the image for faster re-deploy
./undeploy-docker.sh --keep-image
```

Or remove the container manually:

```bash
docker rm -f samples-db
```

---

## Quick Start (Docker — Graph Databases)

Graph databases use [Apache AGE](https://age.apache.org/), a PostgreSQL
extension that adds openCypher graph query support.  They are deployed into a
**separate** container from the relational databases.

```bash
chmod +x deploy-docker-age.sh
./deploy-docker-age.sh
```

This will:

1. Pull the `apache/age` image (the `latest` tag).
2. Start a container named `samples-age-db` on **port 5433**.
3. Scan every `*-graph/` subdirectory for a `schema.sql` file.
4. For each discovered graph database — create the database, load the schema
   (extension setup, graph, vertices), and (if present) load `data.sql` (edges).

Once complete the script prints connection details:

```
  Container : samples-age-db
  Host      : localhost:5433
  User      : postgres
  Password  : postgres

  Graph databases:
    - movies_graph
```

### Connecting to a graph database

```bash
# Via local psql client
psql -h localhost -p 5433 -U postgres -d movies_graph

# Via Docker
docker exec -it samples-age-db psql -U postgres -d movies_graph
```

Every session requires AGE to be loaded before running Cypher queries:

```sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Find all movies Keanu Reeves acted in
SELECT * FROM cypher('movies', $$
  MATCH (p:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)
  RETURN m.title, m.released
$$) AS (title agtype, released agtype);
```

### Stopping

```bash
chmod +x undeploy-docker-age.sh

# Remove container and image
./undeploy-docker-age.sh

# Remove container but keep the image for faster re-deploy
./undeploy-docker-age.sh --keep-image
```

Or remove the container manually:

```bash
docker rm -f samples-age-db
```

### Docker Configuration (Graph Databases)

| Variable | Default | Description |
| --- | --- | --- |
| `CONTAINER_NAME` | `samples-age-db` | Docker container name |
| `POSTGRES_USER` | `postgres` | Database superuser |
| `POSTGRES_PASSWORD` | `postgres` | Superuser password |
| `POSTGRES_PORT` | `5433` | Host port mapped to the container |
| `POSTGRES_IMAGE` | `apache/age:latest` | Docker image to use |

### Docker Configuration

Override any default by setting an environment variable before running the
script:

| Variable | Default | Description |
| --- | --- | --- |
| `CONTAINER_NAME` | `samples-db` | Docker container name |
| `POSTGRES_USER` | `postgres` | Database superuser |
| `POSTGRES_PASSWORD` | `postgres` | Superuser password |
| `POSTGRES_PORT` | `5432` | Host port mapped to the container |
| `POSTGRES_IMAGE` | `postgres:latest` | Docker image to use |

Example with custom settings:

```bash
POSTGRES_PASSWORD=secret POSTGRES_PORT=5433 ./deploy-docker.sh
```

---

## Deploy to Azure

The `deploy-azure.sh` script provisions an
[Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
using the included Bicep template, then discovers and loads all databases onto
the same server.

### Prerequisites

- An **Azure subscription** — [create a free account](https://azure.microsoft.com/free/)
  if you don't have one
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) —
  after installing, run `az login` to authenticate
- [psql](https://www.postgresql.org/download/) client — only the client tools
  are needed, not a full PostgreSQL server
- **curl** — used to detect your public IP for the firewall rule (pre-installed
  on most Linux and macOS systems)

### Usage

```bash
chmod +x deploy-azure.sh
./deploy-azure.sh
```

The script will:

1. Verify that `az` and `psql` are installed and that you are logged in.
2. Prompt for the administrator password (if not provided via environment
   variable).
3. Detect your public IP and configure a firewall rule so you can connect.
4. Create the Azure resource group.
5. Deploy `main.bicep` (Flexible Server + initial database + firewall rules).
6. For each discovered subdirectory — create the database, load the schema,
   and (if present) load `data.sql` with sample data.

Once complete, the script prints connection details:

```
  Resource group : postgresql-samples-rg
  Server FQDN    : samples-pg-server.postgres.database.azure.com
  Port           : 5432
  Admin user     : pgadmin

  Databases:
    - adventureworks
    - dvdrental
    - polls

Connect with:
  psql "postgresql://pgadmin:<password>@samples-pg-server.postgres.database.azure.com:5432/<database>?sslmode=require"
```

### Deploying a single database

```bash
./deploy-azure.sh polls
```

### Azure Configuration

Override any default by setting an environment variable before running the
script:

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_RESOURCE_GROUP` | `postgresql-samples-rg` | Azure resource group name |
| `AZURE_LOCATION` | `swedencentral` | Azure region |
| `SERVER_NAME` | `samples-pg-server` | PostgreSQL Flexible Server name |
| `ADMIN_LOGIN` | `pgadmin` | Administrator login |
| `POSTGRES_PASSWORD` | *(prompted)* | Administrator password (min 8 chars) |
| `POSTGRES_VERSION` | `18` | PostgreSQL engine version (`16`, `17`, `18`) |
| `SKU_TIER` | `Burstable` | Compute tier |
| `SKU_NAME` | `Standard_B1ms` | Compute size |
| `STORAGE_SIZE_GB` | `32` | Storage in GB |
| `LOAD_SAMPLE_DATA` | `true` | Set to `false` to skip sample data |

Example with custom settings:

```bash
AZURE_RESOURCE_GROUP=my-rg \
  AZURE_LOCATION=westeurope \
  SERVER_NAME=my-server \
  POSTGRES_PASSWORD='P@ssw0rd123!' \
  ./deploy-azure.sh
```

### Deploying with Bicep directly

If you prefer to deploy the infrastructure separately without the wrapper
script:

```bash
az group create --name postgresql-samples-rg --location eastus

az deployment group create \
  --resource-group postgresql-samples-rg \
  --template-file main.bicep \
  --parameters \
    administratorLoginPassword='P@ssw0rd123!' \
    firewallClientIpAddress='<your-public-ip>'
```

Then load each database manually:

```bash
FQDN="samples-pg-server.postgres.database.azure.com"

# Create the database
PGPASSWORD='P@ssw0rd123!' PGSSLMODE=require psql \
  -h "$FQDN" -p 5432 -U pgadmin \
  -c "CREATE DATABASE polls;"

# Load schema (skip the CREATE DATABASE line)
grep -v '^CREATE DATABASE' polls/schema.sql | \
  PGPASSWORD='P@ssw0rd123!' PGSSLMODE=require psql \
    -h "$FQDN" -p 5432 -U pgadmin -d polls \
    -v ON_ERROR_STOP=1

# Load sample data
PGPASSWORD='P@ssw0rd123!' PGSSLMODE=require psql \
  -h "$FQDN" -p 5432 -U pgadmin -d polls \
  -v ON_ERROR_STOP=1 \
  -f polls/data.sql
```

### Tearing down Azure resources

Use the `undeploy-azure.sh` script to remove all provisioned resources:

```bash
chmod +x undeploy-azure.sh

# Delete the entire resource group (server + databases + firewall rules + group)
./undeploy-azure.sh

# Or delete only the server, keeping the resource group
./undeploy-azure.sh --server-only

# Return immediately without waiting for deletion to finish
./undeploy-azure.sh --no-wait
```

Override the defaults with environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_RESOURCE_GROUP` | `postgresql-samples-rg` | Resource group to delete |
| `SERVER_NAME` | `samples-pg-server` | Server to delete (with `--server-only`) |

```bash
AZURE_RESOURCE_GROUP=my-rg SERVER_NAME=my-server ./undeploy-azure.sh
```

---

## Adding a New Database

### Relational databases

To add a new sample database that is automatically discovered and deployed:

1. Create a new subdirectory at the repository root (e.g. `my-new-db/`).
2. Add a **`schema.sql`** file with the DDL (tables, sequences, indexes,
   constraints). If the file contains a `CREATE DATABASE` line it will be
   automatically skipped — the deploy scripts handle database creation.
3. Optionally add a **`data.sql`** file with `INSERT` statements or other
   DML to seed sample data.

The database name is derived from the directory name: lowercased with hyphens
replaced by underscores. For example:

| Directory | Database name |
| --- | --- |
| `polls/` | `polls` |
| `my-new-db/` | `my_new_db` |
| `Inventory/` | `inventory` |

Run the deploy script and the new database will be picked up automatically:

```bash
./deploy-docker.sh            # deploy all (including the new one)
./deploy-docker.sh my-new-db  # deploy only the new one
```

### Graph databases (Apache AGE)

Graph databases use the `*-graph/` directory naming convention:

1. Create a subdirectory ending with `-graph` (e.g. `my-graph/`).
2. Add a **`schema.sql`** file containing:
   - `CREATE EXTENSION IF NOT EXISTS age;`
   - `LOAD 'age';` and `SET search_path = ag_catalog, "$user", public;`
   - `SELECT create_graph('graph_name');`
   - Vertex `CREATE` statements wrapped in `SELECT * FROM cypher(...)`.
3. Optionally add a **`data.sql`** file with edge/relationship `CREATE`
   statements (also wrapped in `SELECT * FROM cypher(...)`). The file must
   include the `LOAD 'age'` and `SET search_path` preamble.

| Directory | Database name |
| --- | --- |
| `movies-graph/` | `movies_graph` |
| `social-graph/` | `social_graph` |

Graph databases are deployed by `deploy-docker-age.sh` (not `deploy-docker.sh`):

```bash
./deploy-docker-age.sh                  # deploy all graph databases
./deploy-docker-age.sh movies-graph     # deploy only this one
```

### Minimal example

**Relational:**

```
my-new-db/
  schema.sql   # CREATE TABLE items (id SERIAL PRIMARY KEY, name TEXT NOT NULL);
  data.sql     # INSERT INTO items (name) VALUES ('Widget'), ('Gadget');
```

**Graph (Apache AGE):**

```
my-graph/
  schema.sql   # CREATE EXTENSION IF NOT EXISTS age; LOAD 'age'; ...
  data.sql     # LOAD 'age'; SET search_path ...; SELECT * FROM cypher(...) ...
```

---

## Project Files

### Root (generic deployment)

| File | Purpose |
| --- | --- |
| `deploy-docker.sh` | Deploys all discovered relational databases into a single PostgreSQL Docker container |
| `undeploy-docker.sh` | Stops and removes the relational Docker container and optionally the image |
| `deploy-docker-age.sh` | Deploys all discovered graph databases into a single Apache AGE Docker container |
| `undeploy-docker-age.sh` | Stops and removes the AGE Docker container and optionally the image |
| `deploy-azure.sh` | End-to-end Azure deployment — provisions infrastructure and loads all databases (relational + graph) |
| `undeploy-azure.sh` | Tears down Azure resources — deletes the server or the entire resource group |
| `main.bicep` | Bicep template — provisions Azure PostgreSQL Flexible Server, database, and firewall rules |

### polls/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — creates sequences, tables, indexes, and constraints |
| `data.sql` | DML — inserts sample users, polls, metadata, questions, and answers |

> **Source:** Original schema and data created for this repository.

### adventureworks/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — 10 schemas, 68 tables, 6 custom domains, 2 extensions (`uuid-ossp`, `tablefunc`), 87 views, 2 materialized views, 68 primary keys, 90 foreign keys |
| `data.sql` | DML — sample data via `COPY FROM STDIN` (~86 MB, 760K lines covering all 68 tables) |

> **Source:** Converted from Microsoft's
> [AdventureWorks 2014 OLTP](https://learn.microsoft.com/sql/samples/adventureworks-install-configure)
> sample database using
> [lorint/AdventureWorks-for-Postgres](https://github.com/lorint/AdventureWorks-for-Postgres) (MIT License).

### dvdrental/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — 15 tables (with partitioned `payment`), 7 views, 1 materialized view, 8 functions, 15 triggers, 36 foreign keys |
| `data.sql` | DML — sample data via `COPY FROM STDIN` (~3.2 MB, ~50K rows across all tables) |

> **Source:** Based on the
> [Pagila](https://github.com/devrimgunduz/pagila) project (PostgreSQL License),
> a PostgreSQL-native port of MySQL's
> [Sakila](https://dev.mysql.com/doc/sakila/en/) sample database.

### movies-graph/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — Apache AGE extension setup, graph creation, 38 Movie nodes and 133 Person nodes |
| `data.sql` | DML — ~253 edges across 6 relationship types: ACTED_IN, DIRECTED, PRODUCED, WROTE, REVIEWED, FOLLOWS |

> **Source:** Adapted from the
> [Neo4j Movies](https://github.com/neo4j-graph-examples/movies) example dataset.
> All data is factual (movie titles, actor names, release years) and is not
> subject to copyright.

### tpch/

| File | Purpose |
| --- | --- |
| `generate-and-load.sh` | Clones [tpch-kit](https://github.com/gregrahn/tpch-kit), compiles dbgen, generates TPC-H data at the requested scale factor, creates the schema (8 tables, PKs, FKs, indexes), and bulk-loads data via `COPY` |

> **Source:** Data is generated at runtime by the TPC-H `dbgen` tool.  The
> TPC-H specification and dbgen source code are copyrighted by the
> [Transaction Processing Performance Council (TPC)](https://www.tpc.org/).
> No TPC materials are stored in this repository — the script clones and builds
> dbgen from a public GitHub mirror at deploy time.

**Usage:**

```bash
# Tiny dataset (~10 MB) against the local Docker container
./tpch/generate-and-load.sh

# 1 GB dataset
./tpch/generate-and-load.sh --scale-factor 1

# Against a remote server
./tpch/generate-and-load.sh -s 1 -h myserver.postgres.database.azure.com -U pgadmin -W 'P@ss!'

# See all options
./tpch/generate-and-load.sh --help
```

---

## Resources

- [Azure Database for PostgreSQL Flexible Server — Documentation](https://learn.microsoft.com/azure/postgresql/flexible-server/)
- [Azure Free Account — 12 months free with Flexible Server](https://docs.microsoft.com/azure/postgresql/flexible-server/how-to-deploy-on-azure-free-account)
- [Apache AGE — Graph Extension for PostgreSQL](https://age.apache.org/)
- [Apache AGE on Azure — Preview documentation](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#apache-age)
- [openCypher Query Language](https://opencypher.org/)
- [psql — PostgreSQL client](https://www.postgresql.org/docs/current/app-psql.html)
- [pgAdmin — GUI for PostgreSQL](https://www.pgadmin.org/)
