extends RigidBody2D

func _ready() -> void:
	# Add locomotive to 'train' group so IceTile detects it
	add_to_group("train")
