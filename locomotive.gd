extends CharacterBody2D
class_name Locomotive

enum TrainType {
	VINTAGE_STEAM,  # Level 1 Tutorial: Heavy Vintage Steam Engine
	X2000_SERIES,   # Levels 2 & 3: Iconic Swedish X2000 Tilting High-Speed Train
	BULLET_TRAIN    # Levels 4 & 5: Ultra-sleek Aerodynamic Bullet Train
}

@export var current_train_type: TrainType = TrainType.VINTAGE_STEAM

@export var acceleration := 120.0
@export var max_speed := 250.0
@export var braking := 300.0
@export var turn_speed := 2.0
@export var jolt_sensitivity := 0.05 ## Sensitivity for sharp turns causing passenger bumps

var prev_velocity := Vector2.ZERO
var passenger_ui: PassengerUI
var anim_time: float = 0.0
var bump_cooldown: float = 0.0


func _ready() -> void:
	# Add locomotive to 'train' group so IceTile detects it
	add_to_group("train")
	
	# Hide default sprite if present so custom procedural graphics render
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

	# Find PassengerUI in current scene tree if available
	passenger_ui = get_node_or_null("../PassengerUI") as PassengerUI
	
	set_train_type(current_train_type)


func set_train_type(type: TrainType) -> void:
	current_train_type = type
	match current_train_type:
		TrainType.VINTAGE_STEAM:
			max_speed = 220.0
			acceleration = 100.0
		TrainType.X2000_SERIES:
			max_speed = 280.0
			acceleration = 140.0
		TrainType.BULLET_TRAIN:
			max_speed = 350.0
			acceleration = 180.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	anim_time += delta
	if bump_cooldown > 0.0:
		bump_cooldown -= delta

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
	if absf(steering) > 0.1 and speed > 80.0 and bump_cooldown <= 0.0:
		var jolt := (speed / max_speed) * absf(steering) * jolt_sensitivity * 100.0 * delta
		apply_passenger_bump(jolt, "SHARP TURN!")

	# Test bump key (Spacebar) for quick testing
	if Input.is_action_just_pressed("ui_accept"):
		apply_passenger_bump(15.0, "TEST BUMP!")

	# Reset game key (R key)
	if Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()

	prev_velocity = velocity
	move_and_slide()
	queue_redraw()


## Apply passenger bump/jolt to PassengerUI with visual bounce and floating text popup
func apply_passenger_bump(amount: float, reason: String = "BUMP!") -> void:
	if passenger_ui:
		passenger_ui.apply_jolt(amount)

	# Visual train bounce tween
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.06)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06)

	# Spawn floating text popup above train
	if amount >= 5.0 and bump_cooldown <= 0.0:
		bump_cooldown = 0.4
		var popup_msg := "%s -%d" % [reason, int(amount)]
		FloatingPopup.spawn(get_parent(), global_position, popup_msg)


func _draw() -> void:
	match current_train_type:
		TrainType.VINTAGE_STEAM:
			_draw_vintage_steam()
		TrainType.X2000_SERIES:
			_draw_x2000_series()
		TrainType.BULLET_TRAIN:
			_draw_bullet_train()


## Level 1: Vintage Steam Engine 🚂
func _draw_vintage_steam() -> void:
	# Heavy Cast Iron Boiler Body
	draw_rect(Rect2(-60, -20, 100, 40), Color(0.2, 0.2, 0.25), true)
	draw_rect(Rect2(-60, -20, 100, 40), Color(0.85, 0.7, 0.2), false, 2.5) # Gold Trim
	
	# Driver Cabin
	draw_rect(Rect2(-60, -25, 35, 50), Color(0.3, 0.15, 0.1), true) # Wooden Cabin
	draw_rect(Rect2(-55, -20, 12, 14), Color(0.9, 0.9, 0.7), true)  # Cabin Window
	
	# Smokestack & Chimney
	draw_rect(Rect2(25, -28, 12, 16), Color(0.1, 0.1, 0.1), true)
	
	# Animated Steam Puffs
	if velocity.length() > 10.0:
		var puff_size := 6.0 + sin(anim_time * 15.0) * 3.0
		draw_circle(Vector2(31 + cos(anim_time * 10.0) * 5.0, -35), puff_size, Color(0.95, 0.95, 0.95, 0.7))


## Levels 2 & 3: Swedish X2000 Tilting High-Speed Train 🚆
func _draw_x2000_series() -> void:
	# Sleek Silver & Blue Aerodynamic Body
	var points := PackedVector2Array([
		Vector2(-64, -20),
		Vector2(40, -20),
		Vector2(64, 0),    # Angled Nose Cone
		Vector2(40, 20),
		Vector2(-64, 20)
	])
	draw_colored_polygon(points, Color(0.85, 0.88, 0.92)) # Metallic Silver
	draw_polyline(points, Color(0.1, 0.35, 0.75), 3.0)    # X2000 Signature Blue Stripe
	
	# Passenger Tinted Windows
	for i in range(4):
		draw_rect(Rect2(-45 + (i * 20), -12, 14, 8), Color(0.15, 0.25, 0.4), true)


## Levels 4 & 5: Futuristic Bullet Train 🚅
func _draw_bullet_train() -> void:
	# Ultra-aerodynamic Bullet Nose
	var points := PackedVector2Array([
		Vector2(-70, -18),
		Vector2(30, -18),
		Vector2(75, 0),    # Sharp Bullet Nose Cone
		Vector2(30, 18),
		Vector2(-70, 18)
	])
	draw_colored_polygon(points, Color(0.95, 0.98, 1.0)) # Pristine White
	draw_polyline(points, Color(0.0, 0.75, 0.85), 3.5)   # Cyan High-Speed Glow Stripe
	
	# Sleek Tinted Visor
	var visor_points := PackedVector2Array([
		Vector2(20, -10), Vector2(50, -5), Vector2(50, 5), Vector2(20, 10)
	])
	draw_colored_polygon(visor_points, Color(0.1, 0.15, 0.25))
