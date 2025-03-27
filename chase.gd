extends State
class_name Chase

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
var target_mon : CharacterBody2D


func Enter():
	select_target()
	animation_player.play("run")

#TODO: Check if the target_monster was knocked out while chasing
func Physics_Update(_delta:float):
	if target_mon:
		var direction = target_mon.global_position - monster.global_position
		if direction.length() > 100:
			monster.velocity = direction.normalized() * monster.move_speed
		else:
			monster.velocity = Vector2()
			ChooseNewState.emit(self)

#TODO: Check first if monster is not knocked out
func select_target():
	var player_collection = get_tree().get_nodes_in_group("Player")
	var self_in_player_collection = player_collection.find(monster)
	player_collection.remove_at(self_in_player_collection)
	if player_collection.size()  != 0:
		target_mon = player_collection.pick_random()
	else: 
		print("Could not find target")
		ChooseNewState.emit(self)
