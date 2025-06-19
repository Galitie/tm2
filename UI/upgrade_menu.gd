extends Control
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player_upgrade_panels = get_tree().get_nodes_in_group("PlayerUpgradePanel")


func _ready():
	for player_index in range(players.size()):
		player_upgrade_panels[player_index].player = players[player_index]


func setup():
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.setup_cards()
		player_upgrade_panel.setup_rerolls()
		player_upgrade_panel.upgrade_title.text = "EXP POINTS [x" + str(player_upgrade_panel.player.upgrade_points) + "]"
