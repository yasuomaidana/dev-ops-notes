@minLength(3)
@maxLength(24)
@description('A globally unique, lowercase storage account name.')
param storageName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
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
