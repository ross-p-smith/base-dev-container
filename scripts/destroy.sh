#!/bin/bash
set -euo pipefail

# We use WORKSPACE so we can use a single state store but for multiple
# Terraform instances; this is helpful for an instance per Pull Request
WORKSPACE=${WORKSPACE:-default}
echo -e "\e[34mWORKSPACE is $WORKSPACE\e[0m"

# Set these variables so Terraform doesn't complain they're unset when running a destroy
# They're not actually needed for the destroy process so it doesn't matter what they are
TF_VAR_deployer_object_id="00000000-0000-0000-0000-000000000000"
TF_VAR_deployer_display_name="NotDefined"
TF_VAR_branch_id="NotDefined"

# We export these variables so they are available to the Terraform scripts
export TF_VAR_deployer_object_id
export TF_VAR_deployer_display_name
export TF_VAR_branch_id

# Initialise the terraform providers
terraform -chdir=infra/terraform init

# Check whether a workspace exists before we use it
workspace_exists=$(
  terraform -chdir=infra/terraform workspace list | grep -qE "\s${WORKSPACE}$"
  echo $?
)
if [ "$workspace_exists" != "0" ]; then
  echo -e "\e[34m\n*** WORKSPACE ${WORKSPACE} not found - Nothing to destroy ***\e[0m\n"
  exit 0
fi

# Switch workspace
terraform -chdir=infra/terraform workspace select "${WORKSPACE}"

# Destroy deployed infrastructure
terraform -chdir=infra/terraform destroy -auto-approve

# Tidy up the workspace
terraform -chdir=infra/terraform workspace select default
if [ "$WORKSPACE" != "default" ]; then
  terraform -chdir=infra/terraform workspace delete -force "${WORKSPACE}"
fi
