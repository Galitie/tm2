extends Node2D
class_name Game
@export var rounds : int = 10
@export var debug_mode : bool = true
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player_count = players.size()
@onready var upgrade_panel = $UpgradePanel

var dead_monsters : int


func _init():
	Globals.game = self


func _ready():
	var upgrade_cards = upgrade_panel.get_tree().get_nodes_in_group("card")
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
	get_node("UpgradePanel").visible = true
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		monster.state_machine.transition_state("upgradestart")
		monster.global_position = upgrade_pos.global_position


func set_fight_mode():
	#$SuddenDeathTimer.start()
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
	if Input.is_action_just_pressed("ui_cancel"):
		set_fight_mode()
	if Input.is_action_just_pressed("ui_down"):
		Globals.is_sudden_death_mode = false


func card_pressed(resource, monster):
	if resource.hp:
		monster.max_hp += resource.hp
		monster.apply_hp(monster.max_hp)
	if resource.state_id and not monster.state_machine.state_choices.has(resource.state_id):
		monster.state_machine.state_choices.append(resource.state_id)
