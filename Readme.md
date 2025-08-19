# DR Terraform scaffold (ASR + Backup + GRS) — minimal-repetition

What this does:
- Creates resource groups, storage accounts (GRS), VNets/subnets for each region in `var.regions`.
- Deploys a simple Linux VM in the primary region.
- Creates Recovery Services Vaults per region.
- Creates a backup policy and protects the primary VM.
- Adds ASR replication resources scaffold (replication policy, fabric, protection container, replicated VM).

Notes:
- Some ASR resources require fabric/container IDs that Azure populates asynchronously. If you get TF errors referencing these IDs:
  1. `terraform apply` the vault/vnet/VM resources first.
  2. Use `az` CLI to list the ASR fabrics/protection containers to obtain the IDs.
  3. Add them as data sources or import them into state, then apply the ASR replicated VM resource.
- Keep secrets (admin_password, sql_password) in Azure DevOps variable groups or Key Vault; do not store in repo.

Quick start:
1. Copy `terraform.tfvars.example` → `terraform.tfvars` and fill values (or set variables in pipeline).
2. `cd infra`
3. `terraform init`
4. `terraform plan -out plan.tfplan`
5. `terraform apply plan.tfplan`

After first apply:
- If ASR `replicated_vm` fails due to missing fabric/container IDs: query the vault and import the needed resources or add data lookups.

CI/CD:
- Use the included `azure-pipelines.yml` as a starting point. Store secrets in pipeline variable groups or Azure Key Vault-backed service connection.

If you want, I will:
- create scripts to query the ASR fabric/container IDs and patch Terraform variables automatically, or
- convert the ASR setup to a two-step Terraform flow (apply infra, run script to gather IDs, then apply ASR).
