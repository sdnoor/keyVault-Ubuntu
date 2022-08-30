param location string
param project string
param computerName string
param vmSize string
param adminUsername string
param adminKey string


@allowed([
  'prod'
  'dev'
])
param environmentType string

var vmName = 'ubuntu-${project}-${location}-${environmentType}'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
     {
      path: '/home/${adminUsername}/.ssh/authorized_keys}'
      keyData: adminKey
     }
    ]
  }
}
var osDiskName = 'osDisk-${project}-${location}-${environmentType}'
var nicName = 'nic-${project}-${location}-${environmentType}'
var pubIP = 'pubIP-${project}-${location}-${environmentType}'
var subnetAg = 'ag-${project}-${location}-${environmentType}'
var storageAccountName = 'st${project}${location}${environmentType}'




resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminKey
      linuxConfiguration: any(linuxConfiguration == 'password' ? 'null':'linuxConfiguration')
      
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'storageUri'
      }
    }
  }
}
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: pubIP
        properties: {
          publicIPAddress: {
           id: publicIPAddress.id
 sku: {
  tier: 'Global'
 }          
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: pubIP
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'cebsdevops'
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'name'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetAg
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}


