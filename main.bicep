// ---------------------------------------------------------------------------
// main.bicep — Azure Database for PostgreSQL Flexible Server (generic)
// ---------------------------------------------------------------------------
// Deploys:
//   1. A PostgreSQL Flexible Server with public network access
//   2. A single database on that server (additional databases are created by
//      the deploy-azure.sh script via psql)
//   3. A firewall rule to expose the PostgreSQL port (5432) to a given client IP
//   4. An optional firewall rule to allow Azure-internal traffic
//
// Usage:
//   az deployment group create \
//     --resource-group <rg-name> \
//     --template-file main.bicep \
//     --parameters administratorLoginPassword='<strong-password>' \
//                  firewallClientIpAddress='<your-public-ip>'
// ---------------------------------------------------------------------------

// ---- Metadata -------------------------------------------------------------
metadata description = 'Deploys an Azure Database for PostgreSQL Flexible Server with a database, firewall rules, and public access.'

// ---- General parameters ---------------------------------------------------

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Tags to apply to every resource.')
param tags object = {}

// ---- Server parameters ----------------------------------------------------

@description('Name of the PostgreSQL Flexible Server (3-63 chars, alphanumeric and hyphens only).')
@minLength(3)
@maxLength(63)
param serverName string = 'samples-pg-server'

@description('Administrator login name. Cannot be "azure_superuser", "admin", "administrator", "root", "guest", or "public".')
@minLength(1)
param administratorLogin string = 'pgadmin'

@description('Administrator login password. Must be 8-128 characters and contain uppercase, lowercase, and numbers or symbols.')
@secure()
@minLength(8)
@maxLength(128)
param administratorLoginPassword string

@description('PostgreSQL engine version.')
@allowed([
  '16'
  '17'
  '18'
])
param postgresVersion string = '18'

// ---- Compute parameters ---------------------------------------------------

@description('The SKU tier for the server.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Burstable'

@description('The SKU name (compute size). Must match the selected tier. Standard_B1ms is the lowest-cost Burstable option widely available.')
param skuName string = 'Standard_B1ms'

// ---- Storage parameters ---------------------------------------------------

@description('Storage size in GB.')
@minValue(32)
@maxValue(16384)
param storageSizeGB int = 32

@description('Automatically grow storage when space is running low.')
@allowed([
  'Enabled'
  'Disabled'
])
param storageAutoGrow string = 'Disabled'

// ---- Backup parameters ----------------------------------------------------

@description('Number of days to retain backups (7-35).')
@minValue(7)
@maxValue(35)
param backupRetentionDays int = 7

@description('Enable geo-redundant backups.')
@allowed([
  'Enabled'
  'Disabled'
])
param geoRedundantBackup string = 'Disabled'

// ---- High-availability parameters -----------------------------------------

@description('High-availability mode.')
@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
param highAvailabilityMode string = 'Disabled'

// ---- Network / firewall parameters ----------------------------------------

@description('Your client public IP address to allow through the firewall (e.g. "203.0.113.50"). Leave empty to skip client firewall rule.')
param firewallClientIpAddress string = ''

@description('Allow connections from other Azure services.')
param allowAzureServices bool = true

// ---- Extension parameters -------------------------------------------------

@description('Comma-separated list of PostgreSQL extensions to allow-list on the server (e.g. "tablefunc,uuid-ossp"). Leave empty to skip.')
param allowedExtensions string = ''

// ---- Database parameters --------------------------------------------------

@description('Name of the initial PostgreSQL database to create. Additional databases are created by the deploy script.')
@minLength(1)
@maxLength(63)
param databaseName string = 'postgres'

@description('Character set for the database.')
param databaseCharset string = 'UTF8'

@description('Collation for the database.')
param databaseCollation string = 'en_US.utf8'

// ---- Maintenance window parameters ----------------------------------------

@description('Use a custom maintenance window.')
param useCustomMaintenanceWindow bool = false

@description('Day of week for maintenance (0 = Sunday, 6 = Saturday). Only used when useCustomMaintenanceWindow is true.')
@minValue(0)
@maxValue(6)
param maintenanceWindowDayOfWeek int = 0

@description('Start hour (UTC) for maintenance (0-23). Only used when useCustomMaintenanceWindow is true.')
@minValue(0)
@maxValue(23)
param maintenanceWindowStartHour int = 3

@description('Start minute for maintenance (0-59). Only used when useCustomMaintenanceWindow is true.')
@minValue(0)
@maxValue(59)
param maintenanceWindowStartMinute int = 0

// ---------------------------------------------------------------------------
// PostgreSQL Flexible Server
// ---------------------------------------------------------------------------
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2025-08-01' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    createMode: 'Default'
    version: postgresVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    storage: {
      storageSizeGB: storageSizeGB
      autoGrow: storageAutoGrow
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: highAvailabilityMode
    }
    maintenanceWindow: {
      customWindow: useCustomMaintenanceWindow ? 'Enabled' : 'Disabled'
      dayOfWeek: useCustomMaintenanceWindow ? maintenanceWindowDayOfWeek : 0
      startHour: useCustomMaintenanceWindow ? maintenanceWindowStartHour : 0
      startMinute: useCustomMaintenanceWindow ? maintenanceWindowStartMinute : 0
    }
  }
}

// ---------------------------------------------------------------------------
// Database — creates the initial database on the server
// ---------------------------------------------------------------------------
resource initialDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2025-08-01' = {
  parent: postgresServer
  name: databaseName
  properties: {
    charset: databaseCharset
    collation: databaseCollation
  }
}

// ---------------------------------------------------------------------------
// Allow-listed extensions — sets the azure.extensions server parameter so that
// CREATE EXTENSION / COMMENT ON EXTENSION statements succeed for the listed
// extensions.
// ---------------------------------------------------------------------------
resource allowedExtensionsConfig 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2025-08-01' = if (!empty(allowedExtensions)) {
  parent: postgresServer
  name: 'azure.extensions'
  properties: {
    value: allowedExtensions
    source: 'user-override'
  }
}

// ---------------------------------------------------------------------------
// Firewall Rule — exposes port 5432 to the caller's IP
// ---------------------------------------------------------------------------
resource clientFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2025-08-01' = if (!empty(firewallClientIpAddress)) {
  parent: postgresServer
  name: 'AllowClientIp'
  properties: {
    startIpAddress: firewallClientIpAddress
    endIpAddress: firewallClientIpAddress
  }
}

// ---------------------------------------------------------------------------
// Allow Azure Services — lets other Azure resources connect to the server
// (start/end = 0.0.0.0 is the Azure-portal convention)
// ---------------------------------------------------------------------------
resource azureServicesFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2025-08-01' = if (allowAzureServices) {
  parent: postgresServer
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

@description('Resource ID of the PostgreSQL Flexible Server.')
output serverResourceId string = postgresServer.id

@description('The fully qualified domain name of the PostgreSQL server.')
output fqdn string = postgresServer.properties.fullyQualifiedDomainName

@description('The PostgreSQL server name.')
output serverNameOutput string = postgresServer.name

@description('The initial database name.')
output databaseNameOutput string = initialDatabase.name

@description('The PostgreSQL port (always 5432 for Azure Flexible Server).')
output port int = 5432

@description('Connection string template — substitute <password> and <database> before use.')
output connectionString string = 'postgresql://${administratorLogin}:<password>@${postgresServer.properties.fullyQualifiedDomainName}:5432/<database>?sslmode=require'
