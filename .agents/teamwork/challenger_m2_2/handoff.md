# Adversarial Challenge Handoff Report: Milestone 2 — Onboarding Flow (R2)

**Challenger Subagent:** `challenger_m2_2`  
**Milestone:** Milestone 2: Onboarding Flow (R2)  
**Parent Agent:** `2283687a-5c7c-4e1f-9d03-d89b8d745253`  
**Timestamp:** 2026-11-04T20:41:00Z  
**Verdict:** **REQUEST_CHANGES**

---

## 1. Observation

1. **Test Suite Execution:**
   Created and executed a dedicated adversarial test suite under `test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart` (13 tests) covering:
   - State resilience when `OnboardingPreferences.complete()` throws an exception.
   - Double-tap prevention while `_busy` is true.
   - Unmount safety mid-animation and mid-drag gesture.
   - Unmount safety when async completion resolves or errors in background.
   - Viewport constraints across 412×915 dp, 600×1000 dp, 320×640 dp, and 320×480 dp.

2. **Command & Execution Output:**
   Ran:
   ```bash
   fvm flutter test test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart
   ```
   **Output:**
   ```text
   00:00 +0: loading /home/tn-99778/Towha/LinguaPages/test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart
   00:00 +1: Adversarial Stress Test: State & Error Resilience Scenario 1.1: OnboardingPreferences.complete() exception on Import displays error, resets _busy, avoids unhandled crash
   00:00 +2: Adversarial Stress Test: State & Error Resilience Scenario 1.2: OnboardingPreferences.complete() exception on Explore First displays error, resets _busy
   00:00 +3: Adversarial Stress Test: State & Error Resilience Scenario 1.3: Double-tapping "Import your first book" while _busy is true triggers single execution
   00:01 +4: Adversarial Stress Test: State & Error Resilience Scenario 1.4: Double-tapping "Explore first" while _busy is true triggers single execution
   00:01 +5: Adversarial Stress Test: State & Error Resilience Scenario 1.5: Tapping Skip on Page 4 while _busy is true does not trigger duplicate completion
   00:01 +6: Adversarial Stress Test: Lifecycle & Unmount Safety Scenario 2.1: Unmount mid-animation yields zero FlutterError and clean disposal
   00:01 +7: Adversarial Stress Test: Lifecycle & Unmount Safety Scenario 2.2: Unmount mid-drag gesture yields zero FlutterError
   00:01 +8: Adversarial Stress Test: Lifecycle & Unmount Safety Scenario 2.3: Unmount while async completion is pending does not throw on resolution
   00:01 +9: Adversarial Stress Test: Lifecycle & Unmount Safety Scenario 2.4: Unmount while async completion errors does not call setState on unmounted State
   00:01 +10: Adversarial Stress Test: Viewport Constraints & Zero RenderFlex Overflow Scenario 3: Zero RenderFlex overflow on all 4 pages under Target mobile (412x915 dp)
   00:01 +11: Adversarial Stress Test: Viewport Constraints & Zero RenderFlex Overflow Scenario 3: Zero RenderFlex overflow on all 4 pages under Large display (600x1000 dp)
   00:01 +11 -1: Adversarial Stress Test: Viewport Constraints & Zero RenderFlex Overflow Scenario 3: Zero RenderFlex overflow on all 4 pages under Narrow phone (320x640 dp) [E]
   00:02 +11 -2: Adversarial Stress Test: Viewport Constraints & Zero RenderFlex Overflow Scenario 3: Zero RenderFlex overflow on all 4 pages under Ultra-compact height (320x480 dp) [E]
   ```

3. **Verbatim RenderFlex Overflow Error:**
   On both 320×640 dp (narrow phone) and 320×480 dp (ultra-compact):
   ```text
   ══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞══════════════════════
   The following assertion was thrown during layout:
   A RenderFlex overflowed by 32 pixels on the right.

   The relevant error-causing widget was:
     Row
     Row:file:///home/tn-99778/Towha/LinguaPages/lib/presentation/screen/onboarding/onboarding_screen.dart:104:16

   The specific RenderFlex in question is: RenderFlex relayoutBoundary=up14 OVERFLOWING:
     parentData: offset=Offset(0.0, 0.0) (can use size)
     constraints: BoxConstraints(0.0<=w<=196.0, 0.0<=h<=Infinity)
     size: Size(196.0, 28.0)
     direction: horizontal
     mainAxisAlignment: start
     mainAxisSize: min
     crossAxisAlignment: center
     textDirection: ltr
     verticalDirection: down
     spacing: 0.0
   ```

---

## 2. Logic Chain

1. **State Resilience (VERIFIED ROBUST):**
   - When `OnboardingPreferences.complete()` throws an exception, `OnboardingScreen` catches the error, sets `_busy = false`, and assigns `_error = context.l10n.onboardingFailed`.
   - The UI displays `'Something went wrong. Try again.'` in `AppColors.destructiveColor`, hides `CircularProgressIndicator`, restores the icon, and re-enables the button without throwing an unhandled exception or crashing.
   - Subsequent retry successfully completes and routes to `DashboardRoute`.

2. **Double-Tap Guarding (VERIFIED ROBUST):**
   - While `_busy == true`, both "Import your first book" and "Explore first" have `onPressed: null` (disabled).
   - In addition, `_completeOnboarding()` immediately returns `if (_busy) return;`.
   - Double-tapping while an operation is in flight results in exactly 1 call to `OnboardingPreferences.complete()`.

3. **Lifecycle & Unmount Safety (VERIFIED ROBUST):**
   - Unmounting mid-animation (e.g. 50ms into a 300ms curve) disposes `_pageController` cleanly with zero `FlutterError`.
   - Unmounting while `OnboardingPreferences.complete()` is pending or when it throws asynchronously in the background does not call `setState()` because lines 55 and 58 rigorously check `if (!mounted) return;`.

4. **Viewport Constraints (FAILURE DETECTED):**
   - In `lib/presentation/screen/onboarding/onboarding_screen.dart` lines 98–140:
     ```dart
     appBar: AppBar(
       automaticallyImplyLeading: false,
       titleSpacing: 20,
       title: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           const Icon(Icons.local_library_outlined, size: 24, ...),
           const SizedBox(width: 8),
           Text('OpenPages', style: GoogleFonts.newsreader(fontSize: 22, ...)),
         ],
       ),
       actions: [
         Padding(
           padding: const EdgeInsets.only(right: 12),
           child: TextButton(onPressed: _handleSkip, child: const Text('Skip')),
         ),
       ],
     ),
     ```
   - On a 320dp width screen:
     - Available width: 320 dp.
     - `titleSpacing`: 20 dp.
     - Trailing action: `TextButton` + padding reserves ~104 dp.
     - `NavigationToolbar` provides `title` with constraint `BoxConstraints(0.0 <= w <= 196.0)`.
     - The intrinsic width of `Row([Icon(24), SizedBox(8), Text('OpenPages')])` is 228 dp.
     - Because `Text` is not wrapped in `Flexible` or `Expanded`, the `Row` overflows by exactly `228 - 196 = 32 pixels`.

---

## 3. Caveats

- No caveats. The bug is 100% deterministic, empirically isolated to `Row` at `onboarding_screen.dart:104:16`, and verified under standard Flutter test execution on viewport widths <= 320 dp.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

While state resilience, error recovery, double-tap prevention, and controller lifecycle safety are excellently implemented, the screen fails the viewport constraint test on narrow mobile devices (320×640 dp and 320×480 dp) due to a 32-pixel `RenderFlex` overflow in the `AppBar` title `Row`.

### Required Fix for Worker:
In `lib/presentation/screen/onboarding/onboarding_screen.dart:104`:
Wrap `Text('OpenPages', ...)` with `Flexible(child: Text('OpenPages', overflow: TextOverflow.ellipsis, ...))` inside the `Row`, or adjust `titleSpacing` / `actions` padding on compact widths so the `AppBar` title accommodates narrower screens without overflow.

---

## 5. Verification Method

To independently reproduce and verify this finding:
```bash
# 1. Run the dedicated adversarial stress test suite
fvm flutter test test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart

# 2. Run specifically the narrow phone viewport scenario
fvm flutter test test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart --name="Narrow phone"
```

### Invalidation Conditions
- `fvm flutter test test/presentation/screen/onboarding/onboarding_screen_adversarial_test.dart` passes all 13 tests with zero `RenderFlex` overflow errors on 320dp viewports.
- No bottom navigation bar is introduced.
- Static analysis passes with 0 warnings via `fvm flutter analyze`.
