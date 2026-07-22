# ARM template examples

These examples are separate from the lab's `../azuredeploy.json`, which creates the complete Debian VM environment.

| File | What it demonstrates |
| --- | --- |
| `empty-template.json` | The smallest valid ARM template. |
| `storage-account.json` | A fixed-name StorageV2 storage account. Replace the placeholder name before deployment. |
| `storage-account-with-parameter.json` | A storage account whose name is supplied as a parameter. |
| `storage-account-with-parameter.parameters.json` | Example parameter values for the parameterized storage account. |
| `windows-vm-existing-network.json` | A Windows Server VM and NIC; it uses an existing `myVNet/mySubnet`. |
| `windows-vm-existing-network.parameters.json` | Example non-secret values for the Windows VM example. |

## Deploy an example

Set a dedicated resource group and create it if needed:

```powershell
$resourceGroup = "arm-examples-rg"
$location = "eastus"
az group create --name $resourceGroup --location $location
```

Validate and preview the parameterized storage example:

```powershell
az deployment group validate `
  --resource-group $resourceGroup `
  --template-file .\storage-account-with-parameter.json `
  --parameters .\storage-account-with-parameter.parameters.json

az deployment group what-if `
  --resource-group $resourceGroup `
  --template-file .\storage-account-with-parameter.json `
  --parameters .\storage-account-with-parameter.parameters.json
```

Deploy it after checking the What-If output:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name storage-example `
  --template-file .\storage-account-with-parameter.json `
  --parameters .\storage-account-with-parameter.parameters.json
```

## Supply a name from the console

The literal placeholder in `storage-account.json` is deliberately not deployable until you replace it. ARM templates cannot read your local PowerShell environment directly. Instead, use the parameterized template and let Azure CLI pass the value after PowerShell expands it:

```powershell
$env:STORAGE_NAME = "examplestorage$((Get-Random -Minimum 10000 -Maximum 99999))"

az deployment group create `
  --resource-group $resourceGroup `
  --name storage-from-environment `
  --template-file .\storage-account-with-parameter.json `
  --parameters "storageName=$env:STORAGE_NAME"
```

Storage account names must be globally unique, 3–24 characters long, and contain only lowercase letters and numbers. The command still fails if another Azure customer already owns the generated name, so use `what-if` and choose another name if necessary.

You can also generate a stable name inside the template rather than provide a parameter. For example, replace the storage account's `name` property with this expression:

```json
"name": "[concat('st', uniqueString(resourceGroup().id))]"
```

`uniqueString(resourceGroup().id)` produces a deterministic string for that resource group. Prefix it with lowercase letters and keep the combined result within the storage-account naming rules.

The Windows VM example needs an existing `myVNet` virtual network containing a `mySubnet` subnet in the same resource group. Supply the password only at deployment time; do not save it in the parameters file:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name windows-vm-example `
  --template-file .\windows-vm-existing-network.json `
  --parameters .\windows-vm-existing-network.parameters.json `
  "adminPassword=<use-a-strong-password>"
```
