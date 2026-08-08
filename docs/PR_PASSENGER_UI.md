# Pull Request: Feature - Passenger Comfort & "Bump-o-Meter" UI (`PassengerUI`)

## 📝 Overview
Implements the **Passenger Comfort ("Bump-o-Meter") HUD UI** component (`PassengerUI`) for *Thin Ice Express*.

The UI displays a live comfort progress bar and passenger status text (`😴 Sleeping Soundly` -> `😳 Restless` -> `😰 DANGER` -> `😱 WOKEN UP!`).
Bumps, sharp turns, collisions, or cracking ice reduce passenger comfort. If comfort reaches 0%, the `passengers_woken_up` signal fires (Game Over).

---

## 📁 Files Created / Modified
* `[NEW]` [`passenger_ui.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/passenger_ui.gd): CanvasLayer script handling comfort bar, recovery over time, and game over triggers.
* `[NEW]` [`passenger_ui.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/passenger_ui.tscn): Reusable UI overlay scene.
* `[NEW]` [`tests/run_passenger_ui_tests.py`](file:///Users/manoj-axelsson/Documents/thin-ice-express/tests/run_passenger_ui_tests.py): Automated test suite.
* `[MODIFY]` [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd): Connected turn velocity to `apply_jolt(amount)` and added Spacebar test bump key.
* `[MODIFY]` [`main.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/main.tscn): Added `PassengerUI` overlay to the main game scene.

---

## 🏷️ Naming Conventions Followed
* **Scene & Script Files:** `snake_case` (`passenger_ui.gd`, `passenger_ui.tscn`)
* **Node Names:** `PascalCase` (`PassengerUI`, `ProgressBar`, `StatusLabel`)
* **Signals:** `snake_case` (`passengers_woken_up`, `comfort_changed`)
* **Exported Variables:** `snake_case` (`max_comfort`, `comfort_recovery_rate`)

---

## ⚡ How to Trigger Bumps in Code
```gdscript
# Apply a bump/jolt to passenger comfort (e.g. from an obstacle collision or jump landing)
passenger_ui.apply_jolt(15.0)

# Listen for game over signal
passenger_ui.passengers_woken_up.connect(_on_passengers_woken_up)
```
