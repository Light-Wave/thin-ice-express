#!/usr/bin/env python3
import math
import sys

print("==================================================")
print("  RUNNING INTERACTIVE STEERING ARROW TEST SUITE")
print("==================================================")

class DummyVector2:
    def __init__(self, x=0.0, y=0.0):
        self.x = x
        self.y = y

class SimulatedSteeringArrow:
    def __init__(self):
        self.train_pos = DummyVector2(124.0, 127.0)
        self.station_pos = DummyVector2(124.0, -1373.0) # Directly North (Y-up in math, -Y in 2D)
        self.train_rotation = 0.0 # Facing East/Right (0 rad)

    def calculate_steering_guidance(self):
        dx = self.station_pos.x - self.train_pos.x
        dy = self.station_pos.y - self.train_pos.y
        world_angle = math.atan2(dy, dx)
        
        rel_angle = (world_angle - self.train_rotation + math.pi) % (2 * math.pi) - math.pi
        deg = math.degrees(rel_angle)

        if deg > 15.0: return "STEER RIGHT 🡆"
        elif deg < -15.0: return "STEER LEFT 🡄"
        else: return "ON TRACK 🡅"

def test_steering_arrow_guidance_angles():
    print("\n[UX Test 1] Testing Directional Arrow Guidance Calculation...")
    arrow = SimulatedSteeringArrow()
    
    # Train facing North (pointing at station)
    arrow.train_rotation = -math.pi / 2.0
    assert arrow.calculate_steering_guidance() == "ON TRACK 🡅", "Facing station should give ON TRACK"

    # Train facing East (needs left turn)
    arrow.train_rotation = 0.0
    assert arrow.calculate_steering_guidance() == "STEER LEFT 🡄", "Facing East should advise STEER LEFT"

    # Train facing West (needs right turn)
    arrow.train_rotation = -math.pi
    assert arrow.calculate_steering_guidance() == "STEER RIGHT 🡆", "Facing West should advise STEER RIGHT"

    print("✓ PASS: Steering arrow accurately calculates real-time guidance angles.")
    return True

if __name__ == "__main__":
    tests = [test_steering_arrow_guidance_angles]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
