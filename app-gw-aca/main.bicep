@description('The suffix applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location to deploy all these resources to')
param location string = resourceGroup().location

@description('The tags to apply to all resources')
param tags object = {
  Application: 'Zero-Trust Minibank Deposits'
  Environment: 'DEMO'
}

@description('The name of the container app env')
param envName string = 'env-${appSuffix}'

@description('The name of the Virtual Network that will be deployed')
param virtualNetworkName string = 'vnet-${appSuffix}'

@description('The name of the Log Analytics workspace that will be deployed')
param logAnalyticsName string = 'law-${appSuffix}'

@description('The name of the Container App that will be deployed')
param containerAppName string = 'app-${appSuffix}'

@description('The name of the App Gateway that will be deployed')
param appGatewayName string = 'gw-${appSuffix}'

@description('The name of the Public IP address that will be deployed')
param ipAddressName string = '${appGatewayName}-pip'

@description('The name of the Private Link Service that will be created')
param privateLinkServiceName string = 'my-agw-private-link'

@description('This is the built-in Contributor role. See https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource networkContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, deployer().objectId, networkContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: networkContributorRoleDefinition.id
    principalId: deployer().objectId
    principalType: 'User'
  }
}

module vnet 'network/virtual-network.bicep' = {
  name: 'vnet'
  params: {
    location: location 
    tags: tags
    vnetName: virtualNetworkName
  }
}

module law 'monitoring/log-analytics.bicep' = {
  name: 'law'
  params: {
    location: location 
    logAnalyticsWorkspaceName: logAnalyticsName
    tags: tags
  }
}

module env 'host/container-app-env.bicep' = {
  name: 'env'
  params: {
    acaSubnetId: vnet.outputs.acaSubnetId 
    envName: envName 
    lawName: law.outputs.name
    location: location
    tags: tags
  }
}

module accountapi 'host/container-app.bicep' = {
  name: 'accountapi'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerAppName: 'app-accountapi-${appSuffix}'
    containerImage: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    location: location
    tags: tags
  }
}

module paymentapi 'host/container-app.bicep' = {
  name: 'paymentapi'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerAppName: 'app-paymentapi-${appSuffix}'
    containerImage: 'kennethreitz/httpbin:latest'
    location: location
    tags: tags
  }
}

module privateDnsZone 'network/private-dns-zone.bicep' = {
  name: 'pdns'
  params: {
    envDefaultDomain: env.outputs.domain
    envStaticIp: env.outputs.staticIp
    tags: tags
    vnetName: vnet.outputs.name
  }
}

module appGateway 'network/app-gateway.bicep' = {
  name: 'appgateway'
  params: {
    appGatewayName: appGatewayName
    pool1_fqdn: paymentapi.outputs.fqdn
    pool1_path: '/payments'
    pool2_fqdn: accountapi.outputs.fqdn
    pool2_path: '/accounts'
    envSubnetId: vnet.outputs.acaSubnetId
    ipAddressName: ipAddressName
    location: location
    //privateLinkServiceName: privateLinkServiceName
    subnetId: vnet.outputs.appGatewaySubnetId
    tags: tags
  }
}
