# ADR-001: Project Scope

**Status:** Accepted

## Background

WolfSec Labs needed a starting point that every later repository could build
on, rather than a set of disconnected virtual machines built for their own
sake. Before any infrastructure was built, the scope of that starting point
had to be decided: what the environment represents, how big it should be, and
where the line sits between what Atlas builds and what later repositories
build on top of it.

## Decision

Atlas builds a small, realistic enterprise environment for a fictional
company, Apex Dynamics Ltd, a ~150-person UK SaaS business. The initial
environment consists of four hosts on a single isolated subnet:

- DC01, a Windows Server domain controller providing Active Directory and DNS
- APP01, an Ubuntu server for internal application hosting
- WS01, a Windows client representing a standard employee workstation
- KALI01, a security testing workstation for the engineer's own use

Atlas is the first of four repositories in the WolfSec Labs portfolio
(Atlas → Sentinel → Hunt → Forge), and its job is to build the enterprise
that the other three depend on. Monitoring, attack simulation and hardening
all need something to point at first.

## Why this decision?

The alternative to a single continuous enterprise is a set of standalone labs
built for individual demonstrations, each with its own throwaway
infrastructure. That approach is common in portfolios, but it doesn't reflect
how security work actually happens. In a real organisation, the same
directory, the same servers and the same client estate get monitored,
attacked and defended over time. Building one enterprise once and reusing it
means Sentinel is watching real infrastructure with a real history, Hunt is
assessing an environment that was actually built and configured by hand
rather than spun up fresh, and Forge is hardening weaknesses that were
genuinely found rather than staged.

The four-host scope is deliberately small. A junior security engineer is far
more likely to encounter a company like Apex Dynamics than a hundred-server
datacenter, and every host here has a clear reason to exist rather than being
added for coverage. Four hosts is enough to have a real domain, a real
Linux/Windows mix, a real client, and a dedicated place to run tools from,
without the build taking months before anything else in the portfolio can
start.

## Trade-offs

Keeping the environment this small means some enterprise realities are out of
scope for now: no redundancy (single domain controller), no network
segmentation (one flat subnet), no additional application or database tiers
beyond APP01, and no email or collaboration infrastructure. These are all
legitimate things a real 150-person company would have.

They're treated as expansion points rather than gaps. The IP plan reserves
`10.10.10.100` and above specifically so more hosts can be added later without
re-addressing anything, and weaknesses like the lack of segmentation are
recorded as hardening candidates for Forge rather than problems to fix now.
Building them in from day one would mean solving problems that don't exist
yet, at the cost of taking longer to reach a working environment that
Sentinel, Hunt and Forge can actually use.

## Outcome

The four-host scope defined here was carried through the full build. DC01,
APP01, WS01 and KALI01 were built in that order, each validated before moving
to the next, and each documented in
[the build guide](../setup/installation-guide.md) and the
[engineering journal](../notes/engineering-journal.md). This closes the
initial Atlas build; what comes next is validation of the environment as a
whole and preparing it to be handed off to Sentinel.
