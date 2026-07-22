targetScope = 'subscription'

@description('Resource group used for the policy assignment scope and for testing the VM deployment.')
param resourceGroupName string = 'dca-tech-policy-rg'

@description('Azure region for the resource group deployment record.')
param resourceGroupLocation string = deployment().location

@description('Custom initiative name.')
param initiativeName string = 'get-secure'

@description('Custom initiative display name.')
param initiativeDisplayName string = 'Get Secure'

@description('Custom initiative description.')
param initiativeDescription string = 'Audits Windows virtual machines that do not use Azure Disk Encryption or EncryptionAtHost.'

@description('Initiative category shown in Azure Policy.')
param initiativeCategory string = 'Compute'

@description('Policy assignment name.')
param assignmentName string = 'get-secure-assignment'

@description('Policy assignment display name.')
param assignmentDisplayName string = 'Get Secure assignment'

@description('Policy assignment description.')
param assignmentDescription string = 'Assigns the Get Secure initiative to the lab resource group.'

@description('Non-compliance message shown in Azure Policy.')
param nonComplianceMessage string = 'Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.'

@description('Built-in policy definition ID for "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."')
param builtInPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0'

resource labResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

resource initiative 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: initiativeName
  properties: {
    policyType: 'Custom'
    displayName: initiativeDisplayName
    description: initiativeDescription
    metadata: {
      category: initiativeCategory
    }
    policyDefinitions: [
      {
        policyDefinitionReferenceId: 'windowsVmDiskEncryption'
        policyDefinitionId: builtInPolicyDefinitionId
      }
    ]
  }
}

module initiativeAssignment './modules/policy-assignment.bicep' = {
  name: '${assignmentName}-module'
  scope: resourceGroup(resourceGroupName)
  params: {
    assignmentName: assignmentName
    assignmentDisplayName: assignmentDisplayName
    assignmentDescription: assignmentDescription
    policyDefinitionId: initiative.id
    nonComplianceMessage: nonComplianceMessage
  }
  dependsOn: [
    labResourceGroup
    initiative
  ]
}

output resourceGroupId string = labResourceGroup.id
output initiativeId string = initiative.id
output assignmentId string = initiativeAssignment.outputs.assignmentId
