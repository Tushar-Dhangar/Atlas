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

## WS01: domain join completed

WS01 was built in VMware Workstation on `corpnet`, alongside DC01 and APP01,
with 4 GB RAM, 2 vCPUs and a 60 GB disk. Windows 11 needs a virtual TPM, so
VMware encrypted the TPM-related files with a password stored in its own
credential manager, rather than the whole VM.

The available install media only offered Windows 11 Home and Pro, not the
Enterprise edition the design calls for. Pro was installed instead, since it
supports domain join and Home doesn't. This is a media substitution, not a
design change, and is recorded as such rather than treated as matching the
original spec exactly.

Two setup obstacles came up and were handled the same way they'd come up on a
real deployment: no product key was entered, and the out-of-box setup's
internet requirement was bypassed with `OOBE\BYPASSNRO` from a command prompt,
since corpnet has no gateway for setup to reach out on.

The machine was renamed to `WS01` before joining the domain, to avoid a second
rename and rejoin afterward, then joined to `apexdynamics.internal` using the
`APEX\Administrator` account. The post-join prompt to assign a specific
account local rights was skipped, since WS01 is a shared test workstation and
any domain user already gets standard local rights by logging on.

Validation logged in as `james.whitmore`, an existing AD account, rather than
the local admin account, specifically to confirm real domain authentication.
`whoami` returned `apex\james.whitmore`, hostname returned `WS01`, and
`%USERDOMAIN%` returned `APEX`, confirming the join. The `WS01 - Domain Join
Baseline` VMware snapshot was taken once this was confirmed.

The next build milestone is KALI01, the security workstation.

## KALI01: dual-homed build completed

KALI01 was built in VMware Workstation with 4 GB RAM, 2 vCPUs and an 80 GB
disk, using Debian 12.x as the closest guest OS profile since VMware has no
dedicated Kali entry. It's the fourth and final host in the initial build,
and the only one that isn't a production Apex Dynamics asset — it's the
security engineer's own testing box.

It's also the only host with two network adapters: LAN Segment `corpnet` for
reaching the enterprise network, and NAT for internet access to pull tooling.
The install itself used the graphical Kali installer, hostname `KALI01`, no
domain suffix, default disk partitioning, Xfce with the standard top10 and
default tool collections, and the `wolfsec-admin` local account convention
used across the non-domain hosts.

Two networking problems showed up after first boot, both worth recording
since they're easy to hit again on a rebuild. First, only one interface
existed at all — the NAT adapter had been skipped when the VM was created,
so only corpnet was present. This was fixed by adding a second Network
Adapter set to NAT in VM Settings and rebooting, after which the interface
appeared with a DHCP address. Second, the static `10.10.10.40/24` address
entered during install never actually bound to the corpnet interface;
`nmcli con show` showed the connection profile existed but wasn't attached
to a device. Setting `ifname`, `ipv4.addresses` and `ipv4.method manual` all
in a single `nmcli con modify` command fixed it — setting the method before
the address exists fails, since manual mode requires an address or route to
already be present.

Validation confirmed both paths: a 4/4, 0%-loss ping to DC01 over corpnet, a
4/4, 0%-loss ping to `8.8.8.8` over NAT, and a correct `nslookup` resolution
of `apexdynamics.internal` against DC01. The `KALI01 - Dual-Homed Baseline`
snapshot was taken once both paths were confirmed.

With KALI01 built, the initial four-host Atlas environment (DC01, APP01,
WS01, KALI01) is complete. Next steps move into validation and documentation
of the environment as a whole, ahead of the Atlas v1.0 milestone.

## Environment-wide connectivity validated

Every host had been validated against DC01 individually, but not against each
other, so a connectivity matrix was run across all four corpnet hosts:
WS01↔APP01 and KALI01→WS01/APP01, on top of the DC01 legs already covered
during each host's own build.

WS01→APP01 worked immediately. APP01→WS01 came back 100% packet loss, which
was the useful signal here: since APP01 was already reachable from elsewhere,
the problem had to be WS01 refusing inbound traffic specifically, not a
corpnet issue. That turned out to be Windows Defender Firewall's default of
blocking inbound ICMP while allowing outbound, which is exactly why the WS01
side worked and masked the problem until the reverse direction was tested.
`Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"` fixed it;
adding `-Enabled True` to that command looks reasonable but is wrong, since
that flag filters for already-enabled rules rather than switching them on.

Getting to an elevated session on WS01 to run that command surfaced a second
issue: the UAC prompt defaulted to `APEX\Administrator`, which failed because
WS01 couldn't reach DC01 to validate the domain credential at that moment.
The local `wolfsec-admin` account elevated without a problem, since local
elevation doesn't depend on domain availability. That's now the account to
reach for on WS01's own local administration, rather than assuming the domain
Administrator is always usable there.

With the firewall rule enabled, every leg of the matrix passed at 0% packet
loss. Every host on corpnet can reach every other host, not just DC01,
closing out the validation phase. The full four-host Atlas build is
complete and pushed to GitHub. The environment is ready to hand off as the
foundation for Sentinel.
