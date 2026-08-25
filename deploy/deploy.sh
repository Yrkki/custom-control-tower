#!/bin/bash
set -e  # Stop on any error

# 1. Deploy the IAM role first
aws cloudformation deploy \
  --template-file ../resources/IAM/lambda-role.yaml \
  --stack-name ct-lifecycle-enforcer-role \
  --capabilities CAPABILITY_NAMED_IAM \
  --region eu-west-1 \
  --profile AWSAdministratorAccess-801610064192

# 2. Fetch the role ARN from stack output
LAMBDA_ROLE_ARN=$(aws cloudformation describe-stacks \
  --stack-name ct-lifecycle-enforcer-role \
  --region eu-west-1 \
  --profile AWSAdministratorAccess-801610064192 \
  --query "Stacks[0].Outputs[?OutputKey=='RoleArn'].OutputValue" \
  --output text)

echo "Lambda Role ARN: $LAMBDA_ROLE_ARN"

# 3. Package Lambda
# zip -j lifecycle_enforcer.zip ../resources/Lambda/lifecycle_enforcer.py
"/c/Program Files/7-Zip/7z.exe" a lifecycle_enforcer.zip ../resources/Lambda/lifecycle_enforcer.py

# 4. Deploy Lambda + EventBridge
aws cloudformation deploy \
  --template-file ../resources/EventBridge/lifecycle-enforcer-stack.yaml \
  --stack-name ct-lifecycle-enforcer \
  --parameter-overrides \
      LambdaRoleArn="$LAMBDA_ROLE_ARN" \
      ExpirationInDays=365 \
      NoncurrentVersionExpirationInDays=1 \
      AbortIncompleteMultipartUploadDays=7 \
  --capabilities CAPABILITY_IAM \
  --region eu-west-1 \
  --profile AWSAdministratorAccess-801610064192

# 5. Update Lambda code from zip
aws lambda update-function-code \
  --function-name ct-lifecycle-enforcer \
  --zip-file fileb://lifecycle_enforcer.zip \
  --region eu-west-1 \
  --profile AWSAdministratorAccess-801610064192

# 6. Test it manually
aws lambda invoke \
  --function-name ct-lifecycle-enforcer \
  --region eu-west-1 \
  --profile AWSAdministratorAccess-801610064192 \
  --log-type Tail \
  output.json && cat output.json && echo
