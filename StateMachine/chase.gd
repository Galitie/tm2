extends State
class_name Chase

var monster: CharacterBody2D
var target_mon: CharacterBody2D
var chase_time: float
var move_speed_adjust: int = 10

# --- Avoidance tuning ---
var avoidance_radius: float = 96.0      # how far to "feel" other monsters
var avoidance_strength: float = 1.0     # how strongly to push away
var max_accel: float = 1200.0           # acceleration cap for steering

func randomize_chase():
	chase_time = randf_range(3, 8)

func Enter():
	select_target()
	randomize_chase()

func Exit():
	monster.move_speed -= move_speed_adjust

func Physics_Update(delta: float) -> void:
	if target_mon:
		var to_target = target_mon.global_position - monster.global_position
		var dist = to_target.length()
		chase_time -= delta

		if dist > 200.0 and target_mon.current_hp > 0.0 and chase_time > 0.0:
			# Base desired direction toward target
			var desired_dir = Vector2()
			if to_target.length() > 0.0:
				desired_dir = to_target.normalized()

			# Add avoidance (separation) from nearby monsters
			var avoidance = get_avoidance_vector()
			if avoidance.length() > 0.0001:
				desired_dir = (desired_dir + avoidance).normalized()

			# Keep full move speed; steer with an accel cap
			var desired_velocity = desired_dir * monster.move_speed
			var steering = desired_velocity - monster.velocity
			if steering.length() > max_accel:
				steering = steering.normalized() * max_accel

			monster.velocity = monster.velocity + steering * delta
		else:
			monster.velocity = Vector2()
			ChooseNewState.emit()

func select_target():
	var targetable_monsters: Array = get_targetable_monsters()
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

# --- NEW: avoidance helpers ---
func get_avoidance_vector() -> Vector2:
	var push_sum = Vector2()
	var neighbors = get_neighbor_monsters()

	for other in neighbors:
		var offset = monster.global_position - other.global_position  # push away from other
		var d = offset.length()
		if d > 0.0 and d < avoidance_radius:
			# Weight falls off linearly with distance; stronger when closer
			var weight = (1.0 - (d / avoidance_radius)) * avoidance_strength
			push_sum = push_sum + offset.normalized() * weight

	# Normalize to keep it as a direction contribution
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
