extends Node

# ============================================================
# TUTORIAL MANAGER — Autoload (name: TutorialManager)
# ============================================================

var tutorial_active: bool = false
var tutorial_complete: bool = false
var current_step: int = 0

enum Step {
	WELCOME,
	MOVE_LEFT_RIGHT,
	JUMP,
	CROUCH,
	BASIC_ATTACK,
	SKILL_1,
	SKILL_2,
	ULTIMATE,
	COMPLETE
}

signal step_changed(new_step: int)
signal tutorial_finished
signal tutorial_skipped


func start_tutorial() -> void:
	tutorial_active   = true
	tutorial_complete = false
	current_step      = Step.WELCOME
	step_changed.emit(current_step)
	print("Tutorial started — Step:", current_step)


func advance_step() -> void:
	if not tutorial_active:
		return
	current_step += 1
	print("Tutorial step:", current_step)
	step_changed.emit(current_step)
	if current_step >= Step.COMPLETE:
		finish_tutorial()


func finish_tutorial() -> void:
	tutorial_active   = false
	tutorial_complete = true
	tutorial_finished.emit()
	print("Tutorial complete!")


func skip_tutorial() -> void:
	tutorial_active   = false
	tutorial_complete = true
	tutorial_skipped.emit()
	print("Tutorial skipped!")
