extends Control
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player_customize_panels = get_tree().get_nodes_in_group("PlayerCustomizePanel")


func _ready():
	for player_index in range(players.size()):
		player_customize_panels[player_index].player = players[player_index]
		players[player_index].customize_panel = player_customize_panels[player_index]


func disable():
	for player in player_customize_panels:
		player.disabled = true
