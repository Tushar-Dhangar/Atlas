# Atlas Infrastructure Build Guide

## Purpose

This guide records the implementation of each host in the Atlas environment.
It is written from the completed build so the environment can be rebuilt or
reviewed without relying on chat history.

## DC01

DC01 is the first domain controller for Apex Dynamics.

### Virtual machine

DC01 is hosted in VMware Workstation under the WolfSec Labs Machines directory,
outside the Atlas repository. The VM uses Windows Server 2022 Standard
Evaluation with Desktop Experience, 4 GB RAM, two vCPUs and a 60 GB dynamic
virtual disk.

The VMware adapter is attached to the LAN segment named `corpnet`. This is the
VMware equivalent of the isolated internal network used by Atlas. NAT is not
used because DC01 is an internal enterprise host and has no internet path.

### Base operating system configuration

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

### Active Directory promotion

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

### Directory structure

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

### Validation

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

Group membership was checked separately, once all 16 accounts existed:

```powershell
$Groups = Get-ADGroup -Filter 'Name -like "GG-*"'
foreach ($Group in $Groups) {
    $Members = Get-ADGroupMember -Identity $Group |
        Select-Object -ExpandProperty SamAccountName

    "$($Group.Name): $($Members -join ', ')"
}
```

Each of the seven `GG-*` groups contained the users from its matching
department, confirming the New-ApexUsers.ps1 run added everyone to the correct
group and nobody was left out.

Two VMware recovery points were taken:

```text
DC01 - Domain Baseline
DC01 - Directory Baseline
```

`DC01 - Domain Baseline` was captured right after promotion, before any OUs,
groups or users existed. `DC01 - Directory Baseline` was captured after the
full directory was in place and validated, so a rebuild only has to roll back
to a known-good identity foundation rather than repeat the whole promotion.

## APP01

APP01 is the internal Ubuntu application server, the second host built in the
environment.

### Virtual machine

APP01 is hosted in VMware Workstation alongside DC01, outside the Atlas
repository. The VM runs Ubuntu Server 24.04 LTS with 2 GB RAM, 2 vCPUs and a
30 GB dynamically allocated disk.

The VMware adapter is attached to the same LAN segment as DC01, `corpnet`.
NAT is not used, for the same reason as DC01: APP01 is an internal enterprise
host with no internet path.

### Base operating system configuration

Ubuntu Server was installed as a standard (non-minimized) install. Networking
was configured manually during the installer's network step rather than left
on DHCP:

| Setting | Value |
|---|---|
| Hostname | `app01` |
| IPv4 address | `10.10.10.20` |
| Subnet | `10.10.10.0/24` |
| Default gateway | None |
| DNS server | `10.10.10.10` |
| Search domain | `apexdynamics.internal` |

No gateway is configured for the same reason as DC01: corpnet is isolated and
APP01 has no route to the internet. Because of this, the installer could not
reach the internet to check for updates or validate the archive mirror, and
those steps were skipped (`Continue without updating`, default mirror address
left unchanged, no proxy).

The installer's network summary screen only displays the IPv4 address, not
the DNS server or search domain fields, even when they've been entered
correctly. This looks like the configuration was lost, but it isn't — it's a
display limitation of that screen, confirmed after install by checking
`resolvectl status` and `/etc/netplan/50-cloud-init.yaml`, both of which showed
the DNS server and search domain exactly as entered.

Storage used the guided LVM layout on the full 30 GB disk. The installer's
default LVM sizing left roughly half the volume group as free space rather
than allocating it all to the root logical volume. This is normal guided-LVM
behaviour (it reserves headroom for future snapshots) and was left as-is,
since an internal application server at this stage doesn't need the full disk
allocated up front.

OpenSSH server was installed during setup so the host can be administered
over SSH rather than through the VMware console. Password authentication over
SSH was left enabled, since this is a single-admin lab environment rather than
a shared or production system.

The admin account created is `wolfsec-admin`, a local account used to manage
the box directly. It isn't tied into Active Directory. APP01 is DNS-aware of
the domain (it points at DC01 for name resolution) but is not domain-joined.

### Validation

The completed build was validated with the following checks, run after first
boot:

```bash
hostname
ip a
resolvectl status
ping -c 4 10.10.10.10
nslookup apexdynamics.internal 10.10.10.10
```

Expected and actual results: hostname `app01`, static address `10.10.10.20/24`
on `ens33`, DNS server `10.10.10.10` with search domain `apexdynamics.internal`
reported by `resolvectl`, a successful 4/4 ping to DC01, and a successful
`nslookup` resolving `apexdynamics.internal` to `10.10.10.10`.

The ping to DC01 initially failed with "Destination Host Unreachable" because
DC01's VM was powered off. Once DC01 was started, the same ping succeeded with
0% packet loss, confirming the earlier failure was a powered-off dependency
rather than a networking fault on APP01's side.

The VMware recovery point `APP01 - Base Build` was taken once networking was
validated, giving a rebuild point for APP01 before any application services
are installed on it.
