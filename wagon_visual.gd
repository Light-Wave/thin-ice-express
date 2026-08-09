extends Node2D

@onready var wagon := get_parent() as TrainWagon

func _draw() -> void:
	$Sprite2D.hide()
	if not wagon.locomotive.current_train_type:
		_draw_vintage_wagon();
		return;
	match wagon.locomotive.current_train_type:
		Locomotive.TrainType.VINTAGE_STEAM:
			_draw_vintage_wagon()
		Locomotive.TrainType.X2000_SERIES:
			_draw_x2000_wagon()
		Locomotive.TrainType.BULLET_TRAIN:
			_draw_bullet_wagon()

## Level 1: Vintage Steam Coal Tender / Carriage 🚃
func _draw_vintage_wagon() -> void:
	# Heavy Cast Iron Coal Tender Chassis
	draw_rect(Rect2(-55, -18, 90, 36), Color(0.18, 0.18, 0.22), true)
	draw_rect(Rect2(-55, -18, 90, 36), Color(0.85, 0.7, 0.2), false, 2.0) # Gold Trim
	
	# Dark Coal Deposit Fill
	draw_rect(Rect2(-45, -12, 70, 24), Color(0.08, 0.08, 0.1), true)
	
	# Metallic Coupler Joint Pins
	draw_circle(Vector2(-55, 0), 4.0, Color(0.6, 0.6, 0.6))
	draw_circle(Vector2(35, 0), 4.0, Color(0.6, 0.6, 0.6))


## Levels 2 & 3: Swedish X2000 Passenger Carriage 🚆
func _draw_x2000_wagon() -> void:
	# Metallic Silver Streamlined Body
	draw_rect(Rect2(-56, -18, 92, 36), Color(0.85, 0.88, 0.92), true)
	draw_rect(Rect2(-56, -18, 92, 36), Color(0.4, 0.45, 0.5), false, 1.5)
	
	# Signature X2000 Blue Stripe
	draw_line(Vector2(-56, 0), Vector2(36, 0), Color(0.1, 0.35, 0.75), 4.0)
	
	# Tinted Passenger Windows
	for i in range(5):
		draw_rect(Rect2(-46 + (i * 16), -12, 11, 8), Color(0.15, 0.25, 0.4), true)
		draw_rect(Rect2(-46 + (i * 16), 4, 11, 8), Color(0.15, 0.25, 0.4), true)


## Levels 4 & 5: Futuristic Bullet Train Passenger Carriage 🚅
func _draw_bullet_wagon() -> void:
	# Sleek Pristine White Aerodynamic Body
	draw_rect(Rect2(-58, -16, 96, 32), Color(0.95, 0.98, 1.0), true)
	draw_rect(Rect2(-58, -16, 96, 32), Color(0.7, 0.8, 0.9), false, 1.5)
	
	# Cyan High-Speed Glow Stripe
	draw_line(Vector2(-58, 2), Vector2(38, 2), Color(0.0, 0.75, 0.85), 3.5)
	
	# Continuous Aerodynamic Visor Windows
	draw_rect(Rect2(-48, -10, 76, 7), Color(0.1, 0.15, 0.25), true)
