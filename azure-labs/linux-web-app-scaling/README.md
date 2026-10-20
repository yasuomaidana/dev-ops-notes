# Linux Web App scaling lab

This lab teaches the same scaling change with two different tools:

1. Azure CLI + Bicep: deploy a small baseline, scale it, verify it, and delete the resource group.
2. OpenTofu: deploy the same baseline, scale it, verify it, and keep the OpenTofu-managed resources and state.

The two phases are deliberately separate. Azure does not create OpenTofu state, and OpenTofu does not read Azure
deployment history as state. Do not switch tools for the same resources unless you intentionally import those resources
into the new tool's state.

## What this lab changes

- Vertical scaling changes the App Service plan SKU. This lab keeps the `B1` SKU so the exercise stays inexpensive.
- Horizontal scaling changes the number of workers from `1` to `2`.
- Runtime scaling upgrades Node.js from `20-lts` to `22-lts`.

The runtime syntax is tool-specific:

- `az webapp list-runtimes --os-type linux` displays `NODE:22-lts`.
- Bicep's `linuxFxVersion` uses `NODE|22-lts`.
- OpenTofu's `node_version` uses `22-lts`.

The Node runtime must be compatible with the application. For a real application, check its `package.json` `engines`
field and test the application before changing the production runtime.

## Prerequisites

Run these commands from this directory:

```powershell
az login
az account list --all --query "[].{Name:name, Id:id, Tenant:tenantId, State:state, Default:isDefault}" -o table

# Use the subscription that should contain this lab.
$subscriptionId = "<subscription-id>"
az account set --subscription $subscriptionId
$env:ARM_SUBSCRIPTION_ID = $subscriptionId

az account show --query "{Name:name, Id:id, Tenant:tenantId, State:state}" -o table
az bicep version
tofu version
```

The AzureRM provider 4.x needs a subscription ID. Setting `ARM_SUBSCRIPTION_ID` in the current PowerShell session is
the simplest way to provide it to OpenTofu. Set it again when opening a new PowerShell session.

Before changing a runtime, confirm that Azure offers it:

```powershell
az webapp list-runtimes --os-type linux -o tsv | Select-String "NODE:22-lts"
```

## Phase 1: deploy and scale with Azure CLI + Bicep

The Bicep parameter file is the baseline: Node 20, B1, and one worker. The scale-up parameter file changes only the
runtime and worker count, changing the runtime to Node 22 and the worker count to two. Keeping the values in a
parameter file also avoids Windows shell quoting problems with the `|` in `NODE|22-lts`.

Set the names used by this walkthrough:

```powershell
$resourceGroup = "rg-testing-web-apps"
$location = "mexicocentral"
$hostingPlanName = "example-linux-plan"
$webAppPrefix = "example-linux-webapp"

$groupExists = (az group exists --name $resourceGroup --subscription $subscriptionId).Trim()
if ($groupExists -eq "true") {
    throw "The lab resource group '$resourceGroup' already exists. Inspect it before continuing."
}
```

Create the resource group and deploy the baseline. `az deployment group create` is idempotent for the same names: it
creates or updates the resources described by the template.

```powershell
az group create `
  --name $resourceGroup `
  --location $location `
  --tags lab=linux-web-app-scaling phase=bicep

az deployment group create `
  --resource-group $resourceGroup `
  --name linux-web-app-scaling-baseline `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

Verify that the baseline has one B1 worker and Node 20:

```powershell
az appservice plan show `
  --resource-group $resourceGroup `
  --name $hostingPlanName `
  --query "{Sku:sku.name, Workers:sku.capacity}" `
  -o table

$webAppName = (az webapp list `
  --resource-group $resourceGroup `
  --query "[?starts_with(name, '$webAppPrefix')].name | [0]" `
  -o tsv).Trim()

az webapp config show `
  --resource-group $resourceGroup `
  --name $webAppName `
  --query linuxFxVersion `
  -o tsv
```

Apply the scale-up. The Bicep template supports both changes through parameters; the template itself does not need to
be copied or merged with the `linux-web-app` directory.

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name linux-web-app-scaling-node22-two-workers `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.scale.bicepparam
```

Verify the scale-up:

```powershell
az appservice plan show `
  --resource-group $resourceGroup `
  --name $hostingPlanName `
  --query "{Sku:sku.name, Workers:sku.capacity}" `
  -o table

az webapp config show `
  --resource-group $resourceGroup `
  --name $webAppName `
  --query linuxFxVersion `
  -o tsv
```

The expected result is `B1`, `2`, and `NODE|22-lts`.

## Clean up the Azure/Bicep phase

This check prevents accidentally deleting a resource group that belongs to another exercise. Inspect the resource list
first, then delete the whole tagged group:

```powershell
$group = az group show --subscription $subscriptionId --name $resourceGroup | ConvertFrom-Json
if ($group.tags.lab -ne "linux-web-app-scaling" -or $group.tags.phase -ne "bicep") {
    throw "Refusing to delete '$resourceGroup': its expected lab tags were not found."
}

az resource list --subscription $subscriptionId --resource-group $resourceGroup --query "[].{Name:name, Type:type, Id:id}" -o table
az group delete --subscription $subscriptionId --name $resourceGroup --yes --no-wait

for ($i = 0; $i -lt 60; $i++) {
    if ((az group exists --subscription $subscriptionId --name $resourceGroup).Trim() -eq "false") {
        break
    }
    Start-Sleep -Seconds 10
}

if ((az group exists --subscription $subscriptionId --name $resourceGroup).Trim() -eq "true") {
    throw "The Azure resource group still exists; do not start the OpenTofu phase yet."
}
```

Deleting the resource group removes the App Service plan, web app, deployment policy, and other resources created in
the Bicep phase. The Bicep deployment records are not OpenTofu state and do not need to be merged into OpenTofu.

## Phase 2: deploy and scale with OpenTofu

The OpenTofu configuration is in `opentofu`. It has its own local state file. In this repository, the earlier
`linux-web-app` example may have stale state from a resource group that was deleted manually. State is local metadata,
so removing stale entries does not delete Azure resources; it only makes the state truthful again.

If you opened a new PowerShell session, repeat the subscription and name variables from the prerequisites and Phase 1
before running the verification commands below.

First create a backup and inspect the state. Run the state-removal commands only if the listed addresses are present
and the Azure resource group was already deleted:

```powershell
Set-Location .\opentofu

$stateBackup = "terraform.tfstate.before-scaling-$(Get-Date -Format yyyyMMdd-HHmmss).bak"
if (Test-Path .\terraform.tfstate) {
    Copy-Item .\terraform.tfstate $stateBackup
}

tofu state list
```

For the old `..\linux-web-app` state, inspect its list first. If it contains only the five resources from that lab and
the Azure resource group no longer exists, remove those stale state entries from that lab's `opentofu` directory:

```powershell
Set-Location ..\..\linux-web-app\opentofu
tofu state list
tofu state rm azurerm_linux_web_app.web_app_lab
tofu state rm azurerm_resource_group.web_app_lab
tofu state rm azurerm_resource_group_template_deployment.web_app_basic_publishing_policies
tofu state rm azurerm_service_plan.web_app_lab
tofu state rm random_string.web_app_suffix

Set-Location ..\..\linux-web-app-scaling\opentofu
```

If the base lab's `tofu state list` is empty but `tofu output` still shows old hostnames, move that now-empty state file
to a recoverable backup. This removes stale outputs without deleting any Azure resource:

```powershell
Set-Location ..\..\linux-web-app\opentofu
$addresses = @(tofu state list)
if ($addresses.Count -eq 0 -and (Test-Path .\terraform.tfstate)) {
    Move-Item .\terraform.tfstate ("terraform.tfstate.after-stale-cleanup-" + (Get-Date -Format yyyyMMdd-HHmmss) + ".bak")
}
Set-Location ..\..\linux-web-app-scaling\opentofu
```

For the scaling lab's previous partial state, remove only these entries after confirming they are the entries shown by
`tofu state list` and that the old Azure group is gone:

```powershell
tofu state rm azurerm_resource_group.web_app_scaling
tofu state rm random_string.web_app_suffix
```

Do not run `tofu state rm` as a substitute for deleting live Azure resources. It changes only local state. Conversely,
do not run `tofu apply` while state still refers to a resource group that no longer exists: OpenTofu may try to update or
destroy a stale object before it can converge.

Initialize and validate the clean scaling configuration:

```powershell
tofu init
tofu fmt -check
tofu validate
```

For a fresh run, set `terraform.tfvars` to the same resource-group and plan names as the Bicep phase, B1, one worker,
and Node 20 before creating the baseline plan:

```hcl
resource_group_name = "rg-testing-web-apps"
web_app_name_prefix = "example-linux-webapp"
hosting_plan_name   = "example-linux-plan"
sku_code            = "B1"
number_of_workers   = 1
node_version        = "20-lts"
```

The OpenTofu web-app resource also explicitly disables FTP and Web Deploy basic publishing credentials; the policy
deployment reinforces those settings in Azure. Create and review the baseline plan before applying it:

```powershell
tofu plan -out linux-web-app-scaling-baseline.tfplan
tofu show linux-web-app-scaling-baseline.tfplan
tofu apply linux-web-app-scaling-baseline.tfplan
```

Now edit `terraform.tfvars` and change only these values:

```hcl
number_of_workers = 2
node_version      = "22-lts"
```

Create, review, and apply the scale-up plan:

```powershell
tofu plan -out linux-web-app-scaling-node22-two-workers.tfplan
tofu show linux-web-app-scaling-node22-two-workers.tfplan
tofu apply linux-web-app-scaling-node22-two-workers.tfplan
```

Leave the final `number_of_workers = 2` and `node_version = "22-lts"` values in `terraform.tfvars` so a later
`tofu plan` describes the resources that are actually running. This completed workspace is left in that final state.

Verify the final OpenTofu-managed resources in Azure:

```powershell
az appservice plan show `
  --resource-group $resourceGroup `
  --name $hostingPlanName `
  --query "{Sku:sku.name, Workers:sku.capacity}" `
  -o table

$webAppName = (az webapp list `
  --resource-group $resourceGroup `
  --query "[?starts_with(name, '$webAppPrefix')].name | [0]" `
  -o tsv).Trim()
az webapp config show --resource-group $resourceGroup --name $webAppName --query linuxFxVersion -o tsv
tofu output
```

Leave these OpenTofu resources and `terraform.tfstate` in place for the learning exercise. When you are finished with
the lab, inspect the plan and run `tofu destroy` from this directory if you want to remove them:

```powershell
tofu plan -destroy -out linux-web-app-scaling-destroy.tfplan
tofu show linux-web-app-scaling-destroy.tfplan
tofu apply linux-web-app-scaling-destroy.tfplan
```

## Why the earlier workflow failed

- The old base lab and this scaling lab used different resource names and different random suffixes. Configuration in
  one directory cannot automatically reuse state from another directory.
- The scaling state contained a resource group and random suffix, but the complete app and plan were not consistently
  represented in the same state. That made the plan try to create or replace objects unexpectedly.
- AzureRM provider 4.x requires a subscription ID. Azure CLI login alone is not enough for OpenTofu; set
  `ARM_SUBSCRIPTION_ID` or configure `subscription_id` explicitly.
- `tofu plan` is a preview. It does not perform the scale operation until its saved plan is applied.
- A plan containing `-/+` means replacement, not an in-place scale. Stop and reconcile names, state, and configuration
  before applying such a plan.
- The Azure CLI Windows wrapper can interpret the `|` in an inline `NODE|22-lts` parameter as a shell separator. The
  dedicated `azuredeploy.scale.bicepparam` file avoids that quoting trap.
- The AzureRM web-app resource defaults publishing credentials to enabled when those fields are omitted. The explicit
  `false` values in `opentofu/main.tf` keep the OpenTofu plan consistent with the disabled publishing-policy resources.

The safe alternatives are to use a new resource-group/name set for a fresh exercise, or to align names and explicitly
import existing Azure resources before making OpenTofu the owner.
