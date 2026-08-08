extends Area2D
class_name IceTile

## Emitted when the ice tile cracks further (level 1, 2, etc.)
signal ice_cracked(crack_level: int)

## Emitted when the ice tile breaks completely into water
signal ice_broken

@export var max_cracks: int = 3
@export var time_between_cracks: float = 2.5 ## Seconds train must remain on tile before cracking further (for slow driver comfort)
@export var tile_size: Vector2 = Vector2(96, 96)


var crack_level: int = 0
var is_broken: bool = false
var train_on_tile: bool = false
var crack_timer: float = 0.0

# Animation timers & variables
var anim_time: float = 0.0
var wobble_offset := Vector2.ZERO
var melt_scale: float = 1.0
var melt_alpha: float = 1.0

# Color Palette for Ice -> Cracks -> Water
const COLOR_ICE_BASE := Color(0.7, 0.9, 1.0, 1.0)       # Shiny Ice Blue
const COLOR_ICE_BORDER := Color(0.9, 0.98, 1.0, 1.0)    # Crisp White Border
const COLOR_CRACK_LIGHT := Color(0.3, 0.6, 0.8, 1.0)    # Light Crack Lines
const COLOR_CRACK_HEAVY := Color(0.9, 0.3, 0.3, 1.0)    # Danger Red Cracks
const COLOR_WATER_BASE := Color(0.1, 0.35, 0.65, 0.85)  # Deep Water Blue
const COLOR_RIPPLE := Color(0.3, 0.65, 0.9, 0.6)        # Water Ripple


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide sprite if present so custom procedural drawing renders cleanly
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false
		
	queue_redraw()


func _process(delta: float) -> void:
	anim_time += delta

	# Wobble animation if heavily cracked (stage 2)
	if crack_level == 2 and not is_broken:
		wobble_offset = Vector2(
			sin(anim_time * 25.0) * 3.0,
			cos(anim_time * 25.0) * 3.0
		)
	else:
		wobble_offset = Vector2.ZERO

	# Test key 'M' to manually trigger ice crack/melting animation
	if Input.is_physical_key_pressed(KEY_M) and train_on_tile:
		advance_crack()

	# Process cracking timer if train is standing on tile
	if train_on_tile and not is_broken:
		crack_timer += delta
		if crack_timer >= time_between_cracks:
			crack_timer = 0.0
			advance_crack()

	queue_redraw()


func _draw() -> void:
	var rect = Rect2(-tile_size / 2.0 + wobble_offset, tile_size * melt_scale)

	if is_broken:
		# Draw Deep Water with Animated Ripples
		draw_rect(rect, COLOR_WATER_BASE, true)
		
		# Animated Water Ripples
		var ripple_radius := fmod(anim_time * 30.0, tile_size.x * 0.4)
		draw_arc(wobble_offset, ripple_radius, 0, TAU, 16, COLOR_RIPPLE, 2.0)
		draw_rect(rect, COLOR_WATER_BASE.darkened(0.2), false, 2.0)
		return

	# Draw Base Ice Tile Block
	var base_color := COLOR_ICE_BASE
	if crack_level == 1:
		base_color = COLOR_ICE_BASE.lerp(Color(0.5, 0.8, 0.9), 0.5)
	elif crack_level == 2:
		base_color = COLOR_ICE_BASE.lerp(Color(0.8, 0.4, 0.4), 0.4) # Flashes reddish warning

	draw_rect(rect, base_color, true)
	draw_rect(rect, COLOR_ICE_BORDER, false, 3.0)

	# Draw Crack Lines based on crack level
	var half := tile_size / 2.0
	if crack_level >= 1:
		# Light Crack Lines
		draw_line(-half + Vector2(10, 10), half - Vector2(20, 10), COLOR_CRACK_LIGHT, 3.0)
		draw_line(Vector2(0, -half.y + 10), Vector2(-15, 10), COLOR_CRACK_LIGHT, 2.5)

	if crack_level >= 2:
		# Heavy Fractured Spiderweb Cracks
		draw_line(-half + Vector2(15, half.y - 15), half - Vector2(10, half.y - 10), COLOR_CRACK_HEAVY, 3.5)
		draw_line(Vector2(-half.x + 10, 0), Vector2(half.x - 10, 5), COLOR_CRACK_HEAVY, 3.0)
		draw_line(Vector2(10, -half.y + 15), Vector2(-10, half.y - 15), COLOR_CRACK_HEAVY, 3.0)


## Advance crack level by 1 step with visual pop animation
func advance_crack() -> void:
	if is_broken:
		return

	crack_level += 1
	ice_cracked.emit(crack_level)

	# Create a quick bounce/pop scale effect when cracking
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)

	if crack_level >= max_cracks:
		break_ice()

	queue_redraw()


## Break the ice tile into water with dissolve/melting animation
func break_ice() -> void:
	is_broken = true
	ice_broken.emit()

	# Animated Melting / Sinking Dissolve Effect
	var tween = create_tween()
	tween.parallel().tween_property(self, "melt_scale", 0.2, 0.4)
	tween.parallel().tween_property(self, "modulate:a", 0.7, 0.4)
	tween.tween_property(self, "melt_scale", 1.0, 0.1)

	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		train_on_tile = true
		crack_timer = 0.0
		if is_broken:
			if body.has_method("apply_passenger_bump"):
				body.apply_passenger_bump(25.0, "SPLASH WATER!")
		else:
			if body.has_method("apply_passenger_bump"):
				body.apply_passenger_bump(8.0, "ICE BUMP!")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		train_on_tile = false
		crack_timer = 0.0
