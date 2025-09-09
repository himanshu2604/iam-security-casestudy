#!/bin/bash

# IAM Security Audit Script
# XYZ Corporation - Compliance and Security Validation
# Usage: ./security-audit.sh

set -e

REGION="us-east-1"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔍 IAM Security Audit Report${NC}"
echo "============================================"
echo "Date: $(date)"
echo ""

# Check password policy
echo -e "${YELLOW}📋 Password Policy Check${NC}"
PASSWORD_POLICY=$(aws iam get-account-password-policy --region "$REGION" 2>/dev/null || echo "No password policy set")

if [[ "$PASSWORD_POLICY" == "No password policy set" ]]; then
    echo -e "${RED}❌ No password policy configured${NC}"
else
    echo -e "${GREEN}✅ Password policy is configured${NC}"
    echo "   Minimum length: $(echo $PASSWORD_POLICY | jq -r '.PasswordPolicy.MinimumPasswordLength // "Not set"')"
    echo "   Require symbols: $(echo $PASSWORD_POLICY | jq -r '.PasswordPolicy.RequireSymbols // false')"
    echo "   Require numbers: $(echo $PASSWORD_POLICY | jq -r '.PasswordPolicy.RequireNumbers // false')"
fi
echo ""

# Check for users without MFA
echo -e "${YELLOW}👤 MFA Compliance Check${NC}"
USERS=$(aws iam list-users --query 'Users[].UserName' --output text --region "$REGION")
MFA_ISSUES=0

for user in $USERS; do
    MFA_DEVICES=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text --region "$REGION")
    if [[ -z "$MFA_DEVICES" || "$MFA_DEVICES" == "None" ]]; then
        echo -e "${RED}❌ User '$user' has no MFA device${NC}"
        ((MFA_ISSUES++))
    else
        echo -e "${GREEN}✅ User '$user' has MFA enabled${NC}"
    fi
done

if [[ $MFA_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ All users have MFA enabled${NC}"
fi
echo ""

# Check for users with console access but no recent activity
echo -e "${YELLOW}🕐 User Activity Check${NC}"
for user in $USERS; do
    LAST_ACTIVITY=$(aws iam get-user --user-name "$user" --query 'User.PasswordLastUsed' --output text --region "$REGION" 2>/dev/null || echo "None")
    if [[ "$LAST_ACTIVITY" == "None" ]]; then
        echo -e "${YELLOW}⚠️  User '$user' has never logged in${NC}"
    else
        echo -e "${GREEN}✅ User '$user' last active: $LAST_ACTIVITY${NC}"
    fi
done
echo ""

# Check for overprivileged users (users with policies attached directly)
echo -e "${YELLOW}🔒 Direct Policy Attachment Check${NC}"
DIRECT_POLICY_ISSUES=0

for user in $USERS; do
    ATTACHED_POLICIES=$(aws iam list-attached-user-policies --user-name "$user" --query 'AttachedPolicies' --output text --region "$REGION")
    INLINE_POLICIES=$(aws iam list-user-policies --user-name "$user" --query 'PolicyNames' --output text --region "$REGION")
    
    if [[ -n "$ATTACHED_POLICIES" && "$ATTACHED_POLICIES" != "None" ]]; then
        echo -e "${RED}❌ User '$user' has directly attached policies${NC}"
        ((DIRECT_POLICY_ISSUES++))
    fi
    
    if [[ -n "$INLINE_POLICIES" && "$INLINE_POLICIES" != "None" ]]; then
        echo -e "${RED}❌ User '$user' has inline policies${NC}"
        ((DIRECT_POLICY_ISSUES++))
    fi
done

if [[ $DIRECT_POLICY_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ No users have direct policy attachments${NC}"
fi
echo ""

# Check CloudTrail status
echo -e "${YELLOW}📊 CloudTrail Audit Logging${NC}"
TRAILS=$(aws cloudtrail describe-trails --query 'trailList' --output text --region "$REGION")

if [[ -z "$TRAILS" || "$TRAILS" == "None" ]]; then
    echo -e "${RED}❌ No CloudTrail configured${NC}"
else
    echo -e "${GREEN}✅ CloudTrail is configured${NC}"
    # Check if logging is enabled
    for trail in $(aws cloudtrail describe-trails --query 'trailList[].Name' --output text --region "$REGION"); do
        LOGGING_STATUS=$(aws cloudtrail get-trail-status --name "$trail" --query 'IsLogging' --output text --region "$REGION")
        if [[ "$LOGGING_STATUS" == "True" ]]; then
            echo -e "${GREEN}✅ Trail '$trail' is actively logging${NC}"
        else
            echo -e "${RED}❌ Trail '$trail' is not logging${NC}"
        fi
    done
fi
echo ""

# Check for unused access keys
echo -e "${YELLOW}🔑 Access Key Usage Check${NC}"
for user in $USERS; do
    ACCESS_KEYS=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[].AccessKeyId' --output text --region "$REGION")
    
    for key in $ACCESS_KEYS; do
        LAST_USED=$(aws iam get-access-key-last-used --access-key-id "$key" --query 'AccessKeyLastUsed.LastUsedDate' --output text --region "$REGION" 2>/dev/null || echo "Never")
        
        if [[ "$LAST_USED" == "Never" ]]; then
            echo -e "${YELLOW}⚠️  Access key '$key' for user '$user' has never been used${NC}"
        else
            echo -e "${GREEN}✅ Access key '$key' for user '$user' last used: $LAST_USED${NC}"
        fi
    done
done
echo ""

# Security Summary
echo -e "${GREEN}📋 Security Audit Summary${NC}"
echo "============================================"
if [[ $MFA_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ MFA Compliance: PASS${NC}"
else
    echo -e "${RED}❌ MFA Compliance: $MFA_ISSUES issues found${NC}"
fi

if [[ $DIRECT_POLICY_ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ Policy Best Practices: PASS${NC}"
else
    echo -e "${RED}❌ Policy Best Practices: $DIRECT_POLICY_ISSUES issues found${NC}"
fi

if [[ "$PASSWORD_POLICY" != "No password policy set" ]]; then
    echo -e "${GREEN}✅ Password Policy: CONFIGURED${NC}"
else
    echo -e "${RED}❌ Password Policy: NOT CONFIGURED${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Recommendations:${NC}"
echo "1. Enable MFA for all users"
echo "2. Use group-based permissions only"
echo "3. Regular access key rotation"
echo "4. Monitor CloudTrail logs"
echo "5. Review user activity monthly"
