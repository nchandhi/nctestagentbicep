// ========== main.bicep ========== //
targetScope = 'resourceGroup'
var abbrs = loadJsonContent('./abbreviations.json')
@minLength(3)
@maxLength(20)
@description('A unique prefix for all resources in this deployment. This should be 3-20 characters long:')
param environmentName string

@minLength(1)
@description('GPT model deployment type:')
@allowed([
  'Standard'
  'GlobalStandard'
])
param deploymentType string = 'GlobalStandard'

@description('Name of the GPT model to deploy:')
param gptModelName string = 'gpt-4o-mini'

@description('Version of the GPT model to deploy:')
param gptModelVersion string = '2024-07-18'

param azureOpenAIApiVersion string = '2025-01-01-preview'

param azureAiAgentApiVersion string = '2025-05-01'

@minValue(10)
@description('Capacity of the GPT deployment:')
// You can increase this, but capacity is limited per model/region, so you will get errors if you go over
// https://learn.microsoft.com/en-us/azure/ai-services/openai/quotas-limits
param gptDeploymentCapacity int = 150

@minLength(1)
@description('Name of the Text Embedding model to deploy:')
@allowed([
  'text-embedding-ada-002'
])
param embeddingModel string = 'text-embedding-ada-002'

@minValue(10)
@description('Capacity of the Embedding Model deployment')
param embeddingDeploymentCapacity int = 80

param AZURE_LOCATION string=''
var solutionLocation = empty(AZURE_LOCATION) ? resourceGroup().location : AZURE_LOCATION


var uniqueId = toLower(uniqueString(subscription().id, environmentName, solutionLocation, resourceGroup().name))


@metadata({
  azd:{
    type: 'location'
    usageName: [
      'OpenAI.GlobalStandard.gpt-4o-mini,150'
      'OpenAI.GlobalStandard.text-embedding-ada-002,80'
    ]
  }
})
@description('Location for AI Foundry deployment. This is the location where the AI Foundry resources will be deployed.')
param aiDeploymentsLocation string

var solutionPrefix = 'km${padLeft(take(uniqueId, 12), 12, '0')}'


var baseUrl = 'https://raw.githubusercontent.com/nchandhi/nctestagentbicep/main/'


// ========== Managed Identity ========== //
module managedIdentityModule 'deploy_managed_identity.bicep' = {
  name: 'deploy_managed_identity'
  params: {
    miName:'${abbrs.security.managedIdentity}${solutionPrefix}'
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  scope: resourceGroup(resourceGroup().name)
}

// ==========Key Vault Module ========== //
module kvault 'deploy_keyvault.bicep' = {
  name: 'deploy_keyvault'
  params: {
    keyvaultName: '${abbrs.security.keyVault}${solutionPrefix}'
    solutionLocation: solutionLocation
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

// ==========AI Foundry and related resources ========== //
module aifoundry 'deploy_ai_foundry.bicep' = {
  name: 'deploy_ai_foundry'
  params: {
    solutionName: solutionPrefix
    solutionLocation: aiDeploymentsLocation
    keyVaultName: kvault.outputs.keyvaultName
    deploymentType: deploymentType
    gptModelName: gptModelName
    gptModelVersion: gptModelVersion
    azureOpenAIApiVersion: azureOpenAIApiVersion
    gptDeploymentCapacity: gptDeploymentCapacity
    embeddingModel: embeddingModel
    embeddingDeploymentCapacity: embeddingDeploymentCapacity
    managedIdentityObjectId: managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

//========== Deployment script to process and index data ========== //
module createAgent 'run_agent_scripts.bicep' = {
  name : 'run_agent_scripts'
  params:{
    solutionLocation: solutionLocation
    managedIdentityResourceId:managedIdentityModule.outputs.managedIdentityOutput.id
    managedIdentityClientId:managedIdentityModule.outputs.managedIdentityOutput.clientId
    baseUrl:baseUrl
    keyVaultName:aifoundry.outputs.keyvaultName
    projectEndpoint: aifoundry.outputs.projectEndpoint
  }
}

output SOLUTION_NAME string = solutionPrefix
output RESOURCE_GROUP_NAME string = resourceGroup().name
output RESOURCE_GROUP_LOCATION string = solutionLocation
output ENVIRONMENT_NAME string = environmentName

output AZURE_AI_PROJECT_CONN_STRING string = aifoundry.outputs.projectEndpoint
output AZURE_AI_AGENT_API_VERSION string = azureAiAgentApiVersion
output AZURE_AI_FOUNDRY_NAME string = aifoundry.outputs.aiServicesName
output AZURE_AI_PROJECT_NAME string = aifoundry.outputs.aiProjectName

output AGENT_ID string = createAgent.outputs.agentId
