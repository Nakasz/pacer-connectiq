# Pacer — Connect IQ Watch App (Phase 3A.2)

Garmin Forerunner 965 watch app for Pacer running plan.
Custom step-by-step workout viewer — no backend, no pairing, no FIT export.

## Mac Setup (Required for Build)

### 1. Install Connect IQ SDK Manager

```
https://developer.garmin.com/connect-iq/sdk/
```
Download `connectiq-sdk-setup.dmg` (Mac) → run installer.

SDK Manager app appears in Applications.

### 2. Install SDK + Device Profile

1. Open **Garmin Connect IQ SDK Manager**
2. Tab **SDKs** → Install SDK `4.2.x` (latest 4.2.x)
3. Tab **Device** → Install **Forerunner 965**
4. Note SDK path (usually `~/Garmin/ConnectIQ SDK 4.2.x/`)

### 3. Install VS Code + Monkey C Extension

```bash
# VS Code
brew install --cask visual-studio-code

# Or download from https://code.visualstudio.com/

# Monkey C extension
# In VS Code: Cmd+Shift+X → search "Garmin Monkey C" → Install
```

### 4. Generate Developer Key

```bash
mkdir -p ~/garmin-developer
cd ~/garmin-developer

# Generate RSA-2048 private key + self-signed cert
openssl genrsa -out private.pem 2048
openssl req -new -x509 -key private.pem -out developer.der -days 3650 \
  -subj "/CN=PacerDev/O=Pacer/C=ID"

# Verify
openssl x509 -in developer.der -inform PEM -outform DER -out developer.der
ls -la developer.der   # should be ~1.1KB

# IMPORTANT: backup private.pem somewhere safe
# NEVER commit .der or .pem to git
```

### 5. Open Project in VS Code

```bash
cd /path/to/pacer-connectiq    # wherever the repo is cloned
code .
```

Monkey C extension auto-detects `monkey.jungle`.

## Build

### Via VS Code (Recommended)

1. Open `pacer-connectiq` folder in VS Code
2. `Cmd+Shift+P` → `Monkey C: Build for Device`
3. Target: select `Forerunner 965`
4. Developer key: browse to `~/garmin-developer/developer.der`
5. Output: `bin/Pacer.prg`

### Via CLI

```bash
cd /path/to/pacer-connectiq

# Find SDK path
CIQ_HOME=~/Library/Application\ Support/Garmin/ConnectIQ/SDK/4.2.x

# Build
$CIQ_HOME/bin/monkeyc \
  -f monkey.jungle \
  -o bin/Pacer.prg \
  -d fr965 \
  -y ~/garmin-developer/developer.der
```

Expected: `bin/Pacer.prg` (~50-200KB)

### If Build Fails

Common errors + fixes:

| Error | Fix |
|-------|-----|
| `namespace 'iq' not found` | manifest.xml namespace correct — verify SDK 4.2.x installed |
| `cannot find class PacerApp` | Check `monkey.jungle` has `source/PacerApp.mc` listed |
| `missing Toybox.Graphics` | Add `using Toybox.Graphics as Gfx;` |
| `cannot find symbol KEY_DOWN` | Use `WatchUi.KEY_DOWN` not `Toybox.WatchUi.KEY_DOWN` |
| `undefined symbol screenWidth` | Use `System.getDeviceSettings().screenWidth` |

## Simulator QA

### Run Simulator

```bash
CIQ_HOME=~/Library/Application\ Support/Garmin/ConnectIQ/SDK/4.2.x
$CIQ_HOME/bin/simulator -d fr965
```

Or in VS Code: `Cmd+Shift+P` → `Monkey C: Run on Simulator`

Simulator window opens with FR965 device.

### Test Sequence

```
[PASS/FAIL] [Notes]

[ ] App launch → main menu with "PACER" title + 5 workout types
[ ] UP scrolls list → highlight moves down
[ ] DOWN scrolls list → highlight moves up
[ ] ENTER on "Easy" → WorkoutTypeMenu confirmation screen
[ ] UP/DOWN toggles Yes/No selection
[ ] ENTER on "View" → WorkoutPreviewView with "Easy Run" steps
[ ] ENTER on preview → StepRunnerView shows "Easy Run — 40 min"
[ ] ENTER again → "Done!" completion screen
[ ] BACK from StepRunner → returns to WorkoutPreviewView
[ ] BACK from Preview → returns to WorkoutTypeMenu
[ ] BACK from WorkoutTypeMenu → returns to MainMenuView
[ ] BACK from MainMenuView → app exits cleanly
[ ] No crash throughout
[ ] No memory error
[ ] Layout readable at 454x454
[ ] Text not severely clipped
[ ] Touch: tap list item → goes to WorkoutTypeMenu
[ ] Touch: tap "View" button → goes to WorkoutPreviewView
[ ] Touch: tap bottom third of preview → goes to StepRunnerView
```

## FR965 Sideload

### 1. Build

`bin/Pacer.prg` must exist.

### 2. Connect Watch

USB cable → Mac. Watch shows "USB Connected" or file transfer mode.

FR965 appears as drive `/Volumes/GARMIN/`.

### 3. Copy PRG

```bash
cp /path/to/pacer-connectiq/bin/Pacer.prg /Volumes/GARMIN/APPS/
sync    # flush filesystem cache
```

Or Finder drag-drop to `GARMIN/APPS/`.

### 4. Eject

```
diskutil eject /Volumes/GARMIN/
```
Or Finder eject button.

### 5. Launch on Watch

1. Hold START → scroll to **Apps**
2. Find **Pacer** → press START to open
3. If not visible: Settings → Apps → check Pacer listed

### 6. Real Device Test Sequence

```
[PASS/FAIL] [Notes]

[ ] App appears in watch app list
[ ] App launches → main menu with "PACER" title
[ ] UP/DOWN button scrolls workout types
[ ] ENTER on "Threshold" → confirmation screen
[ ] UP/DOWN toggles Yes/No
[ ] ENTER on "View" → preview shows 5 steps
[ ] ENTER on preview → StepRunnerView active
[ ] ENTER → advances to step 2
[ ] ENTER → advances to step 3...
[ ] ENTER on last step → "Done!" screen
[ ] BACK → returns to preview
[ ] BACK → returns to confirmation
[ ] BACK → returns to main menu
[ ] BACK from main menu → exits app
[ ] No crash throughout
[ ] No memory error
[ ] Logs: check /GARMIN/APPS/LOGS/ if crash
```

### If Crash / Missing App

```bash
# Check logs
cat /Volumes/GARMIN/APPS/LOGS/*.log

# Re-check PRG copied
ls -la /Volumes/GARMIN/APPS/Pacer.prg

# Check developer key valid (date not expired)
openssl x509 -in ~/garmin-developer/developer.der -noout -dates

# Verify manifest product ID
grep "fr965" manifest.xml
```

## Device Target

| Property | Value |
|----------|-------|
| Primary device | Forerunner 965 (fr965) |
| Display | 454x454 AMOLED, round, touch + 5 buttons |
| SDK target | Connect IQ 4.2.x |
| App type | Watch App (full UI, multi-screen) |
| Min SDK | 4.2.0 |

## Architecture

```
App Entry (PacerApp)
    └─ MainMenuView        ← workout type picker
        └─ WorkoutTypeMenu ← confirm selection
            └─ WorkoutPreviewView  ← static step breakdown
                └─ StepRunnerView  ← step-by-step runner
```

Navigation: UP/DOWN for selection, ENTER/START to confirm, BACK to pop.
Touch: tap list items (main menu), tap buttons (confirm screen), tap regions (preview/runner).

## UI

All screens use AMOLED-optimized layout:
- Background: pure black (#000000)
- Primary text: white
- Accent: amber (#D4A84B)
- Dim: grey (#888888)
- Dividers: dark grey (#444444)
- Font: system fonts (FONT_SYSTEM_LARGE/MEDIUM/SMALL/TINY)
- High contrast, no emoji, no icons
- 454x454 round viewport (clipped edges considered)

## Workout Types (Static)

All workout data is hardcoded for Phase 3A.1 — no backend integration.

**Easy:**
- Easy Run — 40 min — 4:30–5:00/km

**Tempo:**
1. Warmup — 12 min — Zone 1–2
2. Tempo — 25 min — Zone 3–4
3. Cooldown — 10 min — Zone 1–2

**Threshold:**
1. Warmup — 12 min — Zone 1–2
2. Threshold — 8 min — Zone 4
3. Recovery — 2 min — Zone 1–2
4. Threshold — 8 min — Zone 4
5. Cooldown — 10 min — Zone 1–2

**Long Run:**
- Long Run — 75 min — Zone 2–3

**VO2max:**
1. Warmup — 15 min — Zone 1
2. 6x VO2max — 90 sec — Zone 4–5
3. 6x Recovery — 60 sec — Zone 1–2
4. Cooldown — 10 min — Zone 1

## Build

### SDK

Garmin Connect IQ SDK 4.x required.
Download: https://developer.garmin.com/connect-iq/sdk/

On Linux (headless):

```bash
# Extract SDK
unzip connectiq-sdk-manager-*.zip -d ~/ciq-sdk
export CIQ_HOME=~/ciq-sdk
export PATH=$CIQ_HOME/bin:$PATH

# Download device (fr965)
$CIQ_HOME/bin/monkeyc --help   # verify SDK works

# Build .prg
$CIQ_HOME/bin/monkeyc \
  -f monkey.jungle \
  -o bin/Pacer.prg \
  -d fr965 \
  -y /path/to/developer_key.der
```

On Mac with SDK Manager GUI:

1. Open Connect IQ SDK Manager
2. Install SDK 4.2.x
3. Install device: Forerunner 965
4. Open project in VS Code with Monkey C extension
5. Build → Run on Simulator

### Build Output

```
bin/Pacer.prg      ← compiled watch app
```

## Simulator

```bash
$CIQ_HOME/bin/simulator -d fr965
```

Test sequence:
1. App launches → main menu with PACER title
2. UP/DOWN scrolls through 5 workout types
3. ENTER on Easy → confirmation screen
4. ENTER on "View" → Easy Run preview screen
5. ENTER on preview → StepRunner shows "Easy Run — 40 min — 4:30–5:00/km"
6. ENTER again → "Done!" completion screen
7. BACK repeatedly → returns through each screen to main menu
8. BACK from main menu → app exits cleanly
9. No crashes at any point

## Sideload to Real Device (FR965)

1. Build `bin/Pacer.prg` (see Build section above)
2. Connect FR965 via USB — appears as removable drive
3. Copy `Pacer.prg` to `GARMIN/APPS/` on the device
4. Safely eject the device
5. On the watch: hold START → Apps → find "Pacer"
6. If app doesn't appear:
   - Check firmware version supports CIQ 4.2 (Settings → System → About)
   - Check `GARMIN/APPS/` contains the file
   - Check developer_key.der is valid
   - Check manifest.xml `<iq:product id="fr965"/>` matches device

## Technical Notes

### Why Watch App (not Data Field)

Watch App allows multi-screen custom UI with full control over display.
Data Fields are single-screen overlays inside native activities —
insufficient for workout type selection and step runner.

### Custom Step Viewer vs Native Workout

MVP uses a custom step-by-step viewer built entirely in Monkey C.
Native Garmin structured workouts (FIT files, PersistedContent) require
APIs that need deeper testing — deferred to Phase 3B.

**Known API to investigate (Phase 3B/3C):**
`DataField.setWorkout()` in Connect IQ API 5.2.0.
This may allow launching native structured workouts from a data field.
Needs SDK 5.2.x and FR965 firmware compatibility testing.
Not used in this phase.

### Communication Model

Current: no backend communication. All data is static/hardcoded.

Planned (Phase 3B):
- `Toybox.Communications.makeWebRequest` → HTTPS → Pacer backend
- Communication goes through Garmin Connect Mobile (phone acts as proxy)
- Device linking via 6-digit code: no OAuth
- `Toybox.Properties` stores device token
- API: GET `/api/watch/recommendations`, POST `/api/watch/workouts/generate`

### Not Used

- No Sensor API (no HR/GPS at MVP stage)
- No FITContributor (no activity recording)
- No ANT (no sensor pairing)
- No native workout launch (FIT PersistedContent)
- No Garmin Training API (needs partner access)
- No Strava integration

### Pacer Backend

This watch app is a separate project from the Pacer web dashboard.
No backend changes needed for Phase 3A.1.
Backend endpoints designed but NOT implemented — see Phase 3A.1 completion report.

## File Structure

```
pacer-connectiq/
├── manifest.xml              ← app manifest (devices, permissions, entry point)
├── monkey.jungle             ← build config (source files, device target)
├── bin/                      ← build output
│   └── Pacer.prg            ← compiled watch app (after build)
├── source/
│   ├── PacerApp.mc          ← App entry point
│   ├── MainMenuView.mc      ← Workout type selector (UP/DOWN/ENTER)
│   ├── WorkoutTypeMenu.mc   ← Confirmation screen (View/Back)
│   ├── WorkoutPreviewView.mc← Static workout step breakdown
│   └── StepRunnerView.mc    ← Step-by-step workout runner
├── resources/
│   └── strings.xml          ← App name resource
└── README.md                ← this file
```

## Phase Roadmap

**3A.1 (current):** Skeleton PoC. Static data. Menu navigation. Step viewer.
No backend, no pairing, no native workout, no Data Field.

**3B (next):** Backend integration + device pairing.
- makeWebRequest to Pacer API
- 6-digit code linking (POST `/api/watch/link/start`, POST `/api/watch/link/confirm`)
- Properties for device token
- Dynamic workout data from recommendations
- Real timer with Toybox.Timer

**3C:** Native workout export + activity recording.
- FIT PersistedContent for structured workouts
- setWorkout() research (API 5.2.0 feasibility)
- Data Field overlay for live activity screen
- FitContributor for recording workout data

**3D:** Polish + production.
- Error handling for network failures
- Offline fallback with cached workouts
- Multi-device support (beyond FR965)
- Connect IQ store submission
