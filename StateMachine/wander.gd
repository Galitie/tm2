extends State
class_name Wander

var monster: CharacterBody2D
var move_direction: Vector2
var wander_time: float

# --- Avoidance tuning ---
var avoidance_radius: float = 96.0
var avoidance_strength: float = 1.0
var max_accel: float = 5000.0

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 5)


func Enter():
	monster.animation_player.play("walk")
	randomize_wander()


func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		ChooseNewState.emit()


func Physics_Update(delta: float):
	if monster:
		var desired_dir = move_direction
		var avoidance = get_avoidance_vector()
		
		if avoidance.length() > 0.0001:
			desired_dir = (desired_dir + avoidance).normalized()

		var desired_velocity = desired_dir * monster.move_speed
		var steering = desired_velocity - monster.velocity
		if steering.length() > max_accel:
			steering = steering.normalized() * max_accel

		monster.velocity = monster.velocity + steering * delta


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
