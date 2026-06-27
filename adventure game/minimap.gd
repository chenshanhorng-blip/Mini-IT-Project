extends CanvasLayer

@onready var minimap_viewport = $PanelContainer/SubViewportContainer/MinimapViewport
@onready var minimap_camera = $PanelContainer/SubViewportContainer/MinimapViewport/MinimapCamera
@onready var container = $PanelContainer

var player: Node2D = null

# Zoom Configuration Limits
var min_zoom: float = 0.2
var max_zoom: float = 2.0
var zoom_step: float = 0.5

func _ready():
	while get_tree().current_scene == null:
		await get_tree().process_frame
 
	# Now it's safe to read current_scene
	minimap_viewport.world_2d = get_tree().current_scene.get_world_2d()
		
	# Fix viewport rendering settings
	minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	minimap_viewport.transparent_bg = true
	
	# Position minimap in bottom-right corner automatically
	container.anchor_left = 1.0
	container.anchor_top = 1.0
	container.anchor_right = 1.0
	container.anchor_bottom = 1.0
	container.offset_left = -210.0
	container.offset_top = -210.0
	container.offset_right = -10.0
	container.offset_bottom = -10.0
	
	minimap_viewport.size = Vector2(200, 200)
	
	# Default comfortable camera zoom level
	minimap_camera.zoom = Vector2(0.5, 0.5)
	
	# Draw the custom gold border UI box frame
	var stylebox = StyleBoxFlat.new()
	stylebox.border_width_left = 2
	stylebox.border_width_top = 2
	stylebox.border_width_right = 2
	stylebox.border_width_bottom = 2
	stylebox.border_color = Color(1, 0.85, 0, 1) # Gold
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.bg_color = Color(0, 0, 0, 0.5) # Semi-transparent black
	container.add_theme_stylebox_override("panel", stylebox)

func _process(_delta):
	# Center the camera view tracking onto the player coordinates in real-time
	if player:
		minimap_camera.global_position = player.global_position
		
	# Process the zoom and toggle keys using our passed _delta variable
	handle_minimap_inputs(_delta)

func handle_minimap_inputs(delta_time):
	# 1. Toggle Show/Hide with 'M' key
	if Input.is_key_pressed(KEY_M):
		# Small trick to prevent rapid double-toggling on a simple key hold
		await get_tree().create_timer(0.2).timeout
		container.visible = !container.visible

	# Skip checking zoom controls if the map is currently hidden
	if not container.visible:
		return

	# 2. Zoom In (Using the Equal/Plus key '+')
	if Input.is_key_pressed(KEY_EQUAL) or Input.is_key_pressed(KEY_KP_ADD):
		var new_zoom = clamp(minimap_camera.zoom.x + zoom_step * delta_time, min_zoom, max_zoom)
		minimap_camera.zoom = Vector2(new_zoom, new_zoom)
		
	# 3. Zoom Out (Using the Minus key '-')
	if Input.is_key_pressed(KEY_MINUS) or Input.is_key_pressed(KEY_KP_SUBTRACT):
		var new_zoom = clamp(minimap_camera.zoom.x - zoom_step * delta_time, min_zoom, max_zoom)
		minimap_camera.zoom = Vector2(new_zoom, new_zoom)
