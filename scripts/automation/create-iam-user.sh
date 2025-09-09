#!/bin/bash

# IAM User Creation Automation Script
# XYZ Corporation - Secure Cloud Migration
# Usage: ./create-iam-user.sh <username> <group-name>

set -e

# Configuration
USERNAME=${1:-"dev-user-xyz"}
GROUP_NAME=${2:-"EC2-Operators"}
PASSWORD_LENGTH=16
REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 IAM User Creation Script${NC}"
echo "============================================"
echo "Username: $USERNAME"
echo "Group: $GROUP_NAME"
echo ""

# Generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${PASSWORD_LENGTH}
}

# Create IAM user
echo -e "${YELLOW}📝 Creating IAM user...${NC}"
aws iam create-user --user-name "$USERNAME" --region "$REGION"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ User '$USERNAME' created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create user${NC}"
    exit 1
fi

# Generate and set login password
echo -e "${YELLOW}🔑 Setting up console password...${NC}"
TEMP_PASSWORD=$(generate_password)

aws iam create-login-profile \
    --user-name "$USERNAME" \
    --password "$TEMP_PASSWORD" \
    --password-reset-required \
    --region "$REGION"

# Add user to group
echo -e "${YELLOW}👥 Adding user to group '$GROUP_NAME'...${NC}"
aws iam add-user-to-group \
    --user-name "$USERNAME" \
    --group-name "$GROUP_NAME" \
    --region "$REGION"

# Create access keys (optional - for programmatic access)
echo -e "${YELLOW}🔐 Creating access keys...${NC}"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$USERNAME" --region "$REGION")

# Extract access key details
ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

# Output credentials securely
echo ""
echo -e "${GREEN}🎉 User setup completed successfully!${NC}"
echo "============================================"
echo -e "${YELLOW}⚠️  SAVE THESE CREDENTIALS SECURELY:${NC}"
echo ""
echo "Username: $USERNAME"
echo "Console Password: $TEMP_PASSWORD"
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"
echo ""
echo -e "${RED}⚠️  Password reset required on first login${NC}"
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. User should login and change password"
echo "2. Set up MFA device"
echo "3. Test permissions"
echo ""
echo "Console URL: https://$AWS_ACCOUNT_ID.signin.aws.amazon.com/console"
