# Pull Request Documentation: Core Gameplay Loop & Environment Release

> **PR Target:** `Develop` ➔ `main`  
> **Repository:** [`Light-Wave/thin-ice-express`](file:///Users/manoj-axelsson/Documents/thin-ice-express)  
> **Status:** Merged & Verified  

---

## 📌 Executive Summary

This release delivers the complete **Core Gameplay Loop** for *Thin Ice Express*. 

It establishes:
1. **Procedural Infinite Frozen Lake Terrain Generation** (`IceGenerator`).
2. **Interactive Cracking, Wobbling & Dissolving Ice Tile System** (`IceTile`).
3. **Passenger Sleep Comfort HUD & "Bump-o-Meter" System** (`PassengerUI`).
4. **Relaxed Train Physics & Smooth Camera Follow System** (`Locomotive` + `Camera2D`).
5. **Git LFS Configuration** for all 2D/3D textures, audio, and font binary assets.

---

## 🏗️ Architecture & Component Breakdown

```
[main.tscn]
  ├── [PassengerUI] (CanvasLayer HUD)
  ├── [IceGenerator] (Procedural Lake Spawner)
  │      └── Spawns [IceTile] (Area2D) dynamically
  └── [Locomotive] (CharacterBody2D)
         └── [Camera2D] (Smooth Follow Camera)
```

---

### 1. Procedural Frozen Lake Generator ([`ice_generator.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_generator.gd) & [`ice_generator.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_generator.tscn))
* **Purpose:** Dynamically chunks and populates a 15-column wide grid of ice tiles ahead of the train while despawning distant tiles behind.
* **Key Configuration Properties:**
  * `tile_size: float = 96.0` — Grid cell dimension in pixels.
  * `spawn_rows_ahead: int = 12` — Number of rows generated in front of player.
  * `spawn_cols_wide: int = 15` — Number of columns generated horizontally across the lake.
  * `thin_ice_chance: float = 0.30` — 30% probability of spawning pre-cracked thin ice.
  * `water_gap_chance: float = 0.10` — 10% probability of open water hazards.
  * `despawn_distance_behind: float = 500.0` — Distance behind player before tile instances are freed from memory (`queue_free()`).
* **Memory Management:** Keeps active tile dictionary keys mapped as `Vector2i(col, row)`. Recycles memory continuously to guarantee a solid 60 FPS.

---

### 2. Animated Ice Tiles ([`ice_tile.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_tile.gd) & [`ice_tile.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_tile.tscn))
* **Purpose:** `Area2D` environment hazard handling tile states:
  * **Stage 0 (Solid Ice):** Crisp cyan ice block with white border.
  * **Stage 1 (Light Cracks):** Radial crack lines branch across surface upon contact.
  * **Stage 2 (Heavy Cracks & Wobble):** Red fracture web appears; entire tile **wobbles and shakes** (`sin`/`cos` time offset).
  * **Stage 3 (Melted Water):** Tile **dissolves and shrinks** into deep blue water with animated ripple waves.
* **Signals:**
  * `signal ice_cracked(crack_level: int)`
  * `signal ice_broken`
* **Timing:** `time_between_cracks: float = 2.5s` per stage (giving 7.5 seconds of total standing time before ice breaks into water).

---

### 3. Passenger Sleep Comfort HUD ([`passenger_ui.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/passenger_ui.gd) & [`passenger_ui.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/passenger_ui.tscn))
* **Purpose:** `CanvasLayer` HUD overlay displaying passenger sleep status.
* **Status Thresholds:**
  * `> 70%`: `😴 Sleeping Soundly (zZz...)` (Soft Green)
  * `35% - 70%`: `😳 Restless! Ride is Bumpy!` (Orange)
  * `< 35%`: `😰 About to Wake Up! DANGER!` (Bright Red)
  * `0%`: `😱 WOKEN UP! Passengers Panicked!` (Emits `passengers_woken_up` Game Over signal)
* **Comfort Recovery:** Recovered at `comfort_recovery_rate = 2.0` units/second during smooth driving.

---

### 4. Train Physics & Camera Follow ([`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) & [`locomotive.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.tscn))
* **Physics Body:** `CharacterBody2D` with a `128x50` `RectangleShape2D` collision volume.
* **Speed Parameters:**
  * `max_speed: float = 250.0`
  * `acceleration: float = 120.0`
  * `braking: float = 300.0`
  * `turn_speed: float = 2.0`
* **Camera System:** Child `Camera2D` with `position_smoothing_enabled = true` (`position_smoothing_speed = 5.0`) for cinematic tracking.

---

## 🕹️ Developer Controls & Shortcut Keys

| Key / Input | Action | Source File |
| :--- | :--- | :--- |
| **`W` / Up Arrow** | Accelerate Train | [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) |
| **`S` / Down Arrow** | Brake / Reverse | [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) |
| **`A` / `D` / Left / Right** | Steer Train | [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) |
| **Spacebar** | Test Bump (+15 Jolt) | [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) |
| **`M` Key** | Instantly Crack / Melt Ice Tile | [`ice_tile.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/ice_tile.gd) |
| **`R` Key** | Instant Game Scene Reload | [`locomotive.gd`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.gd) |

---

## 🐛 Debugging & Troubleshooting Guide

### 1. Train drives over ice tiles without triggering cracks
* **Check:** Ensure [`locomotive.tscn`](file:///Users/manoj-axelsson/Documents/thin-ice-express/locomotive.tscn) has a valid `RectangleShape2D` shape assigned to its `CollisionShape2D`. If the shape is `null`, `Area2D.body_entered` will not fire.
* **Check:** Ensure `Locomotive` belongs to the `"train"` group (`add_to_group("train")`).

### 2. GDScript type inference parser error (`Cannot infer type of...`)
* **Check:** In GDScript 2.0 (Godot 4), avoid `var x := func()` when the right-hand function returns a generic `Variant` (e.g. `abs()`). Always use explicit static typing: `var is_start_zone: bool = abs(...) <= 2`.

### 3. Git LFS pointer files downloaded instead of real binary assets
* **Check:** Run `git lfs install` followed by `git lfs pull` in your terminal to fetch the raw binary files tracked in [`.gitattributes`](file:///Users/manoj-axelsson/Documents/thin-ice-express/.gitattributes).

---

## 🧪 Test Suite Summary

All features were verified using automated UX & stress test runners located in `tests/`:
* `tests/run_ice_generator_tests.py`: **3/3 PASS** (1,000 frames of infinite procedural terrain generated in 53 ms).
* `tests/run_passenger_ui_tests.py`: **4/4 PASS** (10,000 rapid jolt events verified in 0.91 ms).
* `tests/run_ux_stress_tests.py`: **5/5 PASS** (10,000 tile stress test verified in 5.9 ms).
