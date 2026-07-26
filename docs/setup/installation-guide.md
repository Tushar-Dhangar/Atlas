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

## WS01

WS01 is the domain-joined Windows client, the third host built in the
environment.

### Virtual machine

WS01 is hosted in VMware Workstation on the same `corpnet` LAN segment as
DC01 and APP01. The VM uses 4 GB RAM, 2 vCPUs and a 60 GB virtual disk.

Windows 11 requires a virtual TPM, which VMware satisfies by encrypting the
files needed to support it (`.nvram`, `.vmsn` and related files). Only those
files are encrypted, not the whole VM, keeping snapshot and clone behaviour
close to a normal unencrypted VM. The encryption password is stored in
VMware's own credential manager rather than recorded here.

### Base operating system installation

The design calls for Windows 11 Enterprise, but the installation media
available only offered Home and Pro editions, not Enterprise (Enterprise
ships through volume licensing or a separate evaluation ISO, not the general
consumer media used here). **Windows 11 Pro** was installed instead. Pro
supports Active Directory domain join, which is the capability WS01 actually
needs; Home does not support this at all. The substitution is a media
availability issue, not a design change.

Two install-time obstacles were expected and handled:

- No product key was entered (skipped via the "I don't have a product key"
  option). Activation isn't required for a lab client.
- The out-of-box setup normally requires an internet connection to continue,
  which corpnet doesn't provide (no gateway). This was bypassed by opening a
  command prompt during OOBE (`Shift+F10`) and running `OOBE\BYPASSNRO`, which
  reboots into the same screen with an "I don't have internet" option
  available, allowing setup to continue with a local account.

The local account created during setup is `wolfsec-admin`, matching the
convention used on APP01. After first boot, the hostname was changed from the
Windows-generated default to `WS01` (Settings > System > About > Rename this
PC), before the domain join, to avoid a second rename and rejoin afterward.

### Network configuration

Static networking was set through Settings > Network & Internet > Ethernet,
matching the pattern used on DC01 and APP01:

| Setting | Value |
|---|---|
| Hostname | `WS01` |
| IPv4 address | `10.10.10.30` |
| Subnet mask | `255.255.255.0` |
| Default gateway | None |
| Preferred DNS server | `10.10.10.10` |

No gateway is configured for the same reason as the other hosts: corpnet is
isolated and WS01 has no route to the internet.

### Domain join

WS01 was joined to `apexdynamics.internal` through Settings > Accounts >
Access work or school > Connect > "Join this device to a local Active
Directory domain". The join requires credentials with rights to add computer
objects to the domain; the built-in `APEX\Administrator` account was used for
this, since no delegated join permissions have been configured yet.

The post-join "Add an account" prompt, which pre-assigns one domain account
local rights on the machine, was skipped. Any domain user can already log on
to a domain-joined machine and receive standard local rights without being
added here; this step only matters for granting a specific account local
Administrator, which WS01 doesn't need since it's a shared test workstation
rather than one person's machine.

### Validation

After the domain join and restart, login was tested with an existing AD
account, `james.whitmore`, rather than the local `wolfsec-admin` account, to
confirm the join actually grants domain authentication rather than just
appearing to succeed.

```powershell
whoami
hostname
echo %USERDOMAIN%
```

Results: `whoami` returned `apex\james.whitmore`, `hostname` returned `WS01`,
and `%USERDOMAIN%` returned `APEX`. Together these confirm the machine is
authenticating against the domain rather than a local account, and that the
NetBIOS domain name is being reported correctly on a client for the first
time in the build (DC01 and APP01 don't surface this the same way).

The VMware recovery point `WS01 - Domain Join Baseline` was taken once the
domain login was confirmed working.

## KALI01

KALI01 is the security engineering workstation, the fourth and final host in
the initial build. Unlike the other three, it is not a production Apex
Dynamics asset — it's the security engineer's own testing box, and it's the
only host with a path to the internet alongside corpnet.

### Virtual machine

KALI01 is hosted in VMware Workstation with 4 GB RAM, 2 vCPUs and an 80 GB
dynamic disk. Kali has no dedicated guest OS entry in VMware's New Virtual
Machine wizard, so **Debian 12.x 64-bit** was selected as the closest match;
this only affects VMware's default resource/driver settings and has no effect
on the actual installed OS, which comes entirely from the Kali installer ISO.

KALI01 is the only host in the environment with two network adapters:

- **Network Adapter:** LAN Segment `corpnet` — the path into the isolated
  enterprise network, same as every other host
- **Network Adapter 2:** NAT — internet access for pulling tooling and
  updates, which no other host in Atlas has

The first adapter was created when the VM itself was set up. The second (NAT)
adapter was missed initially and added afterward through VM Settings once
network validation showed only one interface existed; see the validation
section below for how that was caught.

### Base operating system installation

The Kali installer (graphical, non-live) was used rather than the live image,
since KALI01 needs to be a persistent workstation. During install:

- Hostname was set to `KALI01`, matching the naming convention. No domain
  name was set — KALI01 is not part of `apexdynamics.internal` and doesn't
  need a search suffix for it.
- The corpnet interface was configured manually with address `10.10.10.40/24`,
  reflecting that this network has no DHCP server. Name servers were set to
  `10.10.10.10 8.8.8.8`, so internal Apex Dynamics names resolve via DC01 and
  everything else falls back to a public resolver, since KALI01 is the one
  host that needs both.
- Default partitioning was used, no LVM or disk encryption, since KALI01
  doesn't carry the same directory/identity data DC01 does.
- Xfce was selected as the desktop environment, with the `top10` and
  `default` tool collections, Kali's standard install-time defaults.
- The local account created is `wolfsec-admin`, the same convention used on
  APP01 and WS01.

### Network configuration issue and fix

After first boot, `ip a` showed only one interface (`eth0`, corpnet) with no
IPv4 address at all, and no second interface. Checking VM Settings confirmed
only the corpnet LAN Segment adapter existed; the NAT adapter had not
actually been added before install. A second Network Adapter set to NAT was
added in VM Settings, and the VM was rebooted, after which `eth1` appeared
with a DHCP-assigned address on the NAT network.

Separately, the static address entered for `eth0` during installation did not
persist — `ip a` showed the interface up but with no IPv4 assigned.
`nmcli con show` revealed the corpnet connection profile (`Wired connection
1`) existed but had never been bound to a device. It was fixed directly:

```bash
sudo nmcli con modify "Wired connection 1" ifname eth0 \
    ipv4.addresses 10.10.10.40/24 \
    ipv4.method manual \
    ipv4.gateway "" \
    ipv4.dns "10.10.10.10 8.8.8.8"
sudo nmcli con up "Wired connection 1"
```

Setting `ipv4.method manual` without an address already present fails with
`method 'manual' requires at least an address or a route`, so the address and
method need to be set together in the same command rather than as separate
`nmcli con modify` calls.

### Validation

```bash
ip a
ping -c 4 10.10.10.10
ping -c 4 8.8.8.8
nslookup apexdynamics.internal 10.10.10.10
```

Results: `eth0` shows `10.10.10.40/24` (corpnet, static), `eth1` shows a
`192.168.178.0/24` DHCP address (NAT). Ping to DC01 succeeded with 4/4 packets
and 0% loss, confirming the corpnet path. Ping to `8.8.8.8` succeeded with 4/4
packets and 0% loss, confirming the NAT/internet path. `nslookup` against DC01
correctly resolved `apexdynamics.internal` to `10.10.10.10`, confirming
KALI01 uses DC01 for internal name resolution while still reaching the
internet through its second adapter.

The VMware recovery point `KALI01 - Dual-Homed Baseline` was taken once both
network paths were confirmed working, completing the initial four-host build.
