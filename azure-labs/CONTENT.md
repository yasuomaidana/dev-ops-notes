# Azure Labs

Hands-on labs for deploying Azure resources with Bicep, Azure CLI, and OpenTofu.

Start with the shared [Azure CLI setup](./getting-started.md) before creating resources. Lab-specific deployment, verification, and cleanup steps stay with each lab.

## Suggested learning order

1. [Create a Debian VM with Bicep](./arm-creation/README.md)
2. Review [Bicep and ARM template basics](./arm-creation/docs/arm-template-basics.md)
3. Compare the [OpenTofu VM lab](./arm-creation/opentofu/README.md)
4. Practice with the smaller [Bicep examples](./arm-creation/examples/README.md)
5. Learn about [Azure Policy](./azure-policy/README.md), then review [Policy basics](./azure-policy/docs/policy-basics.md) and [Azure RBAC](./azure-policy/docs/azure-rbac-overview.md)
6. Try the [Linux Web App lab](./linux-web-app/README.md) and [scaling lab](./linux-web-app-scaling/README.md)

## Source files

- VM lab: [Bicep template](./arm-creation/azuredeploy.bicep), [parameters](./arm-creation/azuredeploy.bicepparam), and [OpenTofu configuration](./arm-creation/opentofu/main.tf).
- Policy lab: [Bicep template](./azure-policy/azuredeploy.bicep) and [policy assignment module](./azure-policy/modules/policy-assignment.bicep).
- Linux Web App scaling lab: [Bicep template](./linux-web-app-scaling/azuredeploy.bicep) and [OpenTofu configuration](./linux-web-app-scaling/opentofu/main.tf).
