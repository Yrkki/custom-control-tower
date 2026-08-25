#!/bin/bash
set -e  # Stop on any error

PROFILE="AWSAdministratorAccess-801610064192"
REGION="eu-west-1"

echo "🧹 Starting cleanup of manual Lambda, EventBridge, and IAM infrastructure..."

# 1. Delete the EventBridge and Lambda stack first
# (Deletes the Lambda function, EventBridge Rule, and any associated permissions)
echo "🗑️ Deleting CloudFormation Stack: ct-lifecycle-enforcer..."
aws cloudformation delete-stack \
  --stack-name ct-lifecycle-enforcer \
  --region $REGION \
  --profile $PROFILE

echo "⏳ Waiting for ct-lifecycle-enforcer stack deletion to finish..."
aws cloudformation wait stack-delete-complete \
  --stack-name ct-lifecycle-enforcer \
  --region $REGION \
  --profile $PROFILE
echo "✅ Lambda and EventBridge stack successfully removed."


# 2. Delete the IAM Role stack second
# (Safe to delete now that the Lambda function that was using it is gone)
echo "🗑️ Deleting CloudFormation Stack: ct-lifecycle-enforcer-role..."
aws cloudformation delete-stack \
  --stack-name ct-lifecycle-enforcer-role \
  --region $REGION \
  --profile $PROFILE

echo "⏳ Waiting for ct-lifecycle-enforcer-role stack deletion to finish..."
aws cloudformation wait stack-delete-complete \
  --stack-name ct-lifecycle-enforcer-role \
  --region $REGION \
  --profile $PROFILE
echo "✅ IAM Role stack successfully removed."


# 3. Local Workspace Cleanup
echo "🧹 Cleaning up local artifact archives..."
rm -f lifecycle_enforcer.zip output.json

echo "🎉 All local manual deploy architecture has been cleanly deleted!"
