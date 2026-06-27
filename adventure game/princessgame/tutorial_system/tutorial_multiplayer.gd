extends Node2D

# ============================================================
# MULTIPLAYER TUTORIAL
# Spawns both Player 1 and Player 2.
# Each step only advances once BOTH players have done the action.
# Controls shown for both: P1 = WASD/QER/LMB, P2 = Arrows/p2_ keys
# ============================================================

const P1_SCENE = preload("res://scene_movement/player1_movement.tscn")
const P2_SCENE = preload("res://scene_movement/player2_movement.tscn")

var player1_node = null
var player2_node = null

# Per-player completion flags
var p1_moved_left := false
var p1_moved_right := false
var p2_moved_left := false
var p2_moved_right := false

var p1_jumped := false
var p2_jumped := false

var p1_crouched := false
var p2_crouched := false

var p1_basic_attacked := false
var p2_basic_attacked := false

var p1_used_skill1 := false
var p2_used_skill1 := false

var p1_used_skill2 := false
var p2_used_skill2 := false

var p1_used_ultimate := false
var p2_used_ultimate := false

# Skip countdown
var is_skipping    := false
var skip_countdown := 5.0

# UI nodes
var step_label      = null
var desc_label      = null
var key_label_p1    = null
var key_label_p2    = null
var skip_button     = null
var cancel_button    = null
var countdown_label = null


func _ready() -> void:
	step_label   = get_node_or_null("TutorialUI/Panel/VBoxContainer/StepLabel")
	desc_label   = get_node_or_null("TutorialUI/Panel/VBoxContainer/DescLabel")
	key_label_p1 = get_node_or_null("TutorialUI/Panel/VBoxContainer/KeyLabelP1")
	key_label_p2 = get_node_or_null("TutorialUI/Panel/VBoxContainer/KeyLabelP2")

	if step_label == null:
		step_label = get_node_or_null("TutorialUI/Panel/StepLabel")
	if desc_label == null:
		desc_label = get_node_or_null("TutorialUI/Panel/DescLabel")

	if step_label == null or desc_label == null:
		push_error("Tutorial(MP): Labels not found! Check node names in tutorial_multiplayer.tscn")
		return

	skip_button     = get_node_or_null("TutorialUI/SkipButton")
	cancel_button   = get_node_or_null("TutorialUI/CancelButton")
	countdown_label = get_node_or_null("TutorialUI/CountdownLabel")

	if skip_button != null:
		skip_button.pressed.connect(_on_skip_pressed)
		skip_button.visible = true
	if cancel_button != null:
		cancel_button.pressed.connect(_on_cancel_pressed)
		cancel_button.visible = false
	if countdown_label != null:
		countdown_label.visible = false

	# --- Spawn Player 1 ---
	var p1 = P1_SCENE.instantiate()
	add_child(p1)
	var spawn1 = get_node_or_null("SpawnPoint1")
	p1.global_position = spawn1.global_position if spawn1 else Vector2(150, 0)
	player1_node = p1
	print("Tutorial(MP): Player 1 spawned at ", p1.global_position)

	# --- Spawn Player 2 ---
	var p2 = P2_SCENE.instantiate()
	add_child(p2)
	var spawn2 = get_node_or_null("SpawnPoint2")
	p2.global_position = spawn2.global_position if spawn2 else Vector2(250, 0)
	player2_node = p2
	print("Tutorial(MP): Player 2 spawned at ", p2.global_position)

	TutorialManager.start_tutorial()
	TutorialManager.step_changed.connect(_on_step_changed)
	TutorialManager.tutorial_finished.connect(_on_tutorial_finished)
	TutorialManager.tutorial_skipped.connect(_on_tutorial_skipped)
	_show_step(TutorialManager.current_step)


# ============================================================
# SKIP
# ============================================================

func _on_skip_pressed() -> void:
	if is_skipping:
		return
	is_skipping = true
	skip_countdown = 5.0
	if skip_button != null:
		skip_button.visible = false
	if cancel_button != null:
		cancel_button.visible = true
	if countdown_label != null:
		countdown_label.visible = true
		countdown_label.text = "Loading level in 5..."


func _on_cancel_pressed() -> void:
	is_skipping = false
	skip_countdown = 5.0
	if skip_button != null:
		skip_button.visible = true
	if cancel_button != null:
		cancel_button.visible = false
	if countdown_label != null:
		countdown_label.visible = false


func _process(delta: float) -> void:
	if is_skipping:
		skip_countdown -= delta
		if countdown_label != null:
			countdown_label.text = "Loading level in " + str(ceil(skip_countdown)) + "..."
		if skip_countdown <= 0:
			TutorialManager.skip_tutorial()
		return

	if not TutorialManager.tutorial_active:
		return
	_check_step_completion()


# ============================================================
# SHOW STEP
# ============================================================

func _show_step(step: int) -> void:
	match step:
		TutorialManager.Step.WELCOME:
			_set_ui("Welcome to Princess Game! (Co-op)",
				"Both players — let's learn the controls together.\nDo the action shown to continue.",
				"P1: WASD to begin", "P2: Arrow Keys to begin")
		TutorialManager.Step.MOVE_LEFT_RIGHT:
			_set_ui("Step 1 — Move",
				"Both players move left and right.",
				"P1: A / D", "P2: ← / →")
		TutorialManager.Step.JUMP:
			_set_ui("Step 2 — Jump",
				"Both players jump.",
				"P1: W", "P2: ↑")
		TutorialManager.Step.CROUCH:
			_set_ui("Step 3 — Crouch",
				"Both players hold crouch.",
				"P1: S", "P2: ↓")
		TutorialManager.Step.BASIC_ATTACK:
			_set_ui("Step 4 — Basic Attack",
				"Both players use basic attack.",
				"P1: F", "P2:Alt(right)")
		TutorialManager.Step.SKILL_1:
			_set_ui("Step 5 — Skill 1",
				"Both players use Skill 1.",
				"P1: Q", "P2: P2 press the right shift")
		TutorialManager.Step.SKILL_2:
			_set_ui("Step 6 — Skill 2",
				"Both players use Skill 2.",
				"P1: E", "P2: P2 press the Enter key")
		TutorialManager.Step.ULTIMATE:
			_set_ui("Step 7 — Ultimate",
				"Both players use their Ultimate!",
				"P1: R", "P2: P2 use the backslash key")
		TutorialManager.Step.COMPLETE:
			_set_ui("You are both ready!",
				"Great teamwork! Time to play together.\n\nLoading level...", "", "")


func _set_ui(title: String, desc: String, keys_p1: String, keys_p2: String) -> void:
	if step_label != null:
		step_label.text = title
	if desc_label != null:
		desc_label.text = desc
	if key_label_p1 != null:
		key_label_p1.text = keys_p1
	if key_label_p2 != null:
		key_label_p2.text = keys_p2


# ============================================================
# STEP COMPLETION — BOTH players must complete it
# ============================================================

func _check_step_completion() -> void:
	var step = TutorialManager.current_step

	match step:
		TutorialManager.Step.WELCOME:
			var p1_pressed = Input.is_action_just_pressed("p1_left") \
				or Input.is_action_just_pressed("p1_right") \
				or Input.is_action_just_pressed("p1_up") \
				or Input.is_action_just_pressed("p1_down")
			var p2_pressed = Input.is_action_just_pressed("p2_left") \
				or Input.is_action_just_pressed("p2_right") \
				or Input.is_action_just_pressed("p2_up") \
				or Input.is_action_just_pressed("p2_down")
			if p1_pressed and p2_pressed:
				TutorialManager.advance_step()

		TutorialManager.Step.MOVE_LEFT_RIGHT:
			if Input.is_action_pressed("p1_left"):  p1_moved_left = true
			if Input.is_action_pressed("p1_right"): p1_moved_right = true
			if Input.is_action_pressed("p2_left"):  p2_moved_left = true
			if Input.is_action_pressed("p2_right"): p2_moved_right = true
			if p1_moved_left and p1_moved_right and p2_moved_left and p2_moved_right:
				TutorialManager.advance_step()

		TutorialManager.Step.JUMP:
			if Input.is_action_just_pressed("p1_up"): p1_jumped = true
			if Input.is_action_just_pressed("p2_up"): p2_jumped = true
			if p1_jumped and p2_jumped:
				TutorialManager.advance_step()

		TutorialManager.Step.CROUCH:
			if Input.is_action_pressed("p1_down"): p1_crouched = true
			if Input.is_action_pressed("p2_down"): p2_crouched = true
			if p1_crouched and p2_crouched:
				TutorialManager.advance_step()

		TutorialManager.Step.BASIC_ATTACK:
			if Input.is_action_pressed("basic attack"): p1_basic_attacked = true
			if Input.is_action_pressed("p2_basic_attack"):  p2_basic_attacked = true
			if p1_basic_attacked and p2_basic_attacked:
				TutorialManager.advance_step()

		TutorialManager.Step.SKILL_1:
			if Input.is_action_just_pressed("skill1"):    p1_used_skill1 = true
			if Input.is_action_just_pressed("p2_skill1"): p2_used_skill1 = true
			if p1_used_skill1 and p2_used_skill1:
				TutorialManager.advance_step()

		TutorialManager.Step.SKILL_2:
			if Input.is_action_just_pressed("skill2"):    p1_used_skill2 = true
			if Input.is_action_just_pressed("p2_skill2"): p2_used_skill2 = true
			if p1_used_skill2 and p2_used_skill2:
				TutorialManager.advance_step()

		TutorialManager.Step.ULTIMATE:
			if Input.is_action_just_pressed("ultimate"):    p1_used_ultimate = true
			if Input.is_action_just_pressed("p2_ultimate"): p2_used_ultimate = true
			if p1_used_ultimate and p2_used_ultimate:
				TutorialManager.advance_step()


func _on_step_changed(new_step: int) -> void:
	_show_step(new_step)


func _on_tutorial_finished() -> void:
	_show_step(TutorialManager.Step.COMPLETE)
	if countdown_label != null:
		countdown_label.visible = true
	if skip_button != null:
		skip_button.visible = false
	var timer := 5.0
	while timer > 0:
		if countdown_label != null:
			countdown_label.text = "Loading level in " + str(ceil(timer)) + "..."
		await get_tree().create_timer(1.0).timeout
		timer -= 1.0
	_reset_players_before_level()
	Transition.fade_to_scene("res://scene_level_map/level1.tscn")


func _on_tutorial_skipped() -> void:
	if step_label != null:
		step_label.text = "Tutorial Skipped!"
	if desc_label != null:
		desc_label.text = "Loading level in 5 seconds...\nGood luck, warriors!"
	if countdown_label != null:
		countdown_label.visible = false
	await get_tree().create_timer(5.0).timeout
	_reset_players_before_level()
	Transition.fade_to_scene("res://scene_level_map/level1.tscn")


# ============================================================
# RESET — clears skill/ultimate state for BOTH players
# ============================================================
func _reset_players_before_level() -> void:
	for p_node in [player1_node, player2_node]:
		if p_node != null and is_instance_valid(p_node):
			var skill_controller = p_node.get_node_or_null("skill_adjust")
			if skill_controller != null:
				if skill_controller.has_method("hide_all_effects"):
					skill_controller.hide_all_effects()
				skill_controller.is_attacking = false

	if Global.player1_character != null:
		Global.player1_character.reset_stats()
	if Global.player2_character != null:
		Global.player2_character.reset_stats()

	print("Tutorial(MP): Both character stats reset before entering level1")
