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
	# Wait until current_scene is actually available (not null).
	# During scene transitions via Transition.fade_to_scene(),
	# current_scene can be null for several frames after _ready() fires.
	while get_tree().current_scene == null:
		await get_tree().process_frame

	# Now it's safe to read current_scene
	minimap_viewport.world_2d = get_tree().current_scene.get_world_2d()

	# Fix viewport rendering settings
	minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	minimap_viewport.transparent_bg = true

	# Must disable stretch on the SubViewportContainer before manually
	# setting the viewport size — otherwise Godot throws a warning and
	# ignores the size change
	var svc = minimap_viewport.get_parent()
	if svc is SubViewportContainer:
		svc.stretch = false

	# Position minimap in bottom-right corner
	container.anchor_left   = 1.0
	container.anchor_top    = 1.0
	container.anchor_right  = 1.0
	container.anchor_bottom = 1.0
	container.offset_left   = -210.0
	container.offset_top    = -210.0
	container.offset_right  = -10.0
	container.offset_bottom = -10.0

	minimap_viewport.size = Vector2(200, 200)

	# Default zoom level
	minimap_camera.zoom = Vector2(0.5, 0.5)

	# Gold border style
	var stylebox = StyleBoxFlat.new()
	stylebox.border_width_left   = 2
	stylebox.border_width_top    = 2
	stylebox.border_width_right  = 2
	stylebox.border_width_bottom = 2
	stylebox.border_color = Color(1, 0.85, 0, 1)
	stylebox.corner_radius_top_left     = 8
	stylebox.corner_radius_top_right    = 8
	stylebox.corner_radius_bottom_left  = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.bg_color = Color(0, 0, 0, 0.5)
	container.add_theme_stylebox_override("panel", stylebox)

	# Snap camera to respawn position when player respawns at checkpoint
	if CheckpointManager:
		if not CheckpointManager.player_respawn.is_connected(_on_player_respawn):
			CheckpointManager.player_respawn.connect(_on_player_respawn)


func _process(_delta):
	# Retry finding player every frame until found
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	if player:
		minimap_camera.global_position = player.global_position

	handle_minimap_inputs(_delta)


func handle_minimap_inputs(delta_time):
	if Input.is_key_pressed(KEY_M):
		await get_tree().create_timer(0.2).timeout
		container.visible = !container.visible

	if not container.visible:
		return

	if Input.is_key_pressed(KEY_EQUAL) or Input.is_key_pressed(KEY_KP_ADD):
		var new_zoom = clamp(minimap_camera.zoom.x + zoom_step * delta_time, min_zoom, max_zoom)
		minimap_camera.zoom = Vector2(new_zoom, new_zoom)

	if Input.is_key_pressed(KEY_MINUS) or Input.is_key_pressed(KEY_KP_SUBTRACT):
		var new_zoom = clamp(minimap_camera.zoom.x - zoom_step * delta_time, min_zoom, max_zoom)
		minimap_camera.zoom = Vector2(new_zoom, new_zoom)


func _on_player_respawn(respawn_position: Vector2) -> void:
	minimap_camera.global_position = respawn_position
	print("Minimap: camera snapped to respawn position ", respawn_position)
