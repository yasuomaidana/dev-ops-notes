targetScope = 'resourceGroup'

@description('Policy assignment name.')
param assignmentName string

@description('Policy assignment display name.')
param assignmentDisplayName string

@description('Policy assignment description.')
param assignmentDescription string

@description('Policy definition or initiative ID to assign.')
param policyDefinitionId string

@description('Non-compliance message shown in Azure Policy.')
param nonComplianceMessage string

resource initiativeAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: assignmentName
  properties: {
    displayName: assignmentDisplayName
    description: assignmentDescription
    policyDefinitionId: policyDefinitionId
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: nonComplianceMessage
      }
    ]
  }
}

output assignmentId string = initiativeAssignment.id
