extends Node2D

func _ready():
	# Only render this icon on layer 2, which is the layer the minimap camera captures
	visibility_layer = 2

func _process(_delta):
	# This icon should only be visible inside the Minimap viewport,
	# not in the main game view — so check which viewport is currently drawing
	var current_viewport = get_viewport()
	if current_viewport and "Minimap" in current_viewport.name:
		visible = true
	else:
		visible = false

func _draw():
	# Draw a simple player icon (blue body + peach head + eyes) 
	# directly with code instead of using a sprite, so it stays lightweight on the minimap
	# Blue Body
	draw_circle(Vector2(0, 6), 14, Color(0.2, 0.6, 1.0))
	# Peach Head
	draw_circle(Vector2(0, -10), 12, Color(1.0, 0.85, 0.7))
	# Eyes
	draw_circle(Vector2(-4, -11), 2.5, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(4, -11), 2.5, Color(0.1, 0.1, 0.1))
