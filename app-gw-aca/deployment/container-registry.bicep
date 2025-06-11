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

@description('Output the login server property for later use')
output acrId string = acrResource.id
