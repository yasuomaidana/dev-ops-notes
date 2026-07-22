# Azure Policy lab with Bicep

This lab now matches the DCA Tech scenario: create a resource group, create a custom initiative named `Get Secure`,
add the Microsoft built-in policy **Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.**,
and assign that initiative to the resource group.

## Important behavior correction

As of **July 22, 2026**, Microsoft lists the built-in policy **Windows virtual machines should enable Azure Disk
Encryption or EncryptionAtHost.** as version **1.1.1** with supported effects **`AuditIfNotExists`** and
**`Disabled`**. That means:

- The policy can mark a VM as non-compliant.
- The policy does **not** block VM creation.
- A test VM without `Encryption at host` will usually deploy successfully, then later appear as non-compliant.

If your course screenshot shows VM creation failing at validation time, that is not the behavior of this built-in
policy today.

Sources used to verify this:

- Microsoft Learn policy reference: https://learn.microsoft.com/en-us/azure/virtual-machines/policy-reference
- Microsoft Learn disk encryption overview: https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview

## Files

| File | Purpose |
| --- | --- |
| `azuredeploy.bicep` | Subscription-scope deployment that creates the lab resource group, the `Get Secure` initiative, and the assignment. |
| `azuredeploy.bicepparam` | Default lab values. |
| [`docs/policy-basics.md`](docs/policy-basics.md) | Short explanation of how this lab works and why the test VM becomes non-compliant instead of being denied. |
| [`docs/azure-rbac-overview.md`](docs/azure-rbac-overview.md) | Summary of Azure RBAC, its core components, and how it differs from Azure Policy and legacy Azure Blueprints guidance. |

## Azure CLI quick reference

Use `$location`, `$deploymentName`, and `$resourceGroup` from the workflow below.

| Topic | Command | Purpose |
| --- | --- | --- |
| Authentication and tools | `az login` | Sign in to Azure. |
| Authentication and tools | `az account show --output table` | Show the active subscription. |
| Authentication and tools | `az account set --subscription "<subscription>"` | Select a subscription. |
| Authentication and tools | `az bicep install` | Install the Bicep CLI. |
| Subscription deployments | `az deployment sub validate ...` | Validate the subscription deployment before creating policy resources. |
| Subscription deployments | `az deployment sub what-if ...` | Preview initiative, assignment, and resource-group changes. |
| Subscription deployments | `az deployment sub create ...` | Create or update the lab deployment from Bicep. |
| Subscription deployments | `az deployment sub show --name $deploymentName --location $location --output jsonc` | Show deployment state and outputs. |
| Subscription deployments | `az deployment sub list --location $location --output table` | List subscription-scope deployments recorded in one location. |
| Resource groups | `az group show --name $resourceGroup --output table` | Confirm that the lab resource group exists. |
| Initiative definitions | `az policy set-definition show --name get-secure --output jsonc` | Show the custom initiative definition. |
| Initiative definitions | `az policy definition list --query "[?contains(displayName, 'enable Azure Disk Encryption')]"` | Find built-in policy definitions related to Azure Disk Encryption by display name. |
| Policy assignments | `az policy assignment show --name get-secure-assignment --scope $scope --output jsonc` | Show the assignment at the lab scope. |
| Policy state | `az policy state list --resource-group $resourceGroup --output table` | List compliance results for resources in the lab resource group. |
| Cleanup | `az policy assignment delete --name get-secure-assignment --scope $scope` | Delete the assignment first. |
| Cleanup | `az policy set-definition delete --name get-secure` | Delete the custom initiative after the assignment is gone. |
| Cleanup | `az group delete --name $resourceGroup --yes --no-wait` | Delete the lab resource group and everything in it. |
| Help | `az deployment sub --help` | Show subscription deployment commands. |
| Help | `az policy --help` | Show Azure Policy commands. |

## What the Bicep deploys

The deployment creates:

1. A resource group for the lab.
2. A custom initiative definition named `Get Secure`.
3. An assignment of that initiative to the lab resource group.

The initiative contains one Microsoft built-in policy definition:

- `/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0`

## Prerequisites

```powershell
az login
az bicep install
az account show --output table
```

If needed:

```powershell
az account set --subscription "<your-subscription>"
```

## Deploy the lab

From the `azure-policy` folder:

```powershell
$location = "eastus"
$deploymentName = "azure-policy-get-secure"
```

Validate:

```powershell
az deployment sub validate `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

Preview:

```powershell
az deployment sub what-if `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

Create:

```powershell
az deployment sub create `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

## Check the deployed policy objects

```powershell
$subscriptionId = az account show --query id -o tsv
$scope = "/subscriptions/$subscriptionId/resourceGroups/dca-tech-policy-rg"

az policy set-definition show --name get-secure --output jsonc
az policy assignment show --name get-secure-assignment --scope $scope --output jsonc
```

## Create the test VM

Portal flow:

1. Open the Azure portal.
2. Go to the resource group `dca-tech-policy-rg`.
3. Create a Windows virtual machine in that resource group.
4. Keep the defaults.
5. On the **Disks** tab, leave **Encryption at host** unchecked.
6. Create the VM.

Expected result:

- The VM deployment should succeed.
- After policy evaluation runs, the VM should appear as **Non-compliant** for the `Get Secure` initiative.

## Check compliance

Portal flow:

1. Open **Policy**.
2. Open **Compliance**.
3. Search for `Get Secure`.
4. Open the initiative and review the non-compliant resource details.

CLI option:

```powershell
az policy state list --resource-group dca-tech-policy-rg --output table
```

If the compliance state does not appear immediately, wait a few minutes and check again. Azure Policy evaluation is not
instant.

## Clean up

Delete the assignment first, then the initiative, then the resource group:

```powershell
$subscriptionId = az account show --query id -o tsv
$scope = "/subscriptions/$subscriptionId/resourceGroups/dca-tech-policy-rg"

az policy assignment delete --name get-secure-assignment --scope $scope
az policy set-definition delete --name get-secure
az group delete --name dca-tech-policy-rg --yes --no-wait
```
