#!/usr/bin/env python3
import time
import sys

print("==================================================")
print("   RUNNING PASSENGER UI UX & STRESS TEST SUITE   ")
print("==================================================")

class SimulatedPassengerUI:
    def __init__(self, max_comfort=100.0, recovery_rate=2.0):
        self.max_comfort = max_comfort
        self.recovery_rate = recovery_rate
        self.current_comfort = max_comfort
        self.is_game_over = False
        self.comfort_changed_signals = []
        self.woken_up_signals = 0

    def apply_jolt(self, amount):
        if self.is_game_over:
            return
        self.current_comfort = max(0.0, self.current_comfort - amount)
        self.comfort_changed_signals.append(self.current_comfort)
        if self.current_comfort <= 0.0:
            self.trigger_game_over()

    def process(self, delta):
        if self.is_game_over:
            return
        if self.current_comfort < self.max_comfort:
            self.current_comfort = min(self.max_comfort, self.current_comfort + self.recovery_rate * delta)
            self.comfort_changed_signals.append(self.current_comfort)

    def trigger_game_over(self):
        self.is_game_over = True
        self.woken_up_signals += 1

    def get_status_text(self):
        if self.is_game_over:
            return "😱 WOKEN UP! Passengers Panicked!"
        ratio = self.current_comfort / self.max_comfort
        if ratio > 0.7:
            return "😴 Sleeping Soundly (zZz...)"
        elif ratio > 0.35:
            return "😳 Restless! Ride is Bumpy!"
        else:
            return "😰 About to Wake Up! DANGER!"

def test_ux_comfort_decay_and_status():
    print("\n[UX Test 1] Testing Passenger Comfort Decay & Status Text...")
    ui = SimulatedPassengerUI()
    assert ui.current_comfort == 100.0 and ui.get_status_text() == "😴 Sleeping Soundly (zZz...)", "Initial state failed"
    
    ui.apply_jolt(40.0) # 60% remaining
    assert ui.current_comfort == 60.0 and ui.get_status_text() == "😳 Restless! Ride is Bumpy!", "Medium comfort failed"
    
    ui.apply_jolt(40.0) # 20% remaining
    assert ui.current_comfort == 20.0 and ui.get_status_text() == "😰 About to Wake Up! DANGER!", "Low comfort failed"
    
    ui.apply_jolt(30.0) # 0% remaining -> Game Over
    assert ui.current_comfort == 0.0 and ui.is_game_over and "WOKEN UP" in ui.get_status_text(), "Game over state failed"
    print("✓ PASS: Comfort status thresholds and text feedback work seamlessly.")
    return True

def test_ux_recovery_mechanic():
    print("\n[UX Test 2] Testing Passenger Comfort Recovery Over Time...")
    ui = SimulatedPassengerUI(recovery_rate=10.0)
    ui.apply_jolt(50.0)
    assert ui.current_comfort == 50.0, "Jolt application failed"
    ui.process(2.0) # 2s * 10/s = +20 -> 70
    assert ui.current_comfort == 70.0, f"Expected 70.0, got {ui.current_comfort}"
    print("✓ PASS: Passenger comfort recovers over smooth stretches of track.")
    return True

def test_stress_rapid_jolts():
    print("\n[Stress Test 1] Simulating 10,000 Rapid Jolt Events...")
    ui = SimulatedPassengerUI()
    t0 = time.perf_counter()
    for _ in range(10000):
        ui.apply_jolt(0.01)
    elapsed = (time.perf_counter() - t0) * 1000.0
    print(f"✓ PASS: 10,000 jolt applications completed in {elapsed:.2f} ms.")
    return True

def test_stress_boundary_clamps():
    print("\n[Stress Test 2] Testing Boundary Safety Clamps (Negative & Over 100%)...")
    ui = SimulatedPassengerUI()
    ui.apply_jolt(500.0)
    assert ui.current_comfort == 0.0, "Negative clamp failed"
    ui.is_game_over = False
    ui.process(500.0)
    assert ui.current_comfort == 100.0, "Max clamp failed"
    print("✓ PASS: Comfort values stay strictly bounded within [0, 100].")
    return True

if __name__ == "__main__":
    tests = [
        test_ux_comfort_decay_and_status,
        test_ux_recovery_mechanic,
        test_stress_rapid_jolts,
        test_stress_boundary_clamps
    ]
    passed = 0
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
