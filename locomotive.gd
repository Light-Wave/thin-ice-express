extends CharacterBody2D

@export var acceleration := 200.0
@export var max_speed := 500.0
@export var braking := 300.0
@export var turn_speed := 2.0
@export var jolt_sensitivity := 0.05 ## Sensitivity for sharp turns causing passenger bumps

var prev_velocity := Vector2.ZERO
var passenger_ui: PassengerUI


func _ready() -> void:
	# Add locomotive to 'train' group so IceTile detects it
	add_to_group("train")
	
	# Find PassengerUI in current scene tree if available
	passenger_ui = get_node_or_null("../PassengerUI") as PassengerUI


func _physics_process(delta: float) -> void:
	var throttle := Input.get_axis(
		"ui_down",
		"ui_up"
	)

	if throttle > 0:
		velocity += transform.x * acceleration * delta
	elif throttle < 0:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			braking * delta
		)

	velocity = velocity.limit_length(max_speed)

	var steering := Input.get_axis(
		"ui_left",
		"ui_right"
	)

	rotation += steering * turn_speed * delta

	# Calculate speed & sharp turning jolt for passenger comfort
	var speed := velocity.length()
	if absf(steering) > 0.1 and speed > 100.0:
		var jolt := (speed / max_speed) * absf(steering) * jolt_sensitivity * 100.0 * delta
		apply_passenger_bump(jolt)

	# Test bump key (Spacebar) for quick testing
	if Input.is_action_just_pressed("ui_accept"):
		apply_passenger_bump(15.0)

	prev_velocity = velocity
	move_and_slide()


## Apply passenger bump/jolt to PassengerUI
func apply_passenger_bump(amount: float) -> void:
	if passenger_ui:
		passenger_ui.apply_jolt(amount)
