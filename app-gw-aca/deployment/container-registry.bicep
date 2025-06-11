@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string

@description('Provide a location for the registry.')
param location string

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('The tags that will be applied to the Azure Container Registry')
param tags object

resource acrResource 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: acrName
  tags: tags
  location: location
  sku: {
    name: acrSku
  }

  properties: {
    adminUserEnabled: false
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${acrName}-identity'
  location: location
}

resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role definition ID
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentity.id, acrPullRoleDefinition.id)
  properties: {
    roleDefinitionId: acrPullRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Output the login server property for later use')
output acrId string = acrResource.id
@description('Output the login server URL of the Azure Container Registry')
output acrLoginServer string = acrResource.properties.loginServer
@description('Output the managed identity ID with Pull permissions for the Azure Container Registry')
output managedIdentityId string = managedIdentity.id
