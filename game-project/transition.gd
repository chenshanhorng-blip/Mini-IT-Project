extends CanvasLayer

@onready var overlay = $Overlay

func _ready():
	overlay.modulate.a = 0.0  # Start transparent
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE # Start unblocked

# You can call this manually if you just want to fade out from black on game start!
func fade_in():
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_to_scene(path: String):
	# 1. Block inputs so the player can't click things mid-transition
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fade to black
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# 3. Change the scene
	get_tree().change_scene_to_file(path)
	
	# 4. Fade back out to transparent so they can see the new scene!
	var tween_out = create_tween()
	tween_out.tween_property(overlay, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	# 5. Allow inputs again
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
