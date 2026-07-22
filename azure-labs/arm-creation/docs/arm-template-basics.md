# ARM template example breakdown

This guide explains the building blocks of an Azure Resource Manager (ARM) JSON template. The examples use a small storage account first, followed by a Windows VM and network interface (NIC). The VM example is educational: it expects the virtual network and subnet to exist already.

> JSON ARM templates must be valid JSON. Do not put `//` comments in `azuredeploy.json`; JSON does not support comments. Put explanations in this guide or in each property's `metadata.description` instead.

## What an ARM template is

An ARM template is a declarative JSON file that describes the Azure resources Azure Resource Manager should deploy. You specify the desired state, and Azure creates or updates the resources in the required order.

The main sections are:

| Section | Purpose |
| --- | --- |
| `$schema` | Identifies the template JSON schema. |
| `contentVersion` | Your version label for the template. |
| `parameters` | Deployment-time inputs. |
| `variables` | Reusable expressions evaluated inside the template. |
| `resources` | Azure resources to create or update. |
| `outputs` | Values returned after deployment. |

## `$schema` and `contentVersion`

Every template begins with a schema URL and a template version. The schema helps editors validate the document and helps Azure interpret the template format. `contentVersion` is a version you maintain; change it when that helps you track template revisions.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": []
}
```

## First resource: a storage account

The following valid template creates a StorageV2 account. Replace `replace-with-unique-name` with a globally unique, lowercase storage-account name (3–24 characters, numbers and lowercase letters only).

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2021-09-01",
      "name": "replace-with-unique-name",
      "location": "eastus",
      "sku": {
        "name": "Standard_LRS"
      },
      "kind": "StorageV2",
      "properties": {
        "supportsHttpsTrafficOnly": true
      }
    }
  ]
}
```

`type` identifies the Azure resource provider and resource type. `apiVersion` selects the resource API contract, `name` identifies the resource, and `location` selects its Azure region.

## Parameters

Parameters make a template reusable. Their values are supplied through a parameters file or on the deployment command line. A parameter can have validation such as `minLength`, `maxLength`, and `allowedValues`.

This version accepts the storage account name at deployment time:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageName": {
      "type": "string",
      "minLength": 3,
      "maxLength": 24,
      "metadata": {
        "description": "Globally unique lowercase storage account name."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2021-09-01",
      "name": "[parameters('storageName')]",
      "location": "eastus",
      "sku": {
        "name": "Standard_LRS"
      },
      "kind": "StorageV2",
      "properties": {
        "supportsHttpsTrafficOnly": true
      }
    }
  ]
}
```

Useful parameter types include `string`, `int`, `bool`, `array`, `object`, and `secureString`. Use `secureString` for secrets such as an administrator password; do not commit secret values to a parameters file. For real deployments, prefer retrieving secrets from Azure Key Vault where appropriate.

### VM parameters

The VM example uses these inputs:

```json
"parameters": {
  "vmSize": {
    "type": "string",
    "defaultValue": "Standard_DS1_v2",
    "allowedValues": ["Standard_DS1_v2", "Standard_DS2_v2"],
    "metadata": {
      "description": "Specifies the virtual machine size."
    }
  },
  "adminUsername": {
    "type": "string",
    "metadata": {
      "description": "Specifies the virtual machine administrator username."
    }
  },
  "adminPassword": {
    "type": "secureString",
    "metadata": {
      "description": "Specifies the virtual machine administrator password."
    }
  }
}
```

`vmSize` is limited to two compatible choices. `adminUsername` is plain text, while `adminPassword` is treated as a secret by ARM and should never be placed in source control or deployment output.

## Variables

Variables are internal, reusable values. They are useful for resource IDs and repeated expressions. This variable resolves the resource ID of an existing subnet named `mySubnet` in `myVNet` in the deployment resource group:

```json
"variables": {
  "subnetRef": "[resourceId('Microsoft.Network/virtualNetworks/subnets', 'myVNet', 'mySubnet')]"
}
```

Before deploying, ensure that subnet exists. A `resourceId()` expression creates an ID string; it does not create the resource or by itself establish an ordering dependency.

## VM and NIC resources

This example creates a Windows Server 2019 VM named `myVM` and a NIC named `myNIC`. The VM needs the NIC first, so its `dependsOn` lists the NIC. The NIC connects to the existing subnet through `subnetRef`.

```json
"resources": [
  {
    "type": "Microsoft.Network/networkInterfaces",
    "apiVersion": "2022-03-01",
    "name": "myNIC",
    "location": "[resourceGroup().location]",
    "properties": {
      "ipConfigurations": [
        {
          "name": "ipconfig1",
          "properties": {
            "subnet": {
              "id": "[variables('subnetRef')]"
            }
          }
        }
      ]
    }
  },
  {
    "type": "Microsoft.Compute/virtualMachines",
    "apiVersion": "2022-03-01",
    "name": "myVM",
    "location": "[resourceGroup().location]",
    "dependsOn": [
      "[resourceId('Microsoft.Network/networkInterfaces', 'myNIC')]"
    ],
    "properties": {
      "hardwareProfile": {
        "vmSize": "[parameters('vmSize')]"
      },
      "osProfile": {
        "computerName": "myVM",
        "adminUsername": "[parameters('adminUsername')]",
        "adminPassword": "[parameters('adminPassword')]"
      },
      "storageProfile": {
        "imageReference": {
          "publisher": "MicrosoftWindowsServer",
          "offer": "WindowsServer",
          "sku": "2019-Datacenter",
          "version": "latest"
        },
        "osDisk": {
          "createOption": "FromImage"
        }
      },
      "networkProfile": {
        "networkInterfaces": [
          {
            "id": "[resourceId('Microsoft.Network/networkInterfaces', 'myNIC')]"
          }
        ]
      }
    }
  }
]
```

The VM's `hardwareProfile` reads the VM size parameter. `osProfile` configures the computer and administrator account. `storageProfile` selects the marketplace image and creates its OS disk from that image. `networkProfile` attaches the NIC.

## Outputs

Outputs return useful deployment values. The VM example can start empty:

```json
"outputs": {}
```

For example, a template that creates a public IP can return it with `reference()`:

```json
"outputs": {
  "publicIpAddress": {
    "type": "string",
    "value": "[reference(resourceId('Microsoft.Network/publicIPAddresses', 'myPublicIp'), '2024-05-01').ipAddress]"
  }
}
```

`reference()` reads properties from a deployed resource and creates an implicit dependency when it refers to a resource in the same template. Use it for values that must be read from another resource, rather than adding unnecessary `dependsOn` entries.

## API versions and dependencies

- Use a current, hard-coded `apiVersion` supported by the resource type. Do not make API versions parameters or variables.
- Use implicit dependencies where a `reference()` expression reads another resource. Use `dependsOn` when an ordering requirement cannot be expressed implicitly, such as the VM-to-NIC relationship above.
- Define child resources only after, or with a dependency on, their parent resource.
- If a resource has `condition: false`, do not let another resource unconditionally depend on it.
- Avoid dependencies that are not needed: independent resources can deploy in parallel.

## Additional guidance

- Use `metadata.description` and external documentation to explain a JSON template.
- Retrieve dynamic endpoints with `reference()` instead of hard-coding values that Azure assigns.
- Treat public IP addresses as an exception: restrict inbound rules and follow your organization’s security requirements.
- Do not put passwords in custom-script extensions, source-controlled parameter files, or deployment output. Use managed identities and Key Vault where possible.
- Set explicit property values when an Azure default changing later could affect the deployment.

## Relation to this lab

The lab's [deployment template](../azuredeploy.json) is a fuller Linux example. It creates its own NSG, VNet/subnet, public IP, NIC, managed disk configuration, and Debian VM. Its [parameters file](../azuredeploy.parameters.json) holds non-secret selections; the SSH public key is supplied at deployment time.

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
