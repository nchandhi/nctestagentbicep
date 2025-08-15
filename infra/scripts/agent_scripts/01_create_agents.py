# from azure.keyvault.secrets import SecretClient
# from azure.search.documents.indexes import SearchIndexClient
# from azure.search.documents.indexes.models import (
#     SearchField,
#     SearchFieldDataType,
#     VectorSearch,
#     HnswAlgorithmConfiguration,
#     VectorSearchProfile,
#     AzureOpenAIVectorizer,
#     AzureOpenAIVectorizerParameters,
#     SemanticConfiguration,
#     SemanticSearch,
#     SemanticPrioritizedFields,
#     SemanticField,
#     SearchIndex
# )
# from azure_credential_utils import get_azure_credential

# # === Configuration ===
# KEY_VAULT_NAME = 'kv_to-be-replaced'
# MANAGED_IDENTITY_CLIENT_ID = 'mici_to-be-replaced'
# INDEX_NAME = "call_transcripts_index"

import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

KEY_VAULT_NAME = 'kv_to-be-replaced'
ai_project_endpoint = 'project_endpoint_to-be-replaced'  # This will be replaced in the script


# Initialize the AI project client
project_client = AIProjectClient(
    endpoint= ai_project_endpoint,
    credential=DefaultAzureCredential(),
)

instructions='''You are a helpful assistant'''
with project_client:
    agents_client = project_client.agents
    agent = agents_client.create_agent(
        model='gpt-4o-mini',
        name="my-agent1",
        instructions=instructions
    )
    print(agent.id)