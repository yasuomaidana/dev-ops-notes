# Azure CLI setup

Use this shared setup before starting an Azure lab. Each lab keeps its own deployment, verification, and cleanup commands.

## Sign in and select a subscription

```powershell
az login
az account list --all --query "[].{Name:name, Id:id, Tenant:tenantId, State:state, Default:isDefault}" -o table

# Select the subscription that should contain the lab resources.
$subscriptionId = "<subscription-id>"
az account set --subscription $subscriptionId
az account show --query "{Name:name, Id:id, Tenant:tenantId, State:state}" -o table
```

Confirm the active subscription before creating resources. Lab cleanup commands can delete every resource in the named resource group. Set the subscription again in each new PowerShell session.

## Check the tools used by a lab

```powershell
az version
az bicep install
az bicep version
tofu version
```

OpenTofu is needed only for labs that include an OpenTofu workflow. AzureRM provider configurations may also require the subscription ID in the current shell:

```powershell
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
```
