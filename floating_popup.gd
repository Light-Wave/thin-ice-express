extends Node2D
class_name FloatingPopup

static func spawn(parent_node: Node, pos: Vector2, text_msg: String, font_color: Color = Color(0.8, 0.05, 0.05)) -> void:
	var popup := Node2D.new()
	popup.global_position = pos + Vector2(randf_range(-15, 15), -30)

	var label := Label.new()
	label.text = text_msg
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color.WHITE)
	label.add_theme_constant_override("outline_size", 4)
	label.scale = Vector2(1.2, 1.2)
	popup.add_child(label)

	parent_node.add_child(popup)

	# Animate float upward and fade out
	var tween := popup.create_tween()
	tween.parallel().tween_property(popup, "position", popup.position + Vector2(0, -50), 0.9)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.9)
	tween.tween_callback(popup.queue_free)
