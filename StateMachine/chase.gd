extends State
class_name Chase

var monster: CharacterBody2D
var target_mon: CharacterBody2D
var chase_time: float
var move_speed_adjust: int = 15

var avoidance_radius: float = 96.0
var avoidance_strength: float = 4.0
var max_accel: float = 5000.0

# --- Side-chase settings ---
var side_offset: float = 50     # how far to the side of the target to aim
var side_sign: int = 1            # +1 = target's right, -1 = target's left
var lead_time: float = 0.15       # small predictive lead, optional


func randomize_chase():
	chase_time = randf_range(3, 8)


func Enter():
	select_target()
	randomize_chase()


func Exit():
	monster.move_speed -= move_speed_adjust


func Physics_Update(delta: float) -> void:
	if target_mon:
		var predicted = target_mon.global_position + target_mon.velocity * lead_time
		var forward: Vector2
		if target_mon.velocity.length() > 1.0:
			forward = target_mon.velocity.normalized()
		else:
			var to_target_now = predicted - monster.global_position
			if to_target_now.length() > 0.0:
				forward = to_target_now.normalized()
			else:
				forward = Vector2(1, 0)

		var right_vec = forward.orthogonal()
		side_offset = target_mon.body_collision.shape.radius * 1.25
		var side_goal = predicted + right_vec * side_offset * side_sign
		
		var to_goal = side_goal - monster.global_position
		var dist = to_goal.length()
		chase_time -= delta
		if dist > (target_mon.body_collision.shape.radius * 1.15) and target_mon.current_hp > 0.0 and chase_time > 0.0:
			var desired_dir = Vector2()
			if dist > 0.0:
				desired_dir = to_goal.normalized()

			# Avoidance contribution
			var avoidance = get_avoidance_vector()
			if avoidance.length() > 0.0001:
				desired_dir = (desired_dir + avoidance).normalized()

			var desired_velocity = desired_dir * monster.move_speed
			var steering = desired_velocity - monster.velocity
			if steering.length() > max_accel:
				steering = steering.normalized() * max_accel

			monster.velocity = monster.velocity + steering * delta
		else:
			monster.velocity = Vector2()
			var rand = [1, 2].pick_random()
			if rand == 1:
				ChooseNewState.emit("basic_attack")
				return
			else:
				ChooseNewState.emit("charge_attack")


func select_target():
	var targetable_monsters: Array = get_targetable_monsters()
	if targetable_monsters.size() > 0:
		target_mon = targetable_monsters.pick_random()
		monster.animation_player.play("walk", -1.0, 1.5)
		monster.move_speed += move_speed_adjust

		if randf() < 0.5:
			side_sign = -1
		else:
			side_sign = 1
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


func get_avoidance_vector() -> Vector2:
	var push_sum = Vector2()
	var neighbors = get_neighbor_monsters()

	for other in neighbors:
		var offset = monster.global_position - other.global_position
		var d = offset.length()
		if d > 0.0 and d < avoidance_radius:
			var weight = (1.0 - (d / avoidance_radius)) * avoidance_strength
			push_sum = push_sum + offset.normalized() * weight

	if push_sum.length() > 0.0001:
		return push_sum.normalized()
	return Vector2()


func get_neighbor_monsters() -> Array[CharacterBody2D]:
	var neighbors: Array[CharacterBody2D] = []
	var all_monsters = get_tree().get_nodes_in_group("Monster")
	for other in all_monsters:
		if other != monster and other.current_hp > 0:
			var d = (other.global_position - monster.global_position).length()
			if d < avoidance_radius:
				neighbors.append(other)
	return neighbors


# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
