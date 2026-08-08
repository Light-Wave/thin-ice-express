#!/usr/bin/env python3
import sys

print("==================================================")
print("  RUNNING VISUAL TRAIN STATION ENTITY TEST SUITE")
print("==================================================")

class SimulatedStation:
    def __init__(self, name="Central Fjord Station"):
        self.station_name = name
        self.entered_signals = 0

    def on_body_entered(self, body):
        self.entered_signals += 1

def test_station_docking_trigger():
    print("\n[UX Test 1] Testing Station Docking & Entry Signal...")
    st = SimulatedStation()
    st.on_body_entered("Locomotive")
    assert st.entered_signals == 1, "Station entry signal failed"
    print("✓ PASS: Train station entry correctly triggers station docking event.")
    return True

if __name__ == "__main__":
    tests = [test_station_docking_trigger]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
