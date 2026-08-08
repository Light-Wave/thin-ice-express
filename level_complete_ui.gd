extends CanvasLayer
class_name LevelCompleteUI

## Emitted when player clicks the proceed button to start the next level
signal proceed_requested

@onready var header_label: Label = $Control/Panel/MarginContainer/VBoxContainer/HeaderLabel
@onready var congrats_label: Label = $Control/Panel/MarginContainer/VBoxContainer/CongratsLabel
@onready var next_title_label: Label = $Control/Panel/MarginContainer/VBoxContainer/NextTitleLabel
@onready var hazard_desc_label: Label = $Control/Panel/MarginContainer/VBoxContainer/HazardDescLabel
@onready var proceed_button: Button = $Control/Panel/MarginContainer/VBoxContainer/ProceedButton

var next_level_id: int = 2


func _ready() -> void:
	visible = false
	if proceed_button:
		proceed_button.pressed.connect(_on_proceed_pressed)


## Show Celebration Screen with stats and next level hazard preview
func show_celebration(completed_level: int) -> void:
	next_level_id = completed_level + 1 if completed_level < 5 else 1

	if header_label:
		header_label.text = "🎉 LEVEL %d COMPLETE!" % completed_level

	if congrats_label:
		congrats_label.text = " Passengers Stayed Asleep! Excellent Driving!"

	var next_title := ""
	var hazard_text := ""

	match next_level_id:
		2:
			next_title = "COMING UP: Level 2 - Pine Forest Crossing (X2000 Train 🚆)"
			hazard_text = "⚠️ HAZARDS AHEAD:\n• Unlocked Swedish X2000 Tilting Train!\n• 20% Thin Ice Patches & Narrow Rivers.\n• 40% Penalty Discount Active."
		3:
			next_title = "COMING UP: Level 3 - Midnight Blizzard Pass (X2000 Train 🚆)"
			hazard_text = "⚠️ HAZARDS AHEAD:\n• High-altitude Blizzard Winds.\n• 35% Thin Ice Patches & 10% Open Water Gaps.\n• Standard Bump Penalties Active."
		4:
			next_title = "COMING UP: Level 4 - Fragile Bridge Crossing (Bullet Train 🚅)"
			hazard_text = "⚠️ HAZARDS AHEAD:\n• Unlocked Ultra-Fast Bullet Train!\n• 45% Thin Ice over Deep Bridge Chasms.\n• Higher Penalty Sensitivity!"
		5:
			next_title = "COMING UP: Level 5 - The Dawn Dash (Final Run 🚅)"
			hazard_text = "⚠️ HAZARDS AHEAD:\n• The Final Challenge! Reach the harbor before sunrise!\n• 55% Thin Ice & 20% Open Water Gaps.\n• Maximum Penalty Sensitivity!"
		_:
			next_title = "COMING UP: Victory Lap! (Level 1 Tutorial 🚂)"
			hazard_text = "⚠️ REPLAY TUTORIAL:\n• Return to the Calm Fjord for a relaxed victory lap!"

	if next_title_label:
		next_title_label.text = next_title

	if hazard_desc_label:
		hazard_desc_label.text = hazard_text

	if proceed_button:
		proceed_button.text = "PROCEED TO LEVEL %d ➔" % next_level_id

	visible = true
	get_tree().paused = true


func _on_proceed_pressed() -> void:
	visible = false
	get_tree().paused = false
	proceed_requested.emit()
	
	var level_manager := get_node_or_null("../LevelManager")
	if level_manager and level_manager.has_method("advance_to_next_level"):
		level_manager.advance_to_next_level()
