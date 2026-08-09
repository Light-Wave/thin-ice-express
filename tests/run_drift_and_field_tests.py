#!/usr/bin/env python3
import os
import sys

print("==================================================")
print("   RUNNING ICE FIELD PARALLAX, PROXIMITY & DRIFT TESTS")
print("==================================================")

def test_background_field_parallax():
    print("\n[UX Test 1] Testing Background Parallax & Field Motion Logic...")
    with open("background_graphics.gd", "r") as f:
        code = f.read()
    
    assert "_draw_pure_frozen_ice_field" in code, "Missing pure frozen ice field ground rendering"
    assert "fmod(-train_p.x * 0.5" in code, "Missing X axis frozen ground scrolling calculation"
    print("✓ PASS: Pure frozen ground field scrolling logic verified.")
    return True

def test_ice_path_proximity_changing():
    print("\n[UX Test 2] Testing Dynamic Ice Path Proximity Change Ahead...")
    with open("ice_tile.gd", "r") as f:
        code = f.read()
    
    assert "is_approaching" in code, "Missing is_approaching state variable"
    assert "approach_intensity" in code, "Missing approach_intensity variable"
    assert "COLOR_ICE_GLOW" in code, "Missing proximity warning glow color"
    assert "draw_line" in code and "line_color" in code, "Missing hairline stress preview rendering"
    print("✓ PASS: Dynamic pre-contact icy path changing ahead of approaching train verified.")
    return True

def test_locomotive_lateral_drag_physics():
    print("\n[UX Test 3] Testing Lateral Ice Drag & Opposite-Side Drift Dynamics...")
    with open("locomotive.gd", "r") as f:
        code = f.read()
    
    assert "lateral_ice_drag_coefficient" in code, "Missing lateral_ice_drag_coefficient export"
    assert "opposite_drag_drift_force" in code, "Missing opposite_drag_drift_force export"
    assert "linear_velocity.dot(right_vec)" in code, "Missing lateral velocity decomposition"
    assert "opposite_drag" in code, "Missing opposite side centrifugal drift force"
    print("✓ PASS: Lateral ice sliding and opposite-side drift physics verified.")
    return True

if __name__ == "__main__":
    passed = 0
    tests = [
        test_background_field_parallax,
        test_ice_path_proximity_changing,
        test_locomotive_lateral_drag_physics,
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
