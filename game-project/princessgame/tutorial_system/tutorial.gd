extends Node2D

# ============================================================
# TUTORIAL SCENE — Controls only
# No enemies. Just teaches the player the buttons.
# Steps auto-advance when player does the action.
# After all steps done -> loads level1
# ============================================================

const P1_SCENE = preload("res://scene_movement/player1_movement.tscn")

var player_node = null

var moved_left     := false
var moved_right    := false
var jumped         := false
var crouched       := false
var basic_attacked := false
var used_skill1    := false
var used_skill2    := false
var used_ultimate  := false

# UI nodes found safely in _ready
var step_label = null
var desc_label = null
var key_label  = null


func _ready() -> void:
	# --- Find UI labels safely ---
	# Try with VBoxContainer
	step_label = get_node_or_null("TutorialUI/Panel/VBoxContainer/StepLabel")
	desc_label = get_node_or_null("TutorialUI/Panel/VBoxContainer/DescLabel")
	key_label  = get_node_or_null("TutorialUI/Panel/VBoxContainer/KeyLabel")

	# Fallback: directly inside Panel
	if step_label == null:
		step_label = get_node_or_null("TutorialUI/Panel/StepLabel")
	if desc_label == null:
		desc_label = get_node_or_null("TutorialUI/Panel/DescLabel")
	if key_label == null:
		key_label  = get_node_or_null("TutorialUI/Panel/KeyLabel")

	if step_label == null or desc_label == null:
		push_error("Tutorial: Labels not found! Check node names in tutorial.tscn")
		return

	# --- Spawn player ---
	var p1 = P1_SCENE.instantiate()
	add_child(p1)
	var spawn = get_node_or_null("SpawnPoint")
	if spawn != null:
		p1.global_position = spawn.global_position
	else:
		p1.global_position = Vector2(200, 0)
	player_node = p1
	print("Tutorial: Player spawned at ", p1.global_position)

	# --- Start tutorial ---
	TutorialManager.start_tutorial()
	TutorialManager.step_changed.connect(_on_step_changed)
	TutorialManager.tutorial_finished.connect(_on_tutorial_finished)
	_show_step(TutorialManager.current_step)


func _process(_delta: float) -> void:
	if not TutorialManager.tutorial_active:
		return
	_check_step_completion()


# ============================================================
# SHOW STEP UI
# ============================================================

func _show_step(step: int) -> void:
	match step:
		TutorialManager.Step.WELCOME:
			_set_ui(
				"Welcome to Princess Game!",
				"Let's learn the controls.\nFollow each step and do the action shown.",
				"Press  W / A / D / S  to begin"
			)
		TutorialManager.Step.MOVE_LEFT_RIGHT:
			_set_ui(
				"Step 1 — Move",
				"Move your character left and right.\nDo BOTH directions to continue.",
				"A  =  Move Left\nD  =  Move Right"
			)
		TutorialManager.Step.JUMP:
			_set_ui(
				"Step 2 — Jump",
				"Jump to reach higher platforms\nand avoid enemy attacks.",
				"W  =  Jump"
			)
		TutorialManager.Step.CROUCH:
			_set_ui(
				"Step 3 — Crouch",
				"Crouch to dodge attacks\nor pass through low gaps.",
				"S  =  Crouch  (hold it)"
			)
		TutorialManager.Step.BASIC_ATTACK:
			_set_ui(
				"Step 4 — Basic Attack",
				"Your basic attack deals damage\nto any enemy in front of you.",
				"Left Mouse Button  =  Basic Attack"
			)
		TutorialManager.Step.SKILL_1:
			_set_ui(
				"Step 5 — Skill 1",
				"Your first skill!\nBoar Princess  :  Royal Roast\nTea Egg Knight :  Shine Shield (adds shield)",
				"Q  =  Skill 1"
			)
		TutorialManager.Step.SKILL_2:
			_set_ui(
				"Step 6 — Skill 2",
				"Your second skill!\nBoar Princess  :  Area attack\nTea Egg Knight :  Ranged projectile + heals HP on hit",
				"E  =  Skill 2"
			)
		TutorialManager.Step.ULTIMATE:
			_set_ui(
				"Step 7 — Ultimate",
				"Your most powerful ability!\nBoar Princess  :  Giant Form for 6 seconds\nTea Egg Knight :  Massive strike",
				"R  =  Ultimate"
			)
		TutorialManager.Step.COMPLETE:
			_set_ui(
				"You are ready!",
				"Great job! You know all the controls.\nGood luck, warrior!\n\nLoading level...",
				""
			)


func _set_ui(title: String, desc: String, keys: String) -> void:
	if step_label != null:
		step_label.text = title
	if desc_label != null:
		desc_label.text = desc
	if key_label != null:
		key_label.text = keys


# ============================================================
# STEP COMPLETION — waits for player to press the right button
# ============================================================

func _check_step_completion() -> void:
	var step = TutorialManager.current_step

	match step:
		TutorialManager.Step.WELCOME:
			# Any movement key to begin
			if Input.is_action_just_pressed("p1_left") \
			or Input.is_action_just_pressed("p1_right") \
			or Input.is_action_just_pressed("p1_up") \
			or Input.is_action_just_pressed("p1_down"):
				TutorialManager.advance_step()

		TutorialManager.Step.MOVE_LEFT_RIGHT:
			if Input.is_action_pressed("p1_left"):
				moved_left = true
			if Input.is_action_pressed("p1_right"):
				moved_right = true
			if moved_left and moved_right:
				TutorialManager.advance_step()

		TutorialManager.Step.JUMP:
			if Input.is_action_just_pressed("p1_up"):
				jumped = true
			if jumped:
				TutorialManager.advance_step()

		TutorialManager.Step.CROUCH:
			if Input.is_action_pressed("p1_down"):
				crouched = true
			if crouched:
				TutorialManager.advance_step()

		TutorialManager.Step.BASIC_ATTACK:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				basic_attacked = true
			if basic_attacked:
				TutorialManager.advance_step()

		TutorialManager.Step.SKILL_1:
			if Input.is_action_just_pressed("skill1"):
				used_skill1 = true
			if used_skill1:
				TutorialManager.advance_step()

		TutorialManager.Step.SKILL_2:
			if Input.is_action_just_pressed("skill2"):
				used_skill2 = true
			if used_skill2:
				TutorialManager.advance_step()

		TutorialManager.Step.ULTIMATE:
			if Input.is_action_just_pressed("ultimate"):
				used_ultimate = true
			if used_ultimate:
				TutorialManager.advance_step()


func _on_step_changed(new_step: int) -> void:
	_show_step(new_step)


func _on_tutorial_finished() -> void:
	_show_step(TutorialManager.Step.COMPLETE)
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scene_level_map/level1.tscn")
