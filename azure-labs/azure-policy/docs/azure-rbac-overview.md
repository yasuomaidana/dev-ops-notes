# Azure RBAC overview

Azure role-based access control (Azure RBAC) is Azure's authorization system for managing who can do what on Azure
resources. If you think of an access control list (ACL) as a list of permissions tied directly to objects, Azure RBAC
solves the same problem at cloud scale by assigning roles to identities at a defined scope.

In practice, Azure RBAC answers three questions:

1. Who needs access
2. What they are allowed to do
3. Where that access applies

## How Azure RBAC works

An Azure role assignment has three core parts:

| Component          | Meaning                                                                                                       |
|--------------------|---------------------------------------------------------------------------------------------------------------|
| Security principal | The identity receiving access, such as a user, group, service principal, or managed identity.                 |
| Role definition    | The set of allowed actions, such as read, write, or delete.                                                   |
| Scope              | The boundary where the access applies, such as a management group, subscription, resource group, or resource. |

Azure evaluates these three parts together. If a user is assigned a role at a higher scope, that access is inherited by
lower scopes beneath it.

## Key RBAC concepts

### Roles

Roles define permissions. Common built-in roles include:

| Role                        | Typical use                                                              |
|-----------------------------|--------------------------------------------------------------------------|
| `Owner`                     | Full management access, including the ability to grant access to others. |
| `Contributor`               | Can create and manage resources, but cannot grant access.                |
| `Reader`                    | Can view resources, but cannot make changes.                             |
| `User Access Administrator` | Can manage RBAC assignments without being full owner of every resource.  |

Azure also provides many resource-specific roles, such as `Virtual Machine Contributor`, and supports custom roles when
built-in roles are too broad or too narrow.

### Security principals

Azure RBAC does not assign access only to people. It can assign access to:

- Users
- Groups
- Service principals
- Managed identities

Using groups or managed identities is usually better than assigning broad permissions directly to many individual users.

### Permissions

Permissions are the actions a role allows. Examples include reading a resource, starting a virtual machine, or updating
a network security group. The role definition determines the allowed operations.

### Scope

Scope defines where the role works. Azure RBAC scopes are hierarchical:

1. Management group
2. Subscription
3. Resource group
4. Resource

Granting access at a narrower scope reduces blast radius and supports least privilege.

## Core RBAC principles

Azure RBAC is most effective when used with the following principles:

| Principle            | Why it matters                                                         |
|----------------------|------------------------------------------------------------------------|
| Least privilege      | Grant only the minimum access required to perform a task.              |
| Separation of duties | Split critical responsibilities across different people or teams.      |
| Need to know         | Limit visibility and control to only the resources required for a job. |

## Example

If a developer only needs to manage virtual machines in one resource group, assign `Virtual Machine Contributor` at that
resource-group scope. That lets the developer create and manage VMs there without granting unnecessary access to other
resource groups or unrelated services.

## Azure RBAC compared with Azure Policy

Azure RBAC and Azure Policy are related, but they solve different problems:

| Feature         | Azure RBAC                | Azure Policy                                             |
|-----------------|---------------------------|----------------------------------------------------------|
| Primary purpose | Access control            | Governance and compliance                                |
| Main question   | Who can perform an action | Whether a resource configuration is allowed or compliant |
| Mechanism       | Role assignments          | Policy definitions and assignments                       |
| Typical result  | Access granted or denied  | Resource audited, denied, modified, or remediated        |

Use Azure RBAC when you need to control permissions. Use Azure Policy when you need to control configuration standards.

## RBAC, Policy, and Blueprints summary

The following table gives a quick side-by-side comparison:

| Feature          | Azure RBAC                                | Azure Policy                              | Azure Blueprints                   |
|------------------|-------------------------------------------|-------------------------------------------|------------------------------------|
| Primary function | Access control                            | Resource configuration                    | Standardized deployment            |
| Focus            | User permissions                          | Resource properties                       | Reusable configurations            |
| Mechanism        | Roles                                     | Policy definitions                        | Blueprints (IaC + RBAC + Policies) |
| Scope            | Subscriptions, Resource Groups, Resources | Subscriptions, Resource Groups, Resources | Subscriptions, Resource Groups     |

## Azure Blueprints context

Azure Blueprints historically packaged resources, policy assignments, and RBAC assignments into a reusable deployment
model. That concept is still useful for understanding older training material, but the service itself is in phased
retirement.

As of **July 22, 2026**:

- New blueprint definitions and versions can still be created until **July 31, 2026**.
- Microsoft recommends migrating to **Deployment Stacks** and **Template Specs**.
- Older references to Blueprints are best treated as legacy governance guidance, not a preferred new design.

## Summary

Azure RBAC is Azure's authorization layer. It grants access by assigning a role to an identity at a specific scope. The
main design goal is precise, least-privilege access to Azure resources.

Combined with Azure Policy, RBAC becomes part of a larger governance model:

- Azure RBAC controls who can act.
- Azure Policy controls what is compliant.
- Deployment-focused tooling such as Bicep, Template Specs, and Deployment Stacks helps standardize how environments are
  created.

## Source references

- Microsoft Learn: Azure RBAC overview
  https://learn.microsoft.com/en-us/azure/role-based-access-control/overview
- Microsoft Learn: Understand scope for Azure RBAC
  https://learn.microsoft.com/en-us/azure/role-based-access-control/scope-overview
- Microsoft Learn: Azure Policy overview
  https://learn.microsoft.com/en-us/azure/governance/policy/overview
- Microsoft Learn: Azure Blueprints overview
  https://learn.microsoft.com/en-us/azure/governance/blueprints/overview
- Microsoft Learn: Azure Blueprints retirement
  https://learn.microsoft.com/en-us/azure/governance/blueprints/blueprint-retirement
