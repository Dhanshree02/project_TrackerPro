# RBAC Baseline Permissions Matrix for All Roles
## Official Baseline Specification from `TK I PMS I New Modules RBAC I V01.xlsx`

This document defines the **canonical system baseline permissions** across all **27 organizational roles** and **49 system widgets/actions/tabs** for TrackerPro (Pulse PMO).
These values represent the **factory default settings** seeded into PostgreSQL table `role_widget_permissions` and restored during any *"Reset to Baseline"* operation.

---

## Table of Contents
1. [Permission Value Mapping & Legend](#1-permission-value-mapping--legend)
2. [High-Level Roles Summary Table](#2-high-level-roles-summary-table)
3. [Module-by-Module Permission Matrices](#3-module-by-module-permission-matrices)
   - [3.1 Dashboard](#31-dashboard)
   - [3.2 Action Center](#32-action-center)
   - [3.3 Projects](#33-projects)
   - [3.4 Reports](#34-reports)
   - [3.5 Resource](#35-resource)
   - [3.6 Customers](#36-customers)
   - [3.7 Repository](#37-repository)
   - [3.8 My Team](#38-my-team)
   - [3.9 Settings](#39-settings)
4. [Detailed Role Profiles (All 27 Roles)](#4-detailed-role-profiles)
5. [Database & Backend Synchronization](#5-database--backend-synchronization)

---

## 1. Permission Value Mapping & Legend

The spreadsheet uses 4 string values which map to the database binary flags `CanView` and `CanManage`:

| Excel Sheet Value | Symbol | `CanView` | `CanManage` | Functional UI Meaning | Backend API Enforcement |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Read & Write** | 🟢 | `1` | `1` | Full interactive control. Buttons, forms, and actions are enabled. | `GET`, `POST`, `PUT`, `DELETE` allowed (`200 OK`). |
| **All RWE** | 🟢 | `1` | `1` | Unrestricted Read/Write/Execute control (used for executive/PMO governance). | All endpoints allowed (`200 OK`). |
| **Read Only** | 🟡 | `1` | `0` | Information visible; create, edit, delete, and upload buttons hidden. | `GET` allowed (`200 OK`); write operations blocked (`403`). |
| **No Access** | 🔴 | `0` | `0` | Completely hidden from DOM and navigation. | All requests return `403 Forbidden`. |

> **Note**: In TrackerPro, `CanManage = 1` always requires `CanView = 1`. A role can never possess write permissions without view permissions.

---

## 2. High-Level Roles Summary Table

| # | Role Name | Manage (🟢 `1,1`) | View Only (🟡 `1,0`) | No Access (🔴 `0,0`) | Total Widgets | Governance Category |
| :-: | :--- | :---: | :---: | :---: | :---: | :--- |
| 1 | **CEO** | 0 | 40 | 2 | 49 | Executive Leadership |
| 2 | **COO** | 0 | 40 | 2 | 49 | Executive Leadership |
| 3 | **CTO** | 0 | 40 | 2 | 49 | Executive Leadership |
| 4 | **IT Admin** | 4 | 11 | 27 | 49 | Functional Support |
| 5 | **Accounts** | 6 | 13 | 23 | 49 | Functional Support |
| 6 | **HR** | 6 | 2 | 34 | 49 | Functional Support |
| 7 | **Sales Manger** | 6 | 23 | 13 | 49 | Commercial / Sales |
| 8 | **Sales team member** | 1 | 23 | 18 | 49 | Commercial / Sales |
| 9 | **PMO (Project Management Office)** | 28 | 9 | 5 | 49 | PMO & Project Governance |
| 10 | **EM (Engagement Manager)** | 15 | 20 | 7 | 49 | PMO & Project Governance |
| 11 | **R&D -Team member** | 5 | 7 | 30 | 49 | Research & Development |
| 12 | **SOC - Team Member** | 5 | 9 | 28 | 49 | Services - Operations (SOC) |
| 13 | **SOC - Team Leader** | 9 | 15 | 18 | 49 | Services - Operations (SOC) |
| 14 | **SOC - Manager** | 17 | 14 | 11 | 49 | Services - Operations (SOC) |
| 15 | **SOC - Senior Manager** | 13 | 22 | 7 | 49 | Services - Operations (SOC) |
| 16 | **SOC - HOD** | 13 | 24 | 5 | 49 | Services - Operations (SOC) |
| 17 | **Consulting -Team member** | 5 | 9 | 28 | 49 | Services - Consulting |
| 18 | **Consulting - Team Leader** | 9 | 15 | 18 | 49 | Services - Consulting |
| 19 | **Consulting - Manager** | 17 | 14 | 11 | 49 | Services - Consulting |
| 20 | **Consulting - Senior Manager** | 13 | 22 | 7 | 49 | Services - Consulting |
| 21 | **Consulting - HOD** | 13 | 24 | 5 | 49 | Services - Consulting |
| 22 | **Testing - Team Member** | 5 | 9 | 28 | 49 | Services - Testing |
| 23 | **Testing - Team Leader** | 9 | 15 | 18 | 49 | Services - Testing |
| 24 | **Testing - Manager** | 17 | 14 | 11 | 49 | Services - Testing |
| 25 | **Testing - Senior Manager** | 13 | 22 | 7 | 49 | Services - Testing |
| 26 | **Testing - HOD** | 13 | 23 | 6 | 49 | Services - Testing |
| 27 | **Intern** | 5 | 10 | 27 | 49 | Internship Program |

---

## 3. Module-by-Module Permission Matrices

### 3.1 Dashboard (5 Items)

| Role | KPI'S | Assigned Projects | Pending issues | Project stauts | Pending approvals |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Accounts** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales Manger** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Sales team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **PMO (Project Management Office)** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **EM (Engagement Manager)** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **R&D -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **SOC - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **SOC - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Consulting -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Testing - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Intern** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |


### 3.2 Action Center (5 Items)

| Role | Raise issues | Start timer | Approvals | Alerts | Notifications |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Accounts** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales Manger** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Sales team member** | 🟢 `R/W` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **PMO (Project Management Office)** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **EM (Engagement Manager)** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **R&D -Team member** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - Team Member** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` |
| **SOC - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🟡 `Read` | 🟢 `R/W` |
| **SOC - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - Senior Manager** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - HOD** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting -Team member** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` |
| **Consulting - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🟡 `Read` | 🟢 `R/W` |
| **Consulting - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting - Senior Manager** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting - HOD** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - Team Member** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` |
| **Testing - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🟡 `Read` | 🟢 `R/W` |
| **Testing - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - Senior Manager** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - HOD** | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Intern** | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` |


### 3.3 Projects (17 Items)

| Role | Budget | Extension Request | Sr.project Manger | Project manager | Team leads | Billing Information | PMO Intake & Prerequiste Workflow | Invoice Schedule | Team | Task | Issues | Aletrs | Escalation | Appreciation | Customer Engagment | Additional customer Requirement | Invoice |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Accounts** | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales Manger** | 🟢 `R/W` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` |
| **Sales team member** | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **PMO (Project Management Office)** | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` |
| **EM (Engagement Manager)** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` |
| **R&D -Team member** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Leader** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **SOC - Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` |
| **SOC - Senior Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **SOC - HOD** | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **Consulting -Team member** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Team Leader** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **Consulting - Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` |
| **Consulting - Senior Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **Consulting - HOD** | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **Testing - Team Member** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Leader** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **Testing - Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🔴 `None` |
| **Testing - Senior Manager** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **Testing - HOD** | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟢 `R/W` | 🔴 `None` |
| **Intern** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |


### 3.4 Reports (4 Items)

| Role | Invoice | Invoice | Invoice | Invoice |
| :--- | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Accounts** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales Manger** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Sales team member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **PMO (Project Management Office)** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **EM (Engagement Manager)** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **R&D -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Senior Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - HOD** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Senior Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - HOD** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Senior Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - HOD** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Intern** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |


### 3.5 Resource (8 Items)

| Role | Personal Information | orgnization deatile | employment and bond | Eduacation and experience | Pmo information | Activity Logs | Resource Detailes | Resource Detailes |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Accounts** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **HR** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` |
| **Sales Manger** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales team member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **PMO (Project Management Office)** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **EM (Engagement Manager)** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **R&D -Team member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Leader** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **SOC - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **SOC - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **SOC - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Consulting -Team member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Team Leader** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Team Member** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Leader** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Testing - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` |
| **Intern** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` | 🔴 `None` | 🔴 `None` | 🔴 `None` |


### 3.6 Customers (1 Items)

| Role | Customer profile |
| :--- | :---: |
| **CEO** | 🟡 `Read` |
| **COO** | 🟡 `Read` |
| **CTO** | 🟡 `Read` |
| **IT Admin** | 🟡 `Read` |
| **Accounts** | 🟡 `Read` |
| **HR** | 🔴 `None` |
| **Sales Manger** | 🔴 `None` |
| **Sales team member** | 🔴 `None` |
| **PMO (Project Management Office)** | 🟢 `R/W` |
| **EM (Engagement Manager)** | 🟡 `Read` |
| **R&D -Team member** | 🔴 `None` |
| **SOC - Team Member** | 🟡 `Read` |
| **SOC - Team Leader** | 🟢 `R/W` |
| **SOC - Manager** | 🟢 `R/W` |
| **SOC - Senior Manager** | 🟢 `R/W` |
| **SOC - HOD** | 🟢 `R/W` |
| **Consulting -Team member** | 🟡 `Read` |
| **Consulting - Team Leader** | 🟢 `R/W` |
| **Consulting - Manager** | 🟢 `R/W` |
| **Consulting - Senior Manager** | 🟢 `R/W` |
| **Consulting - HOD** | 🟢 `R/W` |
| **Testing - Team Member** | 🟡 `Read` |
| **Testing - Team Leader** | 🟢 `R/W` |
| **Testing - Manager** | 🟢 `R/W` |
| **Testing - Senior Manager** | 🟢 `R/W` |
| **Testing - HOD** | 🟢 `R/W` |
| **Intern** | 🟡 `Read` |


### 3.7 Repository (1 Items)

| Role | Customer profile |
| :--- | :---: |
| **CEO** | 🟡 `Read` |
| **COO** | 🟡 `Read` |
| **CTO** | 🟡 `Read` |
| **IT Admin** | 🟡 `Read` |
| **Accounts** | 🟡 `Read` |
| **HR** | 🔴 `None` |
| **Sales Manger** | 🔴 `None` |
| **Sales team member** | 🔴 `None` |
| **PMO (Project Management Office)** | 🟢 `R/W` |
| **EM (Engagement Manager)** | 🟡 `Read` |
| **R&D -Team member** | 🔴 `None` |
| **SOC - Team Member** | 🟡 `Read` |
| **SOC - Team Leader** | 🟢 `R/W` |
| **SOC - Manager** | 🟢 `R/W` |
| **SOC - Senior Manager** | 🟢 `R/W` |
| **SOC - HOD** | 🟢 `R/W` |
| **Consulting -Team member** | 🟡 `Read` |
| **Consulting - Team Leader** | 🟢 `R/W` |
| **Consulting - Manager** | 🟢 `R/W` |
| **Consulting - Senior Manager** | 🟢 `R/W` |
| **Consulting - HOD** | 🟢 `R/W` |
| **Testing - Team Member** | 🟡 `Read` |
| **Testing - Team Leader** | 🟢 `R/W` |
| **Testing - Manager** | 🟢 `R/W` |
| **Testing - Senior Manager** | 🟢 `R/W` |
| **Testing - HOD** | 🟢 `R/W` |
| **Intern** | 🟡 `Read` |


### 3.8 My team (3 Items)

| Role | Customer profile | My timsheet | Timesheet Approval |
| :--- | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Accounts** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales Manger** | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Sales team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **PMO (Project Management Office)** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **EM (Engagement Manager)** | 🟡 `Read` | 🟢 `R/W` | 🟢 `R/W` |
| **R&D -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` |
| **SOC - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - Senior Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **SOC - HOD** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting -Team member** | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` |
| **Consulting - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting - Senior Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Consulting - HOD** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - Team Member** | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` |
| **Testing - Team Leader** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - Senior Manager** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Testing - HOD** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` |
| **Intern** | 🟡 `Read` | 🟢 `R/W` | 🟡 `Read` |


### 3.9 Settings (5 Items)

| Role | Moduleswise Access | User Role Access | Project Masters | Customer Masters | Resource Master |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **CEO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **COO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **CTO** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **IT Admin** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Accounts** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **HR** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🟢 `R/W` |
| **Sales Manger** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **Sales team member** | 🔴 `None` | 🔴 `None` | 🟡 `Read` | 🟡 `Read` | 🔴 `None` |
| **PMO (Project Management Office)** | 🟢 `R/W` | 🟢 `R/W` | 🟢 `R/W` | 🟡 `Read` | 🟡 `Read` |
| **EM (Engagement Manager)** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **R&D -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **SOC - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **SOC - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Consulting -Team member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Consulting - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Consulting - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Testing - Team Member** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Team Leader** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Manager** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |
| **Testing - Senior Manager** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Testing - HOD** | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` | 🟡 `Read` |
| **Intern** | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` | 🔴 `None` |


---

## 4. Detailed Role Profiles (All 27 Roles)

### 4.1 CEO
- **Total Accessible**: 40 / 49 widgets (0 Manage, 40 View-only, 2 Hidden)

**🟡 Read-Only (`1,0`) [40 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Raise issues`, `Alerts`, `Notifications`, `Budget`, `Extension Request`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [2 items]**:
`Start timer`, `Approvals`

---

### 4.2 COO
- **Total Accessible**: 40 / 49 widgets (0 Manage, 40 View-only, 2 Hidden)

**🟡 Read-Only (`1,0`) [40 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Raise issues`, `Alerts`, `Notifications`, `Budget`, `Extension Request`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [2 items]**:
`Start timer`, `Approvals`

---

### 4.3 CTO
- **Total Accessible**: 40 / 49 widgets (0 Manage, 40 View-only, 2 Hidden)

**🟡 Read-Only (`1,0`) [40 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Raise issues`, `Alerts`, `Notifications`, `Budget`, `Extension Request`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [2 items]**:
`Start timer`, `Approvals`

---

### 4.4 IT Admin
- **Total Accessible**: 15 / 49 widgets (4 Manage, 11 View-only, 27 Hidden)

**🟢 Full Manage (`1,1`) [4 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`

**🟡 Read-Only (`1,0`) [11 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Team`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🔴 Hidden / No Access (`0,0`) [27 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Start timer`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Eduacation and experience`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.5 Accounts
- **Total Accessible**: 19 / 49 widgets (6 Manage, 13 View-only, 23 Hidden)

**🟢 Full Manage (`1,1`) [6 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Billing Information`, `Invoice Schedule`

**🟡 Read-Only (`1,0`) [13 items]**:
`Budget`, `Sr.project Manger`, `Project manager`, `Team leads`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Project Masters`, `Customer Masters`

**🔴 Hidden / No Access (`0,0`) [23 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Start timer`, `Extension Request`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Eduacation and experience`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Resource Master`

---

### 4.6 HR
- **Total Accessible**: 8 / 49 widgets (6 Manage, 2 View-only, 34 Hidden)

**🟢 Full Manage (`1,1`) [6 items]**:
`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Resource Detailes`, `Resource Master`

**🟡 Read-Only (`1,0`) [2 items]**:
`Pmo information`, `Activity Logs`

**🔴 Hidden / No Access (`0,0`) [34 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Raise issues`, `Start timer`, `Approvals`, `Alerts`, `Notifications`, `Budget`, `Extension Request`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`

---

### 4.7 Sales Manger
- **Total Accessible**: 29 / 49 widgets (6 Manage, 23 View-only, 13 Hidden)

**🟢 Full Manage (`1,1`) [6 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Budget`, `Additional customer Requirement`

**🟡 Read-Only (`1,0`) [23 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Invoice`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Project Masters`, `Customer Masters`

**🔴 Hidden / No Access (`0,0`) [13 items]**:
`Start timer`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Eduacation and experience`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Resource Master`

---

### 4.8 Sales team member
- **Total Accessible**: 24 / 49 widgets (1 Manage, 23 View-only, 18 Hidden)

**🟢 Full Manage (`1,1`) [1 items]**:
`Raise issues`

**🟡 Read-Only (`1,0`) [23 items]**:
`Approvals`, `Alerts`, `Notifications`, `Budget`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Project Masters`, `Customer Masters`

**🔴 Hidden / No Access (`0,0`) [18 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Start timer`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Eduacation and experience`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Resource Master`

---

### 4.9 PMO (Project Management Office)
- **Total Accessible**: 37 / 49 widgets (28 Manage, 9 View-only, 5 Hidden)

**🟢 Full Manage (`1,1`) [28 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Extension Request`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`

**🟡 Read-Only (`1,0`) [9 items]**:
`Additional customer Requirement`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Activity Logs`, `Resource Detailes`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [5 items]**:
`Start timer`, `Budget`, `Billing Information`, `Invoice Schedule`, `Invoice`

---

### 4.10 EM (Engagement Manager)
- **Total Accessible**: 35 / 49 widgets (15 Manage, 20 View-only, 7 Hidden)

**🟢 Full Manage (`1,1`) [15 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Eduacation and experience`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [20 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Customer profile`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [7 items]**:
`Start timer`, `Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.11 R&D -Team member
- **Total Accessible**: 12 / 49 widgets (5 Manage, 7 View-only, 30 Hidden)

**🟢 Full Manage (`1,1`) [5 items]**:
`Raise issues`, `Start timer`, `Alerts`, `Notifications`, `Eduacation and experience`

**🟡 Read-Only (`1,0`) [7 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`

**🔴 Hidden / No Access (`0,0`) [30 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Activity Logs`, `Resource Detailes`, `Customer profile`, `My timsheet`, `Timesheet Approval`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.12 SOC - Team Member
- **Total Accessible**: 14 / 49 widgets (5 Manage, 9 View-only, 28 Hidden)

**🟢 Full Manage (`1,1`) [5 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Eduacation and experience`, `My timsheet`

**🟡 Read-Only (`1,0`) [9 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `Timesheet Approval`

**🔴 Hidden / No Access (`0,0`) [28 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Alerts`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.13 SOC - Team Leader
- **Total Accessible**: 24 / 49 widgets (9 Manage, 15 View-only, 18 Hidden)

**🟢 Full Manage (`1,1`) [9 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Team`, `Task`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [15 items]**:
`Alerts`, `Sr.project Manger`, `Project manager`, `Team leads`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [18 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.14 SOC - Manager
- **Total Accessible**: 31 / 49 widgets (17 Manage, 14 View-only, 11 Hidden)

**🟢 Full Manage (`1,1`) [17 items]**:
`Raise issues`, `Start timer`, `Approvals`, `Alerts`, `Notifications`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [14 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [11 items]**:
`Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.15 SOC - Senior Manager
- **Total Accessible**: 35 / 49 widgets (13 Manage, 22 View-only, 7 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [22 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [7 items]**:
`Start timer`, `Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.16 SOC - HOD
- **Total Accessible**: 37 / 49 widgets (13 Manage, 24 View-only, 5 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [24 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Budget`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [5 items]**:
`Start timer`, `Extension Request`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.17 Consulting -Team member
- **Total Accessible**: 14 / 49 widgets (5 Manage, 9 View-only, 28 Hidden)

**🟢 Full Manage (`1,1`) [5 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Eduacation and experience`, `My timsheet`

**🟡 Read-Only (`1,0`) [9 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `Timesheet Approval`

**🔴 Hidden / No Access (`0,0`) [28 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Alerts`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.18 Consulting - Team Leader
- **Total Accessible**: 24 / 49 widgets (9 Manage, 15 View-only, 18 Hidden)

**🟢 Full Manage (`1,1`) [9 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Team`, `Task`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [15 items]**:
`Alerts`, `Sr.project Manger`, `Project manager`, `Team leads`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [18 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.19 Consulting - Manager
- **Total Accessible**: 31 / 49 widgets (17 Manage, 14 View-only, 11 Hidden)

**🟢 Full Manage (`1,1`) [17 items]**:
`Raise issues`, `Start timer`, `Approvals`, `Alerts`, `Notifications`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [14 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [11 items]**:
`Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.20 Consulting - Senior Manager
- **Total Accessible**: 35 / 49 widgets (13 Manage, 22 View-only, 7 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [22 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [7 items]**:
`Start timer`, `Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.21 Consulting - HOD
- **Total Accessible**: 37 / 49 widgets (13 Manage, 24 View-only, 5 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [24 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Budget`, `Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [5 items]**:
`Start timer`, `Extension Request`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.22 Testing - Team Member
- **Total Accessible**: 14 / 49 widgets (5 Manage, 9 View-only, 28 Hidden)

**🟢 Full Manage (`1,1`) [5 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Eduacation and experience`, `My timsheet`

**🟡 Read-Only (`1,0`) [9 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `Timesheet Approval`

**🔴 Hidden / No Access (`0,0`) [28 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Alerts`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.23 Testing - Team Leader
- **Total Accessible**: 24 / 49 widgets (9 Manage, 15 View-only, 18 Hidden)

**🟢 Full Manage (`1,1`) [9 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Team`, `Task`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [15 items]**:
`Alerts`, `Sr.project Manger`, `Project manager`, `Team leads`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [18 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Budget`, `Extension Request`, `Billing Information`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.24 Testing - Manager
- **Total Accessible**: 31 / 49 widgets (17 Manage, 14 View-only, 11 Hidden)

**🟢 Full Manage (`1,1`) [17 items]**:
`Raise issues`, `Start timer`, `Approvals`, `Alerts`, `Notifications`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [14 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`

**🔴 Hidden / No Access (`0,0`) [11 items]**:
`Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

### 4.25 Testing - Senior Manager
- **Total Accessible**: 35 / 49 widgets (13 Manage, 22 View-only, 7 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [22 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [7 items]**:
`Start timer`, `Budget`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.26 Testing - HOD
- **Total Accessible**: 36 / 49 widgets (13 Manage, 23 View-only, 6 Hidden)

**🟢 Full Manage (`1,1`) [13 items]**:
`Raise issues`, `Approvals`, `Alerts`, `Notifications`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Additional customer Requirement`, `Eduacation and experience`, `Customer profile`, `My timsheet`, `Timesheet Approval`

**🟡 Read-Only (`1,0`) [23 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Budget`, `Sr.project Manger`, `Project manager`, `Team leads`, `PMO Intake & Prerequiste Workflow`, `Team`, `Task`, `Customer Engagment`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

**🔴 Hidden / No Access (`0,0`) [6 items]**:
`Start timer`, `Extension Request`, `Billing Information`, `Invoice Schedule`, `Invoice`, `Activity Logs`

---

### 4.27 Intern
- **Total Accessible**: 15 / 49 widgets (5 Manage, 10 View-only, 27 Hidden)

**🟢 Full Manage (`1,1`) [5 items]**:
`Raise issues`, `Start timer`, `Notifications`, `Eduacation and experience`, `My timsheet`

**🟡 Read-Only (`1,0`) [10 items]**:
`Sr.project Manger`, `Project manager`, `Team leads`, `Billing Information`, `Personal Information`, `orgnization deatile`, `employment and bond`, `Pmo information`, `Customer profile`, `Timesheet Approval`

**🔴 Hidden / No Access (`0,0`) [27 items]**:
`KPI'S`, `Assigned Projects`, `Pending issues`, `Project stauts`, `Pending approvals`, `Approvals`, `Alerts`, `Budget`, `Extension Request`, `PMO Intake & Prerequiste Workflow`, `Invoice Schedule`, `Team`, `Task`, `Issues`, `Aletrs`, `Escalation`, `Appreciation`, `Customer Engagment`, `Additional customer Requirement`, `Invoice`, `Activity Logs`, `Resource Detailes`, `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`

---

## 5. Database & Backend Synchronization

### Automatic Seed & Reset Guarantee
1. **PostgreSQL Seed**: The values above are stored in table `role_widget_permissions`.
2. **C# Baseline Catalog**: Recorded in `RoleBaselines.cs` on the backend so any administrator can click *"Reset to Baseline"* to restore these exact values.
3. **Frontend TypeScript Catalog**: Referenced in `excel-baseline.ts` to provide immediate client-side preview defaults.