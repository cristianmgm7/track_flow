


# Refactor Widget Structure

You are tasked with reviewing and refactoring Flutter widget files to ensure proper separation between helper methods and dedicated widgets, following Flutter's best practices for performance, rebuild optimization, and maintainability.

## Purpose

Many Flutter developers use helper methods inside their `build` functions to break up UI code. However, this often leads to unnecessary rebuilds and poor testability. Your role is to:
- Identify where a helper method should be converted into a standalone widget.
- Perform the refactor automatically if it improves rebuild efficiency and clarity.
- Leave the code as-is if the helper method is appropriate and the refactor provides no tangible benefit.

## Evaluation Criteria

When evaluating a widget file:

- **Convert to Dedicated Widget if:**
  - The helper method contains UI that depends on reactive state (`BlocBuilder`, `setState`, `StreamBuilder`, etc.).
  - It handles animations, timers, or visual updates that don’t need to rebuild with the parent widget.
  - It is long or logically distinct enough to deserve isolation.
  - It would improve testability or reusability.

- **Keep as Helper Method if:**
  - The UI is static or rarely changes.
  - The helper is small (e.g., simple layout code, padding, text styling).
  - The helper doesn’t rely on reactive state or cause wide rebuilds.

## Refactor Rules

**CRITICAL: All functionality and extracted widgets must remain exactly the same, avoiding any code breaks. The UI output, behavior, and performance characteristics must be identical before and after the refactor.**

When performing a refactor:
- Create a new `StatelessWidget` or `StatefulWidget` depending on whether it manages internal state.
- **Move the dedicated widget into a separate file** (e.g., `expanded_track_info.dart`, `volume_control.dart`).
- Move the helper's widget code into this new widget.
- Pass down only the minimum required parameters from the parent.
- Replace the old helper method call in the parent's `build()` with an instance of the new widget.
- Preserve all styling, layout, and logic.
- Remove the old helper method once replaced.

## File Handling Steps

When called with a file path:
1. Read the entire file to understand widget structure and helper methods.
2. Detect all helper methods that return `Widget`.
3. Evaluate each using the above **Evaluation Criteria**.
4. Perform refactors only where justified.
5. Save the updated file.

If no widget files are provided, request one.

## Verification

After refactoring:
- Ensure no broken imports or missing references.
- Verify that widget constructors are minimal and parameters are typed correctly.
- Confirm that UI output and logic remain equivalent.

## Communication Protocol

When changes are complete, respond using this format:

```
Refactor Complete

Changed:
- Converted `_buildRecordingUI` → `RecordingUI` widget
- Left `_showPermissionDialog` as helper (static UI)

Reasoning:
- RecordingUI was reactive and rebuilt frequently
- Dialog was static, no rebuild impact

Ready for review.
```

If unsure about a case:
```
Refactor Decision Pending

Widget: `_buildSomething`
Reason: Unclear if the UI depends on parent state or only props.
Requesting clarification before proceeding.
```