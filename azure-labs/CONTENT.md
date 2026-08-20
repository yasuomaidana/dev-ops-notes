# Azure Labs Content Guide

This file organizes the content inside `azure-labs` in a simple learning order.

## Recommended order

1. Start with [ARM Creation](./arm-creation/README.md)
2. Review [ARM Basics](./arm-creation/docs/arm-template-basics.md)
3. Practice with [ARM Examples](./arm-creation/examples/README.md)
4. Continue with [Azure Policy](./azure-policy/README.md)
5. Review [Policy Basics](./azure-policy/docs/policy-basics.md)
6. Finish with [Azure RBAC Overview](./azure-policy/docs/azure-rbac-overview.md)

## Folder overview

### `arm-creation`

Purpose:
Learn how to create Azure infrastructure with Bicep and deploy a Debian 12 virtual machine.

Main files:

| File | What it is for |
|---|---|
| [README.md](./arm-creation/README.md) | Main lab guide for creating and deploying the VM. |
| [azuredeploy.bicep](./arm-creation/azuredeploy.bicep) | Main Bicep template with the VM, networking, public IP, disk, and NSG. |
| [azuredeploy.bicepparam](./arm-creation/azuredeploy.bicepparam) | Deployment parameter values for the Bicep template. |
| [azuredeploy.json](./arm-creation/azuredeploy.json) | ARM JSON version of the deployment. |
| [azuredeploy.parameters.json](./arm-creation/azuredeploy.parameters.json) | ARM JSON parameters file. |
| [docs/arm-template-basics.md](./arm-creation/docs/arm-template-basics.md) | Beginner explanation of how Bicep templates are structured. |
| [examples/README.md](./arm-creation/examples/README.md) | Smaller practice examples for learning by comparison. |

### `azure-policy`

Purpose:
Learn how Azure Policy can enforce rules during deployments.

Main files:

| File | What it is for |
|---|---|
| [README.md](./azure-policy/README.md) | Main lab guide for policy deployment, testing, compliance, and cleanup. |
| [azuredeploy.bicep](./azure-policy/azuredeploy.bicep) | Main Bicep file for the policy lab. |
| [azuredeploy.bicepparam](./azure-policy/azuredeploy.bicepparam) | Parameter values for the policy deployment. |
| [submission-lab.md](./azure-policy/submission-lab.md) | Submission or hand-in notes for the lab. |
| [docs/policy-basics.md](./azure-policy/docs/policy-basics.md) | Introductory explanation of Azure Policy concepts. |
| [docs/azure-rbac-overview.md](./azure-policy/docs/azure-rbac-overview.md) | RBAC reference to understand permissions and role assignments. |
| [modules/policy-assignment.bicep](./azure-policy/modules/policy-assignment.bicep) | Reusable module for assigning policy definitions. |

## Suggested way to study

### If you are new to Bicep

Read these first:

1. [ARM Creation README](./arm-creation/README.md)
2. [ARM Template Basics](./arm-creation/docs/arm-template-basics.md)
3. [Examples README](./arm-creation/examples/README.md)

### If you want deployment practice

Focus on these files:

1. [arm-creation/azuredeploy.bicep](./arm-creation/azuredeploy.bicep)
2. [arm-creation/azuredeploy.bicepparam](./arm-creation/azuredeploy.bicepparam)
3. [azure-policy/azuredeploy.bicep](./azure-policy/azuredeploy.bicep)
4. [azure-policy/modules/policy-assignment.bicep](./azure-policy/modules/policy-assignment.bicep)

### If you want governance and compliance

Read these after the VM lab:

1. [Azure Policy README](./azure-policy/README.md)
2. [Policy Basics](./azure-policy/docs/policy-basics.md)
3. [Azure RBAC Overview](./azure-policy/docs/azure-rbac-overview.md)

## Quick map

- Infrastructure creation:
  [arm-creation](./arm-creation/README.md)
- Governance and compliance:
  [azure-policy](./azure-policy/README.md)
- Beginner explanations:
  [arm-creation/docs](./arm-creation/docs/arm-template-basics.md),
  [azure-policy/docs](./azure-policy/docs/policy-basics.md)
- Hands-on examples:
  [arm-creation/examples](./arm-creation/examples/README.md)
