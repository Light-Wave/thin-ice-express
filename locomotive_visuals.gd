extends Node2D

@onready var locomotive := get_parent() as Locomotive

func _draw() -> void:
	match locomotive.current_train_type:
		Locomotive.TrainType.VINTAGE_STEAM:
			_draw_vintage_steam()
		Locomotive.TrainType.X2000_SERIES:
			_draw_x2000_series()
		Locomotive.TrainType.BULLET_TRAIN:
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
	if locomotive.linear_velocity.length() > 10.0:
		var puff_size := 6.0 + sin(locomotive.anim_time * 15.0) * 3.0
		draw_circle(Vector2(31 + cos(locomotive.anim_time * 10.0) * 5.0, -35), puff_size, Color(0.95, 0.95, 0.95, 0.7))


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
