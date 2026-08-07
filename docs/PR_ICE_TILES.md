# Pull Request: Feature - Cracking Ice Tiles (`IceTile`)

## 📝 Overview
Implements the core **Cracking Ice Tile** component (`IceTile`) for *Thin Ice Express*.

When a train enters an `IceTile`, the tile begins cracking in stages (`0` -> `1` -> `2` -> `3`). Staying on the tile or landing heavily advances the crack level until the ice breaks into open water.

---

## 📁 Files Created / Modified
* `[NEW]` [`ice_tile.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_tile.gd): Simple `Area2D` script managing crack progression and visual states.
* `[NEW]` [`ice_tile.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_tile.tscn): Reusable Godot scene for an ice tile.
* `[MODIFY]` [`main.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/main.tscn): Added 3 test `IceTile` instances along the locomotive's initial track.

---

## 🏷️ Naming Conventions Followed
* **Scene & Script Files:** `snake_case` (`ice_tile.gd`, `ice_tile.tscn`)
* **Node Names:** `PascalCase` (`IceTile`, `Sprite2D`, `CollisionShape2D`)
* **Signals:** `snake_case` (`ice_cracked`, `ice_broken`)
* **Exported Variables:** `snake_case` (`max_cracks`, `time_between_cracks`)

---

## ⚡ Integration Instructions for Collaborator A (Train / Physics Developer)
1. **Detecting Water / Broken Ice:**
   Listen to the `ice_broken` signal on an `IceTile` instance:
   ```gdscript
   ice_tile.ice_broken.connect(_on_ice_broken)
   ```
2. **Checking Crack Status:**
   Access `ice_tile.is_broken` (boolean) or listen to `ice_cracked(crack_level: int)`.
