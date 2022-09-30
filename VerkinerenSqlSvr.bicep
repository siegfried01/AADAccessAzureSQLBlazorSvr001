param guidValue string = newGuid()
param SQLNamePrefix string = resourceGroup().name

@description('The administrator username of the SQL Server.')
param sqlAdministratorLogin string = 'SQLAdmin'

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Location for all resources.')
param location string = resourceGroup().location
param LinkedTemplatePrefix string

var sqlServerName_var = take('sql-${SQLNamePrefix}-${uniqueString(guidValue)}', 32)
var ADtenantID = '91xxxbe-xxx-43bf-axxx0-c2fxxx47349'
var ADobjectID = '3exxc5-17xx3-xxb-9axxb2-e1xxx74b76'
var ADLogin = 'Applications Team - Database Administrator'

resource sqlServerName 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlServerName_var
  location: location
  tags: {
    displayName: 'SqlServer'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlServerName_ActiveDirectory 'Microsoft.Sql/servers/administrators@2019-06-01-preview' = {
  parent: sqlServerName
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: ADLogin
    sid: ADobjectID
    tenantId: ADtenantID
  }
}

output sqlServerFqdn string = sqlServerName.properties.fullyQualifiedDomainName
output sqlServerName string = sqlServerName_var