# Azure Policy lab with OpenTofu

This OpenTofu configuration creates the same Azure Policy lab as the [Bicep version](../README.md): a resource group,
the custom `Get Secure` initiative, and a resource-group assignment that includes Microsoft's built-in Windows VM disk
encryption policy.

The default resource group is `dca-tech-policy-rg` in `eastus`. The initiative and assignment names match the Bicep
lab. The built-in policy audits compliance; it does not block VM creation. A Windows VM without **Encryption at host**
should deploy and later appear as non-compliant after Azure Policy evaluates it.

## Files

| File | Purpose |
| --- | --- |
| [`providers.tf`](./providers.tf) | OpenTofu and AzureRM provider requirements. |
| [`variables.tf`](./variables.tf) | Configurable resource names, descriptions, and policy settings. |
| [`main.tf`](./main.tf) | Resource group, custom initiative, and resource-group assignment. |
| [`outputs.tf`](./outputs.tf) | Resource IDs for the created lab resources. |
| [`terraform.tfvars.example`](./terraform.tfvars.example) | Example values matching the Bicep lab scenario. |

## Prerequisites

Complete the shared [Azure CLI setup](../../getting-started.md), sign in with `az login`, and select the subscription for
the lab. Set the AzureRM provider's subscription ID in the current PowerShell session:

```powershell
$subscriptionId = az account show --query id -o tsv
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
```

The identity used by OpenTofu needs permission to create resource groups and manage Azure Policy definitions and
assignments at subscription and resource-group scope.

## Deploy

From the repository root:

```powershell
Set-Location .\azure-labs\azure-policy\opentofu
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
tofu init
tofu fmt
tofu validate
tofu plan -out azure-policy.tfplan
tofu apply azure-policy.tfplan
```

Review the plan before applying. It should create the lab resource group, the `Get Secure` initiative, and the assignment
at that resource group's scope.

## Verify the policy objects

```powershell
$resourceGroup = "dca-tech-policy-rg"
$subscriptionId = az account show --query id -o tsv
$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"

az group show --name $resourceGroup --output table
az policy set-definition show --name get-secure --output jsonc
az policy assignment show --name get-secure-assignment --scope $scope --output jsonc
```

## Test compliance

Create a Windows VM in `dca-tech-policy-rg` through the Azure portal and leave **Encryption at host** unchecked. VM
creation should succeed. After policy evaluation runs, check the result with:

```powershell
az policy state list --resource-group $resourceGroup --output table
```

Azure Policy evaluation is not immediate. If the VM does not appear in the results yet, wait a few minutes and check
again. You can also open **Policy > Compliance**, search for `Get Secure`, and inspect the VM's compliance details.

## Clean up

From the OpenTofu directory, remove the resources tracked in this OpenTofu state:

```powershell
tofu destroy
```

## Bicep and OpenTofu state

The Bicep and OpenTofu versions are alternative implementations with separate deployment records and state. They use
the same Azure resource names, so clean up the resources with the tool that created them before switching to the other
version. OpenTofu cannot destroy resources created by Bicep unless they are first imported into its state.
