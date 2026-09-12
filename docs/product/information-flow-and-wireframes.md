<!--
  Reformatted from a Google Docs text export on 2026-09-12. Structure (headings,
  bullets) was rebuilt for navigability; wording is unchanged.
  Source: https://docs.google.com/document/d/13QKPpDpKXkpu8kTFaC1h1JyQvFP2ynZt-XGUvKKpkVE/edit
  MISSING FIGURE: section 1 (IA & screen navigation flow) is an image in the
  original and did not survive the text export.
-->

# Prototyping the Information Flow & UI Wireframes

> **Version** 1.0 · **Status** Draft · **Last updated** Sep 11, 2026

**In this doc:** [Information Architecture](#1-information-architecture--screen-navigation-flow) ·
[Starter Hub](#21-starter-hub-starter-hub) ·
[Habit Planner](#22-habit-planner-screen-planner-hub) ·
[Progress](#23-progress-screen-progress-hub) ·
[Onboarding](#24-onboarding-flow-onboarding-hub)

**Screen route map**

| Screen | Route | Core purpose |
|---|---|---|
| Starter Hub | `/starter-hub` | Low-friction execution, daily focus, rapid habit creation |
| Quick-Add Modal | `/starter-hub#quick-add` | Create a habit in as few taps as possible |
| Habit Planner | `/planner-hub` | Discovery, education, blueprint selection |
| Blueprint Preview | `/planner-hub#blueprint-detail` | Inspect and adopt a 3-habit set |
| Progress | `/progress-hub` | Visualizing balance, momentum, self-reflection |
| Onboarding | `/onboarding-hub` | Values alignment and tailored initial setup |

---

## 1. Information Architecture & Screen Navigation Flow

> **Missing figure.** This section is a diagram in the source document and did
> not survive the text export. The route map above is reconstructed from the
> per-screen specs below — refer to the original Google Doc for the authoritative
> navigation flow.

---

## 2. UI Specifications

### 2.1 Starter Hub Wireframe (`/starter-hub`)

**Core purpose:** Low-friction execution, daily focus, and rapid habit creation.

- **Top Bar**
  - *Left:* Date (Today, Sep 11)
  - *Right:* Dimension Balance Pill (3/3 Domains Active)
- **Goal Context Banner** — Minimal card displaying active weekly focal
  objective (e.g. "Focus: Sustained Deep Work & Recovery").
- **Daily Checklist Section**
  - *Filter Chips:* All | Health | Career | Fun
  - *Habit Item Card:*
    - **Left:** Interactive Checkbox / Progress Ring
    - **Center:** Habit Name (45-min Deep Work Block) + Small Goal Tag
      (Goal: Master System Design)
    - **Right:** Domain Tag Pill (Career)
- **Floating Action Button (FAB)** — `+ Quick Add` positioned at bottom-right.

#### Quick-Add Habit Modal (`/starter-hub#quick-add`)

- **Header:** Create New Habit
- **Input fields:**
  - Title (e.g. Read 15 mins)
  - Dimension Selection (3-way Segmented Control: Health | Career | Fun)
  - Target Frequency (Daily, 3x/week, Custom)
  - Supporting Goal Link (Dropdown select)
- **Actions:** Cancel | Save Habit

### 2.2 Habit Planner Screen Wireframe (`/planner-hub`)

**Core purpose:** Discovery, education, and blueprint selection.

- **Domain Cards Grid**
  - 3 Hero Cards for Health, Career, and Fun.
  - Each card shows: Domain Icon, Active Habit Count, and a *Browse Blueprints*
    CTA.
- **Micro-Resource Feed** — Horizontal scrolling carousel of 1-minute
  educational cards (e.g. "The Science of Habit Stacking", "Why Fun Prevents
  Career Burnout").
- **Curated Blueprint Sets**
  - Pre-packaged 3-habit combinations (e.g. The Balanced Engineer Set).
  - Each card displays the included 3 habits across the 3 dimensions with an
    *Inspect Set* button.

#### Blueprint Preview Modal (`/planner-hub#blueprint-detail`)

- **Header:** Blueprint Title & Target Outcome
- **Content:**
  - List of 3 habits with domain tags.
  - Research Rationale accordion section ("Why this combination works").
- **Action:** Adopt Plan (populates habits directly into Starter Hub).

### 2.3 Progress Screen Wireframe (`/progress-hub`)

**Core purpose:** Visualizing balance, momentum, and self-reflection.

- **Timeframe Selector** — Segmented control (7 Days | 30 Days | 90 Days).
- **Dimension Balance Wheel (Radar Chart)**
  - Visual triangular graph showing effort distribution across Fun, Career,
    and Health.
  - *Insight Badge:* "Balanced effort across all 3 domains this week!"
- **Consistency Bar Chart** — Completion percentage graph per day over the
  selected timeframe, prioritizing overall trend line over unbroken streaks.
- **Milestone Log** — Stacked list of achieved milestones (e.g. "Completed 20
  Career Deep Work Sessions").
- **Reflection CTA Banner** — Prompts weekly alignment check-in: "How did your
  habits feel this week? Tap to reflect."

### 2.4 Onboarding Flow Wireframe (`/onboarding-hub`)

**Core purpose:** Values alignment and tailored initial setup.

- **Progress Bar** — 5-step indicator at top.
- **Step layout:**
  1. **Primary Goal** — 4 selectable option cards.
  2. **Structure Preference** — 3 cards (Structured, Flexible, Exploratory).
  3. **Energy Mapping** — 3 timing chips (Morning, Afternoon, Evening).
  4. **Social Alignment** — 3 environment chips (Solo, Group, Hybrid).
  5. **Core Values** — Multi-select tags (limit 3).
- **Output Screen** — Renders calculated "Starter Plan" with 3 habits ready to
  accept or customize.
