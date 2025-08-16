// Creates Azure dependent resources for Azure AI studio
param solutionName string
param solutionLocation string
param keyVaultName string=''
param deploymentType string
param gptModelName string
param gptModelVersion string
param azureOpenAIApiVersion string
param gptDeploymentCapacity int
param embeddingModel string
param embeddingDeploymentCapacity int
param managedIdentityObjectId string=''

var abbrs = loadJsonContent('./abbreviations.json')
var aiServicesName = '${abbrs.ai.aiServices}${solutionName}'
var workspaceName = '${abbrs.managementGovernance.logAnalyticsWorkspace}${solutionName}'
var applicationInsightsName = '${abbrs.managementGovernance.applicationInsights}${solutionName}'
var keyvaultName = '${abbrs.security.keyVault}${solutionName}'
var location = solutionLocation //'eastus2'
var aiProjectName = '${abbrs.ai.aiFoundryProject}${solutionName}'

var aiModelDeployments = [
  {
    name: gptModelName
    model: gptModelName
    sku: {
      name: deploymentType
      capacity: gptDeploymentCapacity
    }
    version: gptModelVersion
    raiPolicyName: 'Microsoft.Default'
  }
  {
    name: embeddingModel
    model: embeddingModel
    sku: {
      name: 'GlobalStandard'
      capacity: embeddingDeploymentCapacity
    }
    raiPolicyName: 'Microsoft.Default'
  }
]


resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: {}
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' =  {
  name: aiServicesName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: aiServicesName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false //needs to be false to access keys 
  }
}


@batchSize(1)
resource aiServicesDeployments 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = [for aiModeldeployment in aiModelDeployments:  {
  parent: aiServices //aiServices_m
  name: aiModeldeployment.name
  properties: {
    model: {
      format: 'OpenAI'
      name: aiModeldeployment.model
    }
    raiPolicyName: aiModeldeployment.raiPolicyName
  }
  sku:{
    name: aiModeldeployment.sku.name
    capacity: aiModeldeployment.sku.capacity
  }
}]

resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' =  {
  parent: aiServices
  name: aiProjectName
  location: solutionLocation
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource aiUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '53ca6127-db72-4b80-b1b0-d745d6d5456d'
}


resource assignFoundryRoleToMI 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(resourceGroup().id, aiServices.id, aiUser.id)
  scope: aiServices
  properties: {
    principalId: managedIdentityObjectId
    roleDefinitionId: aiUser.id
    principalType: 'ServicePrincipal'
  }
}


output keyvaultName string = keyvaultName
output keyvaultId string = keyVault.id
output aiServicesTarget string = aiServices.properties.endpoints['OpenAI Language Model Instance API'] //aiServices_m.properties.endpoint
output aiServicesName string = aiServicesName

output aiProjectName string = aiProject.name
output projectEndpoint string = aiProject.properties.endpoints['AI Foundry API']
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
