
param location string

@allowed([
  'dev'
  'prod'
])
param environmentType string
param project string
param computerName string
param adminUsername string
param keyVaultName string
param keyVaultRGName string

var vmName = 'ubuntu-${project}-${location}-${environmentType}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultRGName)
}

module virtualMachine 'vm.bicep' = {
  name: vmName
  params: {
    adminUsername: adminUsername
    computerName: computerName
    environmentType: environmentType
    location: location
    project: project
    adminKey: keyVault.getSecret('sshKey')
  }
}


