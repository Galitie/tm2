extends State
class_name Chase

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
var target_mon : CharacterBody2D


func Enter():
	select_target()


func Physics_Update(_delta:float):
	if target_mon:
		var direction = target_mon.global_position - monster.global_position
		if direction.length() > 100:
			monster.velocity = direction.normalized() * monster.move_speed
		else:
			monster.velocity = Vector2()
			ChooseNewState.emit()


func select_target():
	var targetable_monsters : Array = get_targetable_monsters()
	if targetable_monsters.size():
		target_mon = targetable_monsters.pick_random()
		animation_player.play("run")
	else:
		ChooseNewState.emit()


func get_targetable_monsters() -> Array[CharacterBody2D]:
	var targetable_monsters: Array[CharacterBody2D] = []
	var monster_collection = get_tree().get_nodes_in_group("Monster")
	monster_collection.erase(monster)

	for monster in monster_collection:
		var state_machine = monster.get_node("StateMachine")
		if state_machine.current_state != state_machine.states["knockedout"]:
			targetable_monsters.append(monster)

	return targetable_monsters
