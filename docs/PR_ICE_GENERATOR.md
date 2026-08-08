# Pull Request: Feature - Procedural Infinite Frozen Lake Generator (`IceGenerator`)

## 📝 Overview
Implements the **Procedural Infinite Frozen Lake & Track Spawner** component (`IceGenerator`) for *Thin Ice Express*.

Instead of fixed static ice tiles, `IceGenerator` dynamically chunks and populates a wide 15-tile grid ahead of the train as it drives forward.
It procedurally generates solid ice, thin ice (pre-cracked stage 1/2), and open water holes while despawning distant tiles behind the train to maintain a rock-solid 60 FPS.

---

## 📁 Files Created / Modified
* `[NEW]` [`ice_generator.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_generator.gd): Chunking and spawning manager node.
* `[NEW]` [`ice_generator.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_generator.tscn): Generator scene node.
* `[NEW]` [`tests/run_ice_generator_tests.py`](file:///Users/manoj-axelsson/Documents/thin-ice-express/tests/run_ice_generator_tests.py): Automated test suite.
* `[MODIFY]` [`main.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/main.tscn): Replaced 3 static ice tiles with `IceGenerator`.

---

## 🏷️ Naming Conventions Followed
* **Scene & Script Files:** `snake_case` (`ice_generator.gd`, `ice_generator.tscn`)
* **Node Names:** `PascalCase` (`IceGenerator`)
* **Exported Variables:** `snake_case` (`spawn_rows_ahead`, `thin_ice_chance`, `water_gap_chance`)
