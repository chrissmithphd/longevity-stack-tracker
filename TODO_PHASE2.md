# TODO: Phase 2 Features

**Created:** 2026-04-01
**Goal:** Opt-in/out system, calendar history, celebrations, and expanded details

---

## 1. Opt-In/Out System for Supplements & Exercises

### Database Changes
- [x] Add `active` column to supplements table (default true)
- [x] Add `active` column to exercise_modules table (default true)
- [x] Update database migration (version 3)

### Settings Screen - Supplements
- [x] Add toggle switch to each supplement card
- [x] Show active/inactive visual state (50% opacity when inactive)
- [x] Persist changes to database
- [x] Filter inactive supplements from task generation

### Settings Screen - Exercises
- [x] Add toggle switch to each exercise card
- [x] Show active/inactive visual state (50% opacity when inactive)
- [x] Persist changes to database
- [x] Filter inactive exercises from task generation

**Status:** ✅ Completed

---

## 2. Expandable Details in Settings Screens

### Supplements Screen
- [x] Make supplement cards expandable (tap to expand)
- [x] Show full details: dose, timing rule, food requirement, notes
- [x] Add expand/collapse indicator icon

### Exercises Screen
- [x] Make exercise cards expandable (tap to expand)
- [x] Show full exercise details based on module type:
  - [x] Strength: all exercises with sets/reps/rest
  - [x] Joint sequences: all movements with instructions
  - [x] Stretches: all stretches with duration
  - [x] Cardio: intervals, duration, intensity
  - [x] Breathing: pattern, duration

**Status:** ✅ Completed

---

## 3. Individual Items from Packs/Groupings

### Data Model
- [ ] Identify "pack" exercises (joint_sequence, strength_*, stretch_pack_*)
- [ ] Create individual exercise entries for each item in a pack
- [ ] Link pack items to parent pack (parent_id field?)
- [ ] Add opt-out capability for individual pack items

### UI Display
- [ ] Show parent packs AND individual items in exercise list
- [ ] Allow toggling individual items on/off
- [ ] When viewing pack details, show which items are opted out
- [ ] Visual indicator: "⚠️ 2 exercises skipped" in pack summary

### Task Generation
- [ ] When generating tasks from packs, exclude opted-out items
- [ ] Show indicator on Today screen if pack has excluded items

**Status:** Not started

---

## 4. Show Opted-Out Items on Today Screen

### Visual Design
- [x] Grey out opted-out task cards
- [x] Add "Disabled in settings" badge
- [x] Reduce opacity (60%)
- [x] Special border/background styling for inactive cards
- [x] Keep in list order but clearly inactive

### Behavior
- [x] Don't allow Done/Skip actions on opted-out items
- [x] Show "Disabled in settings" badge instead of action buttons
- [x] Don't count toward completion stats (X/Y)

**Status:** ✅ Completed

---

## 5. Calendar View in History Tab

### UI Components
- [x] Create CalendarView widget
- [x] Show current month with day cells
- [x] Each day shows "X/Y" completion count
- [x] Color-code cells by completion percentage:
  - [x] 100%: green (ForestNightTheme.completed)
  - [x] 75-99%: light green (ForestNightTheme.active)
  - [x] 50-74%: yellow/gold
  - [x] 25-49%: orange
  - [x] 0-24%: grey/red
- [x] Highlight today (bold border)
- [x] Add month navigation (prev/next arrows)

### Interaction
- [x] Tap day to view details for that date
- [x] Show existing task list view for selected day
- [x] Add back button to return to calendar

### Data Loading
- [x] Query task completion by date range (month)
- [x] Calculate X/Y for each day (excluding inactive tasks)
- [x] Reload stats when month changes

**Status:** ✅ Completed

---

## 6. Celebration & Stats Section

### Stats to Track
- [ ] Current streak (consecutive days with 100% completion)
- [ ] Longest streak
- [ ] Total days tracked
- [ ] Overall completion rate (all-time)
- [ ] This week's completion rate
- [ ] This month's completion rate
- [ ] Total tasks completed

### Visual Design
- [ ] Create celebration banner at top of History tab
- [ ] Show streak fire emoji 🔥 with count
- [ ] Show key stats in cards/chips
- [ ] Animate/celebrate milestones (7-day streak, 30-day, etc.)

### Milestones
- [ ] 7-day streak
- [ ] 30-day streak
- [ ] 90-day streak
- [ ] 100 total tasks completed
- [ ] 500 total tasks completed
- [ ] 1000 total tasks completed

**Status:** Not started

---

## 7. Research & Define Terms (Zone 2, etc.)

### Research Capability
**⚠️ LIMITATION:** I cannot browse Reddit or do live web research. I don't have WebFetch or WebSearch tools available.

### Alternative Approach
- [ ] I can provide definitions based on my training data (up to Jan 2025)
- [ ] Create glossary.md file with term definitions
- [ ] Terms to define:
  - [ ] Zone 2 cardio
  - [ ] VO2 max
  - [ ] Autophagy
  - [ ] Senescent cells
  - [ ] NAD+ precursors (NMN/NR)
  - [ ] Sirtuins
  - [ ] mTOR
  - [ ] AMPK
  - [ ] Nrf2 pathway

### Supplement Timing & Importance Research
- [ ] Research optimal timing for each supplement
- [ ] Identify importance/priority ranking for each time slot (morning, afternoon, evening)
- [ ] Document why certain supplements are taken at specific times:
  - [ ] Morning supplements (e.g., Vitamin D with sunlight simulation)
  - [ ] With meals supplements (fat-soluble vitamins)
  - [ ] Evening supplements (e.g., Magnesium for sleep)
  - [ ] Fasting-compatible vs food-required
- [ ] Create sorting logic based on timing importance
- [ ] Add notes about synergistic effects (e.g., D3 + K2)

### Implementation
- [ ] Create glossary.md with scientifically-backed definitions
- [ ] Add supplement timing/importance data to supplements.json or database
- [ ] Sort supplements by importance in task display
- [ ] Add info icons (ℹ️) next to terms in app
- [ ] Tap icon to show definition in bottom sheet/dialog

**Status:** Can provide definitions from training data, cannot browse Reddit

---

## 8. Supplement Importance Scoring for Longevity

### Goal
Assign importance scores (1-10) to each supplement based on scientific evidence for longevity impact.

### Research Questions
- [ ] What is the evidence strength for each supplement's longevity benefits?
- [ ] Which supplements have the most robust human studies?
- [ ] Which are fundamental vs. supportive vs. experimental?
- [ ] What are the mechanistic pathways (mTOR, AMPK, NAD+, etc.)?
- [ ] Are there synergistic combinations that increase importance?

### Scoring Criteria (1-10 scale)
**10 - Critical Foundation:**
- Strong human evidence for lifespan/healthspan extension
- Well-established mechanisms (e.g., cellular senescence, autophagy)
- Fundamental to longevity stack
- Example candidates: ?

**8-9 - High Priority:**
- Good evidence from multiple studies
- Clear mechanistic understanding
- Significant impact on aging biomarkers
- Example candidates: ?

**6-7 - Supportive/Beneficial:**
- Moderate evidence
- Supporting role in longevity pathways
- Good safety profile
- Example candidates: ?

**4-5 - Experimental/Emerging:**
- Early research, promising but not conclusive
- Mechanistic rationale but limited human data
- Example candidates: ?

**1-3 - Speculative/Low Priority:**
- Minimal evidence
- Unclear mechanisms
- Mainly preventative or quality-of-life
- Example candidates: ?

### Research by Supplement
For each supplement in supplements.json, determine:
- [ ] **Creatine**: Importance score + rationale
- [ ] **Omega-3 (EPA/DHA)**: Importance score + rationale
- [ ] **Vitamin D3**: Importance score + rationale
- [ ] **Vitamin K2 (MK-7)**: Importance score + rationale (synergy with D3?)
- [ ] **Magnesium**: Importance score + rationale
- [ ] **Zinc**: Importance score + rationale
- [ ] **NMN/NR (NAD+ precursors)**: Importance score + rationale
- [ ] **Resveratrol**: Importance score + rationale
- [ ] **Quercetin**: Importance score + rationale (senolytic potential?)
- [ ] **Curcumin**: Importance score + rationale
- [ ] **Spermidine**: Importance score + rationale (autophagy?)
- [ ] **CoQ10**: Importance score + rationale
- [ ] **Acetyl-L-carnitine**: Importance score + rationale
- [ ] **Sulforaphane**: Importance score + rationale (Nrf2 activation?)

### Key Longevity Mechanisms to Consider
- [ ] NAD+ restoration (cellular energy, DNA repair)
- [ ] Autophagy induction (cellular cleanup)
- [ ] Senescent cell clearance (senolytics)
- [ ] mTOR modulation (growth vs longevity balance)
- [ ] AMPK activation (metabolic health)
- [ ] Sirtuin activation (stress response, DNA repair)
- [ ] Inflammation reduction (inflammaging)
- [ ] Mitochondrial function (energy production)
- [ ] Oxidative stress reduction (ROS management)
- [ ] Telomere maintenance

### Sources to Consider
- [ ] Human clinical trials (PubMed, clinical databases)
- [ ] Mechanistic studies (cell/animal models)
- [ ] Meta-analyses and systematic reviews
- [ ] Longevity researcher consensus (Sinclair, Kennedy, Attia, etc.)
- [ ] ITP (Interventions Testing Program) data
- [ ] Biomarker improvements (biological age clocks)

### Implementation Plan
- [x] Research each supplement (web research completed April 2, 2026)
- [x] Assign importance scores with detailed rationale
- [x] Update supplements.json with importance field
- [x] Create supplement_longevity_research_report.md (comprehensive technical report)
- [x] Create SUPPLEMENT_GUIDE.md (user-friendly practical guide)
- [x] Fix getAllSupplements() to sort by importance DESC, name ASC
- [x] Add tests for importance sorting
- [x] Database column already exists from migration v3

**Status:** ✅ **COMPLETED** - Importance sorting implemented and tested (September 30, 2026)

---

## Priority Order

**High Priority (Do First):**
1. ✅ Item #2: Expandable details (COMPLETED!)
2. ✅ Item #1: Opt-in/out system (COMPLETED!)
3. ✅ Item #4: Show opted-out items on Today screen (COMPLETED!)

**Medium Priority:**
4. ✅ Item #5: Calendar view (COMPLETED!)
5. ⏳ Item #6: Celebrations/stats (motivational, fun) - NEXT

**Lower Priority (Phase 3):**
6. ⏳ Item #3: Individual pack items (complex, refinement)
7. ⏳ Item #7: Glossary/definitions (nice-to-have, can use my knowledge)

---

## Notes

- Individual supplement checkboxes from TODO.md remain for future phase
- Focus on solid implementation of opt-in/out first
- Calendar view is a big UI change - might take time
- Glossary can be simple markdown file initially

**Next Step:** Start with expandable details in Settings screens (quick win!)
