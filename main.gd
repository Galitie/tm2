extends Node2D
class_name Game

@export var total_rounds : int = 10
@export var debug_mode : bool = true
@export var start_in_fight_mode : bool

@onready var players : Array[Node] = get_tree().get_nodes_in_group("Player")
@onready var player_count : int = players.size()
@onready var upgrade_menu : Node = $UpgradePanel


var dead_monsters : int
var current_round : int
var current_mode : Modes
enum Modes {FIGHT, UPGRADE}


func debug_stuff():
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.FIGHT:
		var targetable_monsters: Array[CharacterBody2D] = []
		var monster_collection : Array[Node] = get_tree().get_nodes_in_group("Monster")
		for monster in monster_collection:
			var state_machine = monster.get_node("StateMachine")
			if state_machine.current_state != state_machine.states["knockedout"]:
				targetable_monsters.append(monster)
		if targetable_monsters.size():
			var target_monster = targetable_monsters.pick_random()
			target_monster.state_machine.transition_state("knockedout")
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.UPGRADE:
		set_fight_mode()
	if Input.is_action_just_pressed("ui_down"):
		Globals.is_sudden_death_mode = false


func _init():
	Globals.game = self


func _ready():
	var upgrade_cards = upgrade_menu.get_tree().get_nodes_in_group("UpgradeCard")
	var player_upgrade_panels = upgrade_menu.get_tree().get_nodes_in_group("PlayerUpgradePanel")
	for card in upgrade_cards:
		card.connect("card_pressed", card_pressed)
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.connect("reroll_pressed", reroll_pressed)
	if start_in_fight_mode:
		set_fight_mode()
	else:
		set_upgrade_mode()


func _process(_delta):
	if debug_mode:
		debug_stuff()


func count_death():
	dead_monsters += 1
	if dead_monsters == player_count - 1:
		$RoundOverDelayTimer.start()


func set_upgrade_mode():
	current_mode = Modes.UPGRADE
	check_if_game_over()
	$SuddenDeathTimer.stop()
	Globals.is_sudden_death_mode = false
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		monster.state_machine.transition_state("upgradestart")
		monster.global_position = upgrade_pos.global_position
		player.upgrade_points = 3
		player.rerolls = 3
	upgrade_menu.setup()
	upgrade_menu.visible = true


func set_fight_mode():
	current_mode = Modes.FIGHT
	current_round += 1
	$SuddenDeathTimer.start()
	dead_monsters = 0
	get_node("UpgradePanel").visible = false
	for player in players:
		var monster = player.get_node("Monster")
		var fight_pos = player.get_node("FightPos")
		monster.state_machine.transition_state("fightstart")
		monster.global_position = fight_pos.global_position


func _on_sudden_death_timer_timeout():
	Globals.is_sudden_death_mode = true
	print("Sudden death!")


func _on_round_over_delay_timer_timeout():
	set_upgrade_mode()


func _on_upgrade_over_delay_timer_timeout():
	set_fight_mode()


func card_pressed(card):
	var chosen_card = card.chosen_resource
	if chosen_card.unique:
		card.upgrade_panel.resource_array.erase(chosen_card)
	var player = card.upgrade_panel.player
	player.upgrade_points -= 1
	card.upgrade_panel.upgrade_title.text = "EXP POINTS [x" + str(player.upgrade_points) + "]"
	if chosen_card.attribute_1 != CardResourceScript.Attributes.NONE:
		if chosen_card.attribute_1 == CardResourceScript.Attributes.HP:
			player.monster.max_hp += chosen_card.attribute_amount_1
			player.monster.apply_hp(player.monster.max_hp)
		if chosen_card.attribute_1 == CardResourceScript.Attributes.MOVE_SPEED:
			player.monster.move_speed += chosen_card.attribute_amount_1
		if chosen_card.attribute_1 == CardResourceScript.Attributes.BASE_DAMAGE:
			player.monster.base_damage += chosen_card.attribute_amount_1
	# Sometimes I want to replace slots, not just add potential states...
	if chosen_card.state_id and not player.monster.state_machine.state_choices.has(chosen_card.state_id):
		player.monster.state_machine.state_choices.append(chosen_card.state_id)
	card.upgrade_panel.update_stats()
	check_if_upgrade_round_over(card, player)


func check_if_upgrade_round_over(card, player):
	var upgrade_panel = card.upgrade_panel
	if player.upgrade_points > 0:
		var deep_copy = upgrade_panel.resource_array.duplicate(true)
		for panel_card in upgrade_panel.upgrade_cards:
			if panel_card.chosen_resource.unique:
				deep_copy.erase(panel_card.chosen_resource)
		card.choose_card_resource(deep_copy.pick_random())
	else:
		upgrade_panel.disable_cards()
		upgrade_panel.reroll_button.text = "Out of 🎲"
		upgrade_panel.reroll_button.disabled = true
		upgrade_panel.upgrade_title.text = "DONE UPGRADING"
	var players_have_no_points = true
	for p in players:
		if p.upgrade_points > 0:
			players_have_no_points = false
			break
	if players_have_no_points:
		$UpgradeOverDelayTimer.start()


func reroll_pressed(upgrade_panel):
	var player = upgrade_panel.player
	if player.rerolls > 0 and player.upgrade_points > 0:
		player.rerolls -= 1
		upgrade_panel.setup_cards()
	if player.rerolls != 0 and player.upgrade_points > 0:
		upgrade_panel.reroll_button.text = "🎲 Reroll Upgrades " + "[x" + str(player.rerolls) + "]"
	else:
		upgrade_panel.reroll_button.text = "Out of 🎲"
		upgrade_panel.reroll_button.disabled = true


func check_if_game_over():
	if current_round == total_rounds:
		print("game over")
