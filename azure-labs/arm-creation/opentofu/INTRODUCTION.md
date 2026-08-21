# Terraform / OpenTofu Intro for This Lab

This folder uses **OpenTofu**, which is a community fork of Terraform. For a beginner, you can treat them the same way:

- You write infrastructure as code in `.tf` files.
- The tool reads those files and builds a dependency graph.
- It compares your code with real cloud resources.
- It shows a plan.
- If you approve it, it creates, updates, or deletes resources.

## The basic idea

Instead of clicking around in the Azure portal, you describe the infrastructure you want:

- a resource group
- a virtual network
- a subnet
- a network security group
- a public IP
- a network interface
- a Linux virtual machine

That description lives in files like [main.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/main.tf), [variables.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/variables.tf), and [outputs.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/outputs.tf).

## How the workflow works

The normal flow is:

1. `tofu init`
2. `tofu plan`
3. `tofu apply`

### `tofu init`

This downloads the provider plugins declared in [providers.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/providers.tf).  
In this lab, the main provider is `azurerm`, which is the Azure provider.

### `tofu plan`

This reads all `.tf` files in the folder, evaluates references, and decides:

- what needs to be created
- in what order
- what values are known now
- what values will only be known after Azure creates the resource

### `tofu apply`

This sends the requests to Azure in dependency order and saves the results in the state file, such as `terraform.tfstate`.

The state file is important because it records things like:

- which resources were created
- their Azure resource IDs
- their current attributes

## What `resource "azurerm_subnet" "vm_lab"` means

This block in [main.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/main.tf:34) defines a subnet:

```hcl
resource "azurerm_subnet" "vm_lab" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.vm_lab.name
  virtual_network_name = azurerm_virtual_network.vm_lab.name
  address_prefixes     = ["10.0.0.0/24"]
}
```

The two labels after `resource` have different meanings:

- `azurerm_subnet` = the resource type from the Azure provider
- `vm_lab` = the local name you gave this resource in the configuration

Together, they form the **resource address**:

`azurerm_subnet.vm_lab`

That address is how other resources refer to this subnet.

## Where `azurerm_subnet.vm_lab.id` comes from

`azurerm_subnet.vm_lab.id` means:

- `azurerm_subnet.vm_lab` = "the subnet resource defined in this configuration"
- `.id` = "give me that resource's ID attribute"

So the value comes from the Azure provider's schema for `azurerm_subnet`. After the subnet is created, Azure returns its real resource ID, and OpenTofu stores it in state.

For Azure, that ID looks roughly like this:

```text
/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>
```

You do **not** hardcode that string here. OpenTofu gets it from Azure after creation and makes it available as `.id`.

## Why it is used in this file

This lab uses `azurerm_subnet.vm_lab.id` in two places:

In [main.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/main.tf:42), the subnet is associated with the network security group:

```hcl
subnet_id = azurerm_subnet.vm_lab.id
```

In [main.tf](C:/Users/yasuo.maidana/GolandProjects/dev-ops-notes/azure-labs/arm-creation/opentofu/main.tf:64), the network interface is attached to that subnet:

```hcl
subnet_id = azurerm_subnet.vm_lab.id
```

This is how OpenTofu knows:

- the subnet must exist before the association can be created
- the subnet must exist before the NIC can be created

That dependency is inferred automatically from the reference.

## A simple mental model

You can read a line like this:

```hcl
subnet_id = azurerm_subnet.vm_lab.id
```

as:

> "Use the ID of the subnet resource named `vm_lab`."

That is all it means.

## How dependencies are discovered

OpenTofu looks at references between resources. For example:

- `azurerm_subnet.vm_lab` depends on `azurerm_virtual_network.vm_lab.name`
- `azurerm_virtual_network.vm_lab` depends on `azurerm_resource_group.vm_lab.name`
- `azurerm_network_interface.vm_lab` depends on `azurerm_subnet.vm_lab.id`
- `azurerm_linux_virtual_machine.vm_lab` depends on `azurerm_network_interface.vm_lab.id`

So it builds the infrastructure in roughly this order:

1. Resource group
2. Network security group
3. Virtual network
4. Subnet
5. Subnet-to-NSG association
6. Public IP
7. Network interface
8. Virtual machine

## Variables vs resources vs outputs

It helps to separate these concepts:

- `var.something` = input value you provide
- `azurerm_x.y` = a managed Azure resource in the configuration
- `output "something"` = a value shown after apply

Examples from this lab:

- `var.subnet_name` is an input variable
- `azurerm_subnet.vm_lab` is the subnet resource
- `azurerm_subnet.vm_lab.id` is one attribute of that resource
- `output "vm_resource_id"` exposes `azurerm_linux_virtual_machine.vm_lab.id`

## Why IDs matter

Cloud APIs usually link resources together using IDs, not friendly names.

For example:

- a NIC needs a subnet ID
- a VM needs network interface IDs
- an NSG association needs both a subnet ID and an NSG ID

That is why you often see `.id` in Terraform/OpenTofu code.

## Short summary

- Terraform/OpenTofu reads your `.tf` files as a desired infrastructure definition.
- `resource "azurerm_subnet" "vm_lab"` creates a subnet resource in the configuration.
- `azurerm_subnet.vm_lab` is the address of that resource.
- `azurerm_subnet.vm_lab.id` is the Azure resource ID returned after creation.
- Other resources use that ID to connect themselves to the subnet.

## Useful next commands

If you want to learn by inspecting the config:

```powershell
tofu validate
tofu plan
tofu state list
tofu output
```

If the resources already exist in state, this is especially useful:

```powershell
tofu state show azurerm_subnet.vm_lab
```

That command will show the recorded attributes for the subnet, including its actual `id`.
