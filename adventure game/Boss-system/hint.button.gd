extends TextureButton
# Button


##Initialization
func _ready() -> void:
	pivot_offset = size
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_entered)
	
	
#Pivot Update
func set_pivot() -> void:
	pivot_offset = size/2


#Scale Button
func _on_mouse_entered() -> void:
	create_tween().tween_property(self,"scale",Vector2(1.1,1.1),0.1)
func _on_mouse_excited() -> void:
	create_tween().tween_property(self,"scale",Vector2(1,1),0.1)


func _on_pressed() -> void:
	pass # Replace with function body.
