extends State
class_name Chase

var monster: CharacterBody2D
var target_mon : CharacterBody2D
var chase_time : float
var move_speed_adjust : int = 10
var target_radius : float

func randomize_chase():
	chase_time = randf_range(3,8)
	
	
func Enter():
	select_target()
	randomize_chase()

func Exit():
	monster.move_speed -= move_speed_adjust


func Physics_Update(delta:float):
	if target_mon:
		target_radius = target_mon.body_collision.shape.height
		var direction = target_mon.global_position - monster.global_position
		var distance = direction.length()
		chase_time -= delta
		
		if direction.length() > target_radius and target_mon.current_hp > 0 and chase_time > 0:
			var avoid_vector = get_avoidance_vector()
			var final_direction = (direction.normalized() + avoid_vector).normalized()
			monster.velocity = final_direction * monster.move_speed
		else:
			if target_mon.global_position.x < monster.global_position.x:
				monster.get_node("root").scale = Vector2(-1, 1)
			else:
				monster.get_node("root").scale = Vector2(1, 1)
			monster.velocity = Vector2()
			ChooseNewState.emit()


func select_target():
	var targetable_monsters : Array = get_targetable_monsters()
	if targetable_monsters.size():
		target_mon = targetable_monsters.pick_random()
		monster.animation_player.play("walk", -1.0, 1.5)
		monster.move_speed += move_speed_adjust
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


func get_avoidance_vector() -> Vector2:
	var repulsion = Vector2.ZERO
	var count = 0
	var nearby = monster.vision.get_overlapping_bodies()
	
	for body in nearby:
		if body == monster or !(body is CharacterBody2D) or body is Summon:
			continue

		var offset = monster.global_position - body.global_position
		var distance = offset.length()

		if distance < target_radius and distance > 0:
			var push_strength = (1.0 - (distance / target_radius)) * 1.5
			repulsion += offset.normalized() * push_strength
			count += 1

	if count > 0:
		return repulsion / count
	return Vector2.ZERO
