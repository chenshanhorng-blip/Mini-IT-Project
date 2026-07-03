extends Control

# SKILL UI — MOBA-style radial cooldown

var skill1_base   = null
var skill2_base   = null
var ultimate_base = null

var stat: CharacterStat = null
var player_id: int = 1
# the text of the button of the skill button name 
const SKILL1_TEXT   = "skill 1"
const SKILL2_TEXT   = "skill 2"
const ULTIMATE_TEXT = "ultimate"

# Overlay data per skill: { "overlay": RadialCooldownOverlay, "max_cd": float }
var overlays: Dictionary = {}


func _ready() -> void:
	print("Skill UI ready")

	# print a line to confirm this ran
	skill1_base   = get_node_or_null("PanelContainer/HBoxContainer/Skill1Label")
	skill2_base   = get_node_or_null("PanelContainer/HBoxContainer/Skill2Label")
	ultimate_base = get_node_or_null("PanelContainer/HBoxContainer/UltimateLabel")

	# Fallback — no PanelContainer wrapper, labels directly under HBoxContainer
	if skill1_base == null:
		skill1_base = get_node_or_null("HBoxContainer/Skill1Label")
	if skill2_base == null:
		skill2_base = get_node_or_null("HBoxContainer/Skill2Label")
	if ultimate_base == null:
		ultimate_base = get_node_or_null("HBoxContainer/UltimateLabel")
# #f still not found after both attempts, something's wrong with the scene setup
	if skill1_base == null or skill2_base == null or ultimate_base == null:
		push_error("Skill UI: one or more skill nodes not found under HBoxContainer.")
		print("skill1_base:", skill1_base, " skill2_base:", skill2_base, " ultimate_base:", ultimate_base)
		return

	_build_overlay(skill1_base, "skill1")
	_build_overlay(skill2_base, "skill2")
	_build_overlay(ultimate_base, "ultimate")

	_refresh_stat()#go fetch this character's current stats
	_reset_labels()#reset all three button texts to their defaults

#called from outside to set which player this UI belongs to
func set_player_id(new_player_id: int) -> void:
	player_id = new_player_id#remember the new player number
	_refresh_stat()# player changed and refetch the character stats

#fetch the matching character data based on the player number
func _refresh_stat() -> void:
	stat = Global.player1_character if player_id == 1 else Global.player2_character
	if stat == null:
		print("Skill UI: stat is null")
	else:
		print("Skill UI using:", stat.character_name)

#reset all three skill buttons back to their default text
func _reset_labels() -> void:
	if skill1_base and skill1_base is Label:
		skill1_base.text = SKILL1_TEXT
	if skill2_base and skill2_base is Label:
		skill2_base.text = SKILL2_TEXT
	if ultimate_base and ultimate_base is Label:
		ultimate_base.text = ULTIMATE_TEXT


# creates the circular cooldown overlay for one skill button

func _build_overlay(base_node: Control, skill_name: String) -> void:

	var overlay = RadialCooldownOverlay.new()
	# create a new circular overlay object (the custom class defined below)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# make this overlay ignore mouse clicks so they pass through
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	# make the overlay stretch to fill the entire button
	base_node.add_child(overlay)
	# attach the overlay onto the button (as its child node)
	overlays[skill_name] = overlay
	# store this overlay in the dictionary so it can be found later by skill name

# runs automatically every frame
func _process(_delta: float) -> void:
	if stat == null:
		return
	_update_skill("skill1", skill1_base, SKILL1_TEXT, stat.skill1_cooldown)
	_update_skill("skill2", skill2_base, SKILL2_TEXT, stat.skill2_cooldown)
	_update_skill("ultimate", ultimate_base, ULTIMATE_TEXT, stat.ultimate_cooldown)

# updates one skill's display
func _update_skill(skill_name: String, base_node: Control, normal_text: String, max_cd: float) -> void:
	var remaining = skill_cooldown.get_remaining_time(stat, skill_name)
	var overlay: RadialCooldownOverlay = overlays.get(skill_name)
	if overlay == null:
		return

	if remaining > 0.0:
		var progress = remaining / max(max_cd, 0.001)  # 1.0 = just used, 0.0 = ready
		overlay.set_progress(progress, str(ceil(remaining)))# check how much cooldown time is left for this skill
		if base_node is Label:
			base_node.text = ""
	else:
		overlay.set_progress(0.0, "")#if the skill cooldown is o,will display the skill text
		if base_node is Label:
			base_node.text = normal_text


# RADIAL COOLDOWN OVERLAY — custom drawn Control
# Draws a clockwise pie-shaped dark wipe + centered number


class RadialCooldownOverlay extends Control:
	var progress: float = 0.0   # 1.0 = full cooldown just started, 0.0 = ready
	var display_text: String = ""

	func set_progress(p: float, text: String) -> void:
		progress = clamp(p, 0.0, 1.0)
		display_text = text
		queue_redraw()

	func _draw() -> void:
		if progress <= 0.0:
			return

		var center = size / 2.0
		var radius = min(size.x, size.y) / 2.0

		# Draw a pie slice that shrinks as cooldown completes.
		# Starts full circle (progress = 1.0) and wipes clockwise
		# from the top, revealing the icon as it empties.
		var point_count = 64
		var points = PackedVector2Array()
		points.append(center)

		var start_angle = -PI / 2.0  # 12 o'clock
		var sweep = TAU * progress
		var steps = int(point_count * progress) + 1

		for i in range(steps + 1):
			var t = float(i) / float(steps)
			var angle = start_angle + sweep * t
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)

		if points.size() >= 3:
			draw_colored_polygon(points, Color(0, 0, 0, 0.65))

		# Countdown number, centered, bold with outline
		if display_text != "":
			var font = ThemeDB.fallback_font
			var font_size = 32
			var text_size = font.get_string_size(display_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var pos = center - text_size / 2.0 + Vector2(0, text_size.y * 0.35)

			# Outline (draw text offset in 4 directions in black)
			var outline_color = Color(0, 0, 0, 1)
			for offset in [Vector2(-2,0), Vector2(2,0), Vector2(0,-2), Vector2(0,2)]:
				draw_string(font, pos + offset, display_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, outline_color)

			draw_string(font, pos, display_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(1, 1, 1, 1))
