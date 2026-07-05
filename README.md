# Atlas

**WolfSec Labs** — building, breaking and defending enterprise systems.

![License](https://img.shields.io/badge/license-MIT-blue)

WolfSec Labs is my cybersecurity engineering practice. It designs, attacks and
defends realistic enterprise environments end to end, the way a security-minded
engineer works across both sides of the fence.

Atlas is its first engagement, delivered for the fictional client Apex Dynamics
Ltd. It builds the enterprise that every later engagement depends on — a
realistic Windows and Linux estate for a UK SaaS company.

Rather than a collection of disconnected security tools, WolfSec Labs is a single
continuous engagement against one enterprise. Atlas builds that enterprise;
Sentinel monitors it; Hunt assesses it; Forge hardens it.

## Enterprise overview

Apex Dynamics is a ~150-person SaaS company running a hybrid workforce across
Executive, HR, Finance, Sales, Development, IT and Security functions. Atlas
provides its core infrastructure: centralised identity through Active Directory,
Windows and Linux servers, a managed client estate, and a dedicated security
testing capability.

## Architecture

The enterprise runs on a single private subnet, corpnet (10.10.10.0/24), behind
an edge router.

![Network topology](assets/diagrams/network-topology.drawio.png)

| Host   | Role                        | Address      |
|--------|-----------------------------|--------------|
| DC01   | Domain Controller / DNS     | 10.10.10.10  |
| APP01  | Ubuntu application server   | 10.10.10.20  |
| WS01   | Windows 11 client           | 10.10.10.30  |
| KALI01 | Security workstation        | 10.10.10.40  |

Full reasoning behind the addressing, segmentation and host design is in
[docs/architecture/network-topology.md](docs/architecture/network-topology.md).

## Technology

Windows Server 2022 (Active Directory Domain Services, DNS), Ubuntu Server 24.04
LTS, Windows 11 Enterprise, and Kali Linux, all built and networked in an
isolated lab environment.

## Repository layout

- `docs/architecture/` — enterprise and network design documentation
- `docs/engineering-decisions/` — the reasoning behind major technical choices
- `docs/setup/` — implementation and build guides
- `docs/notes/` — engineering journal
- `assets/diagrams/` — architecture diagrams (draw.io sources and exports)
- `infrastructure/` — per-host configuration
- `scripts/` — supporting automation

## Roadmap

Atlas is built in sprints, moving from architecture through to a validated
enterprise environment.

- Repository foundation and standards — complete
- Enterprise architecture and network design — in progress
- Infrastructure build (Active Directory, DNS, client join) — planned
- Validation and documentation — planned
- Atlas v1.0 — planned

## WolfSec Labs portfolio

**Atlas** → Sentinel → Hunt → Forge

Each repository extends the same enterprise rather than starting over. Atlas
comes first because there is nothing to monitor, attack or harden until the
enterprise exists.