# Create Networking Environment
module "networking" {
  source                   = "./modules/01networking"
  allowed_cidr_blocks      = var.allowed_cidr_blocks
  project_name             = var.project_name
  subnet_cidrs             = var.subnet_cidrs
  environment              = terraform.workspace
  vpc_cidr                 = var.vpc_cidr
  availability_zones_count = var.availability_zones_count
  container_port           = var.container_port
}

# Create Security Environment
module "security" {
  source                = "./modules/02security"
  workspace_config      = local.workspace_config
  portfolio_domain_name = var.portfolio_domain_name
  wildcard_domain_name = var.wildcard_domain_name
  primary_domain_name   = var.primary_domain_name
  iam_cert_name         = var.iam_cert_name
  aws_region            = var.aws_region
  waf_acl_name          = var.waf_acl_name
  waf_scope             = var.waf_scope
  waf_default_action    = var.waf_default_action
  depends_on            = [module.networking]
  project_name          = var.project_name
  owner                 = var.owner
}

# Create Load Balancer
module "load_balancer" {
  source                  = "./modules/03load-balancer"
  aws_region              = var.aws_region
  container_port          = var.container_port
  iam_cert_name           = var.iam_cert_name
  alb_https_listener_port = var.alb_https_listener_port
  alb_certificate_arn     = module.security.acm_certificate_arn
  waf_acl_id              = module.security.waf_acl_arn
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.public_subnet_ids
  alb_security_group_id   = module.networking.alb_security_group_id
  portfolio_domain_name   = var.portfolio_domain_name
  wildcard_domain_name    = var.wildcard_domain_name
  depends_on              = [module.security]
  waf_scope               = var.waf_scope
  project_name            = var.project_name
  owner                   = var.owner
}

# Create Monitoring Environment
module "monitoring" {
  source                   = "./modules/05monitoring"
  aws_region               = var.aws_region
  environment              = terraform.workspace
  project_name             = var.project_name
  owner                    = var.owner
  alb_arn_suffix           = module.load_balancer.alb_arn_suffix
  alert_email_address      = var.alert_email_address
  security_alert_email_address = var.security_alert_email_address
  log_retention_days       = lookup(local.workspace_config[terraform.workspace], "log_retention_days", 30)
  flow_logs_retention_days = lookup(local.workspace_config[terraform.workspace], "flow_logs_retention_days", 30)
  cpu_threshold            = lookup(local.workspace_config[terraform.workspace], "cpu_threshold", 80)
  api_latency_threshold    = lookup(local.workspace_config[terraform.workspace], "api_latency_threshold", 1)

  depends_on = [module.load_balancer, module.security, module.networking]
}

# Create Compute Environment
module "compute" {
  source                = "./modules/04compute"
  workspace_config      = local.workspace_config[terraform.workspace]
  environment           = terraform.workspace
  project_name          = var.project_name
  owner                 = var.owner
  aws_region            = var.aws_region
  waf_acl_id            = module.security.waf_acl_arn
  iam_cert_name         = var.iam_cert_name
  container_port        = var.container_port
  container_user        = var.container_user
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  ecs_security_group_id = module.networking.ecs_security_group_id
  memory_threshold         = lookup(local.workspace_config[terraform.workspace], "memory_threshold", 80)
  depends_on            = [module.load_balancer, module.monitoring]
}

# Create CloudWatch Access Environment
module "cloudwatch_access" {
  source            = "./modules/06cloudwatch-access"
  aws_region        = var.aws_region
  environment       = terraform.workspace
  project_name      = var.project_name
  owner            = var.owner
  enable_sso       = var.enable_sso
  sso_instance_arn = var.sso_instance_arn
  team_member_names = var.team_member_names
  depends_on       = [module.compute]
}

