# Engineering Journal

## DC01: domain foundation completed

The Active Directory design gate was completed before the server build began.
DC01 was then built in VMware Workstation on the isolated `corpnet` LAN segment.
The machine uses Windows Server 2022 Standard Evaluation with Desktop
Experience, 4 GB RAM, two vCPUs and a 60 GB dynamic virtual disk.

The operating system was installed, configured with the static address
`10.10.10.10/24`, renamed to `DC01`, and set to the UK time zone. No default
gateway is configured. DC01 is an internal-only host.

AD DS and DNS were installed and the server was promoted as the first domain
controller in a new forest. The resulting directory is
`apexdynamics.internal`, with NetBIOS name `APEX`. Forest and domain functional
levels are both Windows Server 2016.

The locked Apex OU tree and seven `GG-*` global security groups were created.
Three users were created manually in ADUC, then the remaining 13 were created
with `New-ApexUsers.ps1`. This left the directory with the intended 16 initial
users, each assigned to its department group.

Validation confirmed the DC01 hostname, static addressing, directory name,
NetBIOS name, and Windows Server 2016 functional levels. VMware snapshots were
taken after domain promotion and after directory provisioning.

The next build milestone is APP01, the Ubuntu internal application server.
