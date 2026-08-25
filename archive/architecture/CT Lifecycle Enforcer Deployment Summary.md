# CT Lifecycle Enforcer — Deployment Summary

**Date:** 2026-08-14
**Management Account:** `801610064192`
**Log Account:** `640693977485`
**Region:** `eu-west-1`

---

## Deployed Resources

| Component | Resource | Details | Status |
|---|---|---|---|
| IAM Role | `ct-lifecycle-enforcer-role` | Management account (`801610064192`) | ✅ |
| Lambda Function | `ct-lifecycle-enforcer` | `eu-west-1`, Python 3.12, 128MB, 60s timeout | ✅ |
| EventBridge Rule | `ct-lifecycle-enforcer-trigger` | `eu-west-1`, default event bus | ✅ |
| S3 Lifecycle — CT Logs | `aws-controltower-logs-640693977485-eu-west-1` | 365 day retention | ✅ |
| S3 Lifecycle — Access Logs | `aws-controltower-s3-access-logs-640693977485-eu-west-1` | 730 day retention | ✅ |

---

## CloudFormation Stacks

| Stack | Account | Region | Status |
|---|---|---|---|
| `ct-lifecycle-enforcer-role` | `801610064192` | global | `CREATE_COMPLETE` |
| `ct-lifecycle-enforcer` | `801610064192` | `eu-west-1` | `CREATE_COMPLETE` |

---

## EventBridge Rule

- **Name:** `ct-lifecycle-enforcer-trigger`
- **ARN:** `arn:aws:events:eu-west-1:801610064192:rule/ct-lifecycle-enforcer-trigger`
- **State:** `ENABLED`
- **Event Source:** `aws.controltower`
- **Triggers on:**
  - `CreateManagedAccount`
  - `UpdateManagedAccount`
  - `UpdateLandingZone`
- **Target:** `arn:aws:lambda:eu-west-1:801610064192:function:ct-lifecycle-enforcer`

---

## S3 Lifecycle Rules (Log Account `640693977485`)

### `aws-controltower-logs-640693977485-eu-west-1`

| Rule | Status | Detail |
|---|---|---|
| `RetentionRule` | ✅ Enabled | Current objects expire after **365 days** |
| `RetentionRule` | ✅ Enabled | Noncurrent versions expire after **1 day** |
| `abort-incomplete-multipart` | ✅ Enabled | Aborts incomplete uploads after **7 days** |
| `delete-markers-cleanup` | ✅ Enabled | Auto-removes expired delete markers |

### `aws-controltower-s3-access-logs-640693977485-eu-west-1`

| Rule | Status | Detail |
|---|---|---|
| `RetentionRule` | ✅ Enabled | Current objects expire after **730 days** |
| `RetentionRule` | ✅ Enabled | Noncurrent versions expire after **1 day** |
| `abort-incomplete-multipart` | ✅ Enabled | Aborts incomplete uploads after **7 days** |
| `delete-markers-cleanup` | ✅ Enabled | Auto-removes expired delete markers |

---

## How It Works

1. A Control Tower lifecycle event fires (`CreateManagedAccount`, `UpdateManagedAccount`, or `UpdateLandingZone`)
2. EventBridge rule `ct-lifecycle-enforcer-trigger` catches the event
3. Lambda `ct-lifecycle-enforcer` is invoked in the management account
4. Lambda assumes `AWSControlTowerExecution` role into the Log account (`640693977485`)
5. S3 lifecycle rules are applied/re-enforced on both CT log buckets
