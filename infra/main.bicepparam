using './main.bicep'

param environmentName = 'nctestagent8141'
param deploymentType = 'GlobalStandard'
param gptModelName = 'gpt-4o-mini'
param gptModelVersion = '2024-07-18'
param azureOpenAIApiVersion = '2025-01-01-preview'
param azureAiAgentApiVersion = '2025-05-01'
param gptDeploymentCapacity = 150
param embeddingModel = 'text-embedding-ada-002'
param embeddingDeploymentCapacity = 80
param AZURE_LOCATION = 'eastus'
param aiDeploymentsLocation = 'eastus'

