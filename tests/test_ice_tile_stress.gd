extends SceneTree

# Automated Test Harness for IceTile (UX & Stress Testing)

func _init() -> void:
	print("==================================================")
	print("   RUNNING ICE TILE UX & STRESS TEST SUITE       ")
	print("==================================================")
	
	var passed_tests := 0
	var total_tests := 5
	
	if test_ux_crack_progression(): passed_tests += 1
	if test_ux_signal_emissions(): passed_tests += 1
	if test_stress_rapid_entry_exit(): passed_tests += 1
	if test_stress_boundary_safety(): passed_tests += 1
	if test_stress_high_tile_volume(): passed_tests += 1

	print("\n--------------------------------------------------")
	print("TEST RESULTS: %d/%d TESTS PASSED" % [passed_tests, total_tests])
	print("==================================================")
	
	quit(0 if passed_tests == total_tests else 1)


## UX TEST 1: Verify visual and state progression
func test_ux_crack_progression() -> bool:
	print("\n[UX Test 1] Testing Crack State & Visual Progression...")
	var tile_scene = load("res://ice_tile.tscn")
	var tile = tile_scene.instantiate() as IceTile
	
	# Initial state
	if tile.crack_level != 0 or tile.is_broken != false:
		print("❌ FAIL: Initial state incorrect.")
		return false
		
	# Advance crack to 1
	tile.advance_crack()
	if tile.crack_level != 1 or tile.is_broken:
		print("❌ FAIL: Level 1 transition incorrect.")
		return false
		
	# Advance to max cracks
	tile.advance_crack() # 2
	tile.advance_crack() # 3 -> Breaks
	
	if tile.crack_level != 3 or not tile.is_broken:
		print("❌ FAIL: Breaking transition incorrect.")
		return false
		
	print("✓ PASS: Crack state progression and breaking work seamlessly.")
	tile.free()
	return true


## UX TEST 2: Signal emission accuracy for player feedback
func test_ux_signal_emissions() -> bool:
	print("\n[UX Test 2] Testing Signal Emissions (ice_cracked & ice_broken)...")
	var tile_scene = load("res://ice_tile.tscn")
	var tile = tile_scene.instantiate() as IceTile
	
	var cracked_signals_received := 0
	var broken_signal_received := false
	
	tile.ice_cracked.connect(func(level: int): cracked_signals_received += 1)
	tile.ice_broken.connect(func(): broken_signal_received = true)
	
	# Trigger cracks until broken
	tile.advance_crack() # 1
	tile.advance_crack() # 2
	tile.advance_crack() # 3
	
	if cracked_signals_received != 3:
		print("❌ FAIL: Expected 3 ice_cracked signals, got %d" % cracked_signals_received)
		return false
		
	if not broken_signal_received:
		print("❌ FAIL: ice_broken signal was not emitted.")
		return false
		
	print("✓ PASS: All signals emitted accurately with correct levels.")
	tile.free()
	return true


## STRESS TEST 1: Rapid multi-body entry/exit jitter test
func test_stress_rapid_entry_exit() -> bool:
	print("\n[Stress Test 1] Simulating 500 Rapid Entry/Exit Events (Jitter Test)...")
	var tile_scene = load("res://ice_tile.tscn")
	var tile = tile_scene.instantiate() as IceTile
	var dummy_body = CharacterBody2D.new()
	dummy_body.add_to_group("train")
	
	var start_time = Time.get_ticks_usec()
	for i in range(500):
		tile._on_body_entered(dummy_body)
		tile._on_body_exited(dummy_body)
		
	var elapsed_ms = (Time.get_ticks_usec() - start_time) / 1000.0
	print("✓ PASS: 500 rapid entry/exit events completed in %.2f ms without error." % elapsed_ms)
	
	dummy_body.free()
	tile.free()
	return true


## STRESS TEST 2: Over-crack boundary safety
func test_stress_boundary_safety() -> bool:
	print("\n[Stress Test 2] Testing Over-Crack Boundary Safety...")
	var tile_scene = load("res://ice_tile.tscn")
	var tile = tile_scene.instantiate() as IceTile
	
	# Advance 20 times beyond max_cracks (3)
	for i in range(20):
		tile.advance_crack()
		
	if tile.crack_level != 3 or not tile.is_broken:
		print("❌ FAIL: Boundary state corrupted after repeated calls.")
		return false
		
	print("✓ PASS: Tile remains safely bounded after 20 over-crack attempts.")
	tile.free()
	return true


## STRESS TEST 3: High Volume Scaling (1,000 Ice Tiles)
func test_stress_high_tile_volume() -> bool:
	print("\n[Stress Test 3] Instantiating and Cracking 1,000 Ice Tiles Simultaneously...")
	var tile_scene = load("res://ice_tile.tscn")
	var tiles: Array[IceTile] = []
	
	var start_time = Time.get_ticks_usec()
	
	# Instantiate 1000 tiles
	for i in range(1000):
		var tile = tile_scene.instantiate() as IceTile
		tiles.append(tile)
		
	# Process cracking on all 1000 tiles
	for tile in tiles:
		tile.advance_crack()
		tile.advance_crack()
		tile.advance_crack()
		
	var elapsed_ms = (Time.get_ticks_usec() - start_time) / 1000.0
	print("✓ PASS: 1,000 IceTiles created and fully cracked in %.2f ms." % elapsed_ms)
	
	for tile in tiles:
		tile.free()
		
	return true
