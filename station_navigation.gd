extends CanvasLayer
class_name StationNavigation

## Emitted when the train reaches the station destination
signal station_reached(level_num: int)

@export var station_distance_meters: float = 1500.0 ## Distance from start to station in meters

var player_train: Node2D
var station_position: Vector2 = Vector2.ZERO
var start_distance: float = 1500.0
var level_manager: Node

# High Contrast Dark Font Colors
const COLOR_TEXT_DARK := Color(0.06, 0.12, 0.24, 1.0) # Deep Navy
const COLOR_TEXT_GOLD := Color(0.7, 0.5, 0.0, 1.0)    # Dark Gold

@onready var distance_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/ProgressBar
@onready var distance_label: Label = $Control/MarginContainer/VBoxContainer/DistanceLabel
@onready var minimap_panel: Control = $Control/MinimapPanel


func _ready() -> void:
	player_train = get_node_or_null("../Locomotive") as Node2D
	level_manager = get_node_or_null("../LevelManager")
	
	if distance_label:
		distance_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)
		distance_label.add_theme_color_override("font_outline_color", Color.WHITE)
		distance_label.add_theme_constant_override("outline_size", 4)
	
	if player_train:
		_setup_station(player_train.global_position)
		
	if level_manager and level_manager.has_signal("level_changed"):
		level_manager.level_changed.connect(_on_level_changed)


func _process(_delta: float) -> void:
	if not player_train:
		player_train = get_node_or_null("../Locomotive") as Node2D
		return

	var dist := player_train.global_position.distance_to(station_position)
	var dist_meters := int(dist / 10.0)

	# Update Distance Progress Bar & Label
	if distance_bar:
		distance_bar.max_value = start_distance / 10.0
		distance_bar.value = dist_meters

	if distance_label:
		if dist <= 80.0:
			distance_label.text = "🚉 STATION ARRIVED! Level Complete!"
			distance_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
			station_reached.emit(1)
		else:
			distance_label.text = "🚉 Station Ahead: %d m" % dist_meters
			distance_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)

	# Request minimap redraw
	if minimap_panel:
		minimap_panel.queue_redraw()


func _setup_station(player_start_pos: Vector2) -> void:
	# Place station 1500 units ahead along the Y axis
	station_position = player_start_pos + Vector2(0, -station_distance_meters)
	start_distance = station_distance_meters


func _on_level_changed(_num: int, _name: String) -> void:
	if player_train:
		_setup_station(player_train.global_position)
