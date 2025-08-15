# import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

KEY_VAULT_NAME = 'kv_to-be-replaced' # This will be replaced in the script
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
        name="my-agent2",
        instructions=instructions
    )
    print(agent.id)