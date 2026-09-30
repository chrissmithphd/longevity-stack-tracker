# Longevity Stack Tracker - Project Context

## Project Purpose

A Flutter-based personal longevity routine tracker that manages supplements, exercise protocols, and wellness tasks based on evidence-based longevity science. The app generates daily tasks from a weekly schedule, tracks completion with non-judgmental status options (Done/Skip/Pending), and provides historical calendar views with completion statistics.

**Core Philosophy:** Support consistent longevity practices through calm, judgment-free tracking that respects the science behind supplements, exercise timing, and circadian biology.

## Technology Stack

- **Framework:** Flutter 3.41.6 / Dart 3.11.4
- **Database:** SQLite (sqflite for mobile, sqflite_common_ffi for desktop)
- **Platforms:** Android, iOS, Linux, macOS, Windows, Web
- **Key Dependencies:**
  - `flutter_local_notifications` + `timezone` - Smart notifications based on sunrise/sunset
  - `nrel_spa` + `geolocator` - Astronomical calculations for circadian-aligned timing
  - `flutter_svg` - Custom category icons
  - `intl` - Date/time formatting

## Architecture

### Data Model Hierarchy

```
supplements.json + exercises.json + fullschedule.json
    ↓ (imported via JsonImportService on first run)
Database Tables:
  - supplements (id, name, dose, timing_rule, importance, active)
  - exercise_modules (id, name, module_type, details, active)
  - schedule_events (day_of_week, time, event_type, module_id, supplement_ids)
    ↓ (TaskService generates instances)
  - daily_tasks (task_date, title, category, status, completed_at, metadata)
```

### Key Services

1. **DatabaseService** - SQLite schema and migrations (currently v5)
2. **JsonImportService** - One-time import from JSON assets to database
3. **TaskService** - Daily task generation, completion tracking, history queries
4. **NotificationService** - Location-aware notifications using sunrise/sunset calculations
5. **SunTimingService** - NREL SPA astronomical calculations for circadian timing

### Task Generation Flow

Daily tasks are generated from `schedule_events` at midnight or on-demand:
- Filters out inactive supplements/exercises (active=0)
- Applies timing rules (with_first_meal, 60_min_before_bed, autophagy_day_midmorning, etc.)
- Attaches metadata (supplement lists, exercise details) for expandable cards
- Respects user opt-in/out preferences (Settings screens toggle `active` flag)

## Design System: Forest Night Theme

**Color Palette:** Soft forest greens, muted earth tones, low contrast for calm evening use
**Typography:** Clear hierarchy, gentle on the eyes for daily ritual tracking
**Interaction:** Non-judgmental - "Skip" is neutral grey, not red/negative
**Icons:** Custom SVG category icons (supplements 💊, exercise 🏃, recovery 🌊, sleep 🌙, hydration 💧)

**Design Documentation:**
- `/docs/FOREST_NIGHT_DESIGN_SYSTEM.md` - Complete design system specification
- `/docs/ui_guidelines.md` - Component styling patterns
- `/docs/DESIGN_IMPLEMENTATION_SUMMARY.md` - What's been built

**Critical:** Maintain the calm, supportive aesthetic. Avoid harsh colors, judgmental language, or anxiety-inducing UI patterns.

## Longevity Science Integration

### Supplement Importance Scoring (1-10)

Based on evidence strength from human trials, mechanistic understanding, and longevity researcher consensus:

**Tier 1 (Critical Foundation):**
- Vitamin D3: 10/10 - 25% mortality reduction, strong human RCTs
- Magnesium: 9/10 - DNA repair, 300+ enzyme systems
- Omega-3: 8/10 - Anti-inflammaging, cardiovascular protection

**Tier 2 (High Priority):**
- Creatine: 7/10 - Cognitive + muscle preservation
- Sulforaphane: 7/10 - Nrf2 activation (200+ protective genes)
- Zinc: 7/10 - Immune support, DNA repair
- K2: 6/10 - Arterial health, pairs with D3
- Spermidine: 6/10 - Autophagy induction

**Tier 3-4 (Experimental/Speculative):**
- NMN/NR: 5/10 - NAD+ restoration, promising but limited human data
- CoQ10/ALCAR: 5/10 - Mitochondrial support, mixed evidence
- Quercetin: 4/10 - Potential senolytic, weak alone
- Resveratrol: 3/10 - Bioavailability disaster (0.5%)
- Curcumin: 2/10 - $150M research found no medical value

**Research Documentation:**
- `SUPPLEMENT_GUIDE.md` - User-friendly tier system with practical guidance
- `supplement_longevity_research_report.md` - Technical research backing
- `GLOSSARY.md` - Longevity mechanisms (autophagy, mTOR, AMPK, NAD+, sirtuins, Nrf2)

### Exercise Protocols

- **Zone 2 Cardio** - 60-70% max HR, 45-60min, 3-4x/week → mitochondrial biogenesis
- **VO2 Max Intervals** - 4x4min at 85-95% max HR → aerobic capacity (strongest mortality predictor)
- **Strength Training** - Sarcopenia/osteosarcopenia prevention, metabolic health
- **Joint Sequences** - Longevity through injury prevention and movement quality
- **Breathing Protocols** - Parasympathetic activation, stress reduction

See `exercise_definitions.md` for comprehensive protocol definitions.

## Current Implementation Status

### ✅ Completed Features (Phase 1-2)

- Today screen with expandable task cards (show exercise/supplement details)
- History screen with calendar view (color-coded by completion percentage)
- Settings screens for supplements and exercises (toggle active/inactive)
- Opt-out system filters inactive items from task generation
- Disabled items shown greyed-out on Today screen with "Disabled in settings" badge
- SQLite database with migration system (v5)
- Notification system with sunrise/sunset timing
- Forest Night theme fully implemented

### 🚧 Known Gaps

1. ~~**Importance scoring not used**~~ ✅ **FIXED** - Now sorts by importance DESC, name ASC
2. ~~**Minimal test coverage**~~ ✅ **IMPROVED** - Added database service tests (sorting, active flags, importance persistence)
3. **Individual supplement checkboxes** - Can't mark partial completion (e.g., "took 4 of 6")
4. **Stats dashboard incomplete** - Streaks, milestones, celebration banners not implemented (TODO_PHASE2.md #6)
5. **Individual pack items** - Can't opt-out of single exercises within a joint sequence (TODO_PHASE2.md #3)

## Critical Constraints

### 1. Timing Accuracy Matters

Supplement timing rules are based on chronobiology and bioavailability:
- Fat-soluble vitamins (D3, K2, Omega-3) require fatty meals
- Magnesium glycinate 60min before bed for sleep support
- NAD+ precursors in morning (avoid late-day for sleep disruption)
- Autophagy compounds (spermidine, quercetin) on fasting days

**Do not randomize or simplify timing rules without physiological justification.**

### 2. Evidence-Based Recommendations Only

All supplement recommendations and importance scores are derived from:
- Human RCTs (randomized controlled trials)
- Meta-analyses and systematic reviews
- Longevity researcher consensus (Sinclair, Attia, Patrick)
- ITP (Interventions Testing Program) data

**Do not add supplements or change importance scores without research citations.**

### 3. Database Migration Discipline

Currently at v5. When adding columns or tables:
- Increment version number
- Add migration logic in `_upgradeDB()`
- Test with existing database (don't break user data)
- Document changes in comments

### 4. Non-Judgmental UI Language

- "Skip" not "Miss" or "Fail"
- Neutral grey for skipped tasks, not red
- Completion stats show progress, not shame ("8/10 completed" not "2 missed")
- Optional tasks clearly marked, not pressured

## Code Patterns to Follow

### 1. Expandable Card Pattern

Used in Today screen and Settings screens:
```dart
StatefulWidget with bool _isExpanded
→ GestureDetector wraps card
→ AnimatedSize/AnimatedCrossFade for smooth expansion
→ FutureBuilder loads details on first expand
→ Action buttons move into expanded section
```

### 2. Task Status Enum

```dart
'pending' | 'done' | 'skipped'
// Never add 'failed' or 'missed' - violates non-judgmental principle
```

### 3. Category Icons

Use `CategoryIcons.getIcon(category)` from `utils/category_icons.dart`
- Returns appropriate SVG asset path
- Consistent across Today, History, Settings screens

### 4. Time Calculations

Use `TimeCalculator` utilities for:
- Solar calculations (sunrise/sunset via NREL SPA)
- Meal timing estimation
- Notification scheduling

## Future Work Priority

**High Priority:**
1. Implement importance-based sorting (use the scoring system we researched)
2. Build stats dashboard (streaks, milestones, celebration UI)
3. Add integration tests for task generation logic

**Medium Priority:**
4. Individual supplement checkboxes (partial completion tracking)
5. Export/backup functionality
6. Sync across devices (requires backend or local network sync)

**Low Priority:**
7. Individual pack item opt-out (complex data model change)
8. AI-powered insights (requires privacy-preserving local ML)

## Development Commands

```bash
# Run app (Linux desktop)
flutter run -d linux

# Run tests (need to write more!)
flutter test

# Check for issues
flutter analyze

# Update dependencies
flutter pub get

# Build release (Android)
flutter build apk --release
```

## Testing Strategy (Needs Implementation)

**Unit Tests Needed:**
- Task generation logic (especially inactive filtering)
- Supplement importance sorting
- Time calculations and meal timing
- Notification scheduling

**Integration Tests Needed:**
- JSON import → database → task generation flow
- Opt-in/out system end-to-end
- Calendar calculation accuracy

**Widget Tests Needed:**
- Expandable card interactions
- Task status transitions
- Settings toggle persistence

## References for Longevity Science

When updating supplement recommendations or exercise protocols:

**Trusted Sources:**
- [Examine.com](https://examine.com) - Evidence-based supplement database
- [FoundMyFitness (Rhonda Patrick)](https://www.foundmyfitness.com) - Longevity science summaries
- [PubMed](https://pubmed.ncbi.nlm.nih.gov) - Primary research papers
- Peter Attia, MD - Applied longevity medicine
- David Sinclair, PhD - Aging biology research
- Interventions Testing Program (ITP) - NIA-funded lifespan studies

**Research Quality Hierarchy:**
1. Human RCTs (randomized controlled trials) - Gold standard
2. Meta-analyses - Multiple studies combined
3. Large observational studies - Real-world correlation
4. Small human trials - Suggestive but not conclusive
5. Animal studies - Interesting but often don't translate
6. In vitro studies - Mechanisms only, not proof

## Session-Specific Notes

When making changes:
- Update `TODO_PHASE2.md` status if completing features
- Maintain Forest Night design consistency
- Test on Linux desktop (primary development platform)
- Consider cross-platform implications (notification behavior varies)
- Keep README in sync with actual capabilities

---

*Last Updated: 2026-09-30*
*Database Version: 5*
*Flutter Version: 3.41.6*
