extends CanvasLayer

@onready var panel1 = $panel1
@onready var panel2 = $panel2
@onready var panel3 = $panel3
@onready var panel4 = $panel4
@onready var panel5 = $panel5
@onready var panel6 = $panel6
@onready var label = $Label

var panels = []
var ending_finished = false

func _ready():
	panels = [
		panel1,
		panel2,
		panel3,
		panel4,
		panel5,
		panel6
	]

	for p in panels:
		p.visible = false
		p.modulate.a = 0.0
		p.scale = Vector2.ONE

	label.visible = false

	await get_tree().process_frame
	await play_ending()


func play_ending():
	for p in panels:

		for x in panels:
			x.visible = false
			x.modulate.a = 0.0

		p.visible = true
		p.modulate.a = 0.0
		p.scale = Vector2(0.9, 0.9)

		await get_tree().process_frame

		var tween = create_tween()

		tween.parallel().tween_property(
			p,
			"modulate:a",
			1.0,
			0.5
		)

		tween.parallel().tween_property(
			p,
			"scale",
			Vector2(1.0, 1.0),
			2.0
		)

		await tween.finished

		await get_tree().create_timer(1.5).timeout

		var fade_out = create_tween()

		fade_out.tween_property(
			p,
			"modulate:a",
			0.0,
			0.5
		)

		await fade_out.finished

	label.text = "THE END\n\nPress Enter To Continue"
	label.visible = true
	ending_finished = true


func _process(_delta):
	if label.visible:
		label.modulate.a = 0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.5


func _input(event):
	if ending_finished and event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://main.tscn")
