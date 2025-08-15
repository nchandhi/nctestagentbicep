#!/bin/bash
echo "Started the index script setup..."

# Variables
baseUrl="$1"
keyvaultName="$2"
managedIdentityClientId="$3"
requirementFile="requirements.txt"
requirementFileUrl="${baseUrl}infra/scripts/agent_scripts/requirements.txt"

# # # Step 1: Install system dependencies (Alpine Linux style)
# # echo "Installing system dependencies..."
# # apk update
# # apk add --no-cache curl bash jq py3-pip gcc musl-dev libffi-dev openssl-dev python3-dev
# # apk add --no-cache --virtual .build-deps build-base unixodbc-dev

# # # Install Microsoft ODBC and SQL tools
# # echo "Installing MS ODBC drivers and tools..."
# # curl -s -o msodbcsql17_17.10.6.1-1_amd64.apk https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.6.1-1_amd64.apk
# # curl -s -o mssql-tools_17.10.1.1-1_amd64.apk https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.apk
# # apk add --allow-untrusted msodbcsql17_17.10.6.1-1_amd64.apk
# # apk add --allow-untrusted mssql-tools_17.10.1.1-1_amd64.apk

# # Step 2: Download index scripts
# echo "Downloading index scripts..."
# curl --output "01_create_search_index.py" "${baseUrl}infra/scripts/index_scripts/01_create_agents.py"

# # Step 3: Download and install Python requirements
# echo "Installing Python requirements..."
# curl --output "$requirementFile" "$requirementFileUrl"
# pip install --upgrade pip
# pip install -r "$requirementFile"

# # Step 4: Replace placeholder values with actuals
# echo "Substituting key vault and identity details..."
# #Replace key vault name 
# sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "01_create_search_index.py"
# sed -i "s/mici_to-be-replaced/${managedIdentityClientId}/g" "01_create_search_index.py"
# sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "02_create_cu_template_text.py"
# sed -i "s/mici_to-be-replaced/${managedIdentityClientId}/g" "02_create_cu_template_text.py"
# sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "02_create_cu_template_audio.py"
# sed -i "s/mici_to-be-replaced/${managedIdentityClientId}/g" "02_create_cu_template_audio.py"
# sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "03_cu_process_data_text.py"
# sed -i "s/mici_to-be-replaced/${managedIdentityClientId}/g" "03_cu_process_data_text.py"


# # Step 5: Execute the Python scripts
# echo "Running Python index scripts..."
# python 01_create_agents.py

echo "agent creation completed successfully."

# # IMPORTANT: write outputs for Bicep here
# {
#   echo "copyStatus=success"
#   echo "filesCopied=$keyvaultName"
# } >> "$AZ_SCRIPTS_OUTPUT_PATH"


printf 'kvname=%s\n' "$keyvaultNam" >> "$AZ_SCRIPTS_OUTPUT_PATH"