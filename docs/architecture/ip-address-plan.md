# IP Address Plan

**Project:** Atlas  
**Portfolio:** WolfSec Labs  
**Status:** Draft

## Purpose

Atlas uses a dedicated private network to simulate a small enterprise environment. The addressing scheme has been designed to remain simple while leaving enough room for future systems introduced throughout the portfolio.

---

## Network

Network Name

corpnet

Subnet

10.10.10.0/24

---

## Address Allocation

Infrastructure servers receive the lowest addresses because they provide core services to the rest of the network.

Employee devices are assigned after the servers.

Security systems occupy their own section of the address range.

Current allocation is shown below.

10.10.10.10

Domain Controller (DC01)

10.10.10.20

Ubuntu Server (APP01)

10.10.10.30

Windows Workstation (WS01)

10.10.10.40

Security Workstation (KALI01)

---

## Reserved Range

Addresses from 10.10.10.100 onwards are reserved for future expansion.

This allows additional servers, monitoring platforms and user devices to be introduced without changing the original network design.
