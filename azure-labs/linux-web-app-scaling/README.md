# Linux Web App scaling lab

This lab teaches the same scaling change with two different tools:

1. Azure CLI + Bicep: deploy a small baseline, scale it, verify it, and delete the resource group.
2. OpenTofu: deploy the same baseline, scale it, verify it, and keep the OpenTofu-managed resources and state.

The two phases are deliberately separate. Azure does not create OpenTofu state, and OpenTofu does not read Azure
deployment history as state. Do not switch tools for the same resources unless you intentionally import those resources
into the new tool's state.

Source files: [Bicep template](./azuredeploy.bicep), [baseline parameters](./azuredeploy.bicepparam), [scale-up parameters](./azuredeploy.scale.bicepparam), and [OpenTofu configuration](./opentofu/main.tf).

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

Complete the shared [Azure CLI setup](../getting-started.md) first. Keep the same PowerShell session open so `$subscriptionId` is available for OpenTofu.

```powershell
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
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

The OpenTofu configuration is in `opentofu`. The working directory matters: OpenTofu loads the `.tf` files and the
default local state for the directory from which you run it. Run all commands in this section from
`azure-labs/linux-web-app-scaling/opentofu`.

### Configuration, Azure resources, and state are different things

The `.tf` files describe the resources you want. Azure holds the actual resource group, plan, and app. OpenTofu state
is a separate record that connects configuration addresses (such as `azurerm_service_plan.web_app_scaling`) to the
real Azure resource IDs and remembers generated values such as the random web-app suffix. By default this state is a
local file named `terraform.tfstate` in this working directory. It is not stored in Azure and is not recreated merely
by running `tofu init`.

Consequently, `tofu state list` returning **"No state file was found"** means OpenTofu has no state file in this
directory. It does not mean the configuration is missing, and it does not query Azure to see whether resources exist.
`tofu init` installs providers and initializes the working directory; it does not create resources or recover state.

Choose the workflow that matches the situation:

1. **The resource group and its resources were deleted.** This is a fresh deployment. Initialize, plan, inspect the
   plan, then apply. Since there is no state, the plan should show new resources. Do not first run `state rm`; there
   are no state entries to remove. If the resource group was deleted outside OpenTofu but a state file remains, back
   up and inspect that state before deciding how to reconcile it.
2. **The resources still exist and you are using another computer.** The configuration alone is insufficient. The
   new computer needs the same state (including the random suffix) to manage those same resources. A local state file
   on the first computer is not automatically available on the second. For ongoing multi-computer use, configure a
   shared remote backend with locking and secure access, or deliberately import existing Azure resources into a
   fresh state. Do not run a fresh apply with an empty state against resources that already exist: OpenTofu may try
   to create duplicate names or report conflicts.
3. **The resources still exist but state is missing.** Treat this as a recovery/import task, not a fresh deployment.
   Back up any state you do have, identify the exact Azure resource IDs, and import/reconcile the resources before
   applying. A plan must not propose replacing or duplicating live resources.

### Check the working directory and state

From the repository root in PowerShell, move to the OpenTofu directory and check for a state file before listing addresses:

```powershell
Set-Location .\azure-labs\linux-web-app-scaling\opentofu
Get-Location
Get-ChildItem -Force terraform.tfstate*
tofu state list
```

If no state file exists and the Azure resource group is gone, continue with the fresh deployment below. If a state file
exists, make a backup before state maintenance:

```powershell
$stateBackup = "terraform.tfstate.before-scaling-$(Get-Date -Format yyyyMMdd-HHmmss).bak"
Copy-Item .\terraform.tfstate $stateBackup
tofu state list
```

The old `linux-web-app` example has a separate working directory and separate local state. It does not share state with
this scaling lab. Only if that old lab's Azure resources were deleted and its state still lists stale addresses, remove
the stale entries from that lab's own `opentofu` directory after backing up its state. `tofu state rm` only forgets
state entries; it does not delete Azure resources. Never remove entries for resources that still exist unless you are
intentionally preparing to import them again.

If you previously removed every address from a state but old outputs remain, those outputs are state data too. Back up
and move aside that empty lab state file to clear its outputs. Keep the backup so it can be recovered if needed.

### Ensure OpenTofu is available in the terminal

Before running the workflow, check that the terminal can find OpenTofu:

```powershell
Get-Command tofu
tofu version
```

If PowerShell says `tofu` is not recognized, install OpenTofu for Windows and add the directory containing `tofu.exe`
to the Windows `PATH`. Then open a **new terminal tab** in GoLand and repeat these checks. A terminal inherits its
environment when it starts, so restarting only the terminal tab after changing PATH is sufficient; restarting GoLand
does not install OpenTofu or add it to PATH. You can also invoke `tofu.exe` by its full path while diagnosing PATH.
The command must work in the same terminal session before the steps below will work.

GoLand's terminal runs a shell (usually PowerShell) and inherits Windows environment variables. If `tofu` works in an
external PowerShell but not GoLand, close that project's terminal tab, open a new one, and check its PATH. If it still
fails, inspect GoLand's terminal shell settings and the PATH visible in that terminal; do not terminate other GoLand
windows or processes.

If you opened a new PowerShell session, repeat the subscription and name variables from the prerequisites and Phase 1
before running the verification commands below.

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
