extends Node2D

func _ready():
	visibility_layer = 2

func _process(_delta):
	var current_viewport = get_viewport()
	if current_viewport and "Minimap" in current_viewport.name:
		visible = true
	else:
		visible = false

func _draw():
	# Blue Body
	draw_circle(Vector2(0, 6), 14, Color(0.2, 0.6, 1.0))
	# Peach Head
	draw_circle(Vector2(0, -10), 12, Color(1.0, 0.85, 0.7))
	# Eyes
	draw_circle(Vector2(-4, -11), 2.5, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(4, -11), 2.5, Color(0.1, 0.1, 0.1))
