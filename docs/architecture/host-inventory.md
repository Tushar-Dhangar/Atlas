# Host Inventory

**Project:** Atlas  
**Portfolio:** WolfSec Labs  
**Status:** Draft

## Purpose

This document records every system that forms part of the Atlas environment. Keeping an inventory helps maintain consistency throughout the portfolio and provides a single reference point when configuring services, documenting infrastructure or performing security assessments.

---

# Domain Controller

**Hostname:** DC01

**Operating System:** Windows Server 2022

**Primary Responsibilities**

- Active Directory Domain Services (AD DS)
- DNS Server
- Centralized authentication
- Group Policy management

**IP Address**

10.10.10.10

---

# Ubuntu Application Server

**Hostname:** APP01

**Operating System:** Ubuntu Server 24.04 LTS

**Primary Responsibilities**

- Internal application hosting
- Future web services
- Supporting Linux-based infrastructure

**IP Address**

10.10.10.20

---

# Windows Workstation

**Hostname:** WS01

**Operating System:** Windows 11 Enterprise

**Primary Responsibilities**

- Standard employee workstation
- Domain-joined endpoint
- Used for authentication and policy testing

**IP Address**

10.10.10.30

---

# Security Workstation

**Hostname:** KALI01

**Operating System:** Kali Linux

**Primary Responsibilities**

- Security testing
- Validation of defensive controls
- Future attack simulation

**IP Address**

10.10.10.40

---

## Future Expansion

Additional systems such as monitoring servers, databases and SIEM infrastructure will be added as later repositories in the WolfSec Labs portfolio are developed.