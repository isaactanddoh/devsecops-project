.PHONY: test-opa test-all clean

test-all: test-opa clean

test-opa:
	@echo "Running OPA policy checks..."
	@echo "Current workspace is: $$(terraform workspace show)"
	@if [ -f "environments/terraform.tfvars.$$(terraform workspace show)" ]; then \
		echo "Using tfvars file: environments/terraform.tfvars.$$(terraform workspace show)"; \
		terraform plan -var-file="environments/terraform.tfvars.$$(terraform workspace show)" -lock=false -out=tfplan.binary || exit 1; \
	else \
		echo "Error: tfvars file not found for workspace $$(terraform workspace show)"; \
		exit 1; \
	fi
	@echo "Converting plan to JSON..."
	terraform show -json tfplan.binary > tfplan.json
	@echo "Checking OPA policies..."
	@echo "Found the following policy files:"
	@ls -l policies/opa/*.rego
	@echo "Evaluating policies with debug output..."
	@opa eval --format pretty \
		--data policies/opa/base.rego \
		--data policies/opa/container_security.rego \
		--data policies/opa/ecs_security.rego \
		--data policies/opa/network_security.rego \
		--input tfplan.json \
		--fail \
		"data.terraform.deny" || { \
			echo "OPA policy violations found. Details:"; \
			opa eval --format pretty \
				--data policies/opa/base.rego \
				--data policies/opa/container_security.rego \
				--data policies/opa/ecs_security.rego \
				--data policies/opa/network_security.rego \
				--input tfplan.json \
				--explain full \
				"data.terraform.deny"; \
			exit 1; \
		}
	@echo "All OPA policy checks passed!"

clean:
	@rm -f tfplan.binary tfplan.json