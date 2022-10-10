#!/bin/bash
set -euo pipefail

: "${WORKSPACE?'💥 Check TF WORKSPACE is defined in WORKSPACE in .env'}"

# We use WORKSPACE so we can use a single state store but for multiple
# Terraform instances; this is helpful for an instance per Pull Request
WORKSPACE=${WORKSPACE:-default}
echo -e "\e[34mWORKSPACE is $WORKSPACE\e[0m"

if [ -z "${ARM_CLIENT_ID:-}" ]; then
  SIGNED_IN_USER=$(az ad signed-in-user show --query "{displayName:displayName, id:id}" -o json)
  TF_VAR_deployer_object_id=$(echo "$SIGNED_IN_USER" | jq -r .id)
  TF_VAR_deployer_display_name=$(echo "$SIGNED_IN_USER" | jq -r .displayName)
  TF_VAR_dbranch_id=$(git symbolic-ref --short HEAD)
else
  TF_VAR_deployer_object_id=$(az ad sp show --id "${ARM_CLIENT_ID}" --query id --out tsv)
fi

export TF_VAR_deployer_object_id
export TF_VAR_deployer_display_name
export TF_VAR_dbranch_id

# Initialise the terraform providers
terraform -chdir=infra/terraform init

# Switch to a workspace if one is supplied
workspace_exists=$(
  terraform -chdir=infra/tf workspace list | grep -qE "\s${WORKSPACE}$"
  echo $?
)

if [[ "$workspace_exists" == "0" ]]; then
  echo -e "\e[34mWORKSPACE $WORKSPACE found - selecting\e[0m"
  terraform -chdir=infra/terraform workspace select "$WORKSPACE"
else
  echo -e "\e[34mWORKSPACE $WORKSPACE not found - creating new\e[0m"
  terraform -chdir=infra/terraform workspace new "$WORKSPACE"
fi

# Plan the terraform deployment
terraform -chdir=infra/terraform plan -out infra.tfplan

# Apply the terraform deployment using the plan file
terraform -chdir=infra/terraform apply infra.tfplan

# We only do this when we are running locally
if [ -f ".env" ]; then
  terraform -chdir=infra/terraform output -json > infra/terraform/terraform_output.json
  scripts/json-to-env.sh < infra/terraform/terraform_output.json > infra/terraform/terraform.env

  # Remove everything after a pattern and then merge our .env file with the terraform output
  sed -i '0,/^# =================================================/I!d' .env
  sed -i '/^# =================================================/ r infra/terraform/terraform.env' .env
fi
