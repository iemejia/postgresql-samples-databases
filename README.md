# Sample Databases for Azure Database for PostgreSQL Flexible Server

A collection of sample PostgreSQL databases, each in its own subdirectory.
The root-level deployment scripts auto-discover every subdirectory that follows
the standard convention and deploy them all into a single shared PostgreSQL
instance — either a local Docker container or an Azure Database for PostgreSQL
Flexible Server.

## Available Databases

| Directory | Description |
| --- | --- |
| [polls](./polls) | Lightweight polls / survey application (DDL + sample data) |
| [adventureworks](./adventureworks) | AdventureWorks OLTP — 68 tables, 90 FKs, and 89 views across 10 schemas (converted from SQL Server) |

> **Note:** Only subdirectories that contain a `schema.sql` file are picked up
> by the generic deploy scripts. See [Adding a New Database](#adding-a-new-database)
> for the convention.

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

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
  (logged in via `az login`)
- [psql](https://www.postgresql.org/download/) client

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
  Resource group : samples-rg
  Server FQDN    : samples-pg-server.postgres.database.azure.com
  Port           : 5432
  Admin user     : pgadmin

  Databases:
    - adventureworks
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
| `AZURE_RESOURCE_GROUP` | `samples-rg` | Azure resource group name |
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
az group create --name samples-rg --location eastus

az deployment group create \
  --resource-group samples-rg \
  --template-file main.bicep \
  --parameters \
    administratorLoginPassword='P@ssw0rd123!' \
    firewallClientIpAddress='<your-public-ip>'
```

Then load each database manually:

```bash
FQDN="samples-pg-server.postgres.database.azure.com"

# Create the database
PGPASSWORD='P@ssw0rd123!' psql \
  -h "$FQDN" -p 5432 -U pgadmin \
  --set=sslmode=require \
  -c "CREATE DATABASE polls;"

# Load schema (skip the CREATE DATABASE line)
grep -v '^CREATE DATABASE' polls/schema.sql | \
  PGPASSWORD='P@ssw0rd123!' psql \
    -h "$FQDN" -p 5432 -U pgadmin -d polls \
    -v ON_ERROR_STOP=1 --set=sslmode=require

# Load sample data
PGPASSWORD='P@ssw0rd123!' psql \
  -h "$FQDN" -p 5432 -U pgadmin -d polls \
  -v ON_ERROR_STOP=1 --set=sslmode=require \
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
| `AZURE_RESOURCE_GROUP` | `samples-rg` | Resource group to delete |
| `SERVER_NAME` | `samples-pg-server` | Server to delete (with `--server-only`) |

```bash
AZURE_RESOURCE_GROUP=my-rg SERVER_NAME=my-server ./undeploy-azure.sh
```

---

## Adding a New Database

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

### Minimal example

```
my-new-db/
  schema.sql   # CREATE TABLE items (id SERIAL PRIMARY KEY, name TEXT NOT NULL);
  data.sql     # INSERT INTO items (name) VALUES ('Widget'), ('Gadget');
```

---

## Project Files

### Root (generic deployment)

| File | Purpose |
| --- | --- |
| `deploy-docker.sh` | Deploys all discovered databases into a single PostgreSQL Docker container |
| `undeploy-docker.sh` | Stops and removes the Docker container and optionally the image |
| `deploy-azure.sh` | End-to-end Azure deployment — provisions infrastructure and loads all databases |
| `undeploy-azure.sh` | Tears down Azure resources — deletes the server or the entire resource group |
| `main.bicep` | Bicep template — provisions Azure PostgreSQL Flexible Server, database, and firewall rules |

### polls/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — creates sequences, tables, indexes, and constraints |
| `data.sql` | DML — inserts sample users, polls, metadata, questions, and answers |

### adventureworks/

| File | Purpose |
| --- | --- |
| `schema.sql` | DDL — 10 schemas, 68 tables, 6 custom domains, 2 extensions (`uuid-ossp`, `tablefunc`), 87 views, 2 materialized views, 68 primary keys, 90 foreign keys |
| `data.sql` | DML — sample data via `COPY FROM STDIN` (~86 MB, 760K lines covering all 68 tables) |

---

## Resources

- [Azure Database for PostgreSQL Flexible Server — Documentation](https://learn.microsoft.com/azure/postgresql/flexible-server/)
- [Azure Free Account — 12 months free with Flexible Server](https://docs.microsoft.com/azure/postgresql/flexible-server/how-to-deploy-on-azure-free-account)
- [psql — PostgreSQL client](https://www.postgresql.org/docs/current/app-psql.html)
- [pgAdmin — GUI for PostgreSQL](https://www.pgadmin.org/)
