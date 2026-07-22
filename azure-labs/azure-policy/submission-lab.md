# Azure Policy Submission Lab

This file is the step-by-step version to follow for the DCA Tech lab submission.

## Important note before you start

As of **July 22, 2026**, the Microsoft built-in policy **Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.** uses the `AuditIfNotExists` effect, not `Deny`.

That means the test VM is expected to:

- Deploy successfully.
- Show as **Non-compliant** later in Azure Policy compliance results.

It is **not** expected to fail at validation time with this built-in policy.

## Step 1: Open the lab folder

Work from:

```text
azure-labs/azure-policy
```

Files used in this lab:

- `azuredeploy.bicep`
- `azuredeploy.bicepparam`

## Step 2: Sign in to Azure

Run:

```powershell
az login
az bicep install
az account show --output table
```

If you need to switch subscriptions:

```powershell
az account set --subscription "<your-subscription>"
```

## Step 3: Review the command reference

Use this table during the lab.

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
| Policy assignments | `az policy assignment show --name get-secure-assignment --scope $scope --output jsonc` | Show the assignment at the lab scope. |
| Policy state | `az policy state list --resource-group $resourceGroup --output table` | List compliance results for resources in the lab resource group. |
| Cleanup | `az policy assignment delete --name get-secure-assignment --scope $scope` | Delete the assignment first. |
| Cleanup | `az policy set-definition delete --name get-secure` | Delete the custom initiative after the assignment is gone. |
| Cleanup | `az group delete --name $resourceGroup --yes --no-wait` | Delete the lab resource group and everything in it. |
| Help | `az deployment sub --help` | Show subscription deployment commands. |
| Help | `az policy --help` | Show Azure Policy commands. |

## Step 4: Understand what the Bicep deploys

The Bicep template creates:

1. A resource group named `dca-tech-policy-rg`.
2. A custom initiative named `Get Secure`.
3. A policy assignment named `get-secure-assignment`.

The initiative includes this Microsoft built-in policy:

```text
/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0
```

Display name:

```text
Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.
```

## Step 5: Validate the Bicep deployment

Run:

```powershell
$location = "eastus"
$deploymentName = "azure-policy-get-secure"
$resourceGroup = "dca-tech-policy-rg"
```

Then validate:

```powershell
az deployment sub validate `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

## Step 6: Preview the deployment

Run:

```powershell
az deployment sub what-if `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

Review the output. You should see:

- A resource group being created.
- A policy set definition being created.
- A policy assignment being created.

## Step 7: Deploy the lab

Run:

```powershell
az deployment sub create `
  --location $location `
  --name $deploymentName `
  --template-file .\azuredeploy.bicep `
  --parameters .\azuredeploy.bicepparam
```

## Step 8: Confirm the deployment

Run:

```powershell
az deployment sub show `
  --location $location `
  --name $deploymentName `
  --output jsonc
```

Then set the scope and inspect the policy objects:

```powershell
$subscriptionId = az account show --query id -o tsv
$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"
```

Run:

```powershell
az group show --name $resourceGroup --output table
az policy set-definition show --name get-secure --output jsonc
az policy assignment show --name get-secure-assignment --scope $scope --output jsonc
```

## Step 9: Open Azure Portal and review the deployed policy

In Azure Portal:

1. Open **Resource groups**.
2. Open `dca-tech-policy-rg`.
3. Confirm the resource group exists.
4. Search for **Policy**.
5. Open **Initiatives** and confirm `Get Secure` exists.
6. Open **Assignments** and confirm `get-secure-assignment` exists for the resource group.

This lab should not be split into separate manual authoring tasks such as:

- creating a new policy definition,
- entering policy definition location, name, description, and category,
- creating a separate initiative by hand,
- selecting policy definitions manually in the portal,
- configuring policy parameters manually in the portal.

Those actions are already handled by the Bicep deployment. In this lab, the portal is mainly for verification and for
creating the test VM.

## Step 10: Create the test VM

In Azure Portal:

1. Go to `dca-tech-policy-rg`.
2. Select **Create**.
3. Create a **Windows virtual machine**.
4. Keep the defaults.
5. Enter any VM name.
6. Enter any network name if prompted.
7. On the **Disks** tab, make sure **Encryption at host** is **not** checked.
8. Select **Review + create**.
9. Select **Create**.

## Step 11: Expected result for the VM

With this built-in policy, the expected result is:

- The VM creation should succeed.
- The VM should later be reported as **Non-compliant** by Azure Policy.

If your course material says the VM creation should fail immediately, that is not how this built-in policy behaves on
**July 22, 2026**.

## Step 12: Check compliance in the Azure Portal

In Azure Portal:

1. Open **Policy**.
2. Open **Compliance**.
3. Search for `Get Secure`.
4. Open the initiative.
5. Review the compliance state.
6. Open the non-compliant resource details for the VM.

## Step 13: Check compliance with Azure CLI

Run:

```powershell
az policy state list --resource-group $resourceGroup --output table
```

If no result appears yet, wait a few minutes and run the command again.

## Step 14: What to write in your submission

Your submission can state:

1. A resource group was created for the lab.
2. A Bicep deployment created the `Get Secure` initiative and assigned it to the lab resource group.
3. The initiative included the built-in policy `Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.`
4. A Windows VM was created with **Encryption at host** turned off.
5. The VM deployed successfully.
6. Azure Policy later marked the VM as non-compliant.

## Step 15: Clean up the lab

Run:

```powershell
az policy assignment delete --name get-secure-assignment --scope $scope
az policy set-definition delete --name get-secure
az group delete --name $resourceGroup --yes --no-wait
```

## Source references

- Microsoft Learn policy reference: https://learn.microsoft.com/en-us/azure/virtual-machines/policy-reference
- Microsoft Learn disk encryption overview: https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview
