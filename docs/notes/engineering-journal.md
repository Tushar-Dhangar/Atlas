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
Three users were created manually in ADUC, then the remaining 13 were
provisioned through the New-ADUser workflow. The final user-count and
group-membership commands are recorded in the build guide and should be kept as
the evidence for the 16-user baseline.

Validation confirmed the DC01 hostname, static addressing, directory name,
NetBIOS name, and Windows Server 2016 functional levels. A group-membership
check across all seven `GG-*` groups confirmed every account landed in the
right department group. The `DC01 - Domain Baseline` snapshot was taken right
after promotion, and `DC01 - Directory Baseline` was taken once the full
16-user directory was validated, giving a rebuild path that doesn't require
repeating the promotion step.

The next build milestone is APP01, the Ubuntu internal application server.
The install is under way in VMware: static addressing for `10.10.10.20/24`
was set during the installer's network step, with DNS pointed at DC01 and no
gateway, matching the internal-only design.

## APP01: base build completed

APP01 was built in VMware Workstation on the same `corpnet` LAN segment as
DC01. Ubuntu Server 24.04 LTS was installed with 2 GB RAM, 2 vCPUs and a 30 GB
dynamic disk, using a standard (non-minimized) install.

Networking was set to static during the installer: `10.10.10.20/24`, no
gateway, DNS pointed at DC01, and search domain `apexdynamics.internal`. The
installer's network summary only shows the address, not DNS or search domain,
which looked like the settings weren't sticking. They were — confirmed after
boot with `resolvectl status` and the generated netplan file, both showing the
correct DNS server and search domain. Because there's no gateway, the
installer couldn't reach the internet to check for updates or validate the
mirror, and those checks were skipped as expected for an internal-only host.

Guided storage used the full 30 GB disk as an LVM group, with the default
sizing leaving about half the volume group as free space rather than
allocating it all to the root volume. That's normal guided-LVM behaviour and
was left alone, since APP01 doesn't need the full disk allocated yet.

OpenSSH server was installed during setup for remote administration, with
password authentication left enabled. The local admin account is
`wolfsec-admin`. APP01 is not domain-joined; it participates in the
environment only by using DC01 for DNS.

Post-boot validation confirmed the hostname, static address, and DNS
configuration. The first ping to DC01 failed with "Destination Host
Unreachable" because DC01 was powered off at the time; once DC01 was started,
the same ping succeeded with 0% loss, and `nslookup` against DC01 correctly
resolved `apexdynamics.internal`. The `APP01 - Base Build` VMware snapshot was
taken once networking was confirmed working.

The next build milestones are WS01, the Windows 11 client, and KALI01, the
security workstation.
