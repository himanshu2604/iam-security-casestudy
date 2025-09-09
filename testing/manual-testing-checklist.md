# 🧪 Manual IAM Security Testing Checklist

## 📋 Overview

**Purpose**: Step-by-step manual validation checklist for XYZ Corporation IAM implementation  
**Audience**: Security testers, IT administrators, compliance auditors  
**Duration**: Approximately 2-3 hours  
**Prerequisites**: Access to AWS Console, test user credentials, MFA device  

---

## ✅ Pre-Testing Setup

### Requirements Checklist
- [ ] AWS Console access credentials for test user
- [ ] Mobile device with authenticator app installed
- [ ] Access to test environment AWS account
- [ ] Browser with JavaScript enabled
- [ ] Notepad for recording test results

### Test Environment Validation
- [ ] Confirm AWS account ID: `123456789012` (example)
- [ ] Verify test user exists: `xyz-test-user`
- [ ] Confirm test regions available: `us-east-1`, `us-west-2`
- [ ] Check EC2-Operators group exists
- [ ] Validate CloudTrail is enabled

---

## 🔐 User Authentication Testing

### TEST-001: Initial User Login
**Objective**: Verify user can access AWS Management Console

**Steps**:
1. [ ] Navigate to AWS Console login page
2. [ ] Enter test user credentials
3. [ ] Complete login process
4. [ ] Verify AWS dashboard loads

**Expected Result**: ✅ Successful authentication and dashboard access  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-002: Password Policy Enforcement
**Objective**: Confirm password policy is enforced

**Steps**:
1. [ ] Go to IAM → Users → [Username] → Security credentials
2. [ ] Click "Change password"
3. [ ] Attempt password with 8 characters: `Password1`
4. [ ] Attempt password without symbols: `Password123`
5. [ ] Set compliant password: `SecurePass123!@#`

**Expected Result**: ✅ Weak passwords rejected, compliant password accepted  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 🛡️ Multi-Factor Authentication Testing

### TEST-003: MFA Device Setup
**Objective**: Verify MFA can be configured successfully

**Steps**:
1. [ ] Navigate to IAM → Users → [Username] → Security credentials
2. [ ] Click "Assign MFA device"
3. [ ] Select "Virtual MFA device"
4. [ ] Scan QR code with authenticator app
5. [ ] Enter two consecutive MFA codes
6. [ ] Confirm device assignment

**Expected Result**: ✅ MFA device successfully configured  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-004: MFA-Required Login
**Objective**: Verify MFA is required for subsequent logins

**Steps**:
1. [ ] Sign out of AWS Console
2. [ ] Sign back in with username/password only
3. [ ] Verify MFA code prompt appears
4. [ ] Enter MFA code from authenticator
5. [ ] Confirm successful login

**Expected Result**: ✅ MFA code required for access  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-005: Critical Operations Without MFA
**Objective**: Verify critical actions require active MFA session

**Steps**:
1. [ ] Login with username/password (skip MFA initially)
2. [ ] Navigate to EC2 console
3. [ ] Attempt to start/stop an instance
4. [ ] Verify access is denied
5. [ ] Complete MFA authentication and retry

**Expected Result**: ✅ Operations blocked without MFA, allowed with MFA  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 🔒 Permission Validation Testing

### TEST-006: EC2 Read Access
**Objective**: Verify user can view EC2 instances

**Steps**:
1. [ ] Navigate to EC2 Dashboard
2. [ ] Switch to us-east-1 region
3. [ ] View "Instances" page
4. [ ] Switch to us-west-2 region
5. [ ] View "Instances" page
6. [ ] Record visible instances

**Expected Result**: ✅ Instance lists visible in both allowed regions  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-007: Regional Access Restriction
**Objective**: Verify access is restricted to approved regions

**Steps**:
1. [ ] Navigate to EC2 Dashboard
2. [ ] Switch to eu-west-1 region
3. [ ] Attempt to view instances
4. [ ] Switch to ap-south-1 region
5. [ ] Attempt to view instances
6. [ ] Record access results

**Expected Result**: ✅ Access denied to non-approved regions  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-008: Development Environment Access
**Objective**: Verify user can manage dev-tagged resources

**Steps**:
1. [ ] Identify instance tagged `Environment=dev`
2. [ ] Select the instance
3. [ ] Click "Instance state" → "Start" (if stopped)
4. [ ] Wait for state change
5. [ ] Click "Instance state" → "Stop"
6. [ ] Verify operations complete

**Expected Result**: ✅ Dev environment operations successful  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-009: Production Environment Access Denial
**Objective**: Verify user cannot access production resources

**Steps**:
1. [ ] Identify instance tagged `Environment=production`
2. [ ] Select the instance
3. [ ] Attempt "Instance state" → "Start"
4. [ ] Record error message
5. [ ] Attempt other operations (stop, reboot)
6. [ ] Confirm all operations denied

**Expected Result**: ✅ Production access explicitly denied  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-010: VPC Read-Only Access
**Objective**: Verify user can view network configurations

**Steps**:
1. [ ] Navigate to VPC Dashboard
2. [ ] View "Your VPCs" page
3. [ ] View "Subnets" page
4. [ ] View "Security Groups" page
5. [ ] Attempt to create new security group
6. [ ] Confirm read-only access

**Expected Result**: ✅ Can view but not modify network resources  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 🏷️ Resource Tagging Testing

### TEST-011: Untagged Resource Creation Denial
**Objective**: Verify resource creation requires proper tags

**Steps**:
1. [ ] Navigate to EC2 → Launch Instance
2. [ ] Select Amazon Linux 2 AMI
3. [ ] Choose t2.micro instance type
4. [ ] Skip adding tags (leave empty)
5. [ ] Attempt to launch instance
6. [ ] Record error message

**Expected Result**: ✅ Instance creation blocked due to missing tags  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-012: Properly Tagged Resource Creation
**Objective**: Verify resource creation succeeds with required tags

**Steps**:
1. [ ] Navigate to EC2 → Launch Instance
2. [ ] Select Amazon Linux 2 AMI
3. [ ] Choose t2.micro instance type
4. [ ] Add tags:
   - [ ] `Environment = dev`
   - [ ] `Project = XYZ-Migration`
   - [ ] `Owner = devops`
   - [ ] `CostCenter = CC1001`
5. [ ] Launch instance (or dry-run if preferred)

**Expected Result**: ✅ Instance creation allowed with proper tags  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-013: Invalid Tag Value Rejection
**Objective**: Verify only approved tag values are accepted

**Steps**:
1. [ ] Navigate to EC2 → Launch Instance
2. [ ] Select Amazon Linux 2 AMI
3. [ ] Choose t2.micro instance type
4. [ ] Add invalid tags:
   - [ ] `Environment = test` (not in approved list)
   - [ ] `Project = XYZ-Migration`
   - [ ] `Owner = devops`
   - [ ] `CostCenter = CC1001`
5. [ ] Attempt to launch instance

**Expected Result**: ✅ Instance creation blocked due to invalid tag value  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 🔍 Audit and Compliance Testing

### TEST-014: CloudTrail Logging Verification
**Objective**: Verify user actions are logged in CloudTrail

**Steps**:
1. [ ] Perform several EC2 operations (start/stop instances)
2. [ ] Navigate to CloudTrail → Event History
3. [ ] Filter by User name: `xyz-test-user`
4. [ ] Filter by time range: Last 1 hour
5. [ ] Verify events are recorded with details
6. [ ] Check event includes user identity and source IP

**Expected Result**: ✅ All actions logged with complete audit trail  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-015: Access Review Report Generation
**Objective**: Verify access permissions can be audited

**Steps**:
1. [ ] Navigate to IAM → Users
2. [ ] Select test user
3. [ ] Go to "Permissions" tab
4. [ ] Review attached policies
5. [ ] Click "Download credentials report" (if available)
6. [ ] Verify comprehensive permission listing

**Expected Result**: ✅ Complete permission reports available  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 🔧 Error Handling Testing

### TEST-016: User-Friendly Error Messages
**Objective**: Verify clear error messages are provided

**Steps**:
1. [ ] Trigger access denied scenario (try production resource)
2. [ ] Record exact error message shown
3. [ ] Evaluate message clarity and actionability
4. [ ] Test with missing tag scenario
5. [ ] Record error message
6. [ ] Assess user understanding

**Expected Result**: ✅ Clear, actionable error messages provided  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-017: Recovery Procedures
**Objective**: Verify users can recover from common issues

**Steps**:
1. [ ] Simulate MFA device loss (if safe to test)
2. [ ] Contact IT support for recovery process
3. [ ] Document recovery steps
4. [ ] Test password reset process (if applicable)
5. [ ] Verify account lockout recovery
6. [ ] Document emergency procedures

**Expected Result**: ✅ Recovery processes available and documented  
**Actual Result**: _Record your findings here_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 📈 Performance Testing

### TEST-018: Login Performance
**Objective**: Verify security controls don't impact user experience

**Steps**:
1. [ ] Time complete login process (username + password + MFA)
2. [ ] Record total time in seconds
3. [ ] Test multiple login attempts
4. [ ] Calculate average login time
5. [ ] Assess user experience impact

**Expected Result**: ✅ Login completes within 30 seconds  
**Actual Result**: _Average time: _____ seconds_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

### TEST-019: Console Navigation Performance
**Objective**: Verify policy evaluation doesn't slow operations

**Steps**:
1. [ ] Time navigation to EC2 console
2. [ ] Time instance list loading
3. [ ] Time instance start operation
4. [ ] Compare with expected performance
5. [ ] Record any notable delays

**Expected Result**: ✅ Operations complete within expected timeframes  
**Actual Result**: _Record timing observations_  
**Status**: [ ] PASS [ ] FAIL [ ] N/A  
**Notes**: ____________________

---

## 📊 Final Assessment

### Test Summary
- **Total Tests Performed**: _____
- **Tests Passed**: _____
- **Tests Failed**: _____
- **Tests with Warnings**: _____
- **Success Rate**: _____%

### Risk Assessment
**Overall Security Posture**: [ ] Excellent [ ] Good [ ] Needs Improvement [ ] Critical Issues  
**Compliance Status**: [ ] Fully Compliant [ ] Mostly Compliant [ ] Non-Compliant  
**Risk Level**: [ ] Low [ ] Medium [ ] High [ ] Critical  

### Recommendations
**Immediate Actions Required**:
- [ ] ________________________________
- [ ] ________________________________
- [ ] ________________________________

**Future Enhancements**:
- [ ] ________________________________
- [ ] ________________________________
- [ ] ________________________________

### Approval
**Tested By**: ________________________  
**Date**: ___________________________  
**Approved for Production**: [ ] Yes [ ] No [ ] With Conditions  
**Next Review Date**: ___________________

---

## 📚 Additional Resources

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Security Audit Guidelines](https://docs.aws.amazon.com/security/)
- [CloudTrail User Guide](https://docs.aws.amazon.com/cloudtrail/)
- [MFA Setup Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html)

---

*Document Version: 1.0*  
*Last Updated: September 9, 2025*  
*Next Review: December 9, 2025*
