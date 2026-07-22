targetScope = 'subscription'

// Azure Portal mapping:
// Resource groups -> Create -> Resource group name
// This value also becomes the scope used when the initiative is assigned.
@description('Resource group used for the policy assignment scope and for testing the VM deployment.')
param resourceGroupName string = 'dca-tech-policy-rg'

// Azure Portal mapping:
// Resource groups -> Create -> Region
@description('Azure region for the resource group deployment record.')
param resourceGroupLocation string = deployment().location

// Azure Portal mapping:
// Policy -> Authoring -> Initiatives -> + Initiative definition -> Name
// This is the resource name used by Azure, not the friendly label.
@description('Custom initiative name.')
param initiativeName string = 'get-secure'

// Azure Portal mapping:
// Policy -> Authoring -> Initiatives -> + Initiative definition -> Display name
@description('Custom initiative display name.')
param initiativeDisplayName string = 'Get Secure'

// Azure Portal mapping:
// Policy -> Authoring -> Initiatives -> + Initiative definition -> Description
@description('Custom initiative description.')
param initiativeDescription string = 'Audits Windows virtual machines that do not use Azure Disk Encryption or EncryptionAtHost.'

// Azure Portal mapping:
// Policy -> Authoring -> Initiatives -> + Initiative definition -> Category
@description('Initiative category shown in Azure Policy.')
param initiativeCategory string = 'Compute'

// Azure Portal mapping:
// Policy -> Assign initiative -> Assignment name
// This is the assignment resource name, not the display text.
@description('Policy assignment name.')
param assignmentName string = 'get-secure-assignment'

// Azure Portal mapping:
// Policy -> Assign initiative -> Basics -> friendly name shown in the assignment view
@description('Policy assignment display name.')
param assignmentDisplayName string = 'Get Secure assignment'

// Azure Portal mapping:
// Policy -> Assign initiative -> Basics -> Description
@description('Policy assignment description.')
param assignmentDescription string = 'Assigns the Get Secure initiative to the lab resource group.'

// Azure Portal mapping:
// Policy -> Assign initiative -> Non-compliance messages -> Message
@description('Non-compliance message shown in Azure Policy.')
param nonComplianceMessage string = 'Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.'

// Azure Portal mapping:
// Policy -> Definitions -> search built-in definitions -> select
// "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
// In code, the UI selection becomes a fixed built-in policy resource ID.
@description('Built-in policy definition ID for "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."')
param builtInPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0'

// Azure Portal equivalent:
// Resource groups -> Create -> Review + create -> Create
resource labResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

// Azure Portal equivalent:
// Policy -> Authoring -> Initiatives -> + Initiative definition
// Basics tab fields map from the initiative* parameters above.
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
        // Azure Portal equivalent:
        // This is a user-defined identifier for the policy entry inside this initiative.
        // It does not come from the built-in policy definition ID or from `az policy definition show`.
        // It only needs to be unique within this initiative.
        policyDefinitionReferenceId: 'windowsVmDiskEncryption'
        // Initiative definition -> Policies tab -> Add policy definition(s)
        policyDefinitionId: builtInPolicyDefinitionId
      }
    ]
  }
}

// Azure Portal equivalent:
// After the initiative exists, the portal flow would be:
// Initiatives -> select "Get Secure" -> Assign initiative
// Because the target scope is a resource group, the actual assignment is deployed through a resource-group module.
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
  ]
}

output resourceGroupId string = labResourceGroup.id
output initiativeId string = initiative.id
output assignmentId string = initiativeAssignment.outputs.assignmentId
