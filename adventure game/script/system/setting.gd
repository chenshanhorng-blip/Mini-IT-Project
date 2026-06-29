extends Control

const CONFIG_PATH = "user://settings.cfg"
var config = ConfigFile.new()

@onready var button_click_sound = $ButtonClickSound

func _ready():
	load_settings()
	
	# Connect Back
	if not $Panel/Back.pressed.is_connected(_on_back_pressed):
		$Panel/Back.pressed.connect(_on_back_pressed)
	
	# Connect Sliders
	if not $Panel/MasterSlider.value_changed.is_connected(_on_master_changed):
		$Panel/MasterSlider.value_changed.connect(_on_master_changed)
	if not $Panel/MusicSlider.value_changed.is_connected(_on_music_changed):
		$Panel/MusicSlider.value_changed.connect(_on_music_changed)
	if not $Panel/SFXSlider.value_changed.is_connected(_on_sfx_changed):
		$Panel/SFXSlider.value_changed.connect(_on_sfx_changed)
	
	# Connect Toggles
	if not $Panel/MinimapToggle.toggled.is_connected(_on_minimap_toggled):
		$Panel/MinimapToggle.toggled.connect(_on_minimap_toggled)
	if not $Panel/HintToggle.toggled.is_connected(_on_hint_toggled):
		$Panel/HintToggle.toggled.connect(_on_hint_toggled)
	if not $Panel/VSyncToggle.toggled.is_connected(_on_vsync_toggled):
		$Panel/VSyncToggle.toggled.connect(_on_vsync_toggled)
	# Show starting percentages
	_update_percent($Panel/MasterSlider.value, $Panel/MasterPercent)
	_update_percent($Panel/MusicSlider.value, $Panel/MusicPercent)
	_update_percent($Panel/SFXSlider.value, $Panel/SFXPercent)

# Safely set an audio bus volume — does nothing if the bus
# doesn't exist in the project's Audio Bus Layout, instead of
# crashing with "Index p_bus = -1 is out of bounds"
func _set_bus_volume_safe(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		print("Audio bus '", bus_name, "' does not exist — skipping volume set")
		return
	AudioServer.set_bus_volume_db(bus_index, value)

# ============================================================
# VOLUME
# ============================================================
func _on_master_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	_update_percent(value, $Panel/MasterPercent)
	save_settings()

func _on_music_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	_update_percent(value, $Panel/MusicPercent)
	save_settings()

func _on_sfx_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	_update_percent(value, $Panel/SFXPercent)
	save_settings()

func _update_percent(value: float, label: Label):
	var percent = int((value + 40) / 40.0 * 100)
	label.text = str(percent) + "%"

# ============================================================
# TOGGLES
# ============================================================
func _on_minimap_toggled(enabled: bool):
	Global.show_minimap = enabled
	save_settings()

func _on_hint_toggled(enabled: bool):
	Global.show_hints = enabled
	save_settings()

func _on_vsync_toggled(enabled: bool):
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	save_settings()

# ============================================================
# SAVE / LOAD SETTINGS
# ============================================================
func save_settings():
	config.set_value("audio", "master", $Panel/MasterSlider.value)
	config.set_value("audio", "music", $Panel/MusicSlider.value)
	config.set_value("audio", "sfx", $Panel/SFXSlider.value)
	config.set_value("gameplay", "minimap", $Panel/MinimapToggle.button_pressed)
	config.set_value("gameplay", "hints", $Panel/HintToggle.button_pressed)
	config.set_value("display", "vsync", $Panel/VSyncToggle.button_pressed)
	config.save(CONFIG_PATH)
	print("Settings saved!")

func load_settings():
	if config.load(CONFIG_PATH) != OK:
		print("No settings file, using defaults!")
		_apply_defaults()
		return
	
	# Load audio
	$Panel/MasterSlider.value = config.get_value("audio", "master", 0.0)
	$Panel/MusicSlider.value = config.get_value("audio", "music", 0.0)
	$Panel/SFXSlider.value = config.get_value("audio", "sfx", 0.0)
	
	# Load toggles
	$Panel/MinimapToggle.button_pressed = config.get_value("gameplay", "minimap", true)
	$Panel/HintToggle.button_pressed = config.get_value("gameplay", "hints", true)
	$Panel/VSyncToggle.button_pressed = config.get_value("display", "vsync", true)
	
	# Apply loaded values
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), $Panel/MasterSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $Panel/MusicSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $Panel/SFXSlider.value)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if $Panel/VSyncToggle.button_pressed 
		else DisplayServer.VSYNC_DISABLED
	)
	print("Settings loaded!")

func _apply_defaults():
	$Panel/MasterSlider.value = 0.0
	$Panel/MusicSlider.value = 0.0
	$Panel/SFXSlider.value = 0.0
	$Panel/MinimapToggle.button_pressed = true
	$Panel/HintToggle.button_pressed = true
	$Panel/VSyncToggle.button_pressed = true

func _on_back_pressed():
	button_click_sound.play()
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
