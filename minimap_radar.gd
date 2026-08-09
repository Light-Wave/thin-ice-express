extends Control

var nav_parent: Node

func _ready() -> void:
	nav_parent = get_parent().get_parent().get_parent()


func _draw() -> void:
	var radius: float = size.x / 2.0
	var center: Vector2 = size / 2.0

	# Draw Circular Radar Frame
	draw_circle(center, radius, Color(0.08, 0.15, 0.25, 0.9))
	draw_arc(center, radius, 0, TAU, 32, Color(0.3, 0.75, 0.95, 0.95), 3.0)
	draw_arc(center, radius * 0.5, 0, TAU, 16, Color(0.3, 0.7, 0.9, 0.4), 1.5)

	if not nav_parent or not ("player_train" in nav_parent) or not is_instance_valid(nav_parent.player_train):
		return

	var train_pos: Vector2 = nav_parent.player_train.global_position
	var station_pos: Vector2 = nav_parent.station_position
	
	# Scale factor mapping world distance to radar pixels
	var start_dist: float = nav_parent.start_distance if ("start_distance" in nav_parent and nav_parent.start_distance > 0) else 2500.0
	var scale_factor: float = radius / maxf(start_dist, 500.0)

	# 1. Draw Station Directional Pointer Arrow (Golden Pointer)
	var dir_to_station := (station_pos - train_pos).normalized()
	if dir_to_station.length_squared() > 0.001:
		var arrow_len := radius * 0.7
		var arrow_end := center + dir_to_station * arrow_len
		draw_line(center, arrow_end, Color(1.0, 0.85, 0.2, 0.85), 3.0)
		
		# Arrow Head Pointer Polygon
		var side := Vector2(-dir_to_station.y, dir_to_station.x)
		var p1 := arrow_end
		var p2 := arrow_end - dir_to_station * 9.0 + side * 5.0
		var p3 := arrow_end - dir_to_station * 9.0 - side * 5.0
		draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color.GOLD)

	# 2. Draw Station Marker on Radar
	var rel_station: Vector2 = (station_pos - train_pos) * scale_factor
	if rel_station.length() < radius - 8.0:
		draw_circle(center + rel_station, 6.0, Color.GOLD)
		draw_arc(center + rel_station, 8.0, 0, TAU, 12, Color.YELLOW, 1.5)
	else:
		var clamped: Vector2 = rel_station.normalized() * (radius - 10.0)
		draw_circle(center + clamped, 5.0, Color.GOLD)

	# 3. Draw Player Train Icon on Radar (Green Center Dot)
	draw_circle(center, 5.0, Color(0.2, 0.95, 0.4))
	
	# 4. Draw Train Heading Vector Line
	var heading: Vector2 = Vector2.RIGHT.rotated(nav_parent.player_train.rotation) * 14.0
	draw_line(center, center + heading, Color(0.2, 0.95, 0.4), 2.5)
