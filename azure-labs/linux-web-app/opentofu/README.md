# OpenTofu Linux Web App lab

This OpenTofu project is isolated from the VM lab. It creates a resource group and deploys the sibling
`../azuredeploy.json` ARM template through `azurerm_resource_group_template_deployment`.

## Files

| File | Purpose |
| --- | --- |
| `providers.tf` | OpenTofu and AzureRM provider requirements. |
| `variables.tf` | Input values passed into the ARM template deployment. |
| `main.tf` | Resource group plus the ARM deployment resource. |
| `outputs.tf` | Useful outputs including the default hostname and URL. |
| `terraform.tfvars.example` | Example values for the deployment. |

## Usage

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
tofu init
tofu fmt
tofu validate
tofu plan -out linux-web-app.tfplan
tofu apply linux-web-app.tfplan
```
