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
var current_knocked_out_monsters : Array[Monster] = []
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
	#if Input.is_action_just_pressed("ui_down"):
		#Globals.is_sudden_death_mode = false
	#if Input.is_action_just_pressed("ui_up"):
		#generate_random_name()


func _init():
	Controller.process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.game = self


func _ready():
	if debug_mode:
		for player in players:
			player.monster.debug_mode = true
	for player_index in players.size():
		var player = players[player_index]
		player.controller_port = player_index
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


func count_death(monster: Monster):
	dead_monsters += 1
	current_knocked_out_monsters.append(monster)
	if dead_monsters == player_count - 1:
		$RoundOverDelayTimer.start()


func set_upgrade_mode():
	players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
	clear_knocked_out_monsters()
	current_mode = Modes.UPGRADE
	check_if_game_over()
	$SuddenDeathTimer.stop()
	Globals.is_sudden_death_mode = false
	var rerolls_amount_counter = 0
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		monster.target_point = upgrade_pos.global_position
		monster.state_machine.transition_state("upgradestart")
		player.upgrade_points = 3
		player.rerolls = rerolls_amount_counter
		rerolls_amount_counter += 1
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
	for player in players:
		if player.monster.current_hp > 0:
			current_knocked_out_monsters.append(player.monster)
			break
	var victory_points_gained = 0
	for monster in current_knocked_out_monsters:
		monster.player.victory_points += victory_points_gained
		victory_points_gained += 1
	set_upgrade_mode()
	for player in players:
		print(player.name, " : " ,player.victory_points)


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
	# Replace a slot
	if chosen_card.state_id:
		player.monster.state_machine.state_choices[chosen_card.Type] = chosen_card.state_id
	if chosen_card.remove_specific_states.size():
		for state in chosen_card.remove_specific_states:
			player.monster.state_machine.state_choices.erase(state)
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
	if current_round >= total_rounds:
		print("game over")
		players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
		var highest_score = players[0].victory_points
		var winners = players.filter(func(p): return p.victory_points == highest_score)
		if winners.size() == 1:
			print("Winner:", winners[0].name)
		else:
			print("It's a tie between:")
			for p in winners:
				print("- ", p.name)


func clear_knocked_out_monsters():
	current_knocked_out_monsters.clear()
