extends CanvasLayer
class_name GameBackground

@onready var background_control: Control = $Control

func _ready() -> void:
	# Set layer behind everything else in the game
	layer = -10
	if background_control:
		background_control.queue_redraw()


func _process(_delta: float) -> void:
	if background_control:
		background_control.queue_redraw()
