#!/bin/bash
echo "Started the index script setup..."

# Variables
baseUrl="$1"
keyvaultName="$2"
managedIdentityClientId="$3"
projectEndpoint="$4"
requirementFile="requirements.txt"
requirementFileUrl="${baseUrl}infra/scripts/agent_scripts/requirements.txt"

echo "Downloading files..."
curl --output "01_create_agents.py" "${baseUrl}infra/scripts/agent_scripts/01_create_agents.py"

# Download and install Python requirements
curl --output "$requirementFile" "$requirementFileUrl"
pip install --upgrade pip
pip install -r "$requirementFile"

#Replace placeholder values with actuals
sed -i "s#project_endpoint_to-be-replaced#${projectEndpoint}#g" 01_create_agents.py
sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "01_create_agents.py"
sed -i "s/mici_to-be-replaced/${managedIdentityClientId}/g" "01_create_agents.py"

# Execute the Python scripts
echo "Running Python agent scripts..."
# python 01_create_agents.py
agentId=$(python 01_create_agents.py)

echo "agent creation completed."

# write outputs for Bicep
printf '{"agentId":"%s"}' "$agentId" > "$AZ_SCRIPTS_OUTPUT_PATH"