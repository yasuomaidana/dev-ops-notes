@description('Specifies the virtual machine size.')
@allowed([
  'Standard_DS1_v2'
  'Standard_DS2_v2'
])
param vmSize string = 'Standard_DS1_v2'

@description('Specifies the virtual machine administrator username.')
param adminUsername string

@secure()
@description('Specifies the virtual machine administrator password.')
param adminPassword string

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', 'myVNet', 'mySubnet')

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

output deploymentInfo object = {}
