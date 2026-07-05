# Enterprise Design

**Project:** Atlas  
**Portfolio:** WolfSec Labs  
**Status:** Draft

## Purpose

Atlas is the infrastructure foundation of the WolfSec Labs portfolio.

Rather than building isolated virtual machines, the goal is to recreate the core infrastructure of a realistic enterprise environment. Every future repository in the portfolio will build on this environment, allowing offensive, defensive and security engineering activities to take place against the same network.

## Business Context

The environment represents **Apex Dynamics Ltd.**, a fictional UK-based SaaS company with approximately 150 employees operating from a single office while supporting hybrid working.

The company develops project management software for business customers and relies heavily on Windows-based infrastructure for identity management, endpoint administration and internal services.

As the business continues to grow, the existing infrastructure needs to provide centralized authentication, secure administration and a platform that can support future monitoring and security operations.

## Design Goals

The environment has been designed with the following objectives:

- Centralize identity management.
- Build a realistic Windows enterprise.
- Keep the lab simple enough to understand while remaining expandable.
- Support future security monitoring and detection engineering.
- Provide an environment for realistic attack simulation and defensive validation.

## Infrastructure Overview

The initial deployment consists of:

- Windows Server 2022 acting as the Domain Controller.
- Windows 11 Enterprise client.
- Ubuntu Server for internal Linux services.
- Kali Linux workstation for security testing.
- An isolated internal network using the 10.10.10.0/24 address space.

Additional infrastructure will be introduced during later stages of the portfolio.

## Why this architecture?

The objective is not to build the largest possible lab.

Instead, the aim is to create an environment that resembles what a junior security engineer is likely to encounter in a real organisation.

Every system introduced into Atlas should have a clear business purpose and become relevant in later repositories such as Sentinel, Hunt and Forge.

## Current Status

Sprint 2 – Enterprise Architecture Design