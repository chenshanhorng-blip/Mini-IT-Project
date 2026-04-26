extends Node
class_name Create_Character
#the selection of the character type (princess or knight)
enum CharacterType{
	BOAR_PRINCESS,
	TEA_EGG_KNIGHT
}
#if player chosen the character and the system will create the system 
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
			stat.base_movement = 35
#the basic stat of the Tea Egg Knight	
		CharacterType.TEA_EGG_KNIGHT:
			stat.character_name = "Tea Egg Knight"
			stat.role = "Tank"
			stat.base_max_health = 85
			stat.base_attack = 15
			stat.base_max_shield = 15
			stat.base_movement = 20
		
	stat.setup_stats()
	return stat
				
