using './azuredeploy.bicep'

// These values are the code equivalent of what you would type into the Azure Portal forms.

// Resource groups -> Create -> Resource group name
param resourceGroupName = 'policy-example'

// Resource groups -> Create -> Region
param resourceGroupLocation = 'eastus'

// Policy -> + Initiative definition -> Name
param initiativeName = 'get-secure'

// Policy -> + Initiative definition -> Display name
param initiativeDisplayName = 'Get Secure'

// Policy -> + Initiative definition -> Description
param initiativeDescription = 'Audits Windows virtual machines that do not use Azure Disk Encryption or EncryptionAtHost.'

// Policy -> + Initiative definition -> Category
param initiativeCategory = 'Compute'

// Policy -> Assign initiative -> Assignment name
param assignmentName = 'get-secure-assignment'

// Policy -> Assign initiative -> Basics -> Display name
param assignmentDisplayName = 'Get Secure assignment'

// Policy -> Assign initiative -> Basics -> Description
param assignmentDescription = 'Assigns the Get Secure initiative to the policy-example resource group.'

// Policy -> Assign initiative -> Non-compliance messages -> Message
param nonComplianceMessage = 'Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.'
