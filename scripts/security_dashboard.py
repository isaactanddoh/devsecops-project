#!/usr/bin/env python3

import boto3
import json
import yaml
import datetime
import requests
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

    def get_vulnerability_metrics(self):
        metrics = {
            "critical": 0,
            "high": 0,
            "medium": 0,
            "fixed": 0,
            "in_progress": 0
        }
        
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