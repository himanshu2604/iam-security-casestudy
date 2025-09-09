# IAM Security Testing Script for XYZ Corporation
# PowerShell script for Windows environments
# Version: 1.0
# Date: September 2025

param(
    [string]$TestUser = "xyz-test-user",
    [string]$Region = "us-east-1",
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Continue"
$testResults = @()

function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Details
    )
    
    $result = @{
        Test = $TestName
        Status = $Status
        Details = $Details
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $global:testResults += $result
    
    $color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "WARN" { "Yellow" }
        default { "White" }
    }
    
    Write-Host "[$Status] $TestName - $Details" -ForegroundColor $color
}

function Test-AWSConnection {
    Write-Host "`n=== AWS Connection Tests ===" -ForegroundColor Cyan
    
    try {
        $identity = aws sts get-caller-identity --output json 2>$null | ConvertFrom-Json
        if ($identity) {
            Write-TestResult "AWS CLI Authentication" "PASS" "User: $($identity.Arn)"
        } else {
            Write-TestResult "AWS CLI Authentication" "FAIL" "Unable to authenticate"
            return $false
        }
    } catch {
        Write-TestResult "AWS CLI Authentication" "FAIL" "AWS CLI not configured or accessible"
        return $false
    }
    
    return $true
}

function Test-EC2Permissions {
    Write-Host "`n=== EC2 Permission Tests ===" -ForegroundColor Cyan
    
    # Test EC2 describe permissions in allowed region
    try {
        $instances = aws ec2 describe-instances --region $Region --output json 2>$null
        if ($instances) {
            Write-TestResult "EC2 Describe Access ($Region)" "PASS" "Can view EC2 instances"
        } else {
            Write-TestResult "EC2 Describe Access ($Region)" "WARN" "No instances found or permission denied"
        }
    } catch {
        Write-TestResult "EC2 Describe Access ($Region)" "FAIL" "Cannot access EC2 service"
    }
    
    # Test regional restriction
    try {
        $restrictedInstances = aws ec2 describe-instances --region "eu-west-1" --output json 2>$null
        if ($restrictedInstances) {
            Write-TestResult "Regional Restriction Test" "FAIL" "Should not have access to eu-west-1"
        } else {
            Write-TestResult "Regional Restriction Test" "PASS" "Access properly restricted to eu-west-1"
        }
    } catch {
        Write-TestResult "Regional Restriction Test" "PASS" "Regional access restriction working"
    }
}

function Test-IAMPermissions {
    Write-Host "`n=== IAM Permission Tests ===" -ForegroundColor Cyan
    
    # Test MFA device listing
    try {
        $mfaDevices = aws iam list-mfa-devices --user-name $TestUser --output json 2>$null
        if ($mfaDevices) {
            $devices = $mfaDevices | ConvertFrom-Json
            if ($devices.MFADevices.Count -gt 0) {
                Write-TestResult "MFA Device Configuration" "PASS" "MFA device found for user"
            } else {
                Write-TestResult "MFA Device Configuration" "WARN" "No MFA devices configured"
            }
        } else {
            Write-TestResult "MFA Device Configuration" "FAIL" "Cannot check MFA status"
        }
    } catch {
        Write-TestResult "MFA Device Configuration" "FAIL" "Error checking MFA devices"
    }
    
    # Test user self-service permissions
    try {
        $user = aws iam get-user --user-name $TestUser --output json 2>$null
        if ($user) {
            Write-TestResult "User Self-Service Access" "PASS" "Can access own user information"
        } else {
            Write-TestResult "User Self-Service Access" "FAIL" "Cannot access user information"
        }
    } catch {
        Write-TestResult "User Self-Service Access" "FAIL" "Error accessing user data"
    }
}

function Test-TaggingPolicy {
    Write-Host "`n=== Resource Tagging Tests ===" -ForegroundColor Cyan
    
    # Test instance launch without tags (should fail)
    try {
        $launchResult = aws ec2 run-instances --image-id ami-0abcdef1234567890 --instance-type t2.micro --region $Region --dry-run 2>$null
        if ($launchResult) {
            Write-TestResult "Untagged Resource Creation" "FAIL" "Should not allow untagged resource creation"
        } else {
            Write-TestResult "Untagged Resource Creation" "PASS" "Untagged resource creation properly blocked"
        }
    } catch {
        Write-TestResult "Untagged Resource Creation" "PASS" "Resource creation denied (expected behavior)"
    }
    
    # Test with proper tags
    $tags = @(
        "Key=Environment,Value=dev",
        "Key=Project,Value=XYZ-Migration",
        "Key=Owner,Value=devops",
        "Key=CostCenter,Value=CC1001"
    )
    
    try {
        $taggedLaunchResult = aws ec2 run-instances --image-id ami-0abcdef1234567890 --instance-type t2.micro --region $Region --tag-specifications "ResourceType=instance,Tags=[$($tags -join ',')]" --dry-run 2>$null
        if ($taggedLaunchResult) {
            Write-TestResult "Tagged Resource Creation" "PASS" "Tagged resource creation would succeed"
        } else {
            Write-TestResult "Tagged Resource Creation" "WARN" "Dry-run blocked (may be normal)"
        }
    } catch {
        Write-TestResult "Tagged Resource Creation" "WARN" "Unable to test tagged resource creation"
    }
}

function Test-CloudTrailAccess {
    Write-Host "`n=== Audit and Logging Tests ===" -ForegroundColor Cyan
    
    # Test CloudTrail access
    try {
        $trails = aws cloudtrail describe-trails --region $Region --output json 2>$null
        if ($trails) {
            Write-TestResult "CloudTrail Access" "PASS" "Can view CloudTrail configuration"
        } else {
            Write-TestResult "CloudTrail Access" "WARN" "Cannot view CloudTrail (may be restricted)"
        }
    } catch {
        Write-TestResult "CloudTrail Access" "FAIL" "Error accessing CloudTrail"
    }
    
    # Test recent events access
    try {
        $events = aws cloudtrail lookup-events --region $Region --max-items 1 --output json 2>$null
        if ($events) {
            Write-TestResult "CloudTrail Events Access" "PASS" "Can view recent events"
        } else {
            Write-TestResult "CloudTrail Events Access" "WARN" "Cannot view events (may be restricted)"
        }
    } catch {
        Write-TestResult "CloudTrail Events Access" "FAIL" "Error accessing CloudTrail events"
    }
}

function Test-PasswordPolicy {
    Write-Host "`n=== Password Policy Tests ===" -ForegroundColor Cyan
    
    try {
        $passwordPolicy = aws iam get-account-password-policy --output json 2>$null
        if ($passwordPolicy) {
            $policy = $passwordPolicy | ConvertFrom-Json
            $minLength = $policy.PasswordPolicy.MinimumPasswordLength
            
            if ($minLength -ge 12) {
                Write-TestResult "Password Policy Length" "PASS" "Minimum length: $minLength characters"
            } else {
                Write-TestResult "Password Policy Length" "FAIL" "Minimum length too short: $minLength"
            }
            
            if ($policy.PasswordPolicy.RequireSymbols -eq $true) {
                Write-TestResult "Password Policy Complexity" "PASS" "Symbol requirement enabled"
            } else {
                Write-TestResult "Password Policy Complexity" "WARN" "Symbols not required"
            }
        } else {
            Write-TestResult "Password Policy Check" "FAIL" "Cannot access password policy"
        }
    } catch {
        Write-TestResult "Password Policy Check" "FAIL" "Error checking password policy"
    }
}

function Generate-TestReport {
    Write-Host "`n=== Test Summary Report ===" -ForegroundColor Cyan
    
    $passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
    $failCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
    $warnCount = ($testResults | Where-Object { $_.Status -eq "WARN" }).Count
    $totalCount = $testResults.Count
    
    Write-Host "Total Tests: $totalCount" -ForegroundColor White
    Write-Host "Passed: $passCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor Red
    Write-Host "Warnings: $warnCount" -ForegroundColor Yellow
    
    $successRate = [math]::Round(($passCount / $totalCount) * 100, 2)
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
    
    # Save detailed results to JSON file
    $reportPath = "testing/test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $testResults | ConvertTo-Json -Depth 3 | Out-File $reportPath -Encoding UTF8
    Write-Host "`nDetailed results saved to: $reportPath" -ForegroundColor Cyan
    
    # Risk assessment
    if ($failCount -eq 0) {
        Write-Host "`nRisk Assessment: LOW - All critical tests passed" -ForegroundColor Green
    } elseif ($failCount -le 2) {
        Write-Host "`nRisk Assessment: MEDIUM - Some tests failed" -ForegroundColor Yellow
    } else {
        Write-Host "`nRisk Assessment: HIGH - Multiple failures detected" -ForegroundColor Red
    }
}

# Main execution
Write-Host "IAM Security Testing Script for XYZ Corporation" -ForegroundColor Magenta
Write-Host "Testing user: $TestUser in region: $Region" -ForegroundColor Cyan
Write-Host "Started at: $(Get-Date)" -ForegroundColor Gray

# Check prerequisites
if (-not (Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI not found. Please install AWS CLI and configure credentials." -ForegroundColor Red
    exit 1
}

# Run test suites
if (Test-AWSConnection) {
    Test-EC2Permissions
    Test-IAMPermissions
    Test-TaggingPolicy
    Test-CloudTrailAccess
    Test-PasswordPolicy
} else {
    Write-Host "Skipping remaining tests due to authentication failure" -ForegroundColor Red
}

# Generate final report
Generate-TestReport

Write-Host "`nTesting completed at: $(Get-Date)" -ForegroundColor Gray
Write-Host "Please review the results and address any failures or warnings." -ForegroundColor Cyan
