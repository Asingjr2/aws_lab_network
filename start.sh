#!/bin/bash -x

varCurrentFile=$(basename $0)
echo "Executing $varCurrentFile"

read -p "Please tell me desired stage for project deploment (i.e. prod, demo, etc):    " varProjectStage
echo 
read -p "Please tell me desired kms key to use:    " varDemoProjectKMSKey
varParentStack=$varProjectStage-parent-network-project-stack
varDatabaseStack=$varProjectStage-network-project-stack

# creating stack
aws cloudformation create-stack --stack-name $varDatabaseStack --template-body file://cfn/database.yaml  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://demo_project_parameters.json
aws cloudformation wait stack-create-complete --stack-name $varDatabaseStack;
# getting stack output and uploading code
varBucketName=$(aws cloudformation describe-stacks --stack-name $varDatabaseStack | jq '.["Stacks"][0]["Outputs"][0]["OutputValue"]' | tr -d '""')
aws s3 sync cfn s3://$varBucketName/cfn

echo "
[
    {
    \"ParameterKey\": \"DemoProjectStage\",
    \"ParameterValue\": \"${varProjectStage}\"
    },
    {
    \"ParameterKey\": \"DemoProjectKMSKey\",
    \"ParameterValue\": \"${varDemoProjectKMSKey}\"
    },
    {
    \"ParameterKey\": \"NetworkTemplate\",
    \"ParameterValue\": \"https://${varBucketName}.s3.amazonaws.com/cfn/network.yaml\"
    },
    {
    \"ParameterKey\": \"PermissionsTemplate\",
    \"ParameterValue\": \"https://${varBucketName}.s3.amazonaws.com/cfn/permissions.yaml\"
    }
" > demo_project_parameters.json

# creating parent stack
aws cloudformation create-stack --stack-name $varParentStack --template-body file://parent.yaml  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://demo_project_parameters.json
aws cloudformation wait stack-create-complete --stack-name $varParentStack;
