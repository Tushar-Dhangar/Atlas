# ADR-002: Active Directory as the Enterprise Identity Platform

**Status:** Accepted

## Background

Apex Dynamics requires a centralized method of managing users, computers and security policies.

Managing local user accounts on every workstation would quickly become difficult as the company grows, leading to inconsistent security settings and unnecessary administrative effort.

## Decision

Atlas will use Microsoft Active Directory Domain Services (AD DS) as the enterprise identity platform.

Windows Server 2022 will host the domain controller and provide authentication, authorization, DNS integration and Group Policy management for the environment.

## Why this decision?

Active Directory remains one of the most widely deployed identity platforms in enterprise Windows environments.

Choosing AD allows the portfolio to model:

- Centralized user management
- Group Policy
- Domain authentication
- Computer management
- Organizational Units
- Enterprise administration

These capabilities will become essential in later repositories where endpoint monitoring, attack simulation and security hardening depend on a functioning enterprise directory.

## Trade-offs

Using Active Directory introduces additional complexity compared to local accounts.

The environment requires a dedicated Windows Server, DNS configuration and domain management.

However, those trade-offs are justified because they provide a far more realistic enterprise environment.

## Outcome

Active Directory becomes the foundation for Atlas and every future WolfSec Labs repository.