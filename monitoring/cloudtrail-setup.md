# CloudTrail Setup & Monitoring Configuration

## Overview

This document outlines the CloudTrail configuration for comprehensive IAM activity monitoring and audit logging for XYZ Corporation's secure cloud migration.

## CloudTrail Configuration

### Basic Setup
- **Trail Name**: `xyz-corp-audit-trail`
- **Region**: Multi-region trail enabled
- **Event Type**: Management and data events
- **Storage**: S3 bucket with versioning enabled

### S3 Bucket Configuration
```
Bucket Name: xyz-corp-cloudtrail-logs-2025
Encryption: AES-256 (Server-side)
Versioning: Enabled
Lifecycle Policy: Archive to Glacier after 90 days
```

## Key Events Monitored

### IAM-Specific Events
| Event | Purpose | Alert Level |
|-------|---------|-------------|
| `CreateUser` | New user account creation | Medium |
| `DeleteUser` | User account deletion | High |
| `AttachUserPolicy` | Permission changes | Medium |
| `CreateRole` | New role creation | Medium |
| `PutUserPolicy` | Inline policy attachment | High |
| `ChangePassword` | Password modifications | Low |

### Security-Critical Events
| Event | Purpose | Alert Level |
|-------|---------|-------------|
| `ConsoleLogin` | Console access attempts | Low |
| `AssumeRole` | Role assumption activities | Medium |
| `GetSessionToken` | Temporary credential requests | Low |
| `CreateAccessKey` | New access key generation | High |
| `DeleteAccessKey` | Access key removal | Medium |

## Monitoring Alerts

### CloudWatch Alarms
1. **Failed Console Logins**
   - Metric: Failed sign-in attempts > 5 in 15 minutes
   - Action: SNS notification to security team

2. **Root Account Usage**
   - Metric: Any root account API activity
   - Action: Immediate email alert

3. **Unauthorized IAM Changes**
   - Metric: IAM policy modifications outside business hours
   - Action: SMS and email alert

4. **MFA Bypass Attempts**
   - Metric: Console login without MFA
   - Action: Security team notification

## Log Analysis Queries

### Common CloudTrail Queries
```bash
# Find all IAM user creations in the last 7 days
aws logs filter-log-events --log-group-name CloudTrail/IAMEvents --start-time $(date -d '7 days ago' +%s)000 --filter-pattern "{ $.eventName = CreateUser }"

# Check for failed login attempts
aws logs filter-log-events --log-group-name CloudTrail/ConsoleEvents --filter-pattern "{ $.errorCode = SigninFailure }"

# Monitor policy attachments
aws logs filter-log-events --log-group-name CloudTrail/IAMEvents --filter-pattern "{ $.eventName = AttachUserPolicy || $.eventName = AttachRolePolicy }"
```

### Security Metrics Dashboard
- **Daily IAM Events**: Count of user/role/policy changes
- **Authentication Success Rate**: MFA compliance percentage
- **Geographic Login Distribution**: Unusual location detection
- **API Call Volume**: Baseline vs anomaly detection

## Incident Response Integration

### Automated Responses
| Event Type | Automated Action |
|------------|------------------|
| Multiple Failed Logins | Temporary account lockout |
| Root Account Usage | Immediate security team alert |
| Off-hours Admin Activity | Enhanced logging enabled |
| Unusual Geographic Access | Challenge authentication |

### Manual Investigation Process
1. **Alert Received** → Security team notification
2. **Initial Assessment** → Review CloudTrail logs
3. **Impact Analysis** → Determine affected resources
4. **Containment** → Disable compromised accounts if needed
5. **Documentation** → Record incident details

## Compliance & Retention

### Log Retention Policy
- **CloudTrail Logs**: 7 years (compliance requirement)
- **CloudWatch Logs**: 1 year (operational monitoring)
- **S3 Storage Classes**: 
  - Standard (30 days)
  - Standard-IA (90 days)
  - Glacier (remainder)

### Compliance Mapping
| Requirement | CloudTrail Coverage |
|-------------|-------------------|
| **SOX 404** | ✅ User access tracking |
| **PCI DSS** | ✅ Administrative action logs |
| **HIPAA** | ✅ PHI access monitoring |
| **SOC 2** | ✅ Security control evidence |

## Cost Optimization

### Current Costs
- **CloudTrail**: $2.00 per 100,000 events
- **S3 Storage**: ~$150/month for log storage
- **CloudWatch**: ~$50/month for custom metrics
- **Total Monthly**: ~$200

### Cost Management
- Log file validation enabled (integrity)
- Compress logs before S3 storage
- Lifecycle policies for automated archival
- Regular review of monitored events

## Monitoring Best Practices

### Setup Recommendations
✅ **Enable multi-region trails** for complete coverage  
✅ **Use separate S3 bucket** for log isolation  
✅ **Implement log file validation** for integrity  
✅ **Set up real-time monitoring** for critical events  
✅ **Regular access review** of CloudTrail configuration  

### Security Considerations
- S3 bucket access restricted to audit team only
- CloudTrail configuration changes require approval
- Log tampering detection through file validation
- Cross-account access logging when applicable

## Troubleshooting Common Issues

### Log Delivery Delays
- **Symptom**: Events not appearing in S3 within 15 minutes
- **Solution**: Check S3 bucket permissions and CloudTrail service role

### Missing Events
- **Symptom**: Expected events not in logs
- **Solution**: Verify event is covered by trail configuration

### High Costs
- **Symptom**: Unexpected CloudTrail billing
- **Solution**: Review event volume and implement filtering

## Quick Reference Commands

```bash
# Enable CloudTrail
aws cloudtrail create-trail --name xyz-corp-audit-trail --s3-bucket-name xyz-corp-cloudtrail-logs-2025

# Start logging
aws cloudtrail start-logging --name xyz-corp-audit-trail

# Check trail status
aws cloudtrail get-trail-status --name xyz-corp-audit-trail

# List recent events
aws cloudtrail lookup-events --start-time 2025-01-01 --end-time 2025-01-31
```

This monitoring setup ensures comprehensive audit coverage while maintaining cost efficiency and compliance requirements for the IAM security implementation.
