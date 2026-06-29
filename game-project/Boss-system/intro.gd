extends CanvasLayer

@onready var panel1 = $panel1
@onready var panel2 = $panel2
@onready var panel3 = $panel3
@onready var panel4 = $panel4
@onready var panel5 = $panel5
@onready var panel6 = $panel6
@onready var label = $Label

var panels = []
var intro_finished = false

func _ready():
	panels = [panel1, panel2, panel3, panel4, panel5, panel6]

	# 全部隐藏
	for p in panels:
		p.visible = false
		p.modulate.a = 0

	label.visible = false

	show_comic()


func show_comic():
	for p in panels:

		# 隐藏所有图片
		for x in panels:
			x.visible = false
			x.modulate.a = 0
			x.scale = Vector2.ONE

		# 显示当前图片
		p.visible = true

		# 初始大小
		p.scale = Vector2(1.0, 1.0)

		# Fade In + Zoom In
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
			Vector2(1.15, 1.15),
			2.0
		)

		await tween.finished

		# 停留
		await get_tree().create_timer(1.5).timeout

		# Fade Out
		var fade = create_tween()

		fade.tween_property(
			p,
			"modulate:a",
			0.0,
			0.5
		)

		await fade.finished

	# 最后显示提示文字
	label.visible = true
	intro_finished = true


func _process(_delta):
	if label.visible:
		label.modulate.a = 0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.5


func _input(event):
	if intro_finished and event.is_action_pressed("ui_accept"):
		Transition.fade_to_scene("res://princessgame/multiplayer system/mode_selection.tscn")
