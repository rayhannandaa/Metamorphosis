# DUADDIMAD — Interactable Objects & Monologue System

This module implements the interactable objects system for *Metamorphosis*. It provides proximity detection, visual feedback (flashing alpha and subtle interval-based shaking), state and time-of-day dependent monologues, and a self-contained testing harness.

All logic is strictly additive and contained in this folder (`Metamorphosis/DUADDIMAD/`).

---

## What's Here

```
DUADDIMAD/
├── InteractableObjectType.swift      // 9 object types, dimensions, colors, coordinates, and dialogue mappings
├── InteractableObjectNode.swift      // SpriteKit node with simple rectangle visual, flashing & interval shaking
├── InteractableManager.swift         // Scene coordinator for proximity checks, highlighting, and interaction
├── MonologueOverlayView.swift        // SwiftUI modal dialogue card displaying active monologues
├── InteractableTestingView.swift     // Interactive testing scene & harness with phase/time controls
└── README.md                         // Module documentation
```

---

## Mechanics & Narrative Mapping

### 1. Narrative & Monologue Resolution
Dialogue is mapped directly from the game narrative spreadsheet and resolved dynamically by `InteractableObjectType.monologue(for:isDaytime:)`:

| Object | Function | Larvae (`.worm`) | Pupae (`.pupa`) | Butterfly (`.butterfly`) | Time Dependent? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Bed** | Skip time | **Day:** *"Maybe I’ll sleep later when I’m tired..."*<br>**Night:** *"I’m too tired, need to go sleep..."* | **Day:** *"I can't move but I feel awake..."*<br>**Night:** *"It's warm here, I'm starting to feel sleepy..."* | *"I can just fly away and leave this room!"* | **Yes** (Day vs Night) |
| **Window** | Trigger ending | *"This room is comfortable, protected from outside world..."* | *(Inactive)* | *"Let's go fly away and feel the sunlight outside..."* | No |
| **Smartphone** | Storyline | *"7 missed call from my friend. Are they inviting me to hangout?"* | *(Inactive)* | *"7 missed call from my friend. Are they inviting me to hangout?"* | No |
| **Photo Album** | Storyline | *"Photo from my university graduation. I look so young here..."* | *(Inactive)* | *"Photo from my university graduation. I look so young here..."* | No |
| **Laptop** | Storyline | *"Email from my boss is piling up. Workplace is still as busy as ever..."* | *(Inactive)* | *"Email from my boss is piling up. Workplace is still as busy as ever..."* | No |
| **Crochet Beanie** | Storyline | *"Gift from my girlfriend for our first year anniversary. I miss her..."* | *(Inactive)* | *"Gift from my girlfriend for our first year anniversary. I miss her..."* | No |
| **Wardrobe** | Storyline | *"All my clothes are boring. I wish I could have just worn my favorite band's shirt..."* | *(Inactive)* | *"All my clothes are boring. I wish I could have just worn my favorite band's shirt..."* | No |
| **Door** | Storyline | *"It's locked... I don't want to go out and surprise my family with my sudden appearance anyway..."* | *(Inactive)* | *"I can just leave this room right now through the window..."* | No |
| **Sofa** | Supporting | *"This is strange, below this sofa is dark and cold but I feel comfortable..."* | *(Inactive)* | *"I don't feel comfortable here anymore, I want to feel the sunlight..."* | No |

### 2. Time-of-Day Integration
- References `ASARYUNGameClock.isDaytime` and `ASARYUNGameSessionController.isDaytime`:
  - **Day** (`isDaytime == true` / *Time: Disabled*): Character is awake; sleep is deferred.
  - **Night** (`isDaytime == false` / *Time: Enabled*): Character is tired; sleep/time skip is active.
- Bed is currently the only object that changes dialogue based on time of day.

### 3. Visuals & Proximity Feedback
- **Simple Rectangle Rendering**: Each object is represented by an `SKShapeNode` rectangle with distinct color, subtle border, and centered name label.
- **Proximity Detection**: Every frame, `InteractableManager.update(playerPosition:)` computes the distance to each object.
- When the character enters an object's proximity radius:
  - **Flashing**: Alpha pulses smoothly between `0.45` and `1.0` (`0.22s` cycle).
  - **Subtle Shaking**: Delicate micro-oscillations (`dx: ±1.2, dy: ±0.6`, `0.04s`) followed by a clean `1.2s` resting interval between periodic shivers.
  - Stroke border turns vibrant yellow.
- When the character leaves proximity, animations stop immediately and the node resets to resting state (`alpha = 1.0`, position at origin).

---

## How to Test

### Option A: Xcode Canvas Live Preview (Zero Code Changes)
1. Open `InteractableTestingView.swift` in Xcode.
2. Press **`Option + Command + Enter`** to open the Canvas preview.
3. Click the **Live Preview** play button.
4. Directly walk the character using the D-pad or Teleport menu, approach objects, and test interactions.

### Option B: Running in Simulator
1. In `GameViewController.swift`, temporarily change line 15:
   ```swift
   let hostingController = UIHostingController(rootView: InteractableTestingView())
   ```
2. Press **`Cmd + R`** to run in the iOS simulator.

### Test Controls Guide
- **D-Pad**: Move the player character (`YOU`) around the room.
- **Teleport (📍)**: Dropdown menu to instantly warp to any of the 9 interactable objects.
- **Phase Selector**: Switch between **Larvae (Worm)**, **Pupae**, and **Butterfly**.
- **Day / Night Toggle**: Toggle between **Day (☀️)** and **Night (🌙)** to test the Bed's time-dependent monologues.
- **INTERACT**: Action button that glows when near an object; tapping it displays the monologue dialogue card.

---

## How to Plug into Main Game (Optional)

When ready to integrate these objects into the main `RoomScene` and `GameView`:

1. **In `RoomScene.swift`**:
   ```swift
   let interactableManager = InteractableManager()

   // In buildWorldIfNeeded():
   interactableManager.setupObjects(in: self)

   // In update(_:):
   interactableManager.update(playerPosition: playerNode.position)
   ```

2. **In `GameView.swift`**:
   Connect the existing HUD `ActionButton` to trigger:
   ```swift
   scene.interactableManager.triggerInteraction(
       phase: scene.asaryunSession.phase,
       isDaytime: scene.asaryunSession.isDaytime
   )
   ```
   And add the dialogue overlay into `GameView`'s `ZStack`:
   ```swift
   if let monologue = scene.interactableManager.activeMonologue {
       MonologueOverlayView(
           objectName: monologue.objectName,
           monologueText: monologue.text,
           onDismiss: { scene.interactableManager.dismissMonologue() }
       )
   }
   ```
