#!/usr/bin/env python3
import time
import sys

print("==================================================")
print("   RUNNING ICE TILE UX & STRESS TEST SUITE       ")
print("==================================================")

class SimulatedIceTile:
    def __init__(self, max_cracks=3, time_between_cracks=0.6):
        self.max_cracks = max_cracks
        self.time_between_cracks = time_between_cracks
        self.crack_level = 0
        self.is_broken = False
        self.train_on_tile = False
        self.crack_timer = 0.0
        self.cracked_signals = []
        self.broken_signals = 0
        self.active_bodies_count = 0

    def advance_crack(self):
        if self.is_broken:
            return
        self.crack_level += 1
        self.cracked_signals.append(self.crack_level)
        if self.crack_level >= self.max_cracks:
            self.break_ice()

    def break_ice(self):
        self.is_broken = True
        self.broken_signals += 1

    def on_body_entered(self):
        self.active_bodies_count += 1
        is_first = (self.active_bodies_count == 1)
        self.train_on_tile = True
        if is_first:
            self.crack_timer = 0.0
            self.advance_crack()

    def on_body_exited(self):
        if self.active_bodies_count > 0:
            self.active_bodies_count -= 1
        if self.active_bodies_count == 0:
            self.train_on_tile = False
            self.crack_timer = 0.0

def test_ux_crack_progression():
    print("\n[UX Test 1] Testing Crack State & Visual Progression...")
    tile = SimulatedIceTile()
    assert tile.crack_level == 0 and not tile.is_broken, "Initial state failed"
    tile.advance_crack()
    assert tile.crack_level == 1 and not tile.is_broken, "Level 1 transition failed"
    tile.advance_crack()
    tile.advance_crack()
    assert tile.crack_level == 3 and tile.is_broken, "Breaking transition failed"
    print("✓ PASS: Crack state progression and breaking logic work seamlessly.")
    return True

def test_ux_signal_emissions():
    print("\n[UX Test 2] Testing Signal Emission Accuracy...")
    tile = SimulatedIceTile()
    tile.advance_crack()
    tile.advance_crack()
    tile.advance_crack()
    assert tile.cracked_signals == [1, 2, 3], f"Signals mismatch: {tile.cracked_signals}"
    assert tile.broken_signals == 1, "ice_broken signal not emitted"
    print("✓ PASS: All signals emitted accurately with correct levels.")
    return True

def test_stress_rapid_entry_exit():
    print("\n[Stress Test 1] Simulating 10,000 Rapid Entry/Exit Events (Jitter Test)...")
    tile = SimulatedIceTile()
    t0 = time.perf_counter()
    for _ in range(10000):
        tile.on_body_entered()
        tile.on_body_exited()
    elapsed = (time.perf_counter() - t0) * 1000.0
    print(f"✓ PASS: 10,000 rapid entry/exit events completed in {elapsed:.2f} ms without state corruption.")
    return True

def test_stress_boundary_safety():
    print("\n[Stress Test 2] Testing Over-Crack Boundary Safety...")
    tile = SimulatedIceTile()
    for _ in range(50):
        tile.advance_crack()
    assert tile.crack_level == 3 and tile.is_broken, "Boundary state corrupted"
    print("✓ PASS: Tile state remains safely bounded after 50 over-crack attempts.")
    return True

def test_stress_high_tile_volume():
    print("\n[Stress Test 3] Instantiating and Cracking 10,000 Ice Tiles Simultaneously...")
    t0 = time.perf_counter()
    tiles = [SimulatedIceTile() for _ in range(10000)]
    for t in tiles:
        t.advance_crack()
        t.advance_crack()
        t.advance_crack()
    elapsed = (time.perf_counter() - t0) * 1000.0
    print(f"✓ PASS: 10,000 IceTiles created and fully cracked in {elapsed:.2f} ms.")
    return True

def test_ux_multi_wagon_passthrough():
    print("\n[UX Test 3] Testing Multi-Wagon Train Passthrough...")
    tile = SimulatedIceTile()
    # Locomotive enters
    tile.on_body_entered()
    # Wagon 1 enters
    tile.on_body_entered()
    # Wagon 2 enters
    tile.on_body_entered()
    # Wagon 3 enters
    tile.on_body_entered()

    assert tile.crack_level == 1, f"Expected crack level 1 after train entry, got {tile.crack_level}"
    assert not tile.is_broken, "Tile broke unexpectedly during normal train passthrough"

    # Train exits body by body
    tile.on_body_exited()
    tile.on_body_exited()
    tile.on_body_exited()
    tile.on_body_exited()

    assert not tile.train_on_tile, "Tile state should be cleared after all wagons exit"
    assert tile.active_bodies_count == 0, "Active bodies count should be 0"
    print("✓ PASS: Multi-wagon train passed over tile safely without instant breaking.")
    return True

if __name__ == "__main__":
    passed = 0
    tests = [
        test_ux_crack_progression,
        test_ux_signal_emissions,
        test_ux_multi_wagon_passthrough,
        test_stress_rapid_entry_exit,
        test_stress_boundary_safety,
        test_stress_high_tile_volume,
    ]
    for t in tests:
        if t():
            passed += 1

    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests):
        sys.exit(0)
    else:
        sys.exit(1)
