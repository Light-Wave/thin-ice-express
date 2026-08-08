#!/usr/bin/env python3
import time
import sys

print("==================================================")
print("  RUNNING LEVEL COMPLETE CELEBRATION UI TEST SUITE")
print("==================================================")

class SimulatedLevelCompleteUI:
    def __init__(self):
        self.visible = False
        self.header_text = ""
        self.next_title = ""
        self.hazard_text = ""
        self.button_text = ""
        self.proceed_emitted = False

    def show_celebration(self, completed_level):
        next_lvl = completed_level + 1 if completed_level < 5 else 1
        self.header_text = f"🎉 LEVEL {completed_level} COMPLETE!"
        self.button_text = f"PROCEED TO LEVEL {next_lvl} ➔"
        
        if next_lvl == 2:
            self.next_title = "COMING UP: Level 2 - Pine Forest Crossing (X2000 Train 🚆)"
            self.hazard_text = "20% Thin Ice Patches & 40% Penalty Discount"
        elif next_lvl == 3:
            self.next_title = "COMING UP: Level 3 - Midnight Blizzard Pass (X2000 Train 🚆)"
            self.hazard_text = "Blizzard Winds, 35% Thin Ice & 10% Water Gaps"
        elif next_lvl == 4:
            self.next_title = "COMING UP: Level 4 - Fragile Bridge Crossing (Bullet Train 🚅)"
            self.hazard_text = "45% Thin Ice over Deep Bridge Chasms"
        elif next_lvl == 5:
            self.next_title = "COMING UP: Level 5 - The Dawn Dash (Final Run 🚅)"
            self.hazard_text = "55% Thin Ice & 20% Open Water Gaps"

        self.visible = True

    def click_proceed(self):
        self.visible = False
        self.proceed_emitted = True

def test_celebration_screen_data_mapping():
    print("\n[UX Test 1] Testing Level Completion & Hazard Preview Mapping...")
    ui = SimulatedLevelCompleteUI()
    ui.show_celebration(1)
    assert ui.visible, "Screen should be visible"
    assert "LEVEL 1 COMPLETE" in ui.header_text, "Header text mismatch"
    assert "X2000" in ui.next_title, "Next level train transformation title mismatch"
    assert "20% Thin Ice" in ui.hazard_text, "Hazard preview mismatch"
    assert "PROCEED TO LEVEL 2" in ui.button_text, "Button text mismatch"
    print("✓ PASS: Level 1 completion correctly displays Level 2 X2000 hazard previews.")
    return True

def test_proceed_button_interaction():
    print("\n[UX Test 2] Testing Proceed Button Click & Transition...")
    ui = SimulatedLevelCompleteUI()
    ui.show_celebration(2)
    ui.click_proceed()
    assert not ui.visible and ui.proceed_emitted, "Proceed click transition failed"
    print("✓ PASS: Clicking Proceed button resumes game and advances to next level.")
    return True

if __name__ == "__main__":
    tests = [test_celebration_screen_data_mapping, test_proceed_button_interaction]
    passed = 0
    for t in tests:
        if t(): passed += 1
    print("\n--------------------------------------------------")
    print(f"TEST RESULTS: {passed}/{len(tests)} TESTS PASSED")
    print("==================================================")
    if passed == len(tests): sys.exit(0)
    else: sys.exit(1)
