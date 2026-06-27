extends Control

# ============================================================
# SKILL UI — MOBA-style radial cooldown
#
# Idle: label shows the skill name, no overlay
# On use: a dark radial wipe sweeps clockwise over the icon
#         (like League/Mobile Legends ability cooldowns),
#         with a bold countdown number centered on top
# Ready again: wipe disappears, label shows the skill name
#
# Works with either Button or Label/Control as the base node —
# the radial overlay is drawn as a custom-drawn Control layered
# on top using _draw(), so it works regardless of base node type.
# ============================================================

var skill1_base   = null
var skill2_base   = null
var ultimate_base = null

var stat: CharacterStat = null
var player_id: int = 1

const SKILL1_TEXT   = "skill 1"
const SKILL2_TEXT   = "skill 2"
const ULTIMATE_TEXT = "ultimate"

# Overlay data per skill: { "overlay": RadialCooldownOverlay, "max_cd": float }
var overlays: Dictionary = {}


func _ready() -> void:
	print("Skill UI ready")

	# Try with the PanelContainer wrapper first (current scene layout)
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

	if skill1_base == null or skill2_base == null or ultimate_base == null:
		push_error("Skill UI: one or more skill nodes not found under HBoxContainer.")
		print("skill1_base:", skill1_base, " skill2_base:", skill2_base, " ultimate_base:", ultimate_base)
		return

	_build_overlay(skill1_base, "skill1")
	_build_overlay(skill2_base, "skill2")
	_build_overlay(ultimate_base, "ultimate")

	_refresh_stat()
	_reset_labels()


func set_player_id(new_player_id: int) -> void:
	player_id = new_player_id
	_refresh_stat()


func _refresh_stat() -> void:
	stat = Global.player1_character if player_id == 1 else Global.player2_character
	if stat == null:
		print("Skill UI: stat is null")
	else:
		print("Skill UI using:", stat.character_name)


func _reset_labels() -> void:
	if skill1_base and skill1_base is Label:
		skill1_base.text = SKILL1_TEXT
	if skill2_base and skill2_base is Label:
		skill2_base.text = SKILL2_TEXT
	if ultimate_base and ultimate_base is Label:
		ultimate_base.text = ULTIMATE_TEXT


# ============================================================
# BUILD RADIAL OVERLAY
# ============================================================

func _build_overlay(base_node: Control, skill_name: String) -> void:
	var overlay = RadialCooldownOverlay.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	base_node.add_child(overlay)
	overlays[skill_name] = overlay


func _process(_delta: float) -> void:
	if stat == null:
		return
	_update_skill("skill1", skill1_base, SKILL1_TEXT, stat.skill1_cooldown)
	_update_skill("skill2", skill2_base, SKILL2_TEXT, stat.skill2_cooldown)
	_update_skill("ultimate", ultimate_base, ULTIMATE_TEXT, stat.ultimate_cooldown)


func _update_skill(skill_name: String, base_node: Control, normal_text: String, max_cd: float) -> void:
	var remaining = skill_cooldown.get_remaining_time(stat, skill_name)
	var overlay: RadialCooldownOverlay = overlays.get(skill_name)
	if overlay == null:
		return

	if remaining > 0.0:
		var progress = remaining / max(max_cd, 0.001)  # 1.0 = just used, 0.0 = ready
		overlay.set_progress(progress, str(ceil(remaining)))
		if base_node is Label:
			base_node.text = ""
	else:
		overlay.set_progress(0.0, "")
		if base_node is Label:
			base_node.text = normal_text


# ============================================================
# RADIAL COOLDOWN OVERLAY — custom drawn Control
# Draws a clockwise pie-shaped dark wipe + centered number
# ============================================================

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
