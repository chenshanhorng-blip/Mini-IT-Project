extends Node
class_name avoid_character_bug

var princess: CharacterStat
var knight: CharacterStat


func _ready() -> void:
	princess = Create_Character.Create_Character(Create_Character.CharacterType.BOAR_PRINCESS)
	knight = Create_Character.Create_Character(Create_Character.CharacterType.TEA_EGG_KNIGHT)

	print("\n===== PRINCESS TEST =====")
	princess.print_stat()

	print("\n===== KNIGHT TEST =====")
	knight.print_stat()

	print("\n===== DAMAGE TEST =====")
	print("Knight takes 40 damage")
	knight.take_damage_system(40)
	knight.print_stat()

	print("\n===== HEAL TEST =====")
	print("Knight heals 15 HP")
	knight.heal(15)
	knight.print_stat()
	print("\n===== DEATH TEST =====")
	print("Princess takes 999 damage")
	princess.take_damage_system(999)
	princess.print_stat()

	if princess.is_dead():
		print("Princess is dead")
	if knight.is_dead():
		print("Knight is dead")
