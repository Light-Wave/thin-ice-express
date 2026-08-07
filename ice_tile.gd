extends Area2D
class_name IceTile

## Emitted when the ice tile cracks further (level 1, 2, etc.)
signal ice_cracked(crack_level: int)

## Emitted when the ice tile breaks completely into water
signal ice_broken

@export var max_cracks: int = 3
@export var time_between_cracks: float = 0.6 ## Seconds a train must remain on tile before cracking further

var crack_level: int = 0
var is_broken: bool = false
var train_on_tile: bool = false
var crack_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Visual color modulation for crack states (Solid Ice -> Light Cracks -> Heavy Cracks -> Water)
const COLOR_SOLID := Color(0.85, 0.95, 1.0, 1.0)
const COLOR_CRACKED_LIGHT := Color(0.65, 0.85, 0.95, 1.0)
const COLOR_CRACKED_HEAVY := Color(0.45, 0.70, 0.90, 1.0)
const COLOR_WATER := Color(0.1, 0.3, 0.6, 0.7)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visuals()


func _process(delta: float) -> void:
	if is_broken or not train_on_tile:
		return

	crack_timer += delta
	if crack_timer >= time_between_cracks:
		crack_timer = 0.0
		advance_crack()


## Advance crack level by 1 step
func advance_crack() -> void:
	if is_broken:
		return

	crack_level += 1
	ice_cracked.emit(crack_level)
	_update_visuals()

	if crack_level >= max_cracks:
		break_ice()


## Break the ice tile into water
func break_ice() -> void:
	is_broken = true
	ice_broken.emit()
	_update_visuals()


## Update visual representation based on current crack level
func _update_visuals() -> void:
	if not sprite:
		return

	match crack_level:
		0:
			sprite.modulate = COLOR_SOLID
		1:
			sprite.modulate = COLOR_CRACKED_LIGHT
		2:
			sprite.modulate = COLOR_CRACKED_HEAVY
		_:
			sprite.modulate = COLOR_WATER


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		train_on_tile = true
		crack_timer = 0.0
		advance_crack()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		train_on_tile = false
		crack_timer = 0.0
