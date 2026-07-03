extends Node
class_name Create_Character
#the selection of the character type (princess or knight)
enum CharacterType{#enum is to makr sure what the player can select
	BOAR_PRINCESS,
	TEA_EGG_KNIGHT
}
#if player chosen the character and the system will create the stat selected by player 
static func Create_Character(type: CharacterType) -> CharacterStat:
	var stat = CharacterStat.new()
#match the character stat choose by player 
	match type:
#the basic stat of the Boar Princess
		CharacterType.BOAR_PRINCESS:
			stat.character_name = "Boar Princess"
			stat.role = "Attacker"
			stat.base_max_health = 70
			stat.base_attack = 30
			stat.base_max_shield = 5
			stat.base_movement = 350
			#princess skill and ultimate cooldown
			stat.skill1_cooldown = 5
			stat.skill2_cooldown = 6
			stat.ultimate_cooldown = 25
#the basic stat of the Tea Egg Knight	
		CharacterType.TEA_EGG_KNIGHT:
			stat.character_name = "Tea Egg Knight"
			stat.role = "Tank"
			stat.base_max_health = 90
			stat.base_attack = 20
			stat.base_max_shield = 30
			stat.base_movement=200
			#knight skill and ultimate cooldown 
			stat.skill1_cooldown = 7
			stat.skill2_cooldown = 6
			stat.ultimate_cooldown = 20
		
	stat.setup_stats()
	return stat
				
