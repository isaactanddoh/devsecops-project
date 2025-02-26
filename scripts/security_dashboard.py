#!/usr/bin/env python3

import boto3
import json
import yaml
import datetime
import requests
import os
from tabulate import tabulate
from pathlib import Path

class SecurityDashboard:
    def __init__(self):
        self.aws_session = boto3.Session()
        self.config = self.load_config()
        self.metrics = {}

    def load_config(self):
        config_path = Path(__file__).parent.parent / "docs/security/dashboard-config.yml"
        with open(config_path) as f:
            return yaml.safe_load(f)

    def get_detector_id(self):
        """Get GuardDuty detector ID from SSM Parameter Store"""
        try:
            ssm = self.aws_session.client('ssm')
            response = ssm.get_parameter(
                Name=f"/isaac-{self.get_environment()}/guardduty_detector_id",
                WithDecryption=True
            )
            return response['Parameter']['Value']
        except Exception as e:
            print(f"Warning: Could not fetch GuardDuty detector ID: {str(e)}")
            return None

    def get_environment(self):
        """Get current environment name"""
        try:
            # Try to get environment from AWS session
            sts = self.aws_session.client('sts')
            account_id = sts.get_caller_identity()['Account']
            
            # Map account IDs to environments, or use a default
            # You might want to adjust this mapping based on your setup
            return 'dev'  # Default to dev for safety
        except Exception as e:
            print(f"Warning: Could not determine environment: {str(e)}")
            return 'dev'  # Default to dev environment


    def get_vulnerability_metrics(self):
        metrics = {
            "critical": 0,
            "high": 0,
            "medium": 0,
            "fixed": 0,
            "in_progress": 0
        }
        
        # Get vulnerability metrics from configured sources
        vuln_sources = self.config.get('metrics', {}).get('vulnerability_scanning', {}).get('sources', [])
        
        for source in vuln_sources:
            source_name = source.get('name')
            try:
                if source_name == "Dependabot":
                    # Get Dependabot alerts from GitHub API
                    metrics = self._get_dependabot_metrics(metrics)
                elif source_name == "Snyk":
                    # Get Snyk results
                    metrics = self._get_snyk_metrics(metrics)
                elif source_name == "OWASP Dependency Check":
                    # Get OWASP Dependency Check results
                    report_path = Path(__file__).parent.parent / source.get('path', '').lstrip('/')
                    if report_path.exists():
                        metrics = self._parse_dependency_check_report(report_path, metrics)
            except Exception as e:
                print(f"Warning: Could not fetch metrics from {source_name}: {str(e)}")
            
        return metrics

    def _get_dependabot_metrics(self, metrics):
        """Get vulnerability metrics from Dependabot"""
        try:
            github_token = os.getenv('GITHUB_TOKEN')
            if not github_token:
                print("Warning: GITHUB_TOKEN not set, skipping Dependabot metrics")
                return metrics
            
            headers = {
                'Authorization': f'token {github_token}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            # Get repository details from config or environment
            owner = os.getenv('GITHUB_REPOSITORY_OWNER')
            repo = os.getenv('GITHUB_REPOSITORY').split('/')[-1]
            
            response = requests.get(
                f'https://api.github.com/repos/{owner}/{repo}/dependabot/alerts',
                headers=headers
            )
            
            if response.status_code == 200:
                alerts = response.json()
                for alert in alerts:
                    severity = alert.get('security_advisory', {}).get('severity', '').lower()
                    if severity in metrics:
                        metrics[severity] += 1
                    if alert.get('state') == 'fixed':
                        metrics['fixed'] += 1
                    else:
                        metrics['in_progress'] += 1
        except Exception as e:
            print(f"Warning: Error fetching Dependabot metrics: {str(e)}")
        
        return metrics

    def _get_snyk_metrics(self, metrics):
        """Get vulnerability metrics from Snyk"""
        try:
            snyk_token = os.getenv('SNYK_TOKEN')
            if not snyk_token:
                print("Warning: SNYK_TOKEN not set, skipping Snyk metrics")
                return metrics
            
            headers = {
                'Authorization': f'token {snyk_token}'
            }
            
            # This would need to be configured based on your Snyk setup
            org_id = os.getenv('SNYK_ORG_ID')
            project_id = os.getenv('SNYK_PROJECT_ID')
            
            response = requests.get(
                f'https://snyk.io/api/v1/org/{org_id}/project/{project_id}/aggregated-issues',
                headers=headers
            )
            
            if response.status_code == 200:
                issues = response.json()
                for issue in issues:
                    severity = issue.get('severity', '').lower()
                    if severity in metrics:
                        metrics[severity] += 1
                    if issue.get('isFixed'):
                        metrics['fixed'] += 1
                    else:
                        metrics['in_progress'] += 1
        except Exception as e:
            print(f"Warning: Error fetching Snyk metrics: {str(e)}")
        
        return metrics

    def _parse_dependency_check_report(self, report_path, metrics):
        """Parse OWASP Dependency Check HTML report"""
        try:
            with open(report_path) as f:
                content = f.read()
                # This is a simple example - you might want to use proper HTML parsing
                metrics['critical'] += content.count('Severity: Critical')
                metrics['high'] += content.count('Severity: High')
                metrics['medium'] += content.count('Severity: Medium')
        except Exception as e:
            print(f"Warning: Error parsing Dependency Check report: {str(e)}")
        
        # Get Trivy scan results
        trivy_report_path = Path(__file__).parent.parent / "reports/trivy-results.json"
        if trivy_report_path.exists():
            with open(trivy_report_path) as f:
                report = json.load(f)
                for vulnerability in report.get("vulnerabilities", []):
                    severity = vulnerability.get("severity", "").lower()
                    if severity in metrics:
                        metrics[severity] += 1
                    if vulnerability.get("fixed_version"):
                        metrics["fixed"] += 1
                    else:
                        metrics["in_progress"] += 1

        return metrics

    def get_aws_security_metrics(self):
        metrics = {
            "guardduty_findings": 0,
            "waf_blocks": 0,
            "failed_logins": 0
        }

        # Get GuardDuty findings
        guardduty = self.aws_session.client('guardduty')
        detector_id = self.get_detector_id()
        if detector_id:
            findings = guardduty.list_findings(DetectorId=detector_id)
            metrics["guardduty_findings"] = len(findings.get("FindingIds", []))

        # Get WAF blocks
        wafv2 = self.aws_session.client('wafv2')
        web_acls = wafv2.list_web_acls(Scope='REGIONAL')
        for acl in web_acls.get("WebACLs", []):
            metrics["waf_blocks"] += self.get_waf_blocks(acl["Id"])

        # Get failed logins
        cloudwatch = self.aws_session.client('cloudwatch')
        metrics["failed_logins"] = self.get_failed_logins(cloudwatch)

        return metrics

    def get_container_metrics(self):
        metrics = {
            "vulnerable_containers": 0,
            "unhealthy_tasks": 0,
            "high_cpu_containers": 0
        }

        # Get ECS metrics
        ecs = self.aws_session.client('ecs')
        clusters = ecs.list_clusters()
        for cluster_arn in clusters.get("clusterArns", []):
            metrics["unhealthy_tasks"] += self.get_unhealthy_tasks(cluster_arn)
            metrics["high_cpu_containers"] += self.get_high_cpu_containers(cluster_arn)

        return metrics

    def get_waf_blocks(self, acl_id):
        """Get number of WAF blocks in the last 24 hours"""
        try:
            cloudwatch = self.aws_session.client('cloudwatch')
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/WAFV2',
                MetricName='BlockedRequests',
                Dimensions=[{'Name': 'WebACL', 'Value': acl_id}],
                StartTime=datetime.datetime.utcnow() - datetime.timedelta(hours=24),
                EndTime=datetime.datetime.utcnow(),
                Period=3600,
                Statistics=['Sum']
            )
            return sum(point['Sum'] for point in response.get('Datapoints', []))
        except Exception as e:
            print(f"Warning: Could not fetch WAF blocks: {str(e)}")
            return 0

    def get_failed_logins(self, cloudwatch):
        """Get number of failed login attempts in the last 24 hours"""
        try:
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/CloudTrail',
                MetricName='LoginFailure',
                StartTime=datetime.datetime.utcnow() - datetime.timedelta(hours=24),
                EndTime=datetime.datetime.utcnow(),
                Period=3600,
                Statistics=['Sum']
            )
            return sum(point['Sum'] for point in response.get('Datapoints', []))
        except Exception as e:
            print(f"Warning: Could not fetch failed logins: {str(e)}")
            return 0

    def get_unhealthy_tasks(self, cluster_arn):
        """Get number of unhealthy tasks in an ECS cluster"""
        try:
            ecs = self.aws_session.client('ecs')
            response = ecs.list_tasks(
                cluster=cluster_arn,
                desiredStatus='STOPPED'
            )
            return len(response.get('taskArns', []))
        except Exception as e:
            print(f"Warning: Could not fetch unhealthy tasks: {str(e)}")
            return 0

    def get_high_cpu_containers(self, cluster_arn):
        """Get number of containers with high CPU usage"""
        try:
            cloudwatch = self.aws_session.client('cloudwatch')
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/ECS',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'ClusterName', 'Value': cluster_arn.split('/')[-1]}],
                StartTime=datetime.datetime.utcnow() - datetime.timedelta(hours=1),
                EndTime=datetime.datetime.utcnow(),
                Period=300,
                Statistics=['Average']
            )
            return sum(1 for point in response.get('Datapoints', []) if point['Average'] > 80)
        except Exception as e:
            print(f"Warning: Could not fetch high CPU containers: {str(e)}")
            return 0

    def generate_dashboard(self):
        print("\n=== Security Dashboard ===\n")
        
        # Collect all metrics
        vuln_metrics = self.get_vulnerability_metrics()
        aws_metrics = self.get_aws_security_metrics()
        container_metrics = self.get_container_metrics()

        # Format tables
        vuln_table = [
            ["Critical Vulnerabilities", vuln_metrics["critical"]],
            ["High Vulnerabilities", vuln_metrics["high"]],
            ["Medium Vulnerabilities", vuln_metrics["medium"]]
        ]

        aws_table = [
            ["GuardDuty Findings", aws_metrics["guardduty_findings"]],
            ["WAF Blocks (24h)", aws_metrics["waf_blocks"]],
            ["Failed Logins (24h)", aws_metrics["failed_logins"]]
        ]

        container_table = [
            ["Vulnerable Containers", container_metrics["vulnerable_containers"]],
            ["Unhealthy Tasks", container_metrics["unhealthy_tasks"]],
            ["High CPU Usage", container_metrics["high_cpu_containers"]]
        ]

        # Print dashboard
        print("Application Security:")
        print(tabulate(vuln_table, tablefmt="grid"))
        print("\nAWS Security:")
        print(tabulate(aws_table, tablefmt="grid"))
        print("\nContainer Security:")
        print(tabulate(container_table, tablefmt="grid"))

        # Check thresholds and print alerts
        self.check_alerts(vuln_metrics, aws_metrics, container_metrics)

    def check_alerts(self, vuln_metrics, aws_metrics, container_metrics):
        alerts = []
        
        if vuln_metrics["critical"] > 0:
            alerts.append("⚠️ Critical vulnerabilities detected!")
        if aws_metrics["guardduty_findings"] > 0:
            alerts.append("🚨 Active GuardDuty findings!")
        if container_metrics["unhealthy_tasks"] > 0:
            alerts.append("⚠️ Unhealthy container tasks detected!")

        if alerts:
            print("\nAlerts:")
            for alert in alerts:
                print(alert)

if __name__ == "__main__":
    dashboard = SecurityDashboard()
    dashboard.generate_dashboard() 