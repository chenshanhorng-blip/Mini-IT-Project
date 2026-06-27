extends CanvasLayer

@onready var hint_label = $HintLabel
@onready var cooldown_label = $TextureButton/CooldownLabel

var hints = [
	"Find the hidden key.",
	"Open the red door.",
	"Avoid the poison trap."
]

var hint_index = 0
var can_show_hint = true

func _ready():
	hint_label.visible = false
	cooldown_label.text = "Hint"

func _on_texture_button_pressed() -> void:

	# 冷却中不能按
	if !can_show_hint:
		return

	# 如果提示已经显示
	if hint_label.visible:

		# 关闭提示
		hint_label.visible = false

		# 开始冷却
		can_show_hint = false

		# 60秒倒数
		for i in range(60, 0, -1):

			cooldown_label.text = str(i) + "s"

			await get_tree().create_timer(1.0).timeout

		# 冷却结束
		cooldown_label.text = "Hint"
		can_show_hint = true

	# 如果提示隐藏
	else:

		# 显示提示
		hint_label.visible = true

		# 显示当前hint
		hint_label.text = hints[hint_index]

		# 下一条hint
		hint_index += 1

		# 超过最后一个hint后回到第一个
		if hint_index >= hints.size():
			hint_index = 0
