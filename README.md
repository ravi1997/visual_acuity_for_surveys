# v_a_rpc — Visual Acuity for Surveys

A cross-platform mobile application for recording visual acuity in population survey settings, developed for the Rapid Prevalence Cohort (RPC) study at AIIMS New Delhi.

- **Platform:** Android & iOS (Flutter, Dart SDK ^3.8.1)
- **Version:** 1.0.0
- **Developed by:** Ravinder Singh, Programmer, AIIMS New Delhi

> **Disclaimer:** This application is intended to assist clinicians in recording visual acuity. It is not a substitute for a diagnostic clinical examination. Please consult a licensed ophthalmologist for medical advice and treatment decisions.

---

## Table of Contents

1. [Overview](#overview)
2. [Testing Tracks and Sub-tests](#testing-tracks-and-sub-tests)
3. [Acuity Levels](#acuity-levels)
4. [Algorithm](#algorithm)
5. [Screen Calibration](#screen-calibration)
6. [Optotype Rendering and DPI Handling](#optotype-rendering-and-dpi-handling)
7. [Accessibility Behaviour](#accessibility-behaviour)
8. [Environmental Quality Control](#environmental-quality-control)
9. [Gesture Input](#gesture-input)
10. [Data Storage and History](#data-storage-and-history)
11. [Application Screens](#application-screens)
12. [Installation](#installation)
13. [Usage Guide](#usage-guide)
14. [Dependencies](#dependencies)

---

## Overview

The application records visual acuity for six distance vision modalities and one near vision modality per patient. Completed modalities are tracked per patient ID and marked with a tick in the test selection screen, allowing a full survey session to be conducted without duplication.

**Supported vision types:**

| Vision Type | Label |
|---|---|
| Right eye — uncorrected | UVA |
| Right eye — corrected (with glasses) | CVA |
| Right eye — pinhole | PinVA |
| Left eye — uncorrected | UVA |
| Left eye — corrected (with glasses) | CVA |
| Left eye — pinhole | PinVA |
| Near vision (both eyes) | N6 |

---

## Testing Tracks and Sub-tests

### Distance Vision Track
Starts at 6/60 (level 1, 3 m). The algorithm traverses up to nine levels depending on performance. Three sub-tests are used depending on the level reached:

**1. Tumbling E optotype (levels 0–4)**
- SVG-rendered E displayed at a calibrated physical size
- Patient responds by swiping in the direction the E is pointing (up / down / left / right)
- Screen held in portrait orientation

**2. Finger Counting — FC (level 6)**
- Device rotated to landscape orientation automatically
- SVG finger-count images (1–4 fingers) displayed at 9.4 cm × 9.4 cm physical size at 0.3 m
- Patient (or proxy) selects the number of fingers or "Can't see" via on-screen buttons
- Portrait orientation restored on exit

**3. Perception of Light — PL (levels 7–8)**
- Device torch (rear flashlight) is activated automatically
- Patient indicates whether light is perceived (Yes / No)
- Torch is disabled immediately after response

### Near Vision Track
Single level (N6) assessed at 0.4 m using the tumbling E sub-test. Result is either N6 (pass) or N6-failed.

---

## Acuity Levels

| Level | Name | Distance | Optotype size (cm) | Sub-test |
|---|---|---|---|---|
| 0 | 3/60 | 1.0 m | 2.91 | Tumbling E |
| 1 | 6/60 | 3.0 m | 4.36 | Tumbling E |
| 2 | 6/19 | 3.0 m | 1.38 | Tumbling E |
| 3 | 6/12 | 3.0 m | 0.87 | Tumbling E |
| 4 | 6/9.5 | 3.0 m | 0.69 | Tumbling E |
| 5 | N6 | 0.4 m | 0.11 | Tumbling E |
| 6 | FC | 0.3 m | — | Finger Counting |
| 7 | PL− | 0.1 m | — | Perception of Light |
| 8 | PL+ | 0.1 m | — | Perception of Light |

**Distance vision level progression:**

```
Start: Level 1 (6/60)
  Pass → Level 2 (6/19)
    Pass → Level 3 (6/12)
      Pass → Level 4 (6/9.5)
        Pass → Final: 6/9
        Fail → Final: 6/12
      Fail → Final: 6/18
    Fail → Final: 6/60
  Fail → Level 0 (3/60 at 1m)
    Pass → Final: 3/60
    Fail → Level 6 (FC at 0.3m)
      Pass → Final: FC
      Fail → Level 7 (PL−)
        Pass → Final: PL−
        Fail → Level 8 (PL+)
          Pass → Final: PL+
          Fail → Final: PL−
```

---

## Algorithm

Each level uses a **hierarchical threshold-bracketing procedure** with the following termination criterion:

- **Pass:** ≥ 4 correct responses
- **Fail:** ≥ 2 incorrect responses
- **Maximum trials:** 5 per level (Finger Counting test hard-caps at 5 trials)

The test level always resets to the default starting level (level 1 for distance, level 5 for near) at the beginning of each new examination. Aggregate response counters (total correct, total wrong, ignored gestures) persist across app sessions.

---

## Screen Calibration

Calibration must be performed **once per device** before the first test session, and **repeated if the Android Display Size setting is changed** (see [Accessibility Behaviour](#accessibility-behaviour)).

The calibration screen displays a resizable blue square. The administrator adjusts it until it physically measures exactly 5 cm × 5 cm using a ruler, then saves. The device-specific scale factor is computed as:

```
pxPerCm = P_adjusted / 5
```

where `P_adjusted` is the logical pixel count at which the square measures 5 cm on screen.

The calibration screen also sets the **maximum ambient lux threshold** (default: 15,000 lux). This value is used during testing to flag invalid lighting conditions.

**Fallback (no calibration saved):** The system falls back to 160 logical DPI (≈ 62.99 px/cm) with a logged warning. Testing is still possible but physical optotype sizes will not be guaranteed accurate.

---

## Optotype Rendering and DPI Handling

Each E-optotype is rendered as an SVG at a physical size computed from the calibrated scale factor:

```
S_px = S_cm × (11/5) × pxPerCm
```

where `S_cm` is the level-defined notional optotype dimension and the coefficient `(11/5)` maps the notional size to the SVG bounding box dimensions.

The Finger Counting SVGs are rendered at a fixed 9.4 cm × 9.4 cm physical size using the same formula.

**The manufacturer-reported hardware DPI is not used in any size computation.** The device pixel ratio is captured solely for diagnostic logging. This makes optotype rendering consistent across heterogeneous display hardware regardless of how accurately a device reports its screen density.

---

## Accessibility Behaviour

### Android Font Size (font scaling)
**No effect on optotype dimensions.**

Optotypes are rendered as SVG images with dimensions specified as explicit widget geometry constraints. They do not pass through Flutter's text rendering subsystem and are therefore completely unaffected by Android's font size / text magnification accessibility settings.

### Android Display Size (screen density)
**Requires re-calibration if changed.**

Android's Display Size setting changes the device's screen density, which alters the physical size represented by one logical pixel. Because the calibrated `pxPerCm` value is stored in logical pixels, changing Display Size after calibration invalidates the stored scale factor. **If Display Size is adjusted on the device, the calibration screen must be run again** before testing resumes.

### Offline Operation
The application requires no internet connection. All data is stored on-device only.

---

## Environmental Quality Control

| Parameter | E-test | FC test |
|---|---|---|
| Ambient light polling interval | Every 5 s | Every 15 s |
| Default max lux threshold | 15,000 lux | 15,000 lux |
| Threshold source | Calibration screen setting | Hard-coded default |
| Action on exceedance | Alert dialog + test frozen | Alert dialog shown |
| Screen brightness | Normalised to 90% on start | Normalised to 90% on start |
| Brightness restored | On screen dispose | On screen dispose |

---

## Gesture Input

Applies to the Tumbling E sub-test only.

| Parameter | Value |
|---|---|
| Input method | Touch swipe (pan gesture) |
| Valid directions | Up / Down / Left / Right |
| Minimum swipe displacement | 10 logical pixels |
| Default minimum velocity | 100 px/s |
| Adaptive relaxation (≥ 5 ignored gestures) | 80 px/s |
| Adaptive relaxation (≥ 10 ignored gestures) | 60 px/s |

A gesture is ignored if it falls below either the displacement or velocity threshold. Ignored gesture count is persisted across sessions and drives the adaptive relaxation.

---

## Data Storage and History

### Storage format
Records are written to `test_history.xlsx` in the application documents directory using the following column structure:

| Column | Content |
|---|---|
| DateTime | ISO 8601 timestamp |
| patientInfo | Patient identifier (free text) |
| visionType | Selected vision modality string |
| Result | Final acuity notation (e.g. `6/12`, `FC`, `PL-`) |

### History screen
- Records displayed latest-first
- Paginated: 20 records loaded initially, more loaded on scroll or via "Load more"
- Pull-to-refresh supported
- Tap any record to view full details in a bottom sheet
- Delete all history via the bin icon (confirmation required)

### Patient continuity
On the test entry screen, tapping **Load Last** auto-fills the previous patient's ID from history. Vision types already recorded for that patient are marked with a green tick, preventing accidental re-testing.

---

## Application Screens

| Screen | Route | Purpose |
|---|---|---|
| Home | `/home` | Navigation hub |
| Patient Input | `/testHome` | Enter patient ID and select vision type |
| Distance Instruction | `/distance` | Shown before each test segment; displays required testing distance with diagram |
| E-optotype Test | `/test` | Main tumbling E test screen |
| Summary | `/summary` | Displays final acuity result with plain-language explanation |
| History | `/history` | Paginated test record log |
| Calibration | `/calibrate` | Physical screen calibration and lux threshold setup |
| Instructions | `/instructions` | Static testing instructions (distance, environment, screen position) |
| Tutorial | `/tutorial` | 5-step illustrated guide: calibrate → distance → swipe → brightness → results |
| About | `/about` | App version, credits, disclaimer |

---

## Installation

### Prerequisites
- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`
- Android Studio (for Android) or Xcode (for iOS)
- A physical device is recommended — optotype physical sizing cannot be validated on emulators

### Build and run

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ipa --release
```

### Permissions required (Android)
- `CAMERA` — used by the ambient light sensor package
- `FLASHLIGHT` — used for the perception of light sub-test

These permissions are declared in the Android manifest and requested at runtime as needed.

---

## Usage Guide

### Before the first test session on a new device

1. Open the app and tap **Calibrate Screen**
2. Place a physical ruler against the screen
3. Adjust the slider (or use the +/− buttons for fine control) until the blue square measures exactly **5 cm × 5 cm**
4. Set the **maximum ambient lux** value appropriate for your testing environment (default 15,000)
5. Tap **Save Calibration**

> Recalibrate if the device is replaced, or if Android Display Size is changed.

### Running a test session

1. Tap **Start Test** from the home screen
2. Enter the patient identifier in the ID field
   - Tap **Load Last** to reuse the previous patient's ID
   - Vision types already completed for that patient will be ticked
3. Select the vision type to test
4. Tap **Start Test**
5. Follow the distance instruction screen — position the patient at the stated distance
6. Conduct the test:
   - **E-optotype:** Patient swipes in the direction the E is pointing
   - **Finger Counting:** Patient (or proxy) taps the number of fingers shown
   - **Perception of Light:** Patient indicates whether the torch light is visible
7. The summary screen displays the final acuity result and a plain-language explanation
8. Tap **Restart Test** to test another modality for the same patient, or **View Results** to review history

### Exporting data

The test history file is saved to the app's documents directory as `test_history.xlsx`. To retrieve it:
- **Android:** Use a file manager to navigate to the app's documents folder, or use `adb pull`
- **iOS:** Use Xcode's device file browser or iTunes File Sharing

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_svg` | ^2.2.3 | SVG optotype rendering |
| `screen_brightness` | ^2.1.7 | Normalise screen brightness to 90% |
| `ambient_light` | ^0.1.4 | Read hardware ambient light sensor |
| `torch_light` | ^1.1.0 | Control device torch for PL sub-test |
| `excel` | ^4.0.6 | Read/write `.xlsx` history file |
| `path_provider` | ^2.1.5 | Locate device documents directory |
| `shared_preferences` | ^2.5.4 | Persist calibration and test state |
| `lottie` | ^3.3.0 | Animated eye on summary screen |
| `device_info_sdk` | ^1.0.1 | Device diagnostics |
| `intl` | ^0.20.2 | Date formatting in history screen |
