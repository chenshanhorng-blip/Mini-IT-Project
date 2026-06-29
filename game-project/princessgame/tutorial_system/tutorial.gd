extends Node2D

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

# Skip countdown
var is_skipping    := false
var skip_countdown := 5.0

# UI nodes
var step_label      = null
var desc_label      = null
var key_label       = null
var skip_button     = null   # Button — click to start skip
var cancel_button   = null   # Button — click to cancel skip
var countdown_label = null   # Label — shows "Loading in X..."


func _ready() -> void:
	# --- Find tutorial text labels ---
	step_label = get_node_or_null("TutorialUI/Panel/VBoxContainer/StepLabel")
	desc_label = get_node_or_null("TutorialUI/Panel/VBoxContainer/DescLabel")
	key_label  = get_node_or_null("TutorialUI/Panel/VBoxContainer/KeyLabel")

	if step_label == null:
		step_label = get_node_or_null("TutorialUI/Panel/StepLabel")
	if desc_label == null:
		desc_label = get_node_or_null("TutorialUI/Panel/DescLabel")
	if key_label == null:
		key_label  = get_node_or_null("TutorialUI/Panel/KeyLabel")

	if step_label == null or desc_label == null:
		push_error("Tutorial: Labels not found! Check node names in tutorial.tscn")
		return

	# --- Find skip UI nodes ---
	skip_button     = get_node_or_null("TutorialUI/SkipButton")
	cancel_button   = get_node_or_null("TutorialUI/CancelButton")
	countdown_label = get_node_or_null("TutorialUI/CountdownLabel")

	# Connect skip button
	if skip_button != null:
		skip_button.pressed.connect(_on_skip_pressed)
		skip_button.visible = true
	else:
		push_error("Tutorial: SkipButton not found — add a Button node named SkipButton inside TutorialUI")

	# Hide cancel and countdown at start
	if cancel_button != null:
		cancel_button.pressed.connect(_on_cancel_pressed)
		cancel_button.visible = false

	if countdown_label != null:
		countdown_label.visible = false

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
	TutorialManager.tutorial_skipped.connect(_on_tutorial_skipped)
	_show_step(TutorialManager.current_step)

# SKIP BUTTON CLICKED


func _on_skip_pressed() -> void:
	if is_skipping:
		return
	is_skipping = true
	
	# Show countdown, hide skip button, show cancel button
	if skip_button != null:
		skip_button.visible = false
	if cancel_button != null:
		cancel_button.visible = true
	if countdown_label != null:
		countdown_label.visible = true
		countdown_label.text = "Loading level in 5..."

	print("Skip button clicked — counting down...")


func _on_cancel_pressed() -> void:
	is_skipping = false
	skip_countdown = 5.0

	# Show skip button again, hide cancel and countdown
	if skip_button != null:
		skip_button.visible = true
	if cancel_button != null:
		cancel_button.visible = false
	if countdown_label != null:
		countdown_label.visible = false

	print("Skip cancelled")


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	# --- Countdown tick ---
	if is_skipping:
		skip_countdown -= delta
		if countdown_label != null:
			countdown_label.text = "Loading level in " + str(ceil(skip_countdown)) + "..."
		if skip_countdown <= 0:
			TutorialManager.skip_tutorial()
			is_skipping = false  # FIX: stop this branch from firing every frame
		return

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
				"Hold crouch to duck under gaps\nand dodge attacks.",
				"S  =  Crouch  (hold it)"
			)
		TutorialManager.Step.BASIC_ATTACK:
			_set_ui(
				"Step 4 — Basic Attack",
				"Attack enemies with your basic attack.",
				"F=  Basic Attack"
			)
		TutorialManager.Step.SKILL_1:
			_set_ui(
				"Step 5 — Skill 1",
				"Use your first skill!\nBoar Princess  :  Royal Roast\nTea Egg Knight :  Shine Shield (adds shield)",
				"Q  =  Skill 1"
			)
		TutorialManager.Step.SKILL_2:
			_set_ui(
				"Step 6 — Skill 2",
				"Use your second skill!\nA powerful ranged attack.",
				"E  =  Skill 2"
			)
		TutorialManager.Step.ULTIMATE:
			_set_ui(
				"Step 7 — Ultimate",
				"Unleash your ultimate ability!\nBoar Princess  :  Giant Form (6s)\nTea Egg Knight :  Heavy Strike",
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
# STEP COMPLETION CHECKS
# ============================================================

func _check_step_completion() -> void:
	var step = TutorialManager.current_step

	match step:
		TutorialManager.Step.WELCOME:
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
			if Input.is_action_pressed("basic attack"):
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
	# Show countdown same as skip
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
	_reset_player_before_level()
	Transition.fade_to_scene("res://scene_level_map/level1.tscn")


func _on_tutorial_skipped() -> void:
	if step_label != null:
		step_label.text = "Tutorial Skipped!"
	if desc_label != null:
		desc_label.text = "Loading level in 5 seconds...\nGood luck, warrior!"
	if key_label != null:
		key_label.text = ""
	if countdown_label != null:
		countdown_label.visible = false
	print("Tutorial skipped — loading level in 5 seconds")
	await get_tree().create_timer(5.0).timeout
	Transition.fade_to_scene("res://scene_level_map/level1.tscn")
	
func _reset_player_before_level() -> void:
	# Stop any active skill effects on the tutorial player before it's freed
	if player_node != null and is_instance_valid(player_node):
		var skill_controller = player_node.get_node_or_null("skill_adjust")
		if skill_controller != null:
			# Force-cancel ultimate / attacking state and hide any visible effects
			if skill_controller.has_method("hide_all_effects"):
				skill_controller.hide_all_effects()
			skill_controller.is_attacking = false
 
	# Reset the CharacterStat itself — clears cooldowns + ultimate_active
	if Global.player1_character != null:
		Global.player1_character.reset_stats()
		print("Tutorial: Character stat reset before entering level1")
