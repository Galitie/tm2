extends State
class_name Chase

var monster: CharacterBody2D
var target_mon : CharacterBody2D

func Enter():
	select_target()

# FIX: Since body colliders are uneven in nature, reaching the destination of a target
# is not always possible, or sometimes leaves the attacker in a position that is too far
# to land an attack.
func Physics_Update(_delta:float):
	if target_mon:
		var direction = target_mon.global_position - monster.global_position
		if direction.length() > 80 && target_mon.current_hp > 0:
			monster.velocity = direction.normalized() * monster.move_speed
		else:
			if target_mon.global_position.x < monster.global_position.x:
				monster.get_node("bunny").scale = Vector2(-1, 1)
			else:
				monster.get_node("bunny").scale = Vector2(1, 1)
			monster.velocity = Vector2()
			ChooseNewState.emit()


func select_target():
	var targetable_monsters : Array = get_targetable_monsters()
	if targetable_monsters.size():
		target_mon = targetable_monsters.pick_random()
		# No run animation yet, still deciding
		monster.animation_player.play("walk", -1.0, 1.5)
	else:
		ChooseNewState.emit()


func get_targetable_monsters() -> Array[CharacterBody2D]:
	var targetable_monsters: Array[CharacterBody2D] = []
	var monster_collection = get_tree().get_nodes_in_group("Monster")
	monster_collection.erase(monster)

	for mon in monster_collection:
		if mon.current_hp > 0:
			targetable_monsters.append(mon)

	return targetable_monsters

# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
