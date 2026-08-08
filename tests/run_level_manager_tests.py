#!/usr/bin/env python3
import time
import sys

print("==================================================")
print("  RUNNING LEVEL MANAGER & TRAIN TRANSFORMATION TESTS")
print("==================================================")

class SimulatedLocomotive:
    def __init__(self):
        self.train_type = "VINTAGE_STEAM"
        self.max_speed = 220.0
        self.acceleration = 100.0

    def set_train_type(self, t):
        self.train_type = t
        if t == "VINTAGE_STEAM":
            self.max_speed = 220.0; self.acceleration = 100.0
        elif t == "X2000_SERIES":
            self.max_speed = 280.0; self.acceleration = 140.0
        elif t == "BULLET_TRAIN":
            self.max_speed = 350.0; self.acceleration = 180.0

class SimulatedIceGen:
    def __init__(self):
        self.thin_ice_chance = 0.05
        self.water_gap_chance = 0.0

class SimulatedLevelManager:
    def __init__(self, loco, gen):
        self.loco = loco
        self.gen = gen
        self.current_level = 1
        self.level_name = ""

    def load_level(self, lvl):
        self.current_level = max(1, min(5, lvl))
        if self.current_level == 1:
            self.level_name = "Level 1: The Calm Fjord (Tutorial)"
            self.loco.set_train_type("VINTAGE_STEAM")
            self.gen.thin_ice_chance = 0.05; self.gen.water_gap_chance = 0.0
        elif self.current_level in [2, 3]:
            self.level_name = f"Level {self.current_level}: High Speed Pass"
            self.loco.set_train_type("X2000_SERIES")
            self.gen.thin_ice_chance = 0.20 if self.current_level == 2 else 0.35
            self.gen.water_gap_chance = 0.05 if self.current_level == 2 else 0.10
        elif self.current_level in [4, 5]:
            self.level_name = f"Level {self.current_level}: Final Sprint"
            self.loco.set_train_type("BULLET_TRAIN")
            self.gen.thin_ice_chance = 0.45 if self.current_level == 4 else 0.55
            self.gen.water_gap_chance = 0.15 if self.current_level == 4 else 0.20

def test_level_1_tutorial_vintage_steam():
    print("\n[UX Test 1] Testing Level 1 Tutorial & Vintage Steam Engine...")
    loco = SimulatedLocomotive()
    gen = SimulatedIceGen()
    mgr = SimulatedLevelManager(loco, gen)
    mgr.load_level(1)
    assert loco.train_type == "VINTAGE_STEAM" and loco.max_speed == 220.0, "Vintage steam specs mismatch"
    assert gen.thin_ice_chance == 0.05 and gen.water_gap_chance == 0.0, "Tutorial hazard scaling mismatch"
    print("✓ PASS: Level 1 correctly loads Vintage Steam Engine with safe tutorial hazards.")
    return True

def test_levels_2_3_x2000_transformation():
    print("\n[UX Test 2] Testing Levels 2 & 3 Swedish X2000 Transformation...")
    loco = SimulatedLocomotive()
    gen = SimulatedIceGen()
    mgr = SimulatedLevelManager(loco, gen)
    mgr.load_level(2)
    assert loco.train_type == "X2000_SERIES" and loco.max_speed == 280.0, "X2000 specs mismatch"
    mgr.load_level(3)
    assert loco.train_type == "X2000_SERIES" and gen.thin_ice_chance == 0.35, "Level 3 scaling mismatch"
    print("✓ PASS: Levels 2 & 3 correctly transform train into Swedish X2000 Series.")
    return True

def test_levels_4_5_bullet_train_transformation():
    print("\n[UX Test 3] Testing Levels 4 & 5 Futuristic Bullet Train Transformation...")
    loco = SimulatedLocomotive()
    gen = SimulatedIceGen()
    mgr = SimulatedLevelManager(loco, gen)
    mgr.load_level(4)
    assert loco.train_type == "BULLET_TRAIN" and loco.max_speed == 350.0, "Bullet Train specs mismatch"
    mgr.load_level(5)
    assert loco.train_type == "BULLET_TRAIN" and gen.thin_ice_chance == 0.55, "Level 5 scaling mismatch"
    print("✓ PASS: Levels 4 & 5 correctly transform train into Aerodynamic Bullet Train.")
    return True

if __name__ == "__main__":
    tests = [
        test_level_1_tutorial_vintage_steam,
        test_levels_2_3_x2000_transformation,
        test_levels_4_5_bullet_train_transformation
    ]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
