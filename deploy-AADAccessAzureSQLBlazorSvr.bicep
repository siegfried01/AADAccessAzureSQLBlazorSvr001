/**
   Begin common prolog commands
   write-output "Begin common prolog"
   $name='AADAccessAzureSQLBlazorSvr'
   $rg="rg_$name"
   $loc='westus2'
   write-output "End common prolog loc=$loc rg=$rg"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   echo WaitForBuildComplete
   WaitForBuildComplete
   write-output "Previous build is complete. Begin deployment build."
   az deployment group create --name $name --resource-group $rg   --template-file  deploy-AADAccessAzureSQLBlazorSvr.bicep
   write-output "end deploy"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   echo CreateBuildEvent.exe
   CreateBuildEvent.exe&
   write-output "begin shutdown"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $rg
   BuildIsComplete.exe
   Get-AzResource -ResourceGroupName $rg | ft
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az group create -l $loc -n $rg
   $id=(az group show --name $rg --query 'id' --output tsv)
   write-output "id=$id"
   $sp="spad_$name"
   az ad sp create-for-rbac --name $sp --sdk-auth --role contributor --scopes $id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell


   https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureaduser?view=azureadps-2.0
   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   #$Secure_String_Pwd = ConvertTo-SecureString "P@ssW0rD!" -AsPlainText -Force
   #New-AzADUser -DisplayName "userAADAccessAzureSQLBlazorSvr" -Password $Secure_String_Pwd -UserPrincipalName "AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com" -AccountEnabled $true -MailNickName "userAADAccessAzureSQLBlazorSvr"
   az identity create --name umid-azuresqlid --resource-group $rg --location $loc 
   $azureaduser=(az ad user list --filter "userPrincipalName eq 'AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com'"  --query [].objectId --output tsv)
   write-output "azureaduser=$azureaduser"
   $azureadSignedInUser=$(az ad signed-in-user show --query "objectId" -o tsv)
   write-output "azureadSignedInUser=$azureadSignedInUser"
   az deployment group create --name $name --resource-group $rg   --template-file deploy-SqlSvr.bicep --parameters  '{ \"parameters\": { \"azureSqlServerAdminPassword\": { \"reference\": { \"keyVault\": { \"id\": \"/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/aksbicep02/providers/Microsoft.KeyVault/vaults/aksbicep02SH0001\" }, \"secretName\": \"azureSqlServerAdminPassword\" } } } }'
   az sql server ad-admin create --resource-group $rg --server-name rbacdemoserver --display-name ADMIN --object-id $azureaduser
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az webapp identity assign --resource-group $rg --name hqdqhengdtz4w-website
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   $username=(az webapp list --query "[].{name: name}" -g $rg | jq ".[] | .name")
   write-output "create username=$username"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "CREATE USER [hqdqhengdtz4w-website] FROM EXTERNAL PROVIDER;"
   write-output "add db_datareader"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_datareader ADD MEMBER [hqdqhengdtz4w-website];"
   write-output "add db_datawriter"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_datawriter ADD MEMBER [hqdqhengdtz4w-website];"
   write-output "add db_ddladmin"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_ddladmin  ADD MEMBER [hqdqhengdtz4w-website];"
   End commands for one time initializations using Azure CLI with PowerShell

   see https://github.com/Azure/sql-action

   emacs ESC 7 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "SELECT * FROM TEST"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "INSERT INTO TEST ([name]) VALUES('constance003')"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "INSERT INTO TEST ([name]) VALUES('constance004')"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "SELECT * FROM TEST"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "CREATE USER [sheintze_hotmail.com#EXT#@sheintzehotmail.onmicrosoft.com] FROM EXTERNAL PROVIDER;"
   write-output "add db_datareader"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_datareader ADD MEMBER [sheintze_hotmail.com#EXT#@sheintzehotmail.onmicrosoft.com];"
   write-output "add db_datawriter"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_datawriter ADD MEMBER [sheintze_hotmail.com#EXT#@sheintzehotmail.onmicrosoft.com];"
   write-output "add db_ddladmin"
   sqlcmd -S rbacdemoserver.database.windows.net -d rbacdemoDatabase -U AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com -P $env:AADACCESSAZURESQLBLAZORSVR_PASSWORD -G -l 30 -Q "ALTER ROLE db_ddladmin  ADD MEMBER [sheintze_hotmail.com#EXT#@sheintzehotmail.onmicrosoft.com];"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   $id=(az group show --name $rg --query 'id' --output tsv)
   write-output "id=$id"
   End commands for one time initializations using Azure CLI with PowerShell

 */
@description('region we are operating in')
param location string = resourceGroup().location
param name string = uniqueString(resourceGroup().id)

@description('The web site hosting plan')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param webPlanSku string ='F1'

resource plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${name}-plan'
  location: location
  sku: {
    name: webPlanSku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
resource website 'Microsoft.Web/sites@2020-12-01' = {
  name: '${name}-website'
  location: location
  properties:{
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig:{
      linuxFxVersion: 'DOTNETCORE|6.0'
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
    }
  }
  resource logs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Warning'
        }
      }
      httpLogs: {
        fileSystem: {
          enabled: true
        }
      }
      detailedErrorMessages: {
        enabled: true
      }
    }
  }
}
