extends Control
@onready var playerContainer = $MarginContainer/PlayerContainer
var player_customize_panels

func _ready():
	pass


func disable():
	for player in player_customize_panels:
		player.disabled = true

func set_customize_panels(players):
	for player in players:
		var panel = load("res://UI/player_customize_panel.tscn").instantiate() as PlayerCustomizePanel
		panel.add_to_group("PlayerCustomizePanel")
		playerContainer.add_child(panel)
	player_customize_panels = get_tree().get_nodes_in_group("PlayerCustomizePanel")
	for player_index in players.size():
		player_customize_panels[player_index].player = players[player_index]
		players[player_index].customize_panel = player_customize_panels[player_index]
