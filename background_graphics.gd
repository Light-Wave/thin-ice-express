extends Control

var anim_time: float = 0.0

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()


func _draw() -> void:
	var screen_size := get_viewport_rect().size
	if screen_size.x <= 0 or screen_size.y <= 0:
		screen_size = Vector2(1152, 648)

	# 1. Deep Midnight Arctic Night Sky Gradient
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.05, 0.08, 0.18), true) # Base Midnight Dark Blue

	# 2. Twinkling Stars
	for i in range(25):
		var star_x: float = fmod(i * 137.5, screen_size.x)
		var star_y: float = fmod(i * 91.3, screen_size.y * 0.45)
		var star_alpha: float = 0.4 + sin(anim_time * 3.0 + i) * 0.3
		draw_circle(Vector2(star_x, star_y), 1.8, Color(1.0, 1.0, 1.0, star_alpha))

	# 3. Animated Glowing Aurora Borealis Waves (Northern Lights)
	var aurora_points := PackedVector2Array()
	var step_x: float = screen_size.x / 16.0
	for i in range(17):
		var x: float = i * step_x
		var y: float = screen_size.y * 0.2 + sin(anim_time * 1.5 + i * 0.4) * 25.0
		aurora_points.append(Vector2(x, y))

	# Draw Aurora Glow Ribbon
	for i in range(aurora_points.size() - 1):
		var p1: Vector2 = aurora_points[i]
		var p2: Vector2 = aurora_points[i + 1]
		draw_line(p1, p2, Color(0.0, 0.95, 0.65, 0.4), 18.0) # Electric Green Ribbon
		draw_line(p1 - Vector2(0, 12), p2 - Vector2(0, 12), Color(0.7, 0.3, 0.9, 0.25), 14.0) # Magenta Upper Ribbon

	# 4. Distant Snow-Capped Mountain Range
	_draw_mountains(screen_size)

	# 5. Frozen Lake Ice Bed Surface
	var lake_top: float = screen_size.y * 0.48
	draw_rect(Rect2(Vector2(0, lake_top), Vector2(screen_size.x, screen_size.y - lake_top)), Color(0.12, 0.25, 0.4, 0.65), true)

	# 6. Snowy Pine Tree Shorelines (Left & Right Shores)
	_draw_shoreline_forest(screen_size)


## Draw Distant Snow Mountain Peaks
func _draw_mountains(screen_size: Vector2) -> void:
	var base_y: float = screen_size.y * 0.52
	var mountain_color := Color(0.1, 0.16, 0.28)
	var snow_color := Color(0.9, 0.95, 1.0)

	# 3 Main Mountain Peaks
	var peak1_p0 := Vector2(0, base_y)
	var peak1_p1 := Vector2(screen_size.x * 0.25, base_y - 140)
	var peak1_p2 := Vector2(screen_size.x * 0.5, base_y)

	var peak2_p0 := Vector2(screen_size.x * 0.35, base_y)
	var peak2_p1 := Vector2(screen_size.x * 0.65, base_y - 180)
	var peak2_p2 := Vector2(screen_size.x * 0.95, base_y)

	var peaks := [
		[peak1_p0, peak1_p1, peak1_p2],
		[peak2_p0, peak2_p1, peak2_p2]
	]

	for m in peaks:
		var p0: Vector2 = m[0]
		var p1: Vector2 = m[1]
		var p2: Vector2 = m[2]
		
		var poly := PackedVector2Array([p0, p1, p2])
		draw_colored_polygon(poly, mountain_color)
		
		# Snow Cap Peak
		var snow_top: Vector2 = p1
		var snow_left: Vector2 = p1.lerp(p0, 0.25)
		var snow_right: Vector2 = p1.lerp(p2, 0.25)
		var snow_poly := PackedVector2Array([snow_left, snow_top, snow_right])
		draw_colored_polygon(snow_poly, snow_color)


## Draw Snowy Pine Trees on Shorelines
func _draw_shoreline_forest(screen_size: Vector2) -> void:
	var tree_green := Color(0.08, 0.22, 0.18)
	var snow_white := Color(0.92, 0.96, 1.0)

	# Left Shore Pine Trees
	for i in range(5):
		var tree_pos := Vector2(25 + i * 22, screen_size.y * 0.65 + i * 35)
		_draw_single_pine_tree(tree_pos, tree_green, snow_white)

	# Right Shore Pine Trees
	for i in range(5):
		var tree_pos := Vector2(screen_size.x - 30 - i * 22, screen_size.y * 0.65 + i * 35)
		_draw_single_pine_tree(tree_pos, tree_green, snow_white)


func _draw_single_pine_tree(pos: Vector2, tree_color: Color, snow_color: Color) -> void:
	# Trunk
	draw_rect(Rect2(pos + Vector2(-3, 0), Vector2(6, 15)), Color(0.2, 0.12, 0.08), true)
	
	# 3 Pine Foliage Tiers
	for tier in range(3):
		var y_off: float = -tier * 12
		var width: float = 28.0 - (tier * 6.0)
		var poly := PackedVector2Array([
			pos + Vector2(-width / 2.0, y_off),
			pos + Vector2(0, y_off - 16),
			pos + Vector2(width / 2.0, y_off)
		])
		draw_colored_polygon(poly, tree_color)
		
		# Snow Cap
		var snow_poly := PackedVector2Array([
			pos + Vector2(-width * 0.3, y_off - 4),
			pos + Vector2(0, y_off - 16),
			pos + Vector2(width * 0.3, y_off - 4)
		])
		draw_colored_polygon(snow_poly, snow_color)
