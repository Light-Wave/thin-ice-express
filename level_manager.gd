extends Node
class_name LevelManager

## Emitted when level changes
signal level_changed(level_num: int, level_name: String)

@export var current_level: int = 1

var locomotive: Node2D
var ice_generator: Node2D
var passenger_ui: CanvasLayer


func _ready() -> void:
	# Find dependencies in current scene
	locomotive = get_node_or_null("../Locomotive") as Node2D
	ice_generator = get_node_or_null("../IceGenerator") as Node2D
	passenger_ui = get_node_or_null("../PassengerUI") as CanvasLayer

	load_level(current_level)


func _process(_delta: float) -> void:
	# Level jump shortcut keys (Keys 1, 2, 3, 4, 5) for rapid testing
	if Input.is_physical_key_pressed(KEY_1): load_level(1)
	elif Input.is_physical_key_pressed(KEY_2): load_level(2)
	elif Input.is_physical_key_pressed(KEY_3): load_level(3)
	elif Input.is_physical_key_pressed(KEY_4): load_level(4)
	elif Input.is_physical_key_pressed(KEY_5): load_level(5)


## Advance to the next level automatically upon completing a level
func advance_to_next_level() -> void:
	if current_level < 5:
		load_level(current_level + 1)
	else:
		load_level(1) # Loop back to tutorial upon completing Level 5


func load_level(level_num: int) -> void:
	current_level = clampi(level_num, 1, 5)
	var level_name := ""

	if not locomotive:
		locomotive = get_node_or_null("../Locomotive") as Node2D
	if not ice_generator:
		ice_generator = get_node_or_null("../IceGenerator") as Node2D

	match current_level:
		1:
			level_name = "Level 1: The Calm Fjord (Tutorial)"
			if locomotive:
				if locomotive.has_method("set_train_type"): locomotive.set_train_type(0) # 0 = Vintage Steam
				locomotive.bump_penalty_multiplier = 0.3 # 70% penalty discount for tutorial
			if ice_generator:
				ice_generator.thin_ice_chance = 0.05
				ice_generator.water_gap_chance = 0.0
		2:
			level_name = "Level 2: Pine Forest Crossing"
			if locomotive:
				if locomotive.has_method("set_train_type"): locomotive.set_train_type(1) # 1 = X2000 Series
				locomotive.bump_penalty_multiplier = 0.6 # 40% penalty discount for Level 2
			if ice_generator:
				ice_generator.thin_ice_chance = 0.20
				ice_generator.water_gap_chance = 0.05
		3:
			level_name = "Level 3: Midnight Blizzard Pass"
			if locomotive:
				if locomotive.has_method("set_train_type"): locomotive.set_train_type(1) # 1 = X2000 Series
				locomotive.bump_penalty_multiplier = 1.0 # Standard penalty
			if ice_generator:
				ice_generator.thin_ice_chance = 0.35
				ice_generator.water_gap_chance = 0.10
		4:
			level_name = "Level 4: Fragile Bridge Crossing"
			if locomotive:
				if locomotive.has_method("set_train_type"): locomotive.set_train_type(2) # 2 = Bullet Train
				locomotive.bump_penalty_multiplier = 1.3
			if ice_generator:
				ice_generator.thin_ice_chance = 0.45
				ice_generator.water_gap_chance = 0.15
		5:
			level_name = "Level 5: The Dawn Dash (Final Run)"
			if locomotive:
				if locomotive.has_method("set_train_type"): locomotive.set_train_type(2) # 2 = Bullet Train
				locomotive.bump_penalty_multiplier = 1.5
			if ice_generator:
				ice_generator.thin_ice_chance = 0.55
				ice_generator.water_gap_chance = 0.20

	level_changed.emit(current_level, level_name)
	print("Loaded %s (Penalty Multiplier: %.1fx)" % [level_name, locomotive.bump_penalty_multiplier if locomotive else 1.0])
