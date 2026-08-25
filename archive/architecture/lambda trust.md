# Control Tower Lifecycle Event Enforcer lambda Trust Policy

```text
Management Account (801610064192)
  └── Lambda Role (ct-lifecycle-enforcer-role)
        │
        │  sts:AssumeRole ✅ (trusted via :root)
        ▼
Log Account (640693977485)
  └── AWSControlTowerExecution
        │
        ▼
      s3:PutLifecycleConfiguration on both buckets
