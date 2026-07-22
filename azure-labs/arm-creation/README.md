# ARM virtual-machine creation lab

This project creates the Azure resources for a Debian 12 virtual machine (VM) from ARM JSON templates. It is designed for a GoLand + Azure CLI workflow: GoLand edits JSON and the integrated terminal runs Azure commands. The Azure Toolkit is not required.

## Files

| File | Purpose |
| --- | --- |
| `azuredeploy.json` | ARM template: NSG, VNet/subnet, Standard public IP, NIC, managed OS disk, and VM. |
| `azuredeploy.parameters.json` | Non-secret deployment choices: names, Mexico Central, zone 1, B1ls, and a 32 GiB OS disk. |
| [`docs/arm-template-basics.md`](docs/arm-template-basics.md) | Beginner-friendly explanation of ARM template sections, parameters, variables, resources, outputs, API versions, and dependencies. |
| [`examples/`](examples/README.md) | Separate, deployable starter, storage-account, and Windows VM/NIC template examples. |

The VM configuration matches the requested baseline: `Standard_B1ls`, Debian 12, x64, Trusted Launch with Secure Boot and vTPM, an SSH public key, a zonal Standard public IP, and a `Premium_LRS` managed OS disk. SSH (TCP/22) is open to the Internet for lab access.

> Security: this is intentionally a lab template. Before using it beyond personal testing, restrict the NSG rule's `sourceAddressPrefix` from `*` to your public IP or trusted network range.

## Prepare GoLand and Azure CLI

Install the **Bicep** plugin in GoLand at **Settings → Plugins → Marketplace → Bicep**. It adds Bicep language support if you later choose to author Bicep; JSON ARM templates work directly in GoLand without it.

In GoLand's integrated PowerShell terminal, authenticate and install the Bicep CLI:

```powershell
az login
az bicep install
az account show --output table
```

If the active subscription is not the intended one, select it explicitly:

```powershell
az account set --subscription "Visual Studio Professional Subscription"
```

## Prepare the SSH key

The parameter file deliberately does not contain `adminPublicKey`. Keep private keys out of source control and pass only the public key at deployment time.

Generate an RSA key only if you do not already have one:

```powershell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\vm1_key
```

Read its public key into a PowerShell variable:

```powershell
$sshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\vm1_key.pub" -Raw).Trim()
```

The template's image reference uses `Debian:debian-12:12:latest`. Marketplace availability can differ by region and subscription, so check it before deployment:

```powershell
az vm image list --location mexicocentral --publisher Debian --offer debian-12 --all --output table
```

If the output does not contain the selected image SKU, update the template's `imageReference` with a valid URN from the result.

## Validate and preview the deployment

Set the lab resource-group and deployment names:

```powershell
$resourceGroup = "example"
$location = "mexicocentral"
$deploymentName = "vm1-deployment"
```

Check the JSON locally, create the empty resource group, then validate with Azure:

```powershell
Get-Content .\azuredeploy.json -Raw | ConvertFrom-Json | Out-Null
Get-Content .\azuredeploy.parameters.json -Raw | ConvertFrom-Json | Out-Null

az group create --name $resourceGroup --location $location

az deployment group validate `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --template-file .\azuredeploy.json `
  --parameters .\azuredeploy.parameters.json "adminPublicKey=$sshPublicKey"
```

Preview the exact resource changes before creation:

```powershell
az deployment group what-if `
  --resource-group $resourceGroup `
  --template-file .\azuredeploy.json `
  --parameters .\azuredeploy.parameters.json "adminPublicKey=$sshPublicKey"
```

`what-if` previews ARM resource changes; it does **not** calculate a price. It can also reveal whether the selected B1ls size is supported in Mexico Central zone 1. If that SKU/zone combination is unavailable, choose a supported size or zone in the parameter file.

## Create and check the VM

Create the full deployment:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --template-file .\azuredeploy.json `
  --parameters .\azuredeploy.parameters.json "adminPublicKey=$sshPublicKey"
```

Check the deployment state and its outputs, including the public IP and SSH command:

```powershell
az deployment group show `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --query "{state:properties.provisioningState, outputs:properties.outputs}" `
  --output jsonc
```

List every resource in the group:

```powershell
az resource list `
  --resource-group $resourceGroup `
  --query "[].{Name:name, Type:type, Location:location}" `
  --output table
```

Check individual resource types as needed:

```powershell
az vm list --resource-group $resourceGroup --output table
az disk list --resource-group $resourceGroup --output table
az network public-ip list --resource-group $resourceGroup --output table
az network nic list --resource-group $resourceGroup --output table
az network vnet list --resource-group $resourceGroup --output table
az network nsg list --resource-group $resourceGroup --output table
```

## Cost planning and control

ARM does not return a deployment price. Before deployment, use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) and add: a Linux `Standard_B1ls` VM in Mexico Central, one Premium SSD managed disk (32 GiB or the provisioned tier), one Standard public IPv4 address, and expected outbound bandwidth. Estimates vary by agreement, currency, taxes, region, and usage; do not treat a planning estimate as a quote.

For a small development VM, the main ongoing charges are VM running time, the provisioned managed-disk tier, the public IP, diagnostics storage, and outbound data. Debian normally adds no OS licence charge. A virtual network, subnet, NIC, NSG, Trusted Launch, and availability zone do not normally add a separate charge for this single-VM layout. Premium SSD may be disproportionate for a B1ls lab; use `StandardSSD_LRS` in the template if its performance is sufficient.

To stop compute billing when the VM is not in use, deallocate it from Azure—not merely shut down Debian from inside the guest:

```powershell
az vm deallocate --resource-group $resourceGroup --name vm1
az vm start --resource-group $resourceGroup --name vm1
```

Deallocation stops VM compute charges, but disks, public IPs, diagnostics storage, and any committed reservations can remain billable. Review real spending in **Azure portal → Cost Management + Billing → Cost analysis** and create a budget/alert for the lab subscription.

## Delete the lab

First inspect what will be removed and check for locks:

```powershell
az resource list --resource-group $resourceGroup --output table
az lock list --resource-group $resourceGroup --output table
```

For this dedicated lab, delete the entire resource group. Azure removes dependent resources in the required order:

```powershell
az group delete --name $resourceGroup --yes --no-wait
```

Check until it returns `false`:

```powershell
az group exists --name $resourceGroup
```

> Warning: deleting a resource group permanently deletes every resource in it. Confirm that `$resourceGroup` is the dedicated lab group before running the command.

To delete only the VM while retaining the network, use `az vm delete --resource-group $resourceGroup --name vm1 --yes`; then list the resource group and deliberately remove any remaining disk, NIC, public IP, NSG, or VNet that you no longer need.
