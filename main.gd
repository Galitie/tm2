extends Node2D
class_name Game

@export var total_rounds : int = 10
@export var debug_mode : bool = true
@export var start_in_fight_mode : bool

@onready var players : Array[Node] = get_tree().get_nodes_in_group("Player")
@onready var monsters: Array[Monster]
@onready var player_count : int = players.size()
@onready var upgrade_menu : Node = $UpgradePanel
@onready var sudden_death_label: Label = $SuddenDeathLabel
@onready var sudden_death_timer: Timer = $SuddenDeathTimer

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


func _init():
	Controller.process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.game = self


func _physics_process(_delta: float) -> void:
	# Sort monsters by Y position every second (for performance reasons)
	await get_tree().create_timer(1.0).timeout
	monsters.sort_custom(SortByY)
	for i: int in range(monsters.size()):
		if monsters[i].current_hp > 0:
			monsters[i].z_index = i
		else:
			monsters[i].z_index = -1


func SortByY(a, b):
	return a.global_position.y < b.global_position.y


func _ready():
	for player in players:
		monsters.push_back(player.monster)
		player.monster.state_machine.find_child("Pooping").connect("spawn_poop", spawn_poop)
		
	for monster in monsters:
		MonsterGeneration.Generate(monster.get_node("root"), MonsterGeneration.parts[MonsterPart.MONSTER_TYPE.BUNNY][MonsterPart.PART_TYPE.BODY])
		monster.SetCollisionRefs()
		monster.state_machine.initialize()

	if debug_mode:
		Globals.game.debug_mode = true
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
	if sudden_death_timer.is_stopped():
		sudden_death_label.text = "Sudden Death"
	else:
		var time_left = sudden_death_timer.time_left
		sudden_death_label.text = "Sudden Death: %d" % time_left


func count_death(monster: Monster):
	dead_monsters += 1
	current_knocked_out_monsters.append(monster)
	if dead_monsters == player_count - 1:
		$RoundOverDelayTimer.start()


func set_upgrade_mode():
	sudden_death_label.visible = false
	clean_up_screen()
	players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
	clear_knocked_out_monsters()
	current_mode = Modes.UPGRADE
	check_if_game_over()
	sudden_death_timer.stop()
	Globals.is_sudden_death_mode = false
	var rerolls_amount_counter = 0
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		monster.target_point = upgrade_pos.global_position
		monster.state_machine.transition_state("upgradestart")
		if player.randomize_upgrade_points:
			player.upgrade_points = randi_range(1,5)
		else:
			player.upgrade_points = 3
		if current_round == 0:
			player.rerolls = 3
		else:
			player.rerolls = rerolls_amount_counter + player.bonus_rerolls
		rerolls_amount_counter += 1
	upgrade_menu.setup()
	upgrade_menu.visible = true


func set_fight_mode():
	sudden_death_label.visible = true
	current_mode = Modes.FIGHT
	current_round += 1
	sudden_death_timer.start()
	dead_monsters = 0
	get_node("UpgradePanel").visible = false
	for player in players:
		var monster = player.get_node("Monster")
		var fight_pos = player.get_node("FightPos")
		monster.state_machine.transition_state("fightstart")
		monster.global_position = fight_pos.global_position


func _on_sudden_death_timer_timeout():
	Globals.is_sudden_death_mode = true


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
	card.upgrade_panel.upgrade_title.text = "UPG POINTS [x" + str(player.upgrade_points) + "]"
	apply_card_effects(card)
	if chosen_card.state_id:
		match chosen_card.state_id:
			"poop_summon":
				player.poop_summons = true
			"more_poops":
				player.more_poops = true
			_: # Replace a slot
				player.monster.state_machine.state_choices[chosen_card.Type] = chosen_card.state_id
	# Set a slot weight to 0. This comes from an array of weights
	if chosen_card.remove_specific_states.size():
		for state_index in chosen_card.remove_specific_states:
			player.monster.state_machine.weights[state_index] = 0

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


func spawn_poop(monster):
	var poop = preload("uid://b03qji6okxywb").instantiate()
	poop.z_index = -1
	poop.monster = monster
	poop.move_speed = monster.move_speed
	poop.global_position = monster.poop_checker.global_position
	if monster.player.poop_summons:
		poop.is_a_summon = true
	add_child(poop)
	poop.add_to_group("CleanUp")


func clean_up_screen():
	var items = get_tree().get_nodes_in_group("CleanUp")
	for item in items:
		item.queue_free()


func apply_card_effects(card):
	var attributes = [
		[card.chosen_resource.attribute_1, card.chosen_resource.attribute_amount_1],
		[card.chosen_resource.attribute_2, card.chosen_resource.attribute_amount_2],
		[card.chosen_resource.attribute_3, card.chosen_resource.attribute_amount_3]
	]
	
	for attr_data in attributes:
		var attr = attr_data[0]
		var amount = attr_data[1]
		if attr != CardResourceScript.Attributes.NONE:
			apply_card_attribute(attr, amount, card)


func apply_card_attribute(attribute, amount, card):
	var player = card.upgrade_panel.player
	match attribute:
		CardResourceScript.Attributes.HP:
			player.monster.max_hp += amount
			player.monster.apply_hp(player.monster.max_hp)
		CardResourceScript.Attributes.MOVE_SPEED:
			player.monster.move_speed += amount
		CardResourceScript.Attributes.BASE_DAMAGE:
			player.monster.base_damage += amount
		CardResourceScript.Attributes.REROLL:
			player.bonus_rerolls += amount
		CardResourceScript.Attributes.UPGRADE_POINTS:
			player.randomize_upgrade_points = true
		CardResourceScript.Attributes.CRIT_PERCENT:
			player.monster.crit_chance += amount
		CardResourceScript.Attributes.CRIT_MULTIPLIER:
			player.monster.crit_multiplier += amount
