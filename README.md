# Secure CI/CD Infrastructure Project

A secure infrastructure-as-code project implementing best practices for AWS infrastructure deployment with multiple environments and comprehensive security controls.

## Project Overview

This project implements a secure CI/CD pipeline with:
- Multi-environment infrastructure (dev, staging, prod)
- Security policy enforcement using OPA and Sentinel
- Automated testing and validation
- Infrastructure deployment safeguards
- AWS best practices implementation

## Architecture

The infrastructure is organized into modules:
- **Networking**: VPC, Subnets, Security Groups
- **Security**: WAF, ACM, Security Policies
- **Load Balancer**: Application Load Balancer with HTTPS
- **Compute**: ECS Fargate with auto-scaling
- **Monitoring**: CloudWatch, Alerts, Logging

## Security Features

- WAF protection for web applications
- HTTPS enforcement with modern TLS
- Container security controls
- Network segmentation
- Access logging
- Encryption at rest and in transit
- Regular security scanning

## Prerequisites

- AWS Account
- Terraform >= 1.0
- OPA (Open Policy Agent)
- GitHub Account (for CI/CD)
- AWS CLI configured
- Make utility

## Directory Structure 