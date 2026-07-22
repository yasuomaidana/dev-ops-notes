# Deployment examples

These examples are separate from the lab's `../azuredeploy.bicep`, which creates the complete Debian VM environment.
They are authored in Bicep to match the lab's Bicep-first workflow.

| File | What it demonstrates |
| --- | --- |
| `empty-template.bicep` | The smallest valid resource-group-scope Bicep file. |
| `storage-account.bicep` | A fixed-name StorageV2 storage account. Replace the placeholder name before deployment. |
| `storage-account-with-parameter.bicep` | A storage account whose name is supplied as a parameter. |
| `storage-account-with-parameter.bicepparam` | Example parameter values for the parameterized storage account. |
| `windows-vm-existing-network.bicep` | A Windows Server VM and NIC; it uses an existing `myVNet/mySubnet`. |
| `windows-vm-existing-network.bicepparam` | Example non-secret values for the Windows VM example. |

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
  --template-file .\storage-account-with-parameter.bicep `
  --parameters .\storage-account-with-parameter.bicepparam

az deployment group what-if `
  --resource-group $resourceGroup `
  --template-file .\storage-account-with-parameter.bicep `
  --parameters .\storage-account-with-parameter.bicepparam
```

Deploy it after checking the What-If output:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name storage-example `
  --template-file .\storage-account-with-parameter.bicep `
  --parameters .\storage-account-with-parameter.bicepparam
```

## Supply a name from the console

The literal placeholder in `storage-account.bicep` is deliberately not deployable until you replace it. Bicep files cannot read your local PowerShell environment directly. Instead, use the parameterized template and let Azure CLI pass the value after PowerShell expands it:

```powershell
$env:STORAGE_NAME = "examplestorage$((Get-Random -Minimum 10000 -Maximum 99999))"

az deployment group create `
  --resource-group $resourceGroup `
  --name storage-from-environment `
  --template-file .\storage-account-with-parameter.bicep `
  --parameters "storageName=$env:STORAGE_NAME"
```

Storage account names must be globally unique, 3–24 characters long, and contain only lowercase letters and numbers. The command still fails if another Azure customer already owns the generated name, so use `what-if` and choose another name if necessary.

You can also generate a stable name inside the template rather than provide a parameter. For example, replace the storage account's `name` property with this expression:

```bicep
name: 'st${uniqueString(resourceGroup().id)}'
```

`uniqueString(resourceGroup().id)` produces a deterministic string for that resource group. Prefix it with lowercase letters and keep the combined result within the storage-account naming rules.

The Windows VM example needs an existing `myVNet` virtual network containing a `mySubnet` subnet in the same resource group. Supply the password only at deployment time; do not save it in the parameters file:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name windows-vm-example `
  --template-file .\windows-vm-existing-network.bicep `
  --parameters .\windows-vm-existing-network.bicepparam `
  "adminPassword=<use-a-strong-password>"
```
