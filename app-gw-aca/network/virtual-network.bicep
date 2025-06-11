@description('The name of the virtual network')
param vnetName string

@description('Location of the Vnet')
param location string

@description('The tags that will be applied to the VNet')
param tags object

var applicationSubnetName = 'app-subnet'
var appGatewaySubnetName = 'gateway-subnet'
var firewallSubnetName = 'firewall-subnet'
var endpointSubnetName = 'endpoint-subnet'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      { 
        name: applicationSubnetName
        properties: {
          addressPrefix: '10.0.0.0/23'
        }
      }
      { 
        name: appGatewaySubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      { 
        name: firewallSubnetName
        properties: {
          addressPrefix: '10.0.3.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      { 
        name: endpointSubnetName
        properties: {
          addressPrefix: '10.0.4.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }

  resource applicationSubnet 'subnets' existing = {
    name: applicationSubnetName
  }

  resource appGatewaySubnet 'subnets' existing = {
    name: appGatewaySubnetName
  }
  resource firewallSubnet 'subnets' existing = {
    name: firewallSubnetName
  }
  resource endpointSubnet 'subnets' existing = {
    name: endpointSubnetName
  }
}

output name string = vnet.name
output applicationSubnetId string = vnet::applicationSubnet.id
output gatewaySubnetId string = vnet::appGatewaySubnet.id
output firewallSubnetId string = vnet::firewallSubnet.id
