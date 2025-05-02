extends Control
@export var monster_1 : Monster
@export var monster_2 : Monster
@export var monster_3 : Monster
@export var monster_4 : Monster


func _ready():
	for player_1_card in get_tree().get_nodes_in_group("PlayerOneCard"):
		player_1_card.monster = monster_1
	for player_2_card in get_tree().get_nodes_in_group("PlayerTwoCard"):
		player_2_card.monster = monster_2
	for player_3_card in get_tree().get_nodes_in_group("PlayerThreeCard"):
		player_3_card.monster = monster_3
	for player_4_card in get_tree().get_nodes_in_group("PlayerFourCard"):
		player_4_card.monster = monster_4
		
