# Control Tower Lifecycle Event Enforcer

```text
Management Account                          Log Account (640693977485)
─────────────────────────────────           ──────────────────────────
EventBridge Rule
  (aws.controltower events)
       │
       ▼
Lambda Function                 ──────────► s3:PutLifecycleConfiguration
  (lifecycle enforcer)          assume role   (both buckets)
       │                        AWSControlTowerExecution
       ▼
CloudWatch Logs
```
