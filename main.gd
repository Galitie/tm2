extends Node2D
class_name Game
@export var rounds : int = 10
@onready var players = get_tree().get_nodes_in_group("Player")
var dead_monsters : int


func _init():
	Globals.game = self


func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func count_death():
	dead_monsters += 1
	if dead_monsters == 1:
		print("There's a winner")
		set_upgrade_mode()


func set_upgrade_mode():
	get_node("UpgradePanel").visible = true
	for player in players:
		var monster = player.get_node("Monster")
		var upgrade_pos = player.get_node("UpgradePos")
		var current_state = monster.state_machine.current_state
		monster.state_machine.transition_state(current_state, "upgrade")
		monster.global_position = upgrade_pos.global_position


func set_fight_mode():
	get_node("UpgradePanel").visible = false
	for player in players:
		var monster = player.get_node("Monster")
		var fight_pos = player.get_node("FightPos")
		var current_state = monster.state_machine.current_state
		monster.state_machine.transition_state(current_state, "idle")
		monster.global_position = fight_pos.global_position
