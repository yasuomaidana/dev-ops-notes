# Policy basics for this lab

This lab uses three Azure Policy objects:

| Object | Purpose in this lab |
| --- | --- |
| Built-in policy definition | Microsoft policy that audits Windows VMs for Azure Disk Encryption or EncryptionAtHost. |
| Initiative definition | Custom container named `Get Secure` that includes the built-in policy. |
| Assignment | Applies the initiative to one resource group. |

## Why the old lab felt broken

The earlier files in this folder implemented a custom tag policy. That had nothing to do with the DCA Tech VM
encryption scenario.

There is also a second problem: the Microsoft built-in policy used by the tutorial is not a deny policy. It is an
`AuditIfNotExists` policy, so it records non-compliance instead of blocking VM creation.

## What this means during testing

When you create a Windows VM without `Encryption at host` enabled:

- Azure Resource Manager can still deploy the VM.
- Azure Policy later evaluates the VM against the initiative.
- The VM should show as non-compliant in Policy compliance results.

That is the correct current behavior for this built-in policy.

## Deployment scope

The Bicep file uses:

```bicep
targetScope = 'subscription'
```

That is required because initiative definitions are subscription-level resources. The same deployment also creates the
resource group and then assigns the initiative to that resource group.

## Built-in policy used by this lab

This lab references:

```text
/providers/Microsoft.Authorization/policyDefinitions/3dc5edcd-002d-444c-b216-e123bbfa37c0
```

Display name:

```text
Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost.
```

Microsoft Learn currently lists this policy with supported effects `AuditIfNotExists` and `Disabled`, not `Deny`.

## If you need a blocking policy

If your real requirement is "fail VM creation when encryption-at-host is off", that is a different design:

- You would need a custom `deny` policy.
- That custom policy would realistically validate `EncryptionAtHost`.
- It would not fully reproduce the built-in "Azure Disk Encryption or EncryptionAtHost" logic.

That is why this lab keeps the Microsoft built-in policy and fixes the instructions instead of pretending the VM create
operation will fail.
