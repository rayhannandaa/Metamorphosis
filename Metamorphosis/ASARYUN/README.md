# ASARYUN — Game Mechanics Module

Everything in this folder is additive. No existing file's logic was
rewritten — only a handful of small, clearly-commented hooks (search
for `// ASARYUN` / `ASARYUN:`) were added to `RoomScene.swift` and
`GameView.swift` so this module can plug into the room and the HUD.

## What's here

```
ASARYUN/
├── Core/
│   ├── ASARYUNGameConfig.swift        tunable numbers (day length, stress/hunger rates, demo length)
│   ├── ASARYUNGamePhase.swift         worm / pupa / butterfly enum
│   ├── ASARYUNGameClock.swift         day/night timing, day counter, phase progression (no SpriteKit dependency)
│   ├── ASARYUNStressManager.swift     stress bar logic
│   ├── ASARYUNHungerManager.swift     hunger bar logic
│   ├── ASARYUNPhysicsCategory.swift   physics bitmasks used for contact detection
│   └── ASARYUNDayNightController.swift  visual side: room dimming, night sky in the window, sun ray spawning
├── Nodes/
│   ├── ASARYUNSunRayNode.swift        the sweeping beam of light
│   └── ASARYUNFoodNode.swift          food pickups for the hunger loop
├── Managers/
│   └── ASARYUNGameSessionController.swift  wires all of the above to the scene; single attach point
└── UI/
    └── ASARYUNHUDOverlay.swift        SwiftUI bars + day/phase label
```

New sprites (`ASARYUN_SunRay`, `ASARYUN_NightSky`, `ASARYUN_Food`,
`ASARYUN_Pupa`, `ASARYUN_Butterfly`) were generated and added to
`Assets.xcassets/ASARYUN/`. The project uses Xcode's file-system
synchronized groups, so nothing needed to be added to the `.pbxproj` —
drop this folder in and it builds.

## How it plugs in

`RoomScene` now owns one `let asaryunSession = ASARYUNGameSessionController()`.
- `buildWorldIfNeeded()` calls `asaryunSession.attach(...)` once, right
  after the room and player exist, passing the *existing* `Window`
  object's position/size straight from `RoomConfig` — if the room
  layout changes, this keeps working automatically.
- `update(_:)` forwards its `deltaTime` to `asaryunSession.update(...)`.
- `setMovementDirection` is gated so D-pad input only drives movement
  during the worm phase (the pupa doesn't walk; the butterfly doesn't
  use the walk sprite sheet).

`GameView` adds one line — `ASARYUNHUDOverlay(session: scene.asaryunSession)` —
into its existing `ZStack`, alongside the current `HUDView`.

## Mechanics

**Day/night cycle** — `ASARYUNGameConfig.dayDuration` (80s) +
`nightDuration` (40s) = a 2-minute day, inside the requested 1–3
minute range. Every `sunRayInterval` (30s) during the day, a ray of
sunlight appears anchored at the window and pivots in place — counter-
clockwise from "/" through "|" to "\" — rather than traveling away
from the window (`ASARYUNSunRayNode.pivotSweep`). Each successive ray
that day is a little bigger and anchored a little further right than
the last (`sunRayMaxGrowth`, `sunRayMaxRightShift`), like the sun
arcing across the window as the day goes on; this is driven by how far
through the day the tick landed, so it scales automatically if
`dayDuration` changes. At night the room dims and a starry sky fades
in behind the window glass (`ASARYUN_NightSky`) — that's the "something
outside" at night.

**Stress bar** — only active in the worm phase. While the worm's
physics body keeps overlapping a sun ray's physics body, stress ticks
up by `stressIncreasePerSunHit` every `stressSunIntervalSeconds`
(2.5s) it continues to stand there — a quick pass through a ray barely
registers, but lingering in it adds up. It cools back down on its own
while the worm stays out of the light.

**Hunger bar** — only drains in the worm phase, and persists across
day/night boundaries (it no longer resets at midnight). Its drain rate
is tuned so an unfed worm goes from full to half over one full
day+night cycle. Walking into one of the food pickups scattered around
the room (`ASARYUNFoodNode`) restores it. A fresh batch of
`foodPerDay` food only spawns once every existing piece has been
eaten — not on a timer.

**3-day demo arc** — the real design is 7 days (5 worm / 1 pupa / 1
butterfly). `ASARYUNGameClock.resolvePhase()` compresses that into the
3 demo days: worm for days 1–2, pupa while day 3 is lit, butterfly
once day 3 turns to night. When entering pupa/butterfly, the worm's
sprite is swapped for the generated `ASARYUN_Pupa` / `ASARYUN_Butterfly`
texture — `PlayerNode`'s own walk-cycle code is untouched.

### Going from the 3-day demo back to the full 7-day design
1. In `ASARYUNGameConfig`, set `totalDemoDays = 7`.
2. In `ASARYUNGameClock.resolvePhase()`, swap in the full-arc mapping
   already written in the comment above that function:
   ```swift
   switch currentDay {
   case 1...5: return .worm
   case 6: return .pupa
   default: return .butterfly
   }
   ```
That's it — everything else (bars, sun rays, food, HUD) already scales
to however many days `totalDemoDays` says.
