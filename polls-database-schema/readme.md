# Polls Database Schema

A PostgreSQL schema for building poll and survey applications. Includes the full
DDL, a sample-data script, a one-command Docker setup, and an Azure deployment
script.

## Quick Start (Docker)

The only prerequisite is **Docker**.

```bash
chmod +x deploy-docker.sh
./deploy-docker.sh
```

This will:

1. Pull the official `postgres:18` image.
2. Start a container named `polls-db`.
3. Create the `poll` database.
4. Apply the schema (tables, sequences, indexes, constraints).
5. Load realistic sample data (10 users, 6 polls, 18 questions, 54 answers).

Once complete the script prints connection details:

```
  Container : polls-db
  Host      : localhost:5432
  Database  : poll
  User      : postgres
  Password  : postgres
```

### Connecting

```bash
# Via local psql client
psql -h localhost -p 5432 -U postgres -d poll

# Via Docker
docker exec -it polls-db psql -U postgres -d poll
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
docker rm -f polls-db
```

### Configuration

Override any default by setting an environment variable before running the
script:

| Variable | Default | Description |
| --- | --- | --- |
| `CONTAINER_NAME` | `polls-db` | Docker container name |
| `POSTGRES_USER` | `postgres` | Database superuser |
| `POSTGRES_PASSWORD` | `postgres` | Superuser password |
| `POSTGRES_PORT` | `5432` | Host port mapped to the container |
| `POSTGRES_DB` | `poll` | Name of the database to create |
| `POSTGRES_IMAGE` | `postgres:18` | Docker image to use |

Example with custom settings:

```bash
POSTGRES_PASSWORD=secret POSTGRES_PORT=5433 ./deploy-docker.sh
```

## Deploy to Azure

The `deploy-azure.sh` script provisions an
[Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
using the included Bicep template, then loads the schema and sample data.

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
5. Deploy `main.bicep` (Flexible Server + `poll` database + firewall rules).
6. Load `polls-schema.sql` into the database.
7. Load `generate-data.sql` with sample data.

Once complete, the script prints connection details:

```
  Resource group : polls-rg
  Server FQDN    : polls-pg-server.postgres.database.azure.com
  Port           : 5432
  Database       : poll
  Admin user     : pgadmin

Connect with:
  psql "postgresql://pgadmin:<password>@polls-pg-server.postgres.database.azure.com:5432/poll?sslmode=require"
```

### Configuration

Override any default by setting an environment variable before running the
script:

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_RESOURCE_GROUP` | `polls-rg` | Azure resource group name |
| `AZURE_LOCATION` | `swedencentral` | Azure region |
| `SERVER_NAME` | `polls-pg-server` | PostgreSQL Flexible Server name |
| `ADMIN_LOGIN` | `pgadmin` | Administrator login |
| `POSTGRES_PASSWORD` | *(prompted)* | Administrator password (min 8 chars) |
| `POSTGRES_DB` | `poll` | Database name |
| `POSTGRES_VERSION` | `18` | PostgreSQL engine version (`16`, `17`, `18`) |
| `SKU_TIER` | `Burstable` | Compute tier |
| `SKU_NAME` | `Standard_B1ms` | Compute size |
| `STORAGE_SIZE_GB` | `32` | Storage in GB |
| `LOAD_SAMPLE_DATA` | `true` | Set to `false` to skip sample data |

Example with custom settings:

```bash
AZURE_RESOURCE_GROUP=my-rg \
  AZURE_LOCATION=westeurope \
  SERVER_NAME=my-polls-server \
  POSTGRES_PASSWORD='P@ssw0rd123!' \
  ./deploy-azure.sh
```

### Deploying with Bicep directly

If you prefer to deploy the infrastructure separately without the wrapper
script:

```bash
az group create --name polls-rg --location eastus

az deployment group create \
  --resource-group polls-rg \
  --template-file main.bicep \
  --parameters \
    administratorLoginPassword='P@ssw0rd123!' \
    firewallClientIpAddress='<your-public-ip>'
```

Then load the schema and data manually:

```bash
FQDN="polls-pg-server.postgres.database.azure.com"

# Load schema (skip the CREATE DATABASE line)
grep -v '^CREATE DATABASE' polls-schema.sql | \
  PGPASSWORD='P@ssw0rd123!' psql \
    -h "$FQDN" -p 5432 -U pgadmin -d poll \
    -v ON_ERROR_STOP=1 --set=sslmode=require

# Load sample data
PGPASSWORD='P@ssw0rd123!' psql \
  -h "$FQDN" -p 5432 -U pgadmin -d poll \
  -v ON_ERROR_STOP=1 --set=sslmode=require \
  -f generate-data.sql
```

### Tearing down

Use the `undeploy-azure.sh` script to remove all provisioned resources:

```bash
chmod +x undeploy-azure.sh

# Delete the entire resource group (server + database + firewall rules + group)
./undeploy-azure.sh

# Or delete only the server, keeping the resource group
./undeploy-azure.sh --server-only

# Return immediately without waiting for deletion to finish
./undeploy-azure.sh --no-wait
```

Override the defaults with environment variables:

```bash
AZURE_RESOURCE_GROUP=my-rg SERVER_NAME=my-polls-server ./undeploy-azure.sh
```

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_RESOURCE_GROUP` | `polls-rg` | Resource group to delete |
| `SERVER_NAME` | `polls-pg-server` | Server to delete (with `--server-only`) |

## Project Files

| File | Purpose |
| --- | --- |
| `polls-schema.sql` | DDL — creates the database, sequences, tables, indexes, and constraints |
| `generate-data.sql` | DML — inserts sample users, polls, metadata, questions, and answers |
| `deploy-docker.sh` | Orchestrates Docker container creation, schema loading, and data seeding |
| `undeploy-docker.sh` | Stops and removes the Docker container and optionally the image |
| `main.bicep` | Bicep template — provisions Azure PostgreSQL Flexible Server, database, and firewall rules |
| `deploy-azure.sh` | End-to-end Azure deployment — provisions infrastructure and loads schema + data |
| `undeploy-azure.sh` | Tears down Azure resources — deletes the server or the entire resource group |

## Schema Overview

```
users
  |
  | 1 ── * (surveyHostId)
  v
poll
  |
  |── 1 ── * ── poll_meta      (key-value metadata per poll)
  |
  |── 1 ── * ── poll_question
  |                  |
  |                  | 1 ── *
  |                  v
  └── 1 ── * ── poll_answer     (also references poll_question)
```

### Tables

#### users

Stores user accounts. Users with `host = 1` can create polls.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier (sequence `users_seq`) |
| firstName | VARCHAR(50) | First name |
| lastName | VARCHAR(50) | Last name |
| email | VARCHAR(50) | Email address, usable for login/registration |
| passwordHash | VARCHAR(32) | Hashed password (never store plaintext) |
| host | SMALLINT | `1` if the user can host polls, `0` otherwise |
| registeredAt | TIMESTAMP | Account creation time |
| lastLogin | TIMESTAMP | Most recent login time |
| intro | TEXT | Short bio displayed on poll pages |
| displayName | TEXT | Display name shown on poll pages |

#### poll

Stores polls and surveys. Each poll belongs to a host user.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier (sequence `poll_seq`) |
| surveyHostId | BIGINT FK | References `users.id` |
| title | VARCHAR(75) | Poll title |
| metaTitle | VARCHAR(100) | SEO/browser title |
| summary | TEXT | Key highlights |
| type | SMALLINT | Distinguishes poll vs. survey |
| published | SMALLINT | `1` if publicly visible |
| createdAt | TIMESTAMP | Creation time |
| updatedAt | TIMESTAMP | Last update time |
| publishedAt | TIMESTAMP | Publication time |
| startsAt | TIMESTAMP | Voting opens |
| endsAt | TIMESTAMP | Voting closes |
| content | TEXT | Full poll/survey body |

#### poll_meta

Key-value metadata attached to a poll. Unique on `(pollId, key)`.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier (sequence `poll_meta_seq`) |
| pollId | BIGINT FK | References `poll.id` |
| key | VARCHAR(50) | Metadata key (e.g. `target_audience`) |
| content | TEXT | Metadata value |

#### poll_question

Questions belonging to a poll. Polls typically have one question; surveys have
many.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier (sequence `poll_question_seq`) |
| pollId | BIGINT FK | References `poll.id` |
| type | VARCHAR(50) | Question type (`single_choice`, `multiple_choice`, `open_ended`, `rating_scale`, `ranking`) |
| active | SMALLINT | `1` if the question is active |
| createdAt | TIMESTAMP | Creation time |
| updatedAt | TIMESTAMP | Last update time |
| content | TEXT | The question text |

#### poll_answer

Predefined answer options for a question. Each answer references both its poll
and its question.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier (sequence `poll_answer_seq`) |
| pollId | BIGINT FK | References `poll.id` |
| questionId | BIGINT FK | References `poll_question.id` |
| active | SMALLINT | `1` if the answer is active |
| createdAt | TIMESTAMP | Creation time |
| updatedAt | TIMESTAMP | Last update time |
| content | TEXT | The answer text |

#### poll_vote (not yet implemented in schema)

Intended to store user voting activity.

| Column | Type | Description |
| --- | --- | --- |
| id | BIGINT PK | Unique identifier |
| pollId | BIGINT FK | References `poll.id` |
| questionId | BIGINT FK | References `poll_question.id` |
| answerId | BIGINT FK | References `poll_answer.id` |
| userId | BIGINT FK | References `users.id` |
| createdAt | TIMESTAMP | Vote creation time |
| updatedAt | TIMESTAMP | Vote update time |
| content | TEXT | Free-form user input |

## Sample Data Summary

The `generate-data.sql` script populates the database with the following:

| Table | Rows | Details |
| --- | --- | --- |
| users | 10 | 3 hosts (Alice, Carol, Frank) and 7 regular users |
| poll | 6 | 2 per host; topics include programming, remote work, parks, elections, product feedback, and support |
| poll_meta | 12 | 2 entries per poll (`target_audience`, `estimated_time`) |
| poll_question | 18 | 3 per poll; mixed types |
| poll_answer | 54 | 3 per question |

## Manual Setup (without Docker)

If you already have a PostgreSQL instance running:

```bash
# 1. Create the database and schema
psql -U postgres -f polls-schema.sql

# 2. Load sample data
psql -U postgres -d poll -f generate-data.sql
```
