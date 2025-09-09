#!/bin/bash

# IAM Groups and Policies Setup Script
# XYZ Corporation - Secure Cloud Migration
# Usage: ./setup-iam-groups.sh

set -e

REGION="us-east-1"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}👥 IAM Groups and Policies Setup${NC}"
echo "============================================"

# Create EC2 Operators Group
echo -e "${YELLOW}📝 Creating EC2-Operators group...${NC}"
aws iam create-group --group-name "EC2-Operators" --region "$REGION"

# Create custom EC2 policy
echo -e "${YELLOW}📋 Creating EC2 custom policy...${NC}"
cat > /tmp/ec2-operators-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances",
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy \
    --policy-name "EC2OperatorsPolicy" \
    --policy-document file:///tmp/ec2-operators-policy.json \
    --description "Custom policy for EC2 operators with MFA requirement" \
    --region "$REGION"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Attach policy to group
echo -e "${YELLOW}🔗 Attaching policy to group...${NC}"
aws iam attach-group-policy \
    --group-name "EC2-Operators" \
    --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/EC2OperatorsPolicy" \
    --region "$REGION"

# Create RDS Administrators Group (optional)
echo -e "${YELLOW}📝 Creating RDS-Admins group...${NC}"
aws iam create-group --group-name "RDS-Admins" --region "$REGION"

# Attach AWS managed RDS policy
aws iam attach-group-policy \
    --group-name "RDS-Admins" \
    --policy-arn "arn:aws:iam::aws:policy/AmazonRDSFullAccess" \
    --region "$REGION"

# Create VPC Managers Group
echo -e "${YELLOW}📝 Creating VPC-Managers group...${NC}"
aws iam create-group --group-name "VPC-Managers" --region "$REGION"

# Attach AWS managed VPC policy
aws iam attach-group-policy \
    --group-name "VPC-Managers" \
    --policy-arn "arn:aws:iam::aws:policy/AmazonVPCFullAccess" \
    --region "$REGION"

# Clean up temporary files
rm -f /tmp/ec2-operators-policy.json

echo ""
echo -e "${GREEN}✅ Groups and policies setup completed!${NC}"
echo "============================================"
echo "Created Groups:"
echo "  • EC2-Operators (Custom policy with MFA)"
echo "  • RDS-Admins (AWS managed policy)"
echo "  • VPC-Managers (AWS managed policy)"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Add users to appropriate groups"
echo "2. Test group permissions"
echo "3. Set up MFA for policy conditions"
