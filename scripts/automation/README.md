# IAM Automation Scripts

This directory contains automation scripts for XYZ Corporation's IAM security implementation.

## Scripts Overview

### 1. `create-iam-user.sh`
**Purpose**: Automated IAM user creation with secure defaults
```bash
./create-iam-user.sh [username] [group-name]
```

**Features**:
- Secure password generation
- Console access setup with password reset required
- Access key creation for programmatic access
- Automatic group membership assignment
- Color-coded output with next steps

**Example**:
```bash
./create-iam-user.sh dev-user-xyz EC2-Operators
```

### 2. `setup-iam-groups.sh`
**Purpose**: Create functional groups with appropriate policies
```bash
./setup-iam-groups.sh
```

**Creates**:
- **EC2-Operators**: Custom policy with MFA requirement
- **RDS-Admins**: AWS managed RDS policy
- **VPC-Managers**: AWS managed VPC policy

**Features**:
- MFA-conditional access for sensitive operations
- Principle of least privilege implementation
- AWS managed policies where appropriate

### 3. `security-audit.sh`
**Purpose**: Comprehensive security compliance check
```bash
./security-audit.sh
```

**Validates**:
- Password policy configuration
- MFA compliance across all users
- Direct policy attachments (anti-pattern detection)
- CloudTrail logging status
- Unused access keys identification
- User activity monitoring

## Prerequisites

### Required Tools
- **AWS CLI v2**: Configure with appropriate permissions
- **jq**: JSON parsing (install with `sudo apt install jq`)
- **bash**: Scripts tested on bash 4.0+

### AWS Permissions Required
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*",
        "sts:GetCallerIdentity",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage Workflow

### Initial Setup
1. **Configure Groups**: Run `setup-iam-groups.sh` first
2. **Create Users**: Use `create-iam-user.sh` for each user
3. **Security Audit**: Run `security-audit.sh` to validate

### Regular Operations
```bash
# Create new developer user
./create-iam-user.sh john-doe EC2-Operators

# Run monthly security audit
./security-audit.sh > audit-$(date +%Y%m%d).log

# Review audit results
cat audit-$(date +%Y%m%d).log
```

## Security Best Practices

### Script Security
- ✅ Scripts use `set -e` for error handling
- ✅ Temporary files are cleaned up
- ✅ Credentials are displayed securely (one-time only)
- ✅ MFA requirements built into policies

### Operational Security
- 🔐 **Store credentials securely**: Never commit to git
- 🔑 **Rotate regularly**: Review access keys monthly
- 👥 **Group-based only**: Never attach policies directly to users
- 📊 **Audit regularly**: Run security-audit.sh monthly

## Troubleshooting

### Common Issues
| Issue | Cause | Solution |
|-------|-------|----------|
| Permission Denied | Insufficient IAM permissions | Check AWS credentials and policies |
| Group Already Exists | Re-running setup script | Script will skip existing resources |
| jq command not found | Missing dependency | Install with package manager |
| User creation fails | Username already exists | Choose different username |

### Debug Mode
```bash
# Run with debug output
bash -x ./create-iam-user.sh username groupname
```

## Cost Impact
- **IAM Operations**: No additional cost
- **CloudTrail**: ~$2 per 100K events
- **Script Execution**: Minimal AWS API calls

## Integration
These scripts can be integrated with:
- CI/CD pipelines for automated user provisioning
- Configuration management tools (Ansible, Terraform)
- Monitoring systems for audit reporting
- Identity providers for user lifecycle management
