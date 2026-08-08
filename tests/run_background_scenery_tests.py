#!/usr/bin/env python3
import os
import sys

print("==================================================")
print("   RUNNING BACKGROUND SCENERY & PLOT ARTWORK TESTS")
print("==================================================")

BACKGROUND_ASSETS = {
    1: "assets/backgrounds/level_1_calm_fjord.jpg",
    2: "assets/backgrounds/level_2_pine_forest.jpg",
    3: "assets/backgrounds/level_3_blizzard_pass.jpg",
    4: "assets/backgrounds/level_4_fragile_bridge.jpg",
    5: "assets/backgrounds/level_5_dawn_dash.jpg"
}

def test_background_asset_existence():
    print("\n[UX Test 1] Testing Level Background Image Asset Existence...")
    for lvl, path in BACKGROUND_ASSETS.items():
        assert os.path.exists(path), f"Missing background asset for Level {lvl}: {path}"
        file_size = os.path.getsize(path)
        assert file_size > 50000, f"Asset size too small for Level {lvl}: {file_size} bytes"
    print("✓ PASS: High-resolution artwork assets exist for all 5 level plot stages.")
    return True

def test_background_graphics_script_mapping():
    print("\n[UX Test 2] Testing background_graphics.gd Level Mapping...")
    script_path = "background_graphics.gd"
    assert os.path.exists(script_path), "background_graphics.gd does not exist"
    
    with open(script_path, "r") as f:
        content = f.read()

    for lvl in range(1, 6):
        assert f"level_{lvl}_" in content, f"Missing level_{lvl} texture mapping in script"
    
    assert "draw_texture_rect" in content, "Missing texture rendering logic in script"
    assert "_draw_level1_calm_fjord_overlay" in content, "Missing level 1 overlay"
    assert "_draw_level3_blizzard_pass_overlay" in content, "Missing level 3 overlay"
    assert "_draw_level5_dawn_dash_overlay" in content, "Missing level 5 overlay"

    print("✓ PASS: background_graphics.gd correctly maps all 5 level plots and atmospheric overlays.")
    return True

if __name__ == "__main__":
    passed = 0
    tests = [
        test_background_asset_existence,
        test_background_graphics_script_mapping,
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
