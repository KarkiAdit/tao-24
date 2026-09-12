<!--
  Reformatted from a Google Docs text export on 2026-09-12. Structure (headings,
  bullets) was rebuilt for navigability; wording is unchanged.
  Source: https://docs.google.com/document/d/1a-_1QU_jJUqmEqKB09JZek9j9yALBsk7ZgUm7OfZdNQ/edit
  MISSING FIGURE: section 1 (high-level system architecture diagram) is an
  image in the original and did not survive the text export.
-->

# Black-Box System Architecture & Scalability Design

> **Version** 1.0 · **Status** Draft / Proposal · **Last updated** Sep 11, 2026
> **Target platform** iOS 18.0+ (Native Swift; raised from 17.0 — see `CLAUDE.md`) ·
> **System design model** Local-First, Privacy-Centric Architecture

**In this doc:** [Architectural Principles](#executive-overview--architectural-principles) ·
[System Diagram](#1-high-level-system-architecture-diagram) ·
[Indexing & Query Optimization](#2-database-indexing--query-optimization) ·
[Sync & Conflict Resolution](#3-local-first-synchronization--conflict-resolution) ·
[Security & Privacy](#4-security-privacy--data-isolation-boundaries)

---

## Executive Overview & Architectural Principles

The Habits Tracker Application utilizes a **Local-First System Architecture**
designed for instantaneous UI response, zero offline degradation, and high data
privacy. All primary read and write operations execute synchronously against an
on-device SwiftData database (backed by SQLite). Remote cloud synchronization
operates asynchronously in the background, ensuring core checklist tracking
functions remain unaffected by network latency or connection outages.

---

## 1. High-Level System Architecture Diagram

> **Missing figure.** This section is a diagram in the source document and did
> not survive the text export. Refer to the original Google Doc.

---

## 2. Database Indexing & Query Optimization

> **Implementation note (Phase 01).** The log index below cannot be built as
> written: `#Index` cannot traverse a relationship, so `habit_id` must be a
> denormalized stored column, and `completedAt` is replaced by a day-normalized
> `completedDayStart` because `Calendar` calls are not expressible in
> `#Predicate`. Shipped shape:
> `HabitExecutionLog[habitID, completedDayStart]`. The `Habit` index is
> unchanged. `#Index` is also iOS 18.0+, which is why the deployment floor was
> raised from 17.0.

| Entity | Index | Purpose |
|---|---|---|
| `HabitExecutionLog` | `[habit_id, completedAt]` | Fast lookup of today's execution state for the Starter Hub checklist |
| `Habit` | `[domainRawValue, isArchived]` | Sub-millisecond domain filtering across Health, Career, and Fun portals without full table scans |

- **Execution Log Fast Lookup** — The `HabitExecutionLog` entity incorporates a
  compound database index on `[habit_id, completedAt]`. This ensures
  constant-time *O(1)* query lookups when loading today's execution state for
  the Starter Hub checklist.
- **Domain Filtering Index** — The `Habit` entity indexes
  `[domainRawValue, isArchived]` to allow sub-millisecond filtering across
  Health, Career, and Fun portals without full table scans.
- **In-Memory Caching** — Frequently queried entities (such as active habits for
  the current day) are cached in memory within `@Observable` Controllers to
  eliminate redundant disk I/O.

---

## 3. Local-First Synchronization & Conflict Resolution

- **Instant UI Mutation** — User interactions (e.g. checking off a habit)
  mutate local memory instantly without waiting for network I/O.
- **Conflict Resolution Strategy** — In multi-device sync scenarios (via
  CloudKit), data conflicts are resolved using a **Last-Write-Wins (LWW)**
  policy backed by ISO-8601 UTC timestamps.
- **Background Sync Queue** — Pending cloud synchronization payloads are stored
  in a persistent queue that retries automatically upon network state changes.

---

## 4. Security, Privacy & Data Isolation Boundaries

- **On-Device Processing** — Questionnaire analysis, value alignment scoring,
  and habit mapping algorithms execute entirely on-device, preserving user
  privacy.
- **Encryption at Rest** — All local databases are protected using Apple's
  Complete File Protection API (`NSDataReadingOptions.dataReadingMappedIfSafe`),
  decrypting data only when the device is unlocked.
  > **Implementation note (Phase 01).** Two corrections. The API named here is
  > not a file-protection API — protection level is set via the app's Data
  > Protection entitlement or `FileManager` `.protectionKey`. And Complete File
  > Protection breaks WidgetKit timeline refresh on a locked device, so the
  > level is deferred to Milestone 3.3; Phase 01 sets no entitlement.
- **Zero Tracking Analytics** — The application contains no third-party
  behavioral trackers or privacy-invasive telemetry SDKs.
