# DC01 Build Guide

## Purpose

This guide records the implementation of DC01, the first domain controller for
Apex Dynamics. It is written from the completed build so the environment can be
rebuilt or reviewed without relying on chat history.

## Virtual machine

DC01 is hosted in VMware Workstation under the WolfSec Labs Machines directory,
outside the Atlas repository. The VM uses Windows Server 2022 Standard
Evaluation with Desktop Experience, 4 GB RAM, two vCPUs and a 60 GB dynamic
virtual disk.

The VMware adapter is attached to the LAN segment named `corpnet`. This is the
VMware equivalent of the isolated internal network used by Atlas. NAT is not
used because DC01 is an internal enterprise host and has no internet path.

## Base operating system configuration

Windows Server 2022 Standard Evaluation with Desktop Experience was installed
as a custom installation on the VM's virtual disk. The initial local
Administrator password was set during setup and is not recorded in this
repository.

The server was configured with the following settings before Active Directory
was installed:

| Setting | Value |
|---|---|
| Hostname | `DC01` |
| IPv4 address | `10.10.10.10` |
| Subnet mask | `255.255.255.0` |
| Default gateway | None |
| Preferred DNS server | `10.10.10.10` before promotion |
| Time zone | `(UTC+00:00) Dublin, Edinburgh, Lisbon, London` |

No default gateway is configured because corpnet is isolated. Once DNS was
installed and the server was promoted, Windows used its local loopback DNS
addresses, `127.0.0.1` and `::1`. This is expected for a domain controller.

## Active Directory promotion

The Active Directory Domain Services and DNS Server roles were installed through
Server Manager. DC01 was then promoted using these values:

| Setting | Value |
|---|---|
| Deployment operation | Add a new forest |
| Root domain | `apexdynamics.internal` |
| NetBIOS name | `APEX` |
| Forest functional level | Windows Server 2016 |
| Domain functional level | Windows Server 2016 |
| DNS Server | Enabled |
| Global Catalog | Enabled |
| Read-only domain controller | Disabled |

The DNS delegation warning was expected because this is a new isolated forest
with no parent DNS zone. Default database, log and SYSVOL paths were retained.
The Directory Services Restore Mode password is held outside the repository.

## Directory structure

The following organizational-unit tree was created in Active Directory Users
and Computers. The built-in Domain Controllers OU remains the location for
DC01. The custom Servers OU is for future member servers.

```text
Apex
├── Users
│   ├── Executive
│   ├── HR
│   ├── Finance
│   ├── Sales
│   ├── Development
│   ├── IT
│   └── Security
├── Computers
│   ├── Workstations
│   └── Servers
└── Groups
```

All OUs are protected from accidental deletion.

Seven global security groups were created in `Apex/Groups`:

```text
GG-Executive
GG-HR
GG-Finance
GG-Sales
GG-Development
GG-IT
GG-Security
```

Three accounts were created manually in ADUC to demonstrate the normal
administrative workflow:

```text
james.whitmore   Executive   GG-Executive
priya.nair       Finance     GG-Finance
david.okafor     IT          GG-IT
```

The remaining 13 accounts are provisioned with
`scripts/New-ApexUsers.ps1`. The script prompts for an initial password and
does not store credentials in source control.

## Validation

The completed build was validated with the following checks:

```powershell
whoami
hostname
ipconfig /all
Get-ADDomain | Format-List DNSRoot,NetBIOSName,DomainMode
Get-ADForest | Format-List ForestMode
Get-ADUser -SearchBase 'OU=Users,OU=Apex,DC=apexdynamics,DC=internal' -Filter * |
    Measure-Object
```

Expected results are `apex\administrator`, hostname `DC01`, static address
`10.10.10.10`, domain `apexdynamics.internal`, NetBIOS name `APEX`, Windows
Server 2016 domain and forest modes, and 16 initial users.

Two VMware recovery points were taken:

```text
DC01 - Domain Baseline
DC01 - Directory Baseline
```
