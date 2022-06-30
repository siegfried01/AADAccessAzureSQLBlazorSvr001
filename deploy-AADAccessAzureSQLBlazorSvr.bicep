/**
   Begin common prolog commands
   write-output "Begin common prolog"
   $name='AADAccessAzureSQLBlazorSvr'
   $rg="rg_$name"
   $loc='westus2'
   write-output "End common prolog loc=$loc rg=$rg"
   End common prolog commands

   emacs 1
   Begin commands to deploy this file using Azure CLI with PowerShell
   echo WaitForBuildComplete
   WaitForBuildComplete
   write-output "Previous build is complete. Begin deployment build."
   az.cmd deployment group create --name $name --resource-group $rg   --template-file  deploy-AADAccessAzureSQLBlazorSvr.bicep
   write-output "end deploy"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs 2
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   echo CreateBuildEvent.exe
   CreateBuildEvent.exe&
   write-output "begin shutdown"
   az.cmd deployment group create --mode complete --template-file ./clear-resources.json --resource-group $rg
   BuildIsComplete.exe
   Get-AzResource -ResourceGroupName $rg | ft
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs 3
   Begin commands for one time initializations using Azure CLI with PowerShell
   az.cmd group create -l $loc -n $rg
   $id=(az.cmd group show --name $rg --query 'id' --output tsv)
   write-output "id=$id"
   $sp="spad_$name"
   az.cmd ad sp create-for-rbac --name $sp --sdk-auth --role contributor --scopes $id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell


   https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureaduser?view=azureadps-2.0
   emacs 4
   Begin commands for one time initializations using Azure CLI with PowerShell
   #$Secure_String_Pwd = ConvertTo-SecureString "P@ssW0rD!" -AsPlainText -Force
   #New-AzADUser -DisplayName "userAADAccessAzureSQLBlazorSvr" -Password $Secure_String_Pwd -UserPrincipalName "AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com" -AccountEnabled $true -MailNickName "userAADAccessAzureSQLBlazorSvr"
   az.cmd identity create --name umid-cosmosid --resource-group $rg --location $loc 
   $azureaduser=(az.cmd ad user list --filter "userPrincipalName eq 'AADAccessAzureSQLBlazorSvr@sheintzehotmail.onmicrosoft.com'"  --query [].objectId --output tsv)
   write-output "azureaduser=$azureaduser"
   $azureadSignedInUser=$(az ad signed-in-user show --query "objectId" -o tsv)
   write-output "azureadSignedInUser=$azureadSignedInUser"
   az.cmd deployment group create --name $name --resource-group $rg   --template-file deploy-SqlSvr.bicep --parameters  '{ \"parameters\": { \"azureSqlServerAdminPassword\": { \"reference\": { \"keyVault\": { \"id\": \"/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/aksbicep02/providers/Microsoft.KeyVault/vaults/aksbicep02SH0001\" }, \"secretName\": \"azureSqlServerAdminPassword\" } } } }'
   az.cmd sql server ad-admin create --resource-group $rg --server-name rbac-demo-server --display-name ADMIN --object-id $azureaduser
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
      metadata:[
         {
            name: 'CURRENT_STACK'
            value: 'dotnet'
         }
      ]
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

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/sourcecontrols?tabs=bicep 
// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sourcecontrols?tabs=bicep

  resource srcControls 'sourcecontrols@2021-03-01' = {
    name: 'web'
    properties: {
      repoUrl: 'https://github.com/siegfried01/AADAccessAzureSQLBlazorSvr001.git'
      branch: 'master'
      isManualIntegration: false
      isGitHubAction: true
      gitHubActionConfiguration: {
        codeConfiguration: {
          runtimeStack: 'DOTNET'
          runtimeVersion: '6.0'
        }
        generateWorkflowFile: false
        isLinux: true        
      }      
    }
  }

}
