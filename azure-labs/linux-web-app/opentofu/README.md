# OpenTofu Linux Web App lab

This OpenTofu project is isolated from the VM lab. It creates a resource group and deploys the sibling
`../azuredeploy.json` ARM template through `azurerm_resource_group_template_deployment`.

## Files

| File                       | Purpose                                                |
|----------------------------|--------------------------------------------------------|
| `providers.tf`             | OpenTofu and AzureRM provider requirements.            |
| `variables.tf`             | Input values passed into the ARM template deployment.  |
| `main.tf`                  | Resource group plus the ARM deployment resource.       |
| `outputs.tf`               | Useful outputs including the default hostname and URL. |
| `terraform.tfvars.example` | Example values for the deployment.                     |

## Usage

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
tofu init
tofu fmt
tofu validate
tofu plan -out linux-web-app.tfplan
tofu apply linux-web-app.tfplan
```

`web_app_name_prefix` is combined with an eight-character random suffix to form the Azure Web App name. The suffix is
stored in OpenTofu state, so the generated default hostname remains stable across later applies:
`https://<web_app_name_prefix>-<random_suffix>.azurewebsites.net`. If you intentionally need a new suffix, taint
`random_string.web_app_suffix` before planning. A custom domain does not bypass Azure's unique app-name requirement.

To use a custom domain, first create the web app with a unique Azure name. Then create the required DNS record at your
DNS provider and add an App Service hostname binding (and TLS certificate for HTTPS). This OpenTofu lab currently
outputs the default hostname but does not create custom-domain DNS records or hostname bindings. The comments in
`terraform.tfvars` show the naming implications.

The suffix is stored in state and remains stable. To force a new suffix:
```
tofu apply -replace=random_string.web_app_suffix
```
