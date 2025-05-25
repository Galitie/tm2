extends Node2D
class_name Game
@export var rounds : int = 10
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player_count = players.size()
@onready var upgrade_panel = $UpgradePanel
var dead_monsters : int

@export var debug_mode : bool = true

func _init():
	Globals.game = self


func _ready():
	var upgrade_cards = upgrade_panel.get_tree().get_nodes_in_group("UpgradeCard")
	for card in upgrade_cards:
		card.connect("card_pressed", card_pressed)


func _process(_delta):
	if debug_mode:
		debug_stuff()


func count_death():
	dead_monsters += 1
	if dead_monsters == player_count - 1:
		$RoundOverDelayTimer.start()


func set_upgrade_mode():
	$SuddenDeathTimer.stop()
	get_node("UpgradePanel").setup()
	get_node("UpgradePanel").visible = true
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		monster.state_machine.transition_state("upgradestart")
		monster.global_position = upgrade_pos.global_position


func set_fight_mode():
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
	for player in players:
		player.upgrade_points = 3


func debug_stuff():
	if Input.is_action_just_pressed("ui_accept"):
		var targetable_monsters: Array[CharacterBody2D] = []
		var monster_collection = get_tree().get_nodes_in_group("Monster")
		for monster in monster_collection:
			var state_machine = monster.get_node("StateMachine")
			if state_machine.current_state != state_machine.states["knockedout"]:
				targetable_monsters.append(monster)
		if targetable_monsters.size():
			var target_monster = targetable_monsters.pick_random()
			target_monster.state_machine.transition_state("knockedout")
	if Input.is_action_just_pressed("ui_down"):
		Globals.is_sudden_death_mode = false


func card_pressed(card):
	if card.chosen_resource.limited_to_one:
		card.upgrade_panel.resource_array.erase(card.chosen_resource)
	var player = card.upgrade_panel.player
	player.upgrade_points -= 1
	if card.chosen_resource.attribute_1 != 0:
		if card.chosen_resource.attribute_1 == 1: #HP
			player.monster.max_hp += card.chosen_resource.attribute_amount_1
			player.monster.apply_hp(player.monster.max_hp)
		if card.chosen_resource.attribute_1 == 2: #MOVE_SPEED
			player.monster.move_speed += card.chosen_resource.attribute_amount_1
		if card.chosen_resource.attribute_1 == 3: #BASE_DAMAGE
			player.monster.base_damage += card.chosen_resource.attribute_amount_1
	# Sometimes I want to replace slots, not just add potential states...
	if card.chosen_resource.state_id and not player.monster.state_machine.state_choices.has(card.chosen_resource.state_id):
		player.monster.state_machine.state_choices.append(card.chosen_resource.state_id)
	card.upgrade_panel.update_stats()
	check_if_upgrade_round_over(card, player)


func check_if_upgrade_round_over(card, player):
	if player.upgrade_points > 0:
		var deep_copy = card.upgrade_panel.resource_array.duplicate(true)
		for panel_card in card.upgrade_panel.upgrade_cards:
			if panel_card.chosen_resource.limited_to_one:
				deep_copy.erase(panel_card.chosen_resource)
		card.choose_card_resource(deep_copy.pick_random())
	else:
		card.upgrade_panel.disable_cards()
	var players_have_no_points = true
	for p in players:
		if p.upgrade_points > 0:
			players_have_no_points = false
			break
	if players_have_no_points:
		set_fight_mode()
