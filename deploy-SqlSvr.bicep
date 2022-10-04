/*
 * Begin commands to execute this file using Azure CLI with PowerShell
 * $name='AADAccessAzureSQLBlazorSvr'
 * $rg="rg_$name"
 * $loc='westus2'
 * echo Set-AzDefault -ResourceGroupName $rg 
 * Set-AzDefault -ResourceGroupName $rg
 * az.cmd deployment group create --name $name --resource-group $rg   --template-file deploy-SqlSvr.bicep --parameters  '{ \"parameters\": { \"azureSqlServerAdminPassword\": { \"reference\": { \"keyVault\": { \"id\": \"/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/aksbicep02/providers/Microsoft.KeyVault/vaults/aksbicep02SH0001\" }, \"secretName\": \"azureSqlServerAdminPassword\" } } } }'
 * echo Create AD admin for signed in user
 * $azureaduser=$(az ad signed-in-user show --query "objectId" -o tsv)
 * az.cmd sql server ad-admin create --resource-group rg_AADAccessAzureSQLBlazorSvr --server-name rbac-demo-server --display-name ADMIN --object-id $azureaduser
 * echo Create firewall rule
 * az.cmd sql server firewall-rule create -g rg_AADAccessAzureSQLBlazorSvr -s rbac-demo-server -n AllAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
 * Get-AzResource -ResourceGroupName $rg | ft
 * End commands to execute this file using Azure CLI with Powershell
 */

@description('Azure Sql Server Admin Account')
//@secure()
param azureSqlServerAdminAccount string='serverAdmin'

@description('Azure Sql Server Admin Password')
//@secure()
param azureSqlServerAdminPassword string

//param location string = resourceGroup().location

@description('Azure Sql Server location')
param sqlsvrLocation string = 'West US3'

@description('The base name for resources')
param name string = uniqueString(resourceGroup().id)

@description('Generated from /subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_AADAccessAzureSQLBlazorSvr/providers/Microsoft.Sql/servers/rbac-demo-server')
resource rbacdemoserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'rbacdemoserver' // will camel case work here? this becomes part of the domain name
  properties: {
    administratorLogin: azureSqlServerAdminAccount
    administratorLoginPassword:  azureSqlServerAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    /*
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Application'
      login: 'AADAccessAzureSQLBlazorSvr'
      sid: '81bdf628-7fbd-48f5-a1ca-cd70e07e2d79'
      tenantId: '7a838aec-0b9e-4856-a3b5-2b02613f36a2'
      azureADOnlyAuthentication: false
    }*/
    restrictOutboundNetworkAccess: 'Disabled'
  }
  location: sqlsvrLocation
  tags: {}  
  
  resource administrators 'administrators@2022-02-01-preview'={
    name:'ActiveDirectory'
    properties:{
      administratorType: 'ActiveDirectory'
      login: 'AADAccessAzureSQLBlazorSvr'
      sid: '81bdf628-7fbd-48f5-a1ca-cd70e07e2d79'
      tenantId: '7a838aec-0b9e-4856-a3b5-2b02613f36a2'
    }
  }
  
  resource rbacDemoDatabase 'databases@2021-11-01-preview' = {
    name: 'rbacDemoDatabase'  
    sku:{
      name: 'GP_S_Gen5'
      tier: 'GeneralPurpose'
      family: 'Gen5'
      capacity: 1
    }    

    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 1073741824
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      zoneRedundant: false
      readScale: 'Disabled'
      autoPauseDelay: 60
      requestedBackupStorageRedundancy: 'Local'
      minCapacity: 1
      isLedgerOn: false
    }
    location: sqlsvrLocation
    tags: {}
  }
}
