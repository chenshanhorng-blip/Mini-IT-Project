extends Control


##Node References
@onready var label : Label = $Label
@onready var timer : Timer = $Timer
@onready var button: Button = $Button

##Variables
var dialogue_array : Array = [
	"hi one two three for",
	"IT'S SPELLED FOURRRRRRRR,BRUHHHHH",
	"ok,chilled bro"
]
var dialogue_index : int = 0:
	set(value):
		dialogue_index = value
		
		label.visible_characters = -1

##Initialization
func _ready() -> void:
	label.text = ""
	timer.timeout.connect(animate_label)
	
	
##
func animate_label() -> void:
	if dialogue_index >= dialogue_array.size():
		return
	
	label.text = dialogue_array[dialogue_index]
	label.visible_characters += 1
	
	if label.visible_ratio == 1:
		dialogue_index += 1
	else:
		timer.start()


func _on_button_pressed() -> void:
	if dialogue_index >= dialogue_array.size():
		dialogue_index = 0
		label.text = ""
		return
	
	if timer.is_stopped():
		animate_label()
	else:
		dialogue_index += 1
		timer.stop()
