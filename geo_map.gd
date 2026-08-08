extends CanvasLayer
class_name GeoMap

## Signal emitted when station is reached
signal destination_reached

var player_train: Node2D
var station_world_pos: Vector2 = Vector2(0, -1500.0)
var path_history: Array[Vector2] = []
var is_full_map_open: bool = false
var sample_timer: float = 0.0

@onready var map_panel: Control = $Control/MapPanel
@onready var distance_label: Label = $Control/MapPanel/DistanceTextLabel


func _ready() -> void:
	player_train = get_node_or_null("../Locomotive") as Node2D
	if player_train:
		path_history.append(player_train.global_position)


func _process(delta: float) -> void:
	if not player_train:
		player_train = get_node_or_null("../Locomotive") as Node2D
		return

	# Sample train path history every 0.1s for geographical tracking
	sample_timer += delta
	if sample_timer >= 0.1:
		sample_timer = 0.0
		if path_history.is_empty() or path_history[-1].distance_to(player_train.global_position) > 10.0:
			path_history.append(player_train.global_position)

	# Toggle full map view with 'Tab' key
	if Input.is_action_just_pressed("ui_focus_next"):
		is_full_map_open = not is_full_map_open
		_update_map_layout()

	# Redraw map widget
	if map_panel:
		map_panel.queue_redraw()


func _update_map_layout() -> void:
	if not map_panel:
		return
	var vp_size := get_viewport().get_visible_rect().size
	if is_full_map_open:
		map_panel.custom_minimum_size = Vector2(500, 400)
		map_panel.position = Vector2(vp_size.x / 2.0 - 250, vp_size.y / 2.0 - 200)
	else:
		map_panel.custom_minimum_size = Vector2(220, 160)
		map_panel.position = Vector2(vp_size.x - 240, vp_size.y - 180)
