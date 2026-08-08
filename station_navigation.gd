extends CanvasLayer
class_name StationNavigation

## Emitted when the train reaches the station destination
signal station_reached(level_num: int)

@export var station_distance_meters: float = 1500.0 ## Distance from start to station in meters

var player_train: Node2D
var station_position: Vector2 = Vector2.ZERO
var start_distance: float = 1500.0
var level_manager: Node
var level_completed: bool = false

# High Contrast Dark Font Colors
const COLOR_TEXT_DARK := Color(0.06, 0.12, 0.24, 1.0) # Deep Navy
const COLOR_TEXT_GOLD := Color(0.7, 0.5, 0.0, 1.0)    # Dark Gold

@onready var distance_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/ProgressBar
@onready var distance_label: Label = $Control/MarginContainer/VBoxContainer/DistanceLabel
@onready var minimap_panel: Control = $Control/MinimapPanel


var anim_time: float = 0.0


func _ready() -> void:
	player_train = get_node_or_null("../Locomotive") as Node2D
	level_manager = get_node_or_null("../LevelManager")
	
	if distance_label:
		distance_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)
		distance_label.add_theme_color_override("font_outline_color", Color.WHITE)
		distance_label.add_theme_constant_override("outline_size", 4)
	
	var cur_lvl := 1
	if level_manager and "current_level" in level_manager:
		cur_lvl = level_manager.current_level

	station_distance_meters = get_distance_for_level(cur_lvl)
	if player_train:
		_setup_station(player_train.global_position)
		
	if level_manager and level_manager.has_signal("level_changed"):
		level_manager.level_changed.connect(_on_level_changed)


func get_distance_for_level(level_num: int) -> float:
	# Level 1 Tutorial: 250m. Successive levels grow progressively (+250m per level)
	return 250.0 + (level_num - 1) * 250.0


func _process(delta: float) -> void:
	anim_time += delta
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
		if dist <= 80.0 and not level_completed:
			level_completed = true
			distance_label.text = "🎉 LEVEL COMPLETE!"
			distance_label.add_theme_color_override("font_color", COLOR_TEXT_GOLD)
			
			var cur_lvl := 1
			if level_manager and "current_level" in level_manager:
				cur_lvl = level_manager.current_level
				
			station_reached.emit(cur_lvl)
			
			# Trigger Level Complete Celebration UI overlay
			var complete_ui := get_node_or_null("../LevelCompleteUI")
			if complete_ui and complete_ui.has_method("show_celebration"):
				complete_ui.show_celebration(cur_lvl)
			elif level_manager and level_manager.has_method("advance_to_next_level"):
				level_manager.advance_to_next_level()

		elif not level_completed:
			distance_label.text = "🚉 Station Ahead: %d m" % dist_meters
			distance_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)

	# Request minimap redraw
	if minimap_panel:
		minimap_panel.queue_redraw()


func _setup_station(player_start_pos: Vector2) -> void:
	# Place station at the furthest turn ahead along the icy lake valley path
	var dist_units := station_distance_meters * 10.0
	station_position = player_start_pos + Vector2(0, -dist_units)
	start_distance = dist_units
	level_completed = false

	# Sync GeoMap station position if present
	var geo_map = get_node_or_null("../GeoMap")
	if geo_map and "station_world_pos" in geo_map:
		geo_map.station_world_pos = station_position


func _on_level_changed(num: int, _name: String) -> void:
	station_distance_meters = get_distance_for_level(num)
	if player_train:
		_setup_station(player_train.global_position)
