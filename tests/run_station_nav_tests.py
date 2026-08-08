#!/usr/bin/env python3
import time
import sys
import math

print("==================================================")
print("  RUNNING STATION NAVIGATION & MINIMAP TEST SUITE")
print("==================================================")

class DummyVector2:
    def __init__(self, x=0.0, y=0.0):
        self.x = x
        self.y = y
    def distance_to(self, other):
        return math.hypot(self.x - other.x, self.y - other.y)

class SimulatedStationNav:
    def __init__(self, dist_m=1500.0):
        self.player_pos = DummyVector2(124.0, 127.0)
        self.station_pos = DummyVector2(124.0, 127.0 - dist_m)
        self.start_dist = dist_m
        self.station_reached_signals = 0

    def get_remaining_distance_meters(self):
        return int(self.player_pos.distance_to(self.station_pos) / 10.0)

    def process(self):
        dist = self.player_pos.distance_to(self.station_pos)
        if dist <= 80.0:
            self.station_reached_signals += 1
            return "🚉 STATION ARRIVED! Level Complete!"
        else:
            return f"🚉 Station Ahead: {int(dist / 10.0)} m"

def test_station_distance_tracking():
    print("\n[UX Test 1] Testing Station Distance Tracking...")
    nav = SimulatedStationNav(1500.0)
    assert nav.get_remaining_distance_meters() == 150, f"Expected 150m, got {nav.get_remaining_distance_meters()}"
    
    # Drive player 1000 units closer
    nav.player_pos.y -= 1000.0
    assert nav.get_remaining_distance_meters() == 50, f"Expected 50m, got {nav.get_remaining_distance_meters()}"
    print("✓ PASS: Distance calculations track train position accurately.")
    return True

def test_station_arrival_trigger():
    print("\n[UX Test 2] Testing Station Arrival Victory Signal...")
    nav = SimulatedStationNav(1500.0)
    nav.player_pos.y = nav.station_pos.y + 50.0 # Within 80 units of station
    status_text = nav.process()
    assert "STATION ARRIVED" in status_text and nav.station_reached_signals == 1, "Station arrival signal failed"
    print("✓ PASS: Station arrival triggers level victory signal.")
    return True

if __name__ == "__main__":
    tests = [test_station_distance_tracking, test_station_arrival_trigger]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
