@description('Specifies the location for resources.')
param location string
param baseUrl string // Base URL for the script location
param identity string // Fully qualified resource ID for the managed identity. 
param fabricWorkspaceId string // Workspace ID for the Fabric resources
param timeout string = 'PT30M' // Optional timeout for the deployment script
param forceUpdateTag string = '' // Optional tag to force re-execution when changed

var myArguments = '"${baseUrl}" "${fabricWorkspaceId}"'


resource create_fabric_resources 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'CreateFabricResourcesScriptDeployment'
  location: location // Replace with your desired location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.52.0'
    primaryScriptUri: baseUrl
    arguments: myArguments
    timeout: timeout
    forceUpdateTag: forceUpdateTag
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'OnSuccess'
  }
}

