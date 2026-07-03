extends Control

## Node References
@onready var label: Label = get_node("Panel/Label")
@onready var timer: Timer = get_node("Timer")

## Dialogue
var dialogue_array = []
var dialogue_index = 0


func _ready():
	# Must process even when game is paused (e.g. player died mid-dialogue)
	# so the dialogue can be dismissed and doesn't block death screen buttons
	process_mode = PROCESS_MODE_ALWAYS

	label = get_node_or_null("Panel/Label")
	timer = get_node_or_null("Timer")

	if label == null:
		return

	label.text = ""
	label.visible_characters = 0

	if timer:
		timer.timeout.connect(_on_timer_timeout)

func start():

	dialogue_index = 0

	if dialogue_array.size() == 0:
		queue_free()
		return

	start_dialogue()


func start_dialogue():

	if dialogue_index >= dialogue_array.size():
		queue_free()
		return

	label.text = dialogue_array[dialogue_index]
	label.visible_characters = 0

	timer.start()


func _on_timer_timeout():

	label.visible_characters += 1

	if label.visible_characters < label.text.length():
		timer.start()


func _input(event):

	if event.is_action_pressed("ui_accept") \
	or (event is InputEventMouseButton and event.pressed):

		# 文字还没显示完
		if !timer.is_stopped():

			label.visible_characters = label.text.length()
			timer.stop()

		# 当前句子已经显示完
		else:

			dialogue_index += 1

			if dialogue_index >= dialogue_array.size():
				queue_free()
			else:
				start_dialogue()
