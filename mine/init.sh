#!/bin/bash

ACCESS_KEY=$(terraform -chdir=remote_resources state pull | jq -r '.resources[] | select(.type == "aws_iam_access_key") | .instances[0].attributes.id')
SECRET_KEY=$(terraform -chdir=remote_resources state pull | jq -r '.resources[] | select(.type == "aws_iam_access_key") | .instances[0].attributes.secret')

terraform init \
    -backend-config="bucket=mdm-terraform-state" \
    -backend-config="key=env/terraform.state" \
    -backend-config="region=${REGION:-"us-east-2"}" \
    -backend-config="dynamodb_table=tfstatelock" \
    -backend-config="access_key=${ACCESS_KEY}" \
    -backend-config="secret_key=${SECRET_KEY}"

 
