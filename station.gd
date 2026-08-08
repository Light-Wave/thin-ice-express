extends Area2D
class_name TrainStation

signal station_entered(body: Node2D)

@export var station_name: String = "Central Fjord Station"
@export var platform_width: float = 240.0

var anim_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()


func _draw() -> void:
	# 1. Wooden Station Platform Dock
	draw_rect(Rect2(-platform_width / 2.0, -20, platform_width, 40), Color(0.35, 0.22, 0.12), true)
	draw_rect(Rect2(-platform_width / 2.0, -20, platform_width, 40), Color(0.85, 0.7, 0.3), false, 3.0) # Yellow Safety Edge

	# 2. Main Station Building House
	draw_rect(Rect2(-70, -110, 140, 90), Color(0.6, 0.18, 0.15), true) # Red Brick / Wood House
	draw_rect(Rect2(-70, -110, 140, 90), Color(0.2, 0.1, 0.08), false, 3.0)

	# Station Roof (Overhanging Canopy)
	var roof := PackedVector2Array([
		Vector2(-85, -110), Vector2(0, -145), Vector2(85, -110)
	])
	draw_colored_polygon(roof, Color(0.18, 0.22, 0.3))
	draw_polyline(roof, Color.WHITE, 2.0)

	# Clock Tower / Station Clock
	draw_circle(Vector2(0, -90), 12.0, Color.WHITE)
	draw_arc(Vector2(0, -90), 12.0, 0, TAU, 16, Color.BLACK, 2.0)
	# Clock Hands
	var hour_hand := Vector2.RIGHT.rotated(-PI/3.0) * 7.0
	var min_hand := Vector2.RIGHT.rotated(PI/6.0) * 10.0
	draw_line(Vector2(0, -90), Vector2(0, -90) + hour_hand, Color.BLACK, 2.0)
	draw_line(Vector2(0, -90), Vector2(0, -90) + min_hand, Color.BLACK, 1.5)

	# Station Windows & Door
	draw_rect(Rect2(-45, -70, 22, 28), Color(0.95, 0.85, 0.4), true) # Warm Yellow Window
	draw_rect(Rect2(23, -70, 22, 28), Color(0.95, 0.85, 0.4), true)  # Warm Yellow Window
	draw_rect(Rect2(-12, -60, 24, 40), Color(0.3, 0.15, 0.08), true) # Door

	# Glowing Green Signal Light
	var signal_glow := 0.7 + sin(anim_time * 5.0) * 0.3
	draw_circle(Vector2(-100, -50), 8.0, Color(0.1, 0.95, 0.3, signal_glow))
	draw_arc(Vector2(-100, -50), 10.0, 0, TAU, 12, Color.WHITE, 1.5)

	# Welcome Banner Text
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-80, -155), "🚉 WELCOME TO STATION", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(0.95, 0.9, 0.3))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("train") or body is CharacterBody2D:
		station_entered.emit(body)
