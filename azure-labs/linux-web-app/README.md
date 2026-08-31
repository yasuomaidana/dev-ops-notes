# Linux Web App lab

This folder is a separate Azure lab for a Linux Web App and App Service Plan. It does not reuse the VM lab files in
`../arm-creation`.

## Files

| File                          | Purpose                                                                                   |
|-------------------------------|-------------------------------------------------------------------------------------------|
| `azuredeploy.json`            | ARM template for the App Service plan, Linux Web App, and publishing credential policies. |
| `azuredeploy.bicep`           | Bicep source equivalent of the ARM template.                                              |
| `azuredeploy.parameters.json` | ARM parameter values for a sample deployment.                                             |
| `azuredeploy.bicepparam`      | Bicep parameter values for a sample deployment.                                           |
| `opentofu`                    | Separate OpenTofu project that deploys this ARM template.                                 |

## Deploy with Bicep

```powershell
$resourceGroup = "example-webapp-rg"
$location = "mexicocentral"
$deploymentName = "linux-web-app"

az group create --name $resourceGroup --location $location

az deployment group create `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

## Deploy with ARM JSON

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --template-file .\azuredeploy.json `
  --parameters .\azuredeploy.parameters.json
```
