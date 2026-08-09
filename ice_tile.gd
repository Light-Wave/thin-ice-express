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
var active_bodies: Array[Node2D] = []

# Animation timers & variables
var anim_time: float = 0.0
var wobble_offset := Vector2.ZERO
var melt_scale: float = 1.0
var melt_alpha: float = 1.0

# Dynamic Proximity Ahead Detection
var is_approaching: bool = false
var approach_intensity: float = 0.0
var player_train_ref: Node2D

# Color Palette for Ice -> Cracks -> Water
const COLOR_ICE_BASE := Color(0.75, 0.9, 1.0, 0.15)      # Translucent Glassy Ice Sheet (85% transparent!)
const COLOR_ICE_BORDER := Color(0.9, 0.98, 1.0, 0.35)    # Subtle Frost Border (65% transparent)
const COLOR_CRACK_LIGHT := Color(0.3, 0.6, 0.8, 0.9)    # Crisp Light Crack Lines
const COLOR_CRACK_HEAVY := Color(0.95, 0.3, 0.3, 0.95)  # Vivid Red Danger Cracks
const COLOR_WATER_BASE := Color(0.1, 0.35, 0.65, 0.75)  # Deep Water Blue
const COLOR_RIPPLE := Color(0.3, 0.65, 0.9, 0.8)        # Water Ripple
const COLOR_ICE_GLOW := Color(0.4, 0.85, 1.0, 0.5)      # Proximity Warning Glow
const COLOR_GLASS_SHEEN := Color(1.0, 1.0, 1.0, 0.25)   # Crystalline Glass Highlight Sheen


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

	# Track train proximity to dynamically change icy path in front of train as it nears
	if not player_train_ref or not is_instance_valid(player_train_ref):
		player_train_ref = get_node_or_null("../Train/Locomotive") as Node2D
		if not player_train_ref:
			player_train_ref = get_node_or_null("../Locomotive") as Node2D

	if player_train_ref and not is_broken:
		var dist := global_position.distance_to(player_train_ref.global_position)
		if dist < 180.0:
			is_approaching = true
			approach_intensity = clampf(1.0 - (dist / 180.0), 0.0, 1.0)
		else:
			is_approaching = false
			approach_intensity = 0.0
	else:
		is_approaching = false
		approach_intensity = 0.0

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
	var half := tile_size / 2.0

	if is_broken:
		# Draw Deep Open Water with Animated Ripples and Splashing Floes
		draw_rect(rect, COLOR_WATER_BASE, true)
		var ripple_radius := fmod(anim_time * 30.0, tile_size.x * 0.45)
		draw_arc(wobble_offset, ripple_radius, 0, TAU, 16, COLOR_RIPPLE, 2.0)
		draw_rect(rect, COLOR_WATER_BASE.darkened(0.2), false, 2.0)
		return

	# Draw Base Ice Layer:
	# Unbroken ice (crack_level == 0) is 100% transparent so high-res top-down frozen lake artwork shines through seamlessly!
	if crack_level == 1:
		draw_rect(rect, Color(0.4, 0.75, 0.95, 0.25), true)
	elif crack_level == 2:
		draw_rect(rect, Color(0.9, 0.3, 0.3, 0.35), true) # Flashes reddish warning

	# Hairline stress lines forming under approaching engine weight
	if is_approaching and not is_broken and crack_level == 0:
		var line_color := Color(0.6, 0.88, 1.0, approach_intensity * 0.7)
		draw_line(Vector2(-half.x + 15, 0), Vector2(half.x - 15, 0), line_color, 1.5)

	# Draw Crack Lines based on crack level
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
		if not active_bodies.has(body):
			active_bodies.append(body)
		
		var is_first_body := active_bodies.size() == 1
		train_on_tile = true

		if is_broken:
			if body.has_method("apply_passenger_bump"):
				body.apply_passenger_bump(25.0, "SPLASH WATER!")
		else:
			if is_first_body:
				crack_timer = 0.0
				advance_crack()
				if body.has_method("apply_passenger_bump"):
					body.apply_passenger_bump(8.0, "ICE BUMP!")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		active_bodies.erase(body)
		if active_bodies.is_empty():
			train_on_tile = false
			crack_timer = 0.0
