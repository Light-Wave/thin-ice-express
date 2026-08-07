@export var acceleration := 200.0
@export var max_speed := 500.0
@export var braking := 300.0
@export var turn_speed := 2.0


func _physics_process(delta):
	var throttle := Input.get_axis(
		"train_brake",
        "train_accelerate"
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
		"train_turn_left",
        "train_turn_right"
	)

	rotation += steering * turn_speed * delta

	move_and_slide()
