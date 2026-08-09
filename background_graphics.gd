extends Control

var anim_time: float = 0.0
var current_level: int = 1
var level_textures: Dictionary = {}


func _ready() -> void:
	# Pre-load high quality background textures for each level plot stage
	_load_background_textures()
	
	# Connect to LevelManager if available
	var level_mgr = get_node_or_null("../../LevelManager")
	if level_mgr and level_mgr.has_signal("level_changed"):
		level_mgr.level_changed.connect(_on_level_changed)
		current_level = level_mgr.current_level


func _on_level_changed(level_num: int, _level_name: String) -> void:
	current_level = level_num
	queue_redraw()


func _load_background_textures() -> void:
	var path_map := {
		1: "res://assets/backgrounds/level_1_calm_fjord.jpg",
		2: "res://assets/backgrounds/level_2_pine_forest.jpg",
		3: "res://assets/backgrounds/level_3_blizzard_pass.jpg",
		4: "res://assets/backgrounds/level_4_fragile_bridge.jpg",
		5: "res://assets/backgrounds/level_5_dawn_dash.jpg"
	}
	
	for lvl in path_map:
		var file_path: String = path_map[lvl]
		if ResourceLoader.exists(file_path):
			var tex = load(file_path) as Texture2D
			if tex:
				level_textures[lvl] = tex
				continue
		
		# Fallback: load directly from raw file if import cache is pending
		var global_path := ProjectSettings.globalize_path(file_path)
		if FileAccess.file_exists(file_path) or FileAccess.file_exists(global_path):
			var img := Image.load_from_file(file_path if FileAccess.file_exists(file_path) else global_path)
			if img:
				level_textures[lvl] = ImageTexture.create_from_image(img)


var player_train: Node2D
var train_pos := Vector2.ZERO


func _process(delta: float) -> void:
	anim_time += delta
	
	# Find player train to track position across the icy field
	if not player_train:
		player_train = get_node_or_null("../../Train/Locomotive") as Node2D
		if not player_train:
			player_train = get_node_or_null("../../Locomotive") as Node2D
			
	if player_train:
		train_pos = player_train.global_position

	# Auto-detect level changes if LevelManager is present
	var level_mgr = get_node_or_null("../../LevelManager")
	if level_mgr and level_mgr.current_level != current_level:
		current_level = level_mgr.current_level

	queue_redraw()


func _draw() -> void:
	var screen_size := get_viewport_rect().size
	if screen_size.x <= 0 or screen_size.y <= 0:
		screen_size = Vector2(1152, 648)

	# 1. Render Pure Infinite Frozen Ice Field Ground over the whole display
	_draw_pure_frozen_ice_field(screen_size, train_pos)

	# 2. Render Plot-Matching Dynamic Atmospheric Overlays
	match current_level:
		1:
			_draw_level1_calm_fjord_overlay(screen_size)
		2:
			_draw_level2_pine_forest_overlay(screen_size)
		3:
			_draw_level3_blizzard_pass_overlay(screen_size)
		4:
			_draw_level4_fragile_bridge_overlay(screen_size)
		5:
			_draw_level5_dawn_dash_overlay(screen_size)


## Render Pure Frozen Ground / Infinite Ice Sheet Field over whole display
func _draw_pure_frozen_ice_field(screen_size: Vector2, train_p: Vector2) -> void:
	# Base Frozen Ground Palette: Deep Crystalline Ice Blue Foundation
	var base_ice := Color(0.12, 0.22, 0.35, 1.0)
	draw_rect(Rect2(Vector2.ZERO, screen_size), base_ice, true)

	# Glacial Frost Surface Overlay
	var ice_surface := Color(0.35, 0.65, 0.85, 0.35)
	draw_rect(Rect2(Vector2.ZERO, screen_size), ice_surface, true)

	# Infinite Scrolling Ice Tract Grid & Crack Pattern
	var grid_step := 128.0
	var field_line_color := Color(0.6, 0.85, 1.0, 0.25)
	
	var offset_x: float = fmod(-train_p.x * 0.5, grid_step)
	var offset_y: float = fmod(-train_p.y * 0.5, grid_step)
	
	# Horizontal frozen ground tract lines
	var y: float = offset_y
	while y < screen_size.y:
		draw_line(Vector2(0, y), Vector2(screen_size.x, y), field_line_color, 1.5)
		y += grid_step

	# Vertical frozen ground tract lines
	var x: float = offset_x
	while x < screen_size.x:
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), field_line_color, 1.5)
		x += grid_step

	# Diagonal crystalline frost veins on the frozen ground
	var diag_step := 256.0
	var diag_offset := fmod((-train_p.x - train_p.y) * 0.3, diag_step)
	var d: float = diag_offset - diag_step
	while d < screen_size.x + screen_size.y:
		draw_line(Vector2(d, 0), Vector2(d - screen_size.y, screen_size.y), Color(0.7, 0.9, 1.0, 0.12), 1.0)
		d += diag_step

	# Frost shimmer particles floating over frozen ground
	for i in range(25):
		var shimmer_x: float = fmod(i * 101.0 - train_p.x * 0.2 + anim_time * 12.0, screen_size.x)
		var shimmer_y: float = fmod(i * 59.0 - train_p.y * 0.2 + sin(anim_time + i) * 10.0, screen_size.y)
		var shimmer_alpha: float = 0.3 + sin(anim_time * 3.0 + i) * 0.25
		draw_circle(Vector2(shimmer_x, shimmer_y), 2.5, Color(0.9, 0.98, 1.0, shimmer_alpha))


## Level 1: The Calm Fjord (Soft Morning Sun Rays & Lake Shimmer)
func _draw_level1_calm_fjord_overlay(screen_size: Vector2) -> void:
	# Gentle morning sun flare overlay
	var sun_center := Vector2(screen_size.x * 0.35, screen_size.y * 0.25)
	var sun_glow_alpha: float = 0.15 + sin(anim_time * 1.2) * 0.05
	draw_circle(sun_center, 120.0, Color(1.0, 0.95, 0.7, sun_glow_alpha))
	draw_circle(sun_center, 60.0, Color(1.0, 1.0, 0.8, sun_glow_alpha * 1.5))


## Level 2: Pine Forest Crossing (Twilight Mist & Falling Snow)
func _draw_level2_pine_forest_overlay(screen_size: Vector2) -> void:
	# Subtle twilight mist gradient tint
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.05, 0.1, 0.2, 0.15), true)
	
	# Falling snow flakes
	for i in range(20):
		var flake_x: float = fmod(i * 97.0 + anim_time * 20.0, screen_size.x)
		var flake_y: float = fmod(i * 61.0 + anim_time * 45.0, screen_size.y)
		var flake_size: float = 1.5 + fmod(i, 3) * 0.8
		draw_circle(Vector2(flake_x, flake_y), flake_size, Color(1.0, 1.0, 1.0, 0.6))


## Level 3: Midnight Blizzard Pass (Aurora Borealis & Heavy Snowstorm)
func _draw_level3_blizzard_pass_overlay(screen_size: Vector2) -> void:
	# Animated Glowing Aurora Borealis Ribbons
	var aurora_points := PackedVector2Array()
	var step_x: float = screen_size.x / 16.0
	for i in range(17):
		var x: float = i * step_x
		var y: float = screen_size.y * 0.15 + sin(anim_time * 1.8 + i * 0.4) * 20.0
		aurora_points.append(Vector2(x, y))

	for i in range(aurora_points.size() - 1):
		var p1: Vector2 = aurora_points[i]
		var p2: Vector2 = aurora_points[i + 1]
		draw_line(p1, p2, Color(0.0, 0.95, 0.65, 0.35), 20.0) # Electric Green Ribbon
		draw_line(p1 - Vector2(0, 10), p2 - Vector2(0, 10), Color(0.7, 0.3, 0.9, 0.25), 15.0) # Magenta Ribbon

	# Swirling blizzard particles
	for i in range(40):
		var flake_x: float = fmod(i * 73.0 + anim_time * 120.0, screen_size.x)
		var flake_y: float = fmod(i * 41.0 + anim_time * 90.0, screen_size.y)
		draw_circle(Vector2(flake_x, flake_y), 2.2, Color(0.9, 0.95, 1.0, 0.75))


## Level 4: Fragile Bridge Crossing (Dramatic Canyon Mist & Deep Shadows)
func _draw_level4_fragile_bridge_overlay(screen_size: Vector2) -> void:
	# Canyon depth shadow gradient
	var canyon_top: float = screen_size.y * 0.55
	draw_rect(Rect2(Vector2(0, canyon_top), Vector2(screen_size.x, screen_size.y - canyon_top)), Color(0.02, 0.05, 0.1, 0.3), true)
	
	# Atmospheric canyon fog wave
	var fog_y: float = screen_size.y * 0.6 + sin(anim_time * 0.8) * 10.0
	draw_rect(Rect2(Vector2(0, fog_y), Vector2(screen_size.x, 40)), Color(0.7, 0.8, 0.9, 0.12), true)


## Level 5: The Dawn Dash (Golden Horizon Dawn Burst & Victory Glow)
func _draw_level5_dawn_dash_overlay(screen_size: Vector2) -> void:
	# Radiant golden dawn sky bloom
	var dawn_rect := Rect2(Vector2.ZERO, screen_size)
	draw_rect(dawn_rect, Color(1.0, 0.5, 0.2, 0.08), true) # Warm Orange Sunburst Glow
	
	# Golden particle sparkles celebrating final run
	for i in range(15):
		var spark_x: float = fmod(i * 113.0 + anim_time * 15.0, screen_size.x)
		var spark_y: float = fmod(i * 67.0 - anim_time * 30.0, screen_size.y)
		var spark_alpha: float = 0.3 + sin(anim_time * 4.0 + i) * 0.3
		draw_circle(Vector2(spark_x, spark_y), 2.5, Color(1.0, 0.85, 0.4, spark_alpha))


## Fallback procedural sky if texture fails
func _draw_procedural_sky(screen_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.05, 0.08, 0.18), true)
	for i in range(25):
		var star_x: float = fmod(i * 137.5, screen_size.x)
		var star_y: float = fmod(i * 91.3, screen_size.y * 0.45)
		var star_alpha: float = 0.4 + sin(anim_time * 3.0 + i) * 0.3
		draw_circle(Vector2(star_x, star_y), 1.8, Color(1.0, 1.0, 1.0, star_alpha))
