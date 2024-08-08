# Terraform setup for creating VS Code and Intellij Workstations

Note: The following APIs have to be enabled manually (even though they are enabled in the main.tf as well), as there are some terraform provider issues - https://github.com/hashicorp/terraform-provider-google/issues/13459

1. Service Usage API
2. Compute Engine API
3. Cloud Resource Manager API
4. Workstation API

## Setup
Cloud shell is the recommended tool to follow this setup.

Terraform will pick up the GCP project name from the environment variable.

```bash
export GOOGLE_CLOUD_PROJECT=<PROJECT-ID>
```

After that, let's get Terraform started. Run the following to pull in the providers:

```terraform
terraform init
```

Create the resources mentioned in main.tf using the following commands:

```terraform
terraform plan -out workstations.plan
terraform apply "workstations.plan"
```

Use the following command to destroy the resources:

```terraform
terraform destroy
```
