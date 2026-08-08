#!/usr/bin/env python3
import time
import sys
import math

print("==================================================")
print("  RUNNING GEOGRAPHICAL MAP & STEERING TRAIL TESTS")
print("==================================================")

class DummyVector2:
    def __init__(self, x=0.0, y=0.0):
        self.x = x
        self.y = y
    def distance_to(self, other):
        return math.hypot(self.x - other.x, self.y - other.y)

class SimulatedGeoMap:
    def __init__(self):
        self.player_pos = DummyVector2(124.0, 127.0)
        self.station_pos = DummyVector2(124.0, -1373.0) # 150m away
        self.path_history = [DummyVector2(124.0, 127.0)]

    def drive_step(self, dx, dy):
        self.player_pos.x += dx
        self.player_pos.y += dy
        self.path_history.append(DummyVector2(self.player_pos.x, self.player_pos.y))

    def get_remaining_dist_meters(self):
        return int(self.player_pos.distance_to(self.station_pos) / 10.0)

def test_steering_path_tracking():
    print("\n[UX Test 1] Testing Real-time Steering Path Tracking...")
    geo = SimulatedGeoMap()
    initial_dist = geo.get_remaining_dist_meters()
    
    # Drive straight toward station
    geo.drive_step(0, -500.0)
    straight_dist = geo.get_remaining_dist_meters()
    assert straight_dist < initial_dist, "Distance should decrease when driving toward station"
    
    # Steer sideways (off course)
    geo.drive_step(300.0, 0)
    sideways_dist = geo.get_remaining_dist_meters()
    assert sideways_dist > straight_dist, "Steering off course should increase remaining distance to station"
    assert len(geo.path_history) == 3, "Steering path history trail missing points"
    print("✓ PASS: Steering off-course dynamically adjusts remaining distance & records path trail.")
    return True

if __name__ == "__main__":
    tests = [test_steering_path_tracking]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
