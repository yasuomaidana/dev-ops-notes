# OpenTofu virtual-machine creation lab

This lab creates the same Azure baseline as the Bicep VM lab, but uses OpenTofu configuration files instead of Bicep.
It provisions a Debian 12 virtual machine, a resource group, virtual network, subnet, network security group, public
IP, and network interface.

The configuration keeps the same intended defaults as the Bicep lab:

- `Standard_B1ls`
- Debian 12
- SSH public-key authentication
- Trusted Launch equivalents through Secure Boot and vTPM
- Standard static public IP
- `Premium_LRS` 32 GiB OS disk

> Security: this is still a lab configuration. The NSG opens SSH (`TCP/22`) to `*`. Restrict it before using this
> outside personal testing.

## Files

| File | Purpose |
| --- | --- |
| `providers.tf` | OpenTofu and AzureRM provider requirements. |
| `variables.tf` | Input variables for names, region, SSH key, VM size, and disk settings. |
| `main.tf` | Azure resources for the resource group, network, public IP, NIC, NSG, and Linux VM. |
| `outputs.tf` | Useful outputs including the public IP and SSH command. |
| `terraform.tfvars.example` | Example values; copy to `terraform.tfvars`, keep non-sensitive values there, and prefer env vars for sensitive inputs. |

## Prerequisites

Install and verify:

```powershell
tofu version
az version
az login
az account show --output table
```

If the active subscription is not the intended one, select it explicitly:

```powershell
az account set --subscription "Visual Studio Professional Subscription"
```

## Prepare your variables

Generate an SSH key if you do not already have one:

```powershell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\vm1_key
```

Create your working variable file:

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
```

Read the public key:

```powershell
$sshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\vm1_key.pub" -Raw).Trim()
$sshPublicKey
```

Standard OpenTofu/Terraform practice is to pass sensitive inputs through environment variables named
`TF_VAR_<variable_name>`. In this lab, that variable is `TF_VAR_admin_public_key`:

```powershell
$env:TF_VAR_admin_public_key = (Get-Content "$env:USERPROFILE\.ssh\vm1_key.pub" -Raw).Trim()
```

If you prefer, you can still paste the displayed public key into `admin_public_key` in `terraform.tfvars`. Do not put a
private key in `terraform.tfvars`.

## Initialize and review the plan

From this `opentofu` folder:

```powershell
tofu init
tofu fmt
tofu validate
tofu plan -out vm1.tfplan
```

If the Debian 12 image or selected zone is unavailable in your subscription and region, Azure will report that during
planning or apply. Adjust `location`, `availability_zone`, or `vm_size` in `terraform.tfvars` if needed.

## Create the VM

Apply the reviewed plan:

```powershell
tofu apply vm1.tfplan
```

Inspect the outputs after creation:

```powershell
tofu output
tofu output public_ip_address
tofu output ssh_command
```

## Connect and manage cost

Use the SSH output to connect:

```powershell
ssh azureuser@<public-ip>
```

For cost planning, use the Azure Pricing Calculator and estimate:

- One Linux `Standard_B1ls` VM in Mexico Central
- One `Premium_LRS` 32 GiB managed OS disk
- One Standard public IPv4 address
- Expected outbound bandwidth

To stop compute billing without destroying the lab:

```powershell
az vm deallocate --resource-group example --name vm1
az vm start --resource-group example --name vm1
```

## Destroy the lab

When you are finished:

```powershell
tofu plan -destroy
tofu destroy
```

OpenTofu will remove the resources it manages in dependency order.
