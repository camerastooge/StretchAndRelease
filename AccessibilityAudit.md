# VoiceOver Accessibility Audit — Stretch & Release

**Date:** 2026-07-22
**Scope:** All SwiftUI views (iOS app + watchOS app). Criteria: accessibility labels, hints, values, and traits for interactive elements and images.

This audit follows Apple's VoiceOver nutrition-label criteria. Each view gets a binary **PASS / FAIL** verdict. FAIL means a fix was required; all FAILs below were **fixed in place**. Recommendations are non-blocking and did not change verdicts.

## Summary

| View | Verdict (before fix) | Change applied |
|---|---|---|
| ContentView (iOS) | FAIL | Corrected misleading help-button label |
| ButtonView | PASS | — (recommendation only) |
| TimerDisplayView | PASS | — |
| Arc | PASS | — (no auditable elements) |
| MainArcView | PASS | — (recommendation only) |
| PlaylistView | PASS | — (recommendation only) |
| PlaylistRowView | PASS | — (recommendation only) |
| AddExerciseView (iOS) | FAIL | Added missing Save-button label (iOS 26 branch) |
| EditExerciseView (iOS) | FAIL | Added missing Save-button label (iOS 26 branch) |
| PhoneAddExerciseViewTypical | FAIL | Corrected Reps label (was interpolating `stretch`) |
| PhoneAddExerciseViewAccessible | PASS | — |
| PhoneTimerSettingsTypicalView | FAIL | Corrected Reps label (was interpolating `stretch`) |
| PhoneTimerSettingsAccessibleView | PASS | — |
| SettingsView (TimerSettingsView) | FAIL | Added missing Save-button label (iOS 26 branch) |
| MainHelpScreenView | PASS | — (recommendation only) |
| ContentView (watchOS) | PASS | — (recommendation only) |
| TimerActionViewWatch | PASS | — (recommendation only) |
| TimerSettingsViewWatch | FAIL | Added missing Save-button label (watchOS 26 branch) |
| WatchApp/Device SettingsView subviews | PASS | — |
| Stretch/Rest/RepsPickerView | PASS | — |
| PlaylistViewWatch | PASS | — |
| AddExerciseViewWatch | FAIL | Added missing Cancel-button label; fixed Rest adjustable action |
| EditExerciseViewWatch | FAIL | Added missing Save-button label; fixed Rest adjustable action |

---

## iOS Views

### ContentView.swift — FAIL → fixed
- **Help button** (line ~75/79): had `.accessibilityLabel("Show playlist")` — a misleading label; the control opens the Help sheet. **Fixed** to `"Show help"` (both the iOS 26 and legacy branches). *(Criterion 2 — non-human-readable / misleading label.)*
- Settings `NavigationLink` (gear): `.accessibilityLabel("Show Settings")` — PASS.
- `TabView`/`Tab("Timer"…)`/`Tab("Set list"…)`: system-managed, auto-labeled from titles — PASS.

### ButtonView.swift — PASS
- Renders only `Image(systemName:)` for a role. In every real usage it is embedded in a `Button`/`NavigationLink` that supplies its own `.accessibilityLabel`, so the icon does not need its own label.
- **Recommendation:** when shown purely as a graphic (e.g. in MainHelpScreenView), the SF Symbol may be announced by VoiceOver alongside the descriptive text. Consider `.accessibilityHidden(true)` inside `ButtonView` for the decorative/help contexts to avoid double announcements.

### TimerDisplayView.swift — PASS
- Previous / Next / Start-Pause / Reset buttons all have `.accessibilityLabel` (+ `.accessibilityInputLabels`, and a hint on Reset). PASS.
- Minor: the Reset hint reads "This button reset the timer." (grammar) — cosmetic, not changed.

### Arc.swift — PASS
- A `Shape`; no interactive elements or images. No auditable elements.

### MainArcView.swift — PASS
- Countdown text, phase text, and reps text each have explicit `.accessibilityLabel`. PASS.
- **Recommendation:** the countdown `Text` changes every second — add `.accessibilityAddTraits(.updatesFrequently)` so VoiceOver handles the rapid value changes gracefully.

### PlaylistView.swift — PASS
- ADD button, Edit `NavigationLink`, and swipe-to-Delete all have labels/hints. Header cells have labels + hints. PASS.
- Minor typo in a header hint ("sretch") — cosmetic, not changed.
- **Recommendation:** the row's swipe-to-delete should also be surfaced as a VoiceOver custom action: `.accessibilityAction(named: "Delete") { modelContext.delete(exercise) }` on the row, since swipe gestures aren't discoverable via VoiceOver.

### PlaylistRowView.swift — PASS
- Contains only `Text` (name + three numbers). It's rendered inside a labeled `NavigationLink` ("Edit …"), which combines into a single element, so the bare numbers are not read out of context.
- **Recommendation:** enrich the Edit link label to include the values, e.g. `"Edit \(name), \(stretch) second stretch, \(rest) second rest, \(reps) reps"`, so VoiceOver users hear the row's data, which is otherwise lost.

### AddExerciseView.swift — FAIL → fixed
- **Save button** (chevron.left): on the **iOS 26 branch** the `Image` had `.glassEffect(.clear)` but **no** `.accessibilityLabel` (only the legacy branch was labeled). VoiceOver would announce "Back"/the symbol name. **Fixed** by adding `.accessibilityLabel("Save changes and return to set list view")` to the iOS 26 branch. *(Criterion 1 — missing label.)*
- Cancel button: labeled in both branches — PASS.

### EditExerciseView.swift — FAIL → fixed
- **Save button** (chevron.left): same iOS 26 branch missing label. **Fixed** identically. *(Criterion 1.)*
- Cancel button: PASS.

### PhoneAddExerciseViewTypical.swift — FAIL → fixed
- **Reps picker** (line ~108): `.accessibilityLabel("Repetition count \(stretch)")` interpolated the wrong variable (`stretch`), so VoiceOver announced the stretch count while showing rep values. **Fixed** to `\(reps)`. *(Criterion 2 — incorrect label content.)*
- Stretch/Rest pickers, "sec." label, and adjustable actions — PASS.

### PhoneAddExerciseViewAccessible.swift — PASS
- All three pickers use `.accessibilityElement(children: .ignore)` + label + hint + value + `.accessibilityAdjustableAction`, each referencing the correct variable. PASS.

### PhoneTimerSettingsTypicalView.swift — FAIL → fixed
- Stretch/Rest pickers fully configured with label/hint/value/adjustable — PASS.
- **Reps picker** (line ~88): `.accessibilityLabel("Repetition count \(stretch)")` interpolated the wrong variable; the value was correct (`reps`) but the spoken label announced the stretch count. **Fixed** to `\(reps)`. *(Criterion 2 — incorrect label content.)*

### PhoneTimerSettingsAccessibleView.swift — PASS
- All pickers correctly labeled/valued with correct variables. PASS.

### TimerSettingsView.swift (SettingsView) — FAIL → fixed
- **Save button** (chevron.left): iOS 26 branch missing `.accessibilityLabel`. **Fixed** by adding `"Save changes and return to set list view"`. *(Criterion 1.)*
- Cancel button, the three `Toggle`s (title = label, each with a hint), and the volume `Slider` (label/hint/value/adjustable) — PASS.

### MainHelpScreenView.swift — PASS
- Descriptive `Text` accompanies each `ButtonView` graphic; previous/next rows have labels; the privacy `Link` is auto-labeled and additionally has label + hint. PASS.
- **Recommendation:** the `ButtonView` icon graphics are decorative here (the adjacent `Text` conveys meaning). Mark them `.accessibilityHidden(true)` or group each row with `.accessibilityElement(children: .combine)` so each control is announced as one element instead of icon-name + description.

---

## watchOS Views

### ContentView.swift (watch) — PASS
- Hosts two content `Tab {}` pages (Timer / Playlist) with no titles; these are paging containers, and their contents are individually accessible. PASS.
- **Recommendation:** consider giving each `Tab` an accessibility label so VoiceOver users can identify the page they've swiped to.

### TimerActionViewWatch.swift — PASS
- Countdown text, timer-phase text (with drag gesture), previous/next buttons, play-pause, reset, and settings all have labels (+ input labels / hints). PASS.
- **Recommendations:**
  - The phase `Text` carries a `DragGesture` for next/previous — a drag isn't VoiceOver-discoverable. Expose the same behavior via `.accessibilityAdjustableAction` or `.accessibilityAction(named:)`.
  - The countdown `Text` updates every second — add `.accessibilityAddTraits(.updatesFrequently)`.

### TimerSettingsViewWatch.swift — FAIL → fixed
- **Save button** (chevron.left): watchOS 26 branch missing `.accessibilityLabel`. **Fixed** by adding `"Save changes and return to set list view"`. *(Criterion 1.)*
- Cancel button, the `WatchAppSettingsView` rows (`.accessibilityElement(children: .combine)` + hint), toggles, volume slider, and the three picker subviews (`StretchPickerView` / `RestPickerView` / `RepsPickerView`, all with label/hint/value/adjustable) — PASS.
- Minor: the "Set list" toggle has no hint (the other toggles do) — cosmetic, not changed.

### AddExerciseViewWatch.swift — FAIL → fixed
- **Cancel button** (top-bar trailing): had **no** `.accessibilityLabel` in either branch — VoiceOver would announce the symbol name. **Fixed** by adding `.accessibilityLabel("Cancel and return to set list view")`. *(Criterion 1.)*
- **Rest picker adjustable action:** `.accessibilityAdjustableAction` incremented/decremented `stretch` instead of `rest`, so swiping up/down on the Rest control changed the wrong value for VoiceOver users. **Fixed** to adjust `rest`. *(Adjustable-value defect.)*
- Save button: labeled on the `Button` — PASS. Name field, Stretch/Reps links & pickers — PASS.

### EditExerciseViewWatch.swift — FAIL → fixed
- **Save button** (`ButtonView(.save)`): the `Button` had **no** `.accessibilityLabel`; the icon-only content would be announced by symbol name. **Fixed** by adding `.accessibilityLabel("Save changes and return to set list view")` to the `Button`. *(Criterion 1.)*
- **Rest picker adjustable action:** same `stretch`-instead-of-`rest` bug as above. **Fixed** to adjust `rest`. *(Adjustable-value defect.)*
- Name field, Stretch/Reps links & pickers — PASS.

### PlaylistViewWatch.swift — PASS
- Add button, Edit `NavigationLink`, and swipe-to-Delete all labeled. PASS.
- **Recommendation:** as with the iOS list, expose swipe-to-delete as an `.accessibilityAction(named: "Delete")` on the row.

---

## What changed (files edited)

1. `ContentView.swift` (iOS) — help-button label `"Show playlist"` → `"Show help"`.
2. `AddExerciseView.swift` — added Save-button label on iOS 26 branch.
3. `EditExerciseView.swift` — added Save-button label on iOS 26 branch.
4. `TimerSettingsView.swift` — added Save-button label on iOS 26 branch.
5. `PhoneAddExerciseViewTypical.swift` — Reps label `\(stretch)` → `\(reps)`.
6. `TimerSettingsViewWatch.swift` — added Save-button label on watchOS 26 branch.
7. `AddExerciseViewWatch.swift` — added Cancel-button label; Rest adjustable action now adjusts `rest`.
8. `EditExerciseViewWatch.swift` — added Save-button label; Rest adjustable action now adjusts `rest`.
9. `PhoneTimerSettingsTypicalView.swift` — Reps label `\(stretch)` → `\(reps)`.

All edited files were re-checked with Xcode diagnostics and report no issues.

## Recommendations not yet applied (non-blocking)
- `.accessibilityAddTraits(.updatesFrequently)` on the per-second countdown text (MainArcView, TimerActionViewWatch).
- Expose swipe-to-delete as `.accessibilityAction(named: "Delete")` on list rows (PlaylistView, PlaylistViewWatch).
- Expose the watch drag-to-change-stretch gesture as an accessibility action/adjustable (TimerActionViewWatch).
- Enrich the playlist Edit link label with the stretch/rest/reps values (PlaylistRowView).
- Mark decorative `ButtonView` icons hidden / combine rows in MainHelpScreenView.
