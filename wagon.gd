extends RigidBody2D
class_name TrainWagon

var locomotive_ref: Node2D
var anim_time: float = 0.0


@onready var locomotive := get_parent().get_node("Locomotive") as Locomotive
var bump_cooldown: float = 0.0
const FloatingPopupScript = preload("res://floating_popup.gd")

func _physics_process(delta: float) -> void:
	if bump_cooldown > 0.0:
		bump_cooldown -= delta

func _ready() -> void:
	add_to_group("train")
	
	# Hide default Godot mascot sprite node so custom era graphics render cleanly
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false

	$Visuals.queue_redraw()


func _process(delta: float) -> void:
	anim_time += delta
	
	# Match locomotive train era
	if not locomotive_ref or not is_instance_valid(locomotive_ref):
		locomotive_ref = get_node_or_null("../Locomotive") as Node2D
		if not locomotive_ref:
			locomotive_ref = get_node_or_null("../../Locomotive") as Node2D
	queue_redraw()


func apply_passenger_bump(amount: float, reason:String = "") -> void:
	var final_amount := amount * locomotive.bump_penalty_multiplier
	if locomotive.passenger_ui:
		locomotive.passenger_ui.apply_jolt(final_amount)

	# Visual train bounce tween
	var tween := create_tween()
	tween.tween_property($Visuals, "scale", Vector2(1.15, 1.15), 0.06)
	tween.tween_property($Visuals, "scale", Vector2(1.0, 1.0), 0.06)

	# Spawn floating text popup above train
	if final_amount >= 1.0 and bump_cooldown <= 0.0:
		bump_cooldown = 0.4
		var popup_msg := "%s -%d" % [reason, max(1, int(final_amount))]
		FloatingPopupScript.spawn(get_parent(), global_position, popup_msg)
