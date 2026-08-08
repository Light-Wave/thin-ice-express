extends CanvasLayer
class_name PassengerUI

## Emitted when passenger comfort reaches 0% and all passengers wake up!
signal passengers_woken_up

## Emitted whenever comfort value changes
signal comfort_changed(current_comfort: float)

@export var max_comfort: float = 100.0
@export var comfort_recovery_rate: float = 2.0 ## Comfort recovered per second when smooth

var current_comfort: float = 100.0
var is_game_over: bool = false

# High Contrast Dark Font Colors for Light Blue Backgrounds
const COLOR_TEXT_DARK := Color(0.06, 0.12, 0.24, 1.0)     # Deep Navy
const COLOR_STATUS_GREEN := Color(0.05, 0.5, 0.15, 1.0)    # Dark Forest Green
const COLOR_STATUS_ORANGE := Color(0.75, 0.35, 0.0, 1.0)   # Dark Amber
const COLOR_STATUS_RED := Color(0.8, 0.05, 0.05, 1.0)     # Dark Crimson

@onready var comfort_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/ProgressBar
@onready var status_label: Label = $Control/MarginContainer/VBoxContainer/StatusLabel
@onready var title_label: Label = $Control/MarginContainer/VBoxContainer/TitleLabel
@onready var level_label: Label = $Control/MarginContainer/VBoxContainer/LevelLabel


func _ready() -> void:
	current_comfort = max_comfort
	_apply_dark_font_theme()
	_update_ui()
	
	# Connect to LevelManager decoupled
	var level_manager = get_node_or_null("../LevelManager")
	if level_manager and level_manager.has_signal("level_changed"):
		level_manager.level_changed.connect(_on_level_changed)
		if "current_level" in level_manager:
			set_level_name("Level %d" % level_manager.current_level)


func _apply_dark_font_theme() -> void:
	if level_label:
		level_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)
		level_label.add_theme_color_override("font_outline_color", Color.WHITE)
		level_label.add_theme_constant_override("outline_size", 4)

	if title_label:
		title_label.add_theme_color_override("font_color", COLOR_TEXT_DARK)
		title_label.add_theme_color_override("font_outline_color", Color.WHITE)
		title_label.add_theme_constant_override("outline_size", 4)

	if status_label:
		status_label.add_theme_color_override("font_outline_color", Color.WHITE)
		status_label.add_theme_constant_override("outline_size", 4)


func _process(delta: float) -> void:
	if is_game_over:
		return

	# Slowly recover passenger comfort over time if not broken
	if current_comfort < max_comfort:
		current_comfort = minf(max_comfort, current_comfort + comfort_recovery_rate * delta)
		comfort_changed.emit(current_comfort)
		_update_ui()


## Set Level Title in HUD
func set_level_name(level_text: String) -> void:
	if level_label:
		level_label.text = level_text


func _on_level_changed(_num: int, level_name: String) -> void:
	set_level_name(level_name)


## Call this function whenever a bump, sharp turn, or collision occurs
func apply_jolt(amount: float) -> void:
	if is_game_over:
		return

	current_comfort = maxf(0.0, current_comfort - amount)
	comfort_changed.emit(current_comfort)
	_update_ui()

	if current_comfort <= 0.0:
		_trigger_game_over()


## Reset comfort back to 100%
func reset_comfort() -> void:
	current_comfort = max_comfort
	is_game_over = false
	comfort_changed.emit(current_comfort)
	_update_ui()


func _trigger_game_over() -> void:
	is_game_over = true
	passengers_woken_up.emit()
	if status_label:
		status_label.text = "😱 WOKEN UP! Passengers Panicked!"
		status_label.add_theme_color_override("font_color", COLOR_STATUS_RED)


func _update_ui() -> void:
	if comfort_bar:
		comfort_bar.value = current_comfort

	if status_label and not is_game_over:
		var ratio := current_comfort / max_comfort
		if ratio > 0.7:
			status_label.text = "😴 Sleeping Soundly (zZz...)"
			status_label.add_theme_color_override("font_color", COLOR_STATUS_GREEN)
		elif ratio > 0.35:
			status_label.text = "😳 Restless! Ride is Bumpy!"
			status_label.add_theme_color_override("font_color", COLOR_STATUS_ORANGE)
		else:
			status_label.text = "😰 About to Wake Up! DANGER!"
			status_label.add_theme_color_override("font_color", COLOR_STATUS_RED)
