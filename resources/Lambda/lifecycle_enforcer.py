import boto3
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

LOG_ACCOUNT_ID = "640693977485"
LOG_ACCOUNT_ROLE = f"arn:aws:iam::{LOG_ACCOUNT_ID}:role/AWSControlTowerExecution"
REGION = "eu-west-1"

EXPIRATION_DAYS         = int(os.environ.get("EXPIRATION_DAYS", 365))
NONCURRENT_DAYS         = int(os.environ.get("NONCURRENT_VERSION_EXPIRATION_DAYS", 1))
ABORT_MULTIPART_DAYS    = int(os.environ.get("ABORT_INCOMPLETE_MULTIPART_UPLOAD_DAYS", 7))

def lifecycle_rules(expiration_days, noncurrent_days, abort_multipart_days):
    return [
        {
            "ID": "RetentionRule",
            "Filter": {"Prefix": ""},
            "Status": "Enabled",
            "Expiration": {"Days": expiration_days},
            "NoncurrentVersionExpiration": {"NoncurrentDays": noncurrent_days}
        },
        {
            "ID": "abort-incomplete-multipart",
            "Filter": {},
            "Status": "Enabled",
            "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": abort_multipart_days}
        },
        {
            "ID": "delete-markers-cleanup",
            "Filter": {},
            "Status": "Enabled",
            "Expiration": {"ExpiredObjectDeleteMarker": True}
        }
    ]

BUCKETS = {
    "aws-controltower-logs-640693977485-eu-west-1":            lifecycle_rules(EXPIRATION_DAYS, NONCURRENT_DAYS, ABORT_MULTIPART_DAYS),
    "aws-controltower-s3-access-logs-640693977485-eu-west-1":  lifecycle_rules(EXPIRATION_DAYS, NONCURRENT_DAYS, ABORT_MULTIPART_DAYS),
}


def assume_role():
    sts = boto3.client("sts")
    response = sts.assume_role(
        RoleArn=LOG_ACCOUNT_ROLE,
        RoleSessionName="lifecycle-enforcer"
    )
    creds = response["Credentials"]
    return boto3.client(
        "s3",
        region_name=REGION,
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"]
    )


def handler(event, context):
    logger.info(f"Triggered by event: {json.dumps(event)}")

    s3 = assume_role()

    for bucket_name, lifecycle_config in BUCKETS.items():
        try:
            s3.put_bucket_lifecycle_configuration(
                Bucket=bucket_name,
                LifecycleConfiguration=lifecycle_config
            )
            logger.info(f"✅ Applied lifecycle config to {bucket_name}")
        except Exception as e:
            logger.error(f"❌ Failed on {bucket_name}: {str(e)}")
            raise

    return {"status": "success"}
