# Security Incident Scenarios

## Scenario 1: Unauthorized SSH Access Attempt

### Incident Details
- **Type**: Infrastructure Security
- **Severity**: High
- **Detection**: GuardDuty alert for unusual SSH attempts
- **Affected System**: ECS Container Instances

### Detection Methods
1. AWS GuardDuty Alert
2. CloudWatch Logs showing multiple failed SSH attempts
3. Security Group change attempts
4. Unusual IAM role usage

### Response Steps
1. **Immediate Actions**:
   ```bash
   # Block suspicious IPs
   aws waf update-ip-set --ip-set-id ${WAF_IPSET_ID} --changes Action=INSERT,IPAddress=${SUSPICIOUS_IP}
   
   # Rotate IAM credentials
   aws iam update-access-key --access-key-id ${AFFECTED_KEY_ID} --status Inactive
   
   # Update security groups
   aws ec2 revoke-security-group-ingress --group-id ${SG_ID} --protocol tcp --port 22 --cidr ${SUSPICIOUS_IP}
   ```

2. **Investigation**:
   ```bash
   # Gather CloudTrail logs
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
   
   # Check GuardDuty findings
   aws guardduty list-findings --detector-id ${DETECTOR_ID} --finding-criteria '{"Criterion": {"type": {"Eq": ["UnauthorizedAccess:EC2/SSHBruteForce"]}}}' 
   ```

3. **Recovery**:
   - Rotate all affected credentials
   - Update security group rules
   - Enable enhanced monitoring
   - Review IAM permissions

## Scenario 2: Critical Vulnerability in Portfolio App

### Incident Details
- **Type**: Application Security
- **Severity**: Critical
- **Detection**: Dependabot alert for RCE vulnerability
- **Affected System**: Portfolio Application

### Detection Methods
1. Dependabot Security Alert
2. OWASP Dependency Check
3. Snyk Security Scan
4. SonarQube Security Hotspot

### Response Steps
1. **Immediate Actions**:
   ```bash
   # Scale down vulnerable service
   aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-count 0
   
   # Deploy WAF rule
   aws wafv2 update-web-acl --web-acl-id ${WAF_ACL_ID} --rules ${EMERGENCY_RULES}
   ```

2. **Investigation**:
   ```bash
   # Check application logs
   aws logs get-log-events --log-group-name ${LOG_GROUP} --log-stream-name ${LOG_STREAM}
   
   # Review recent changes
   git log --since="24 hours ago" --pretty=format:"%h - %an, %ar : %s"
   ```

3. **Recovery**:
   - Update vulnerable dependencies
   - Deploy patched version
   - Run security scans
   - Update WAF rules 