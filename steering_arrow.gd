extends Node2D
class_name SteeringArrow

var locomotive: Node2D
var station_position: Vector2 = Vector2(0, -1500.0)
var current_guidance_text: String = "ON TRACK 🡅"
var arrow_angle: float = 0.0

# Colors for Arrow and Steering Guidance
const COLOR_ON_TRACK := Color(0.1, 0.9, 0.4, 0.95)   # Green
const COLOR_STEER_LEFT := Color(0.95, 0.7, 0.1, 0.95) # Gold/Orange
const COLOR_STEER_RIGHT := Color(0.95, 0.7, 0.1, 0.95)# Gold/Orange


func _ready() -> void:
	locomotive = get_parent() as Node2D
	z_index = 10 # Draw above train sprite


func _process(_delta: float) -> void:
	if not locomotive:
		locomotive = get_parent() as Node2D
		if not locomotive: return

	# Find station position from StationNavigation if available
	var nav = get_node_or_null("../../../StationNavigation")
	if nav and "station_position" in nav:
		station_position = nav.station_position
	else:
		return;

	# Calculate vector to station in world space
	var to_station := station_position - locomotive.global_position
	log(to_station.length())
	var world_angle_to_station := to_station.angle()
	
	# Angle relative to locomotive's current facing direction
	var relative_angle := wrapf(world_angle_to_station - locomotive.global_rotation, -PI, PI)
	arrow_angle = relative_angle

	# Determine steering advice
	var deg := rad_to_deg(relative_angle)
	current_guidance_text = ""

	queue_redraw()


func _draw() -> void:
	if not locomotive:
		return

	# Offset arrow 70 pixels in front of the train
	var arrow_center := Vector2(0, -75)
	
	# Determine Arrow Color based on alignment
	var draw_color := COLOR_ON_TRACK
	if absf(rad_to_deg(arrow_angle)) > 15.0:
		draw_color = COLOR_STEER_LEFT

	# Draw Rotating Navigation Arrow
	var arrow_size := 22.0
	var head_angle := arrow_angle 
	var p_tip := arrow_center + Vector2.RIGHT.rotated(head_angle) * arrow_size
	var p_left := arrow_center + Vector2.RIGHT.rotated(head_angle + 2.4) * (arrow_size * 0.6)
	var p_right := arrow_center + Vector2.RIGHT.rotated(head_angle - 2.4) * (arrow_size * 0.6)

	var arrow_poly := PackedVector2Array([p_tip, p_left, p_right])
	draw_colored_polygon(arrow_poly, draw_color)
	draw_polyline(arrow_poly, Color.WHITE, 2.0)

	# Draw Text Guidance Label above Arrow
	var label_pos := arrow_center + Vector2(-45, -25)
	draw_string(ThemeDB.fallback_font, label_pos, current_guidance_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, draw_color)
