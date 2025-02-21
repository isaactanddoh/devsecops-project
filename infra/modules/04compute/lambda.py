import json
import boto3
from datetime import datetime
import os
import logging
from typing import Dict, Any
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients with retries
config = boto3.Config(
    retries = dict(
        max_attempts = 3,
        mode = 'adaptive'
    )
)

guardduty_client = boto3.client('guardduty', config=config)
waf_client = boto3.client('wafv2', config=config)
sns_client = boto3.client('sns', config=config)

# Get these from environment variables
WEB_ACL_ID = os.environ['WEB_ACL_ID']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def validate_finding(finding: Dict[str, Any]) -> bool:
    """Validate the GuardDuty finding has required fields."""
    required_fields = [
        'detail.service.action.portProbeAction.portProbeDetails',
        'detail.type',
        'detail.severity',
        'detail.description'
    ]
    
    for field in required_fields:
        keys = field.split('.')
        current = finding
        for key in keys:
            if not isinstance(current, dict) or key not in current:
                logger.error(f"Missing required field: {field}")
                return False
            current = current[key]
    return True

def lambda_handler(event, context):
    logger.info("Received GuardDuty Finding: %s", json.dumps(event, indent=2))
    
    try:
        for record in event.get('Records', []):
            if 'body' not in record:
                logger.error("Invalid record format: missing 'body' field")
                continue
                
            finding = json.loads(record['body'])
            
            if not validate_finding(finding):
                continue
            
            # Extract threat details with safe navigation
            threat_details = finding['detail']['service']['action']['portProbeAction']['portProbeDetails'][0]
            threat_ip = threat_details.get('remoteIpDetails', {}).get('ipAddressV4')
            
            if not threat_ip:
                logger.error("Invalid finding: missing IP address")
                continue
                
            threat_type = finding['detail']['type']
            threat_severity = finding['detail']['severity']
            threat_description = finding['detail']['description']
            
            logger.info(f"Processing threat from IP: {threat_ip}")
            
            # Block the IP with retries
            if block_ip_in_waf(threat_ip):
                # Send notification
                send_notification(
                    threat_ip=threat_ip,
                    threat_type=threat_type,
                    severity=threat_severity,
                    description=threat_description
                )
            
    except Exception as e:
        error_msg = f"Error processing GuardDuty event: {str(e)}"
        logger.error(error_msg, exc_info=True)
        send_notification(error=error_msg)
        raise

    return {
        'statusCode': 200,
        'body': json.dumps('Threat mitigated successfully!')
    }

def block_ip_in_waf(ip_address):
    try:
        response = waf_client.update_ip_set(
            Name='BlockList',
            Scope='REGIONAL',
            Id=WEB_ACL_ID,
            Addresses=[f"{ip_address}/32"]  # Using CIDR notation
        )
        print(f"Successfully blocked IP {ip_address} in WAF")
        return True
    except Exception as e:
        error_msg = f"Error blocking IP in WAF: {str(e)}"
        print(error_msg)
        send_notification(error=error_msg)
        return False

def send_notification(threat_ip=None, threat_type=None, severity=None, description=None, error=None):
    try:
        if error:
            message = f"⚠️ Error in GuardDuty Lambda:\n{error}"
        else:
            message = f"""
🚨 Security Threat Detected and Blocked

IP Address: {threat_ip}
Threat Type: {threat_type}
Severity: {severity}
Description: {description}
Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

Action Taken: IP has been automatically blocked in WAF.
"""
        
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="GuardDuty Alert - Security Threat Detected",
            Message=message
        )
    except Exception as e:
        print(f"Error sending SNS notification: {str(e)}")
