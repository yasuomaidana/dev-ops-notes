# Linux Web App lab

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

The web app name is generated from `namePrefix` plus a deterministic suffix based on the subscription and resource
group. Deploying the same template to another resource group therefore produces a different, collision-resistant name.

## Deploy with ARM JSON

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --template-file .\azuredeploy.json `
  --parameters .\azuredeploy.parameters.json
```
