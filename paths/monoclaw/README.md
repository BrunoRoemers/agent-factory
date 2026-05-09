# Multiclaw (Agent Factory Path)

Run OpenClaw on Hetzner.

1. copy `terraform.tfvars.example` to `terraform.tfvars` and fill in
2. run `terraform init` in this folder
3. run `terraform plan` to see what actions will be taken
4. run `terraform apply` to create the resources
5. run `terraform destroy` to remove the resources again

⚠️ `cloud-init` still needs to run when `terraform` exits, use `cloud-init status --long`
on the server to verify if initialization has completed.

`cloud-init` logs are stored on the server in `/var/log/cloud-init-output.log`.
