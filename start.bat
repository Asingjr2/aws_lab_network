@echo on
REM find a way to call out script name

set /p varProjectStage="Please tell me desired stage for project deploment (i.e. prod, demo, etc):   "
set /p DemoProjectKMSKey="Please tell me desired kms key to use:    "
set varStack=%varProjectStage%-network-project-stack

REM find a way to generate a file with variables
REM need to create other stacks to match .sh files

aws cloudformation create-stack --stack-name $varStack --template-body file://parent.yaml  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://demo_project_parameters.json
aws cloudformation wait stack-create-complete --stack-name $varStack;
