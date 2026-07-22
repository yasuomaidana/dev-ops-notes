targetScope = 'resourceGroup'

// Azure Portal mapping:
// Policy -> Assign initiative -> Assignment name
@description('Policy assignment name.')
param assignmentName string

// Azure Portal mapping:
// Policy -> Assign initiative -> Basics -> Display name
@description('Policy assignment display name.')
param assignmentDisplayName string

// Azure Portal mapping:
// Policy -> Assign initiative -> Basics -> Description
@description('Policy assignment description.')
param assignmentDescription string

// Azure Portal mapping:
// This corresponds to the initiative selected before clicking Assign initiative.
@description('Policy definition or initiative ID to assign.')
param policyDefinitionId string

// Azure Portal mapping:
// Policy -> Assign initiative -> Non-compliance messages -> Message
@description('Non-compliance message shown in Azure Policy.')
param nonComplianceMessage string

// Azure Portal equivalent:
// Policy -> Assign initiative -> Review + create -> Create
resource initiativeAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: assignmentName
  properties: {
    displayName: assignmentDisplayName
    description: assignmentDescription
    policyDefinitionId: policyDefinitionId
    // Portal equivalent: enforcement remains enabled.
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: nonComplianceMessage
      }
    ]
  }
}

output assignmentId string = initiativeAssignment.id
