# Active Directory Design

This records the Active Directory design decisions for the Apex Dynamics domain,
made before the first domain controller was promoted. Nothing here was installed
until every decision below was finalised. Several of these choices are locked permanently once AD is deployed,
so they were settled at design time rather than during the install.

## Domain name (FQDN)

The domain is `apexdynamics.internal`.

`.internal` was chosen over the two common alternatives. `.local` is avoided
because it is reserved for multicast DNS (mDNS) and using it for Active Directory
can cause name-resolution conflicts. A registered public domain (for example a
subdomain like `corp.apexdynamics.com`) wasn't used because Apex Dynamics is a
private, isolated environment with no public domain tied to it. `.internal` is
formally reserved for private internal networks, so it will never collide with a
real registered domain, and it clearly signals that this is an internal-only
namespace.

## NetBIOS name

The NetBIOS (short) domain name is `APEX`.

Windows would have defaulted this to `APEXDYNAMICS` (the first label of the FQDN,
uppercased). That fits within the 15-character NetBIOS limit, but it's long to
type in `DOMAIN\username` logons. `APEX` is short, readable, and produces clean
logon names like `APEX\alice.taylor`.

The one trade-off: "Apex" is a common word, so in a multi-domain or merger
scenario a more distinctive short name would be preferable to avoid NetBIOS
collisions. For a single standalone enterprise this isn't a concern.

## Forest and domain functional levels

Both the forest and domain functional levels are set to Windows Server 2016, the
highest available.

The functional level gates which AD features are enabled and can't be set higher
than the oldest domain controller in the environment. This is a greenfield build
with a single Windows Server 2022 domain controller and no legacy controllers, so
there is nothing forcing a lower level.

Windows Server 2022 has no dedicated functional level. Microsoft has not introduced a new functional level since
Windows Server 2016, so a 2022 domain controller running at the 2016 functional
level is what a current deployment looks like.

## Organizational Unit (OU) structure

The OU hierarchy is:

```
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

The structure is designed around how Group Policy is applied and how
administration is delegated, not around the company org chart. A top-level `Apex`
OU holds everything the organisation creates, kept separate from AD's built-in
containers, and lets a company-wide policy apply once at the top and
inherit downward.

Users, Computers and Groups are split at the top level because user-focused and
machine-focused Group Policy target different object types, so separating them keeps policy targeting clean. Departments sit under Users because department-specific
policy is user-focused.

The default `Users` and `Computers` containers AD creates are not used for policy,
because Group Policy cannot be applied to those containers, only to true OUs.
This is the main reason a custom OU structure is built immediately and objects are
moved out of the defaults.

The structure stops at this depth deliberately. Nesting further into sub-departments or per-site OUs would add complexity the
~150-user scale doesn't need yet. The
current three tiers cover company-wide, user-versus-computer, and per-department
policy, which is enough to manage the environment without over-engineering it.

## Security groups

Department-based global groups are created now, one per department, matching the
OUs:

`GG-Executive`, `GG-HR`, `GG-Finance`, `GG-Sales`, `GG-Development`, `GG-IT`,
`GG-Security`

The `GG-` prefix marks them as global groups. These represent
identity: who belongs to which department. They are used immediately for
department-scoped Group Policy.

This follows the AGDLP model (Accounts → Global groups → Domain Local groups →
Permissions), which separates identity from resource access: user accounts go into
global groups by who they are, and resource access is granted to domain local
groups by what they protect. Only the identity (global group) layer is built now.
Resource-scoped domain local groups are deferred until there are actual resources
to protect, rather than pre-building access groups for resources that don't yet
exist.

## User naming convention

Usernames follow `firstname.lastname` (for example `alice.taylor`).

This is readable, professional, and aligns with email addressing
(`alice.taylor@apexdynamics.internal`). Name collisions are handled by exception, appending a numeral or middle initial (`alice.taylor2`, `alice.m.taylor`).

Department is deliberately kept out of the username. People transfer between
departments, and encoding department in the account name would force a rename on
every transfer. That association lives in OUs and groups instead, so a transfer
becomes a group-membership change and the account name stays put.

## Initial user population

An initial set of users is created to populate every department and group, rather
than the full ~150-person headcount. This is enough to make every OU and group
non-empty and realistic for later monitoring and assessment work, without the
busywork of creating every account by hand.

| Department  | Users                                          |
|-------------|------------------------------------------------|
| Executive   | james.whitmore, sarah.beckett                  |
| HR          | emma.hollis, daniel.reeves                     |
| Finance     | priya.nair, thomas.clarke                      |
| Sales       | olivia.grant, marcus.webb, chloe.dunn          |
| Development | raj.patel, hannah.lowe, george.ellis           |
| IT          | david.okafor, natalie.frost                    |
| Security    | liam.hayes, aisha.rahman                       |

The first few accounts are created manually through Active Directory Users and
Computers to understand the user object model, then the remainder are created with
a PowerShell script (`New-ADUser`). This keeps the fundamentals clear while
demonstrating automation of the repetitive work.

## Build sequence

With the design locked, the build proceeds:

1. Install Windows Server 2022
2. Set the static IP (10.10.10.10) and rename the host to DC01
3. Promote to domain controller, creating the `apexdynamics.internal` forest and
   installing AD DS and DNS
4. Build the OU structure
5. Create the department global groups
6. Create users (manual, then scripted)
7. Verify, document, and join the first client to the domain