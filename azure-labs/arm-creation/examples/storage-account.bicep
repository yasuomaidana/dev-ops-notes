resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'replacewithuniquename'
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
