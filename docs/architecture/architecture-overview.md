# Architecture Overview

**Project:** Atlas

**Portfolio:** WolfSec Labs

**Status:** Draft

---

## Overview

Atlas is the first project in the WolfSec Labs portfolio.

Its purpose is to recreate the core infrastructure of a modern enterprise rather than building isolated virtual machines or unrelated cybersecurity labs. The environment is designed to support every future project in the portfolio, allowing offensive security, defensive security and security engineering activities to take place against the same infrastructure.

Atlas represents the internal network of **Apex Dynamics Ltd.**, a fictional UK-based software company used throughout the portfolio.

---

## Enterprise Environment

The initial environment consists of four systems.

- **DC01** – Windows Server 2022 Domain Controller
- **APP01** – Ubuntu Server providing internal Linux services
- **WS01** – Windows 11 Enterprise workstation
- **KALI01** – Kali Linux security workstation

All systems communicate over an isolated internal network using the **10.10.10.0/24** private address space.

---

## Design Philosophy

The objective of Atlas is not to build the largest possible home lab.

Instead, the environment is intentionally kept small, easy to understand and representative of what a junior security engineer is likely to encounter in a real organisation.

Every system has a clear business purpose and every design decision supports future projects within the WolfSec Labs portfolio.

---

## Relationship to Future Projects

Atlas acts as the foundation for every repository that follows.

- **Sentinel** introduces monitoring, logging and detection engineering.
- **Hunt** performs security assessments and attack simulation against the Atlas environment.
- **Forge** focuses on hardening the infrastructure and implementing security improvements identified during Hunt.

By reusing the same enterprise environment throughout the portfolio, each repository builds upon the previous one rather than existing as an isolated demonstration.

---

## Supporting Documentation

Detailed information about the environment can be found in the following documents.

- Enterprise Design
- Host Inventory
- IP Address Plan
- Naming Convention
- Network Topology
- Engineering Decisions

---

## Current Status

Sprint 2 – Enterprise Architecture