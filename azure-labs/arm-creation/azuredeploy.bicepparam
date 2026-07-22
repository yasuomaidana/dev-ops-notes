using './azuredeploy.bicep'

param vmName = 'vm1'
param location = 'mexicocentral'
param availabilityZone = '1'
param vmSize = 'Standard_B1ls'
param adminUsername = 'azureuser'
param virtualNetworkName = 'vnet-mexicocentral-1'
param subnetName = 'snet-mexicocentral-1'
param publicIpName = 'vm1-ip'
param networkInterfaceName = 'vm1-nic'
param networkSecurityGroupName = 'vm1-nsg'
param osDiskSizeGB = 32
