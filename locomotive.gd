extends RigidBody2D
class_name Locomotive

const FloatingPopupScript = preload("res://floating_popup.gd")

enum TrainType {
	VINTAGE_STEAM,  # Level 1 Tutorial: Heavy Vintage Steam Engine
	X2000_SERIES,   # Levels 2 & 3: Iconic Swedish X2000 Tilting High-Speed Train
	BULLET_TRAIN    # Levels 4 & 5: Ultra-sleek Aerodynamic Bullet Train
}

@export var current_train_type: TrainType = TrainType.VINTAGE_STEAM

@export var engine_force := 1200.0
@export var brake_force := 1500.0
@export var turn_torque := 15000.0
@export var max_speed := 250.0
@export var jolt_sensitivity := 0.05 ## Sensitivity for sharp turns causing passenger bumps
@export var lateral_ice_drag_coefficient: float = 6.0 ## Gentle lateral dampening resisting sideways slide on ice
@export var opposite_drag_drift_force: float = 180.0 ## Opposite side drag force when turning on ice
@export var bump_penalty_multiplier := 0.3

var prev_velocity := Vector2.ZERO
var passenger_ui: PassengerUI
var anim_time: float = 0.0
var bump_cooldown: float = 0.0
var lateral_grip := 1.0


func _ready() -> void:
	# Add locomotive to 'train' group so IceTile detects it
	add_to_group("train")
	
	# Hide default sprite if present so custom procedural graphics render
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

	# Find PassengerUI in current scene tree if available
	passenger_ui = get_node_or_null("../../PassengerUI") as PassengerUI
	
	set_train_type(current_train_type)


func set_train_type(type: TrainType) -> void:
	current_train_type = type
	match current_train_type:
		TrainType.VINTAGE_STEAM:
			max_speed = 220.0
			engine_force = 1000.0
		TrainType.X2000_SERIES:
			max_speed = 280.0
			engine_force = 1400.0
		TrainType.BULLET_TRAIN:
			max_speed = 350.0
			engine_force = 1800.0
	for child in get_parent().get_children():
		var visuals := child.get_node_or_null("Visuals") as Node2D
		if visuals:
			visuals.queue_redraw()

func _physics_process(delta: float) -> void:
	
	var forward := transform.x
	var sideways := transform.y

	# How much we're moving sideways
	var lateral_velocity := linear_velocity.dot(sideways)

	# Force opposing sideways movement
	var lateral_force := -sideways * lateral_velocity * lateral_grip

	apply_central_force(lateral_force)
	anim_time += delta
	if bump_cooldown > 0.0:
		bump_cooldown -= delta

	var throttle := Input.get_axis(
		"ui_down",
		"ui_up"
	)

	# Engine / braking
	if throttle > 0:
		apply_central_force(transform.x * engine_force)
	elif throttle < 0:
		apply_central_force(-transform.x * brake_force)

	# Limit maximum speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.limit_length(max_speed)

	# Steering
	var steering := Input.get_axis(
		"ui_left",
		"ui_right"
	)

	if absf(steering) > 0.0:
		apply_torque(steering * turn_torque)

	# Lateral Ice Drag & Opposite Side Drift Drag Physics
	var speed := linear_velocity.length()

	# Passenger bump from sharp turns
	if absf(steering) > 0.1 and speed > 100.0:
		var jolt := (
			speed / max_speed
			* absf(steering)
			* jolt_sensitivity
			* 100.0
			* delta
		)

		apply_passenger_bump(jolt, "SHARP TURN!")

	# Test bump key (Spacebar)
	if Input.is_action_just_pressed("ui_accept"):
		apply_passenger_bump(15.0, "TEST BUMP!")

	# Reset game key (R key)
	if Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()

	prev_velocity = linear_velocity


## Apply passenger bump/jolt to PassengerUI with visual bounce and floating text popup
func apply_passenger_bump(amount: float, reason: String = "BUMP!") -> void:
	var final_amount := amount * bump_penalty_multiplier
	if not passenger_ui:
		passenger_ui = get_node_or_null("../PassengerUI") as PassengerUI
		if not passenger_ui:
			passenger_ui = get_node_or_null("../../PassengerUI") as PassengerUI

	if passenger_ui:
		passenger_ui.apply_jolt(final_amount)

	# Visual train bounce tween
	if has_node("Visuals"):
		var tween := create_tween()
		tween.tween_property($Visuals, "scale", Vector2(1.15, 1.15), 0.06)
		tween.tween_property($Visuals, "scale", Vector2(1.0, 1.0), 0.06)

	# Spawn floating text popup above train
	if final_amount >= 1.0 and bump_cooldown <= 0.0:
		bump_cooldown = 0.4
		var popup_msg := "%s -%d" % [reason, max(1, int(final_amount))]
		FloatingPopupScript.spawn(get_parent(), global_position, popup_msg)
