extends Control

var nav_parent: Node

func _ready() -> void:
	nav_parent = get_parent().get_parent().get_parent()


func _draw() -> void:
	var radius: float = size.x / 2.0
	var center: Vector2 = size / 2.0

	# Draw Circular Radar Frame
	draw_circle(center, radius, Color(0.08, 0.15, 0.25, 0.85))
	draw_arc(center, radius, 0, TAU, 32, Color(0.3, 0.7, 0.9, 0.9), 2.5)
	draw_arc(center, radius * 0.5, 0, TAU, 16, Color(0.3, 0.7, 0.9, 0.4), 1.5)

	if not nav_parent or not ("player_train" in nav_parent) or not is_instance_valid(nav_parent.player_train):
		return

	var train_pos: Vector2 = nav_parent.player_train.global_position
	var station_pos: Vector2 = nav_parent.station_position
	var scale_factor: float = radius / 1500.0 # Map world distance to radar pixels

	# Draw Station Icon on Radar (Gold Dot)
	var rel_station: Vector2 = (station_pos - train_pos) * scale_factor
	if rel_station.length() < radius - 8.0:
		draw_circle(center + rel_station, 6.0, Color.GOLD)
		draw_arc(center + rel_station, 8.0, 0, TAU, 12, Color.YELLOW, 1.5)
	else:
		# Clamp to radar border if station is far
		var clamped: Vector2 = rel_station.normalized() * (radius - 10.0)
		draw_circle(center + clamped, 5.0, Color.GOLD)

	# Draw Player Train Icon on Radar (Green Center Dot)
	draw_circle(center, 5.0, Color(0.2, 0.9, 0.4))
	
	# Draw Train Heading Pointer
	var heading: Vector2 = Vector2.RIGHT.rotated(nav_parent.player_train.rotation) * 12.0
	draw_line(center, center + heading, Color(0.2, 0.9, 0.4), 2.0)
