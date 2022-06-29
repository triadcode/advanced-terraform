export ACCESS_KEY="..."
export SECRET_KEY="..."

terraform init \
    -backend-config="bucket=mdm-terraform-state" \
    -backend-config="key=red30/ecommerceapp/app.state" \
    -backend-config="region=us-east-1" \
    -backend-config="dynamodb_table=tfstatelock" \
    -backend-config="access_key=${ACCESS_KEY}" \
    -backend-config="secret_key=${SECRET_KEY}"

 
