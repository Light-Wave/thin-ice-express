extends Control

var geo_parent: Node

func _ready() -> void:
	geo_parent = get_parent().get_parent()


func _draw() -> void:
	var rect_size := size
	var center := rect_size / 2.0

	# 1. Parchment / Navy Geographical Map Frame
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.08, 0.14, 0.24, 0.9), true)
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.75, 0.6, 0.25, 0.9), false, 3.0) # Gold Border

	if not geo_parent or not ("player_train" in geo_parent) or not is_instance_valid(geo_parent.player_train):
		return

	var train_pos: Vector2 = geo_parent.player_train.global_position
	var station_pos: Vector2 = geo_parent.station_world_pos
	
	# Scale factor mapping world coords to map UI pixels
	var map_scale: float = rect_size.y / 2200.0

	# 2. Draw Shoreline Coast Geometry
	var left_shore := PackedVector2Array([
		Vector2(0, 0), Vector2(rect_size.x * 0.25, 0),
		Vector2(rect_size.x * 0.2, rect_size.y), Vector2(0, rect_size.y)
	])
	draw_colored_polygon(left_shore, Color(0.12, 0.22, 0.18, 0.7)) # Dark Shoreline

	var right_shore := PackedVector2Array([
		Vector2(rect_size.x * 0.75, 0), Vector2(rect_size.x, 0),
		Vector2(rect_size.x, rect_size.y), Vector2(rect_size.x * 0.8, rect_size.y)
	])
	draw_colored_polygon(right_shore, Color(0.12, 0.22, 0.18, 0.7))

	# 3. Draw Player Steering Path History Trail (Golden Trail)
	if "path_history" in geo_parent and geo_parent.path_history.size() >= 2:
		var map_path := PackedVector2Array()
		for pt in geo_parent.path_history:
			var rel: Vector2 = (pt - train_pos) * map_scale
			map_path.append(center + rel)
		draw_polyline(map_path, Color(0.95, 0.75, 0.2, 0.8), 2.5)

	# 4. Draw Station Marker (Gold Station Flag)
	var rel_station: Vector2 = (station_pos - train_pos) * map_scale
	var station_map_pos: Vector2 = center + rel_station

	# 5. Draw Connecting Route Graph Line between Train and Station Ahead
	draw_dashed_line(center, station_map_pos, Color(0.0, 0.85, 1.0, 0.85), 2.5, 6.0)
	
	# Graph Waypoint Nodes along the route
	for step in range(1, 4):
		var waypoint: Vector2 = center.lerp(station_map_pos, step / 4.0)
		draw_circle(waypoint, 3.5, Color(0.0, 0.85, 1.0, 0.9))

	if Rect2(Vector2.ZERO, rect_size).has_point(station_map_pos):
		draw_circle(station_map_pos, 7.0, Color.GOLD)
		draw_arc(station_map_pos, 10.0, 0, TAU, 12, Color.YELLOW, 2.0)
	else:
		var clamped: Vector2 = center + rel_station.normalized() * (minf(rect_size.x, rect_size.y) * 0.45)
		draw_circle(clamped, 6.0, Color.GOLD)

	# 6. Draw Player Train GPS Marker (Green 🟢)
	draw_circle(center, 6.0, Color(0.2, 0.95, 0.4))
	draw_arc(center, 8.0, 0, TAU, 12, Color.WHITE, 1.5)

	# 7. Live Distance Label
	var dist_m := int(train_pos.distance_to(station_pos) / 10.0)
	var label_node := get_node_or_null("DistanceTextLabel") as Label
	if label_node:
		label_node.text = "%d m to Station" % dist_m
