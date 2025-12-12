extends Control
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player_upgrade_panels = get_tree().get_nodes_in_group("PlayerUpgradePanel")
@onready var playerContainer = $MarginContainer/PlayerContainer

func _ready():
	pass


func setup():
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.setup_cards()
		player_upgrade_panel.setup_rerolls()
		player_upgrade_panel.set_upgrade_text()
		player_upgrade_panel.update_victory_points()
		if player_upgrade_panel.player.player_state == Player.PlayerState.BOT:
			player_upgrade_panel.hide_bot_stats()


func pause_all_inputs():
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.input_paused = true


func unpause_all_inputs():
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.input_paused = false


func set_upgrade_panels(players):
	for player in players:
		var panel = load("uid://ba3142spsuljy").instantiate() as PlayerUpgradePanel
		panel.add_to_group("PlayerUpgradePanel")
		playerContainer.add_child(panel)
	player_upgrade_panels = get_tree().get_nodes_in_group("PlayerUpgradePanel")
	for player_index in players.size():
		player_upgrade_panels[player_index].player = players[player_index]
		players[player_index].upgrade_panel = player_upgrade_panels[player_index]
