# TODO: Expandable Task Cards with Exercise Details

**Goal:** Make task cards expandable to show full exercise details (what exercises, sets/reps, duration, etc.) and supplement details (dose, timing, notes)

## Task Breakdown

### Task Cards - Make Expandable
- [x] Convert _TaskCard from StatelessWidget to StatefulWidget
- [x] Add `isExpanded` state variable
- [x] Add tap handler to toggle expansion
- [x] Add expand/collapse icon indicator

### Exercise Details Display
- [x] Fetch exercise module data when card is exercise type
- [x] Create widget to display exercise details based on module type:
  - [x] Strength workouts (show exercises, sets, reps, rest)
  - [x] Joint sequences (show movements with reps)
  - [x] Stretches (show stretches with duration)
  - [x] Zone 2 / VO2 max (show intervals, duration, intensity)
  - [x] Walks (show duration, intensity)
  - [x] Breathing (show pattern, duration/breaths)

### Supplement Details Display
- [x] Fetch supplement data when card is supplement type
- [x] Display supplement list with:
  - [x] Supplement name
  - [x] Dose
  - [x] Food requirement indicator
  - [x] Notes/instructions
- [ ] Add individual checkboxes for each supplement
  - [ ] Track which supplements were actually taken
  - [ ] Show partial completion (e.g., "4 of 6 taken")
  - [ ] Store individual supplement completion status
  - [ ] Allow marking task as "done" even if not all supplements taken (with warning)
  - [ ] Show which specific supplements were skipped in history

### UI Polish
- [ ] Add smooth expansion animation
- [ ] Style details section (lighter background, proper spacing)
- [ ] Ensure details are readable and well-formatted
- [ ] Add visual separator between summary and details

## Implementation Notes
- Use TaskService.getTaskDetails() to fetch related data
- Keep expansion state per card (use index or task ID as key)
- Animate with AnimatedSize or similar
- Details should feel like "more info" not overwhelming

### Data Model for Individual Supplement Tracking
Need to extend DailyTaskInstance to store:
- `supplementsCompleted`: List<String> (supplement IDs that were taken)
- Maybe add a JSON field or extend metadata
- This allows partial completion tracking

### Two-Level Completion
1. **Individual supplements**: Check/uncheck within expanded view
2. **Overall task**: Mark as done (when all taken) or done with notes (partial)
3. **History**: Show "Took 4 of 6 supplements" with details

---

## ✅ Completed

**Basic Expandable Cards:**
- Cards now expand/collapse on tap
- Show expand/collapse icon
- Exercise modules display full details (sets, reps, rest, instructions)
- Supplements display full list with dose, food requirements, notes
- Smooth loading state while fetching details
- Action buttons (Done/Skip/Reset) move to expanded view

**Status:** Expandable cards working! Individual supplement checkboxes remain for Phase 2.
**Last Updated:** 2026-03-30 17:50
