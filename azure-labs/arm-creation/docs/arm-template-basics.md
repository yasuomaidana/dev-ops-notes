# Bicep example breakdown

This guide explains the building blocks of a Bicep deployment. Bicep is the modern authoring layer for Azure Resource
Manager (ARM): you write `.bicep`, and Azure compiles it to JSON at deployment time. The examples use a small storage
account first, followed by a Windows VM and network interface (NIC). The VM example is educational: it expects the
virtual network and subnet to exist already.

> Bicep supports comments, symbolic resource names, and simpler expressions. Raw ARM JSON is still useful to recognize,
> but prefer authoring new deployments in `.bicep`.

## What a Bicep file is

A Bicep file is a declarative source file that describes the Azure resources Azure Resource Manager should deploy. You
specify the desired state, Bicep compiles to ARM JSON, and Azure creates or updates the resources in the required
order.

The main sections are:

| Section | Purpose |
| --- | --- |
| `targetScope` | Optional deployment scope such as resource group or subscription. |
| `parameters` | Deployment-time inputs. |
| `variables` | Reusable expressions evaluated inside the template. |
| `resources` | Azure resources to create or update. |
| `outputs` | Values returned after deployment. |

## Minimal structure

Unlike raw ARM JSON, Bicep does not require a `$schema` block or `contentVersion`. A minimal resource-group-scope file
can be as small as:

```bicep
resource exampleStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'replace-with-unique-name'
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
```

## First resource: a storage account

The following valid Bicep file creates a StorageV2 account. Replace `replace-with-unique-name` with a globally unique,
lowercase storage-account name (3–24 characters, numbers and lowercase letters only).

```bicep
resource exampleStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'replace-with-unique-name'
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
```

The resource declaration identifies the Azure resource provider and resource type. The API version is part of the
resource header, `name` identifies the resource, and `location` selects its Azure region.

## Parameters

Parameters make a deployment reusable. Their values are supplied through a `.bicepparam` file or on the deployment
command line. A parameter can have validation such as `@minLength`, `@maxLength`, and `@allowed`.

This version accepts the storage account name at deployment time:

```bicep
@minLength(3)
@maxLength(24)
@description('Globally unique lowercase storage account name.')
param storageName string

resource exampleStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
```

Useful parameter types include `string`, `int`, `bool`, `array`, `object`, and `secureString`. In Bicep, secure values
are declared with the `@secure()` decorator. Do not commit secret values to a `.bicepparam` file. For real
deployments, prefer retrieving secrets from Azure Key Vault where appropriate.

### VM parameters

The VM example uses these inputs:

```bicep
@allowed([
  'Standard_DS1_v2'
  'Standard_DS2_v2'
])
@description('Specifies the virtual machine size.')
param vmSize string = 'Standard_DS1_v2'

@description('Specifies the virtual machine administrator username.')
param adminUsername string

@secure()
@description('Specifies the virtual machine administrator password.')
param adminPassword string
```

`vmSize` is limited to two compatible choices. `adminUsername` is plain text, while `adminPassword` is treated as a
secret and should never be placed in source control or deployment output.

## Variables

Variables are internal, reusable values. They are useful for resource IDs and repeated expressions. This variable
resolves the resource ID of an existing subnet named `mySubnet` in `myVNet` in the deployment resource group:

```bicep
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', 'myVNet', 'mySubnet')
```

Before deploying, ensure that subnet exists. A `resourceId()` expression creates an ID string; it does not create the resource or by itself establish an ordering dependency.

## VM and NIC resources

This example creates a Windows Server 2019 VM named `myVM` and a NIC named `myNIC`. The VM needs the NIC first, so its `dependsOn` lists the NIC. The NIC connects to the existing subnet through `subnetRef`.

```bicep
resource nic 'Microsoft.Network/networkInterfaces@2022-03-01' = {
  name: 'myNIC'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: 'myVM'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'myVM'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
```

The VM's `hardwareProfile` reads the VM size parameter. `osProfile` configures the computer and administrator account. `storageProfile` selects the marketplace image and creates its OS disk from that image. `networkProfile` attaches the NIC.

## Outputs

Outputs return useful deployment values. The VM example can start empty:

```bicep
output deploymentInfo object = {}
```

For example, a template that creates a public IP can return it with `reference()`:

```bicep
output publicIpAddress string = reference(resourceId('Microsoft.Network/publicIPAddresses', 'myPublicIp'), '2024-05-01').ipAddress
```

`reference()` reads properties from a deployed resource and creates an implicit dependency when it refers to a resource in the same template. Use it for values that must be read from another resource, rather than adding unnecessary `dependsOn` entries.

## API versions and dependencies

- Use a current, hard-coded `apiVersion` supported by the resource type. Do not make API versions parameters or variables.
- Use implicit dependencies where a `reference()` expression reads another resource. Use `dependsOn` when an ordering requirement cannot be expressed implicitly, such as the VM-to-NIC relationship above.
- Define child resources only after, or with a dependency on, their parent resource.
- If a resource has `condition: false`, do not let another resource unconditionally depend on it.
- Avoid dependencies that are not needed: independent resources can deploy in parallel.

## Additional guidance

- Use `@description()` and external documentation to explain a Bicep file.
- Retrieve dynamic endpoints with `reference()` instead of hard-coding values that Azure assigns.
- Treat public IP addresses as an exception: restrict inbound rules and follow your organization’s security requirements.
- Do not put passwords in custom-script extensions, source-controlled parameter files, or deployment output. Use managed identities and Key Vault where possible.
- Set explicit property values when an Azure default changing later could affect the deployment.

## Relation to this lab

The lab's [deployment file](../azuredeploy.bicep) is a fuller Linux example. It creates its own NSG, VNet/subnet,
public IP, NIC, managed disk configuration, and Debian VM. Its [parameters file](../azuredeploy.bicepparam) holds
non-secret selections; the SSH public key is supplied at deployment time.

## Other deployment commands

Use the following commands after setting the `$resourceGroup` and `$deploymentName` variables shown in the main README.

List deployments in the resource group:

```powershell
az deployment group list --resource-group $resourceGroup --output table
```

Inspect the operations of one deployment. This is useful when a deployment fails because it shows the individual resource operation and its error:

```powershell
az deployment operation group list `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --output jsonc
```

Wait until a deployment succeeds or fails:

```powershell
az deployment group wait `
  --resource-group $resourceGroup `
  --name $deploymentName `
  --created
```

Export the template recorded for a previous deployment:

```powershell
az deployment group export `
  --resource-group $resourceGroup `
  --name $deploymentName
```

Cancel an in-progress deployment:

```powershell
az deployment group cancel `
  --resource-group $resourceGroup `
  --name $deploymentName
```

Delete only the deployment record, not the resources it created:

```powershell
az deployment group delete `
  --resource-group $resourceGroup `
  --name $deploymentName
```

Use `az deployment group --help` or `az deployment group <command> --help` to see the available options for the installed Azure CLI version.
