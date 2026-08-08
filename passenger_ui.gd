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

@onready var comfort_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/ProgressBar
@onready var status_label: Label = $Control/MarginContainer/VBoxContainer/StatusLabel
@onready var title_label: Label = $Control/MarginContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	current_comfort = max_comfort
	_update_ui()


func _process(delta: float) -> void:
	if is_game_over:
		return

	# Slowly recover passenger comfort over time if not broken
	if current_comfort < max_comfort:
		current_comfort = minf(max_comfort, current_comfort + comfort_recovery_rate * delta)
		comfort_changed.emit(current_comfort)
		_update_ui()


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
		status_label.modulate = Color.RED


func _update_ui() -> void:
	if comfort_bar:
		comfort_bar.value = current_comfort

	if status_label and not is_game_over:
		var ratio := current_comfort / max_comfort
		if ratio > 0.7:
			status_label.text = "😴 Sleeping Soundly (zZz...)"
			status_label.modulate = Color(0.4, 0.9, 0.5) # Soft Green
		elif ratio > 0.35:
			status_label.text = "😳 Restless! Ride is Bumpy!"
			status_label.modulate = Color(0.95, 0.8, 0.2) # Orange/Yellow
		else:
			status_label.text = "😰 About to Wake Up! DANGER!"
			status_label.modulate = Color(0.95, 0.3, 0.3) # Bright Red
