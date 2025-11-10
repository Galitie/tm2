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
var side_offset: float = 48.0      # lateral offset from target center
var side_sign: int = 1             # +1 right, -1 left (sticky but can swap)
var lead_time: float = 0.15

# --- Side selection stability & attack reach ---
var side_stick_bias: float = 24.0      # other side must be this many px closer to flip
var side_reselect_cooldown: float = 0.25
var side_reselect_timer: float = 0.0

var attack_range_scale: float = 2      # can attack if within r * scale of target center
var side_arrive_radius_factor: float = 0.9 # can attack if within this fraction of side_offset


func randomize_chase():
	chase_time = randf_range(5, 7)


func Enter():
	select_target()
	randomize_chase()


func Exit():
	monster.move_speed -= move_speed_adjust


func Physics_Update(delta: float) -> void:
	if target_mon == null:
		return

	side_reselect_timer = max(0.0, side_reselect_timer - delta)

	# Predict target and derive forward/right vectors
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

	# Robust target radius (fallback if body_collision/radius not present)
	var target_r := 32.0
	if "body_collision" in target_mon and target_mon.body_collision and "shape" in target_mon.body_collision:
		if "radius" in target_mon.body_collision.shape:
			target_r = float(target_mon.body_collision.shape.radius)

	# Dynamic offsets & thresholds
	side_offset = max(side_offset, target_r)
	var attack_radius = target_r * attack_range_scale
	var side_arrive_radius = max(8.0, side_offset * side_arrive_radius_factor)

	# Compute both side goals relative to current facing
	var side_goal_right = predicted + right_vec * side_offset
	var side_goal_left  = predicted - right_vec * side_offset

	var to_right = side_goal_right - monster.global_position
	var to_left  = side_goal_left  - monster.global_position
	var d_right  = to_right.length()
	var d_left   = to_left.length()

	# --- Attack no matter what side we end up on ---
	var center_dist = (predicted - monster.global_position).length()
	var near_either_side = false
	if d_right <= side_arrive_radius or d_left <= side_arrive_radius:
		near_either_side = true

	chase_time -= delta
	var can_keep_chasing = target_mon.current_hp > 0.0 and chase_time > 0.0

	if (center_dist <= attack_radius or near_either_side) and can_keep_chasing:
		monster.velocity = Vector2.ZERO
		var rand = [1, 2].pick_random()
		if rand == 1:
			ChooseNewState.emit("basic_attack")
			return
		else:
			ChooseNewState.emit("charge_attack")
			return

	# --- Choose side with hysteresis (prevent flip-flop when target spins) ---
	if side_reselect_timer == 0.0:
		var cur_d: float
		var other_d: float
		if side_sign >= 0:
			cur_d = d_right
			other_d = d_left
		else:
			cur_d = d_left
			other_d = d_right

		if other_d < cur_d - side_stick_bias:
			side_sign = -side_sign
			side_reselect_timer = side_reselect_cooldown

	# Pursue current side
	var side_goal: Vector2
	if side_sign >= 0:
		side_goal = side_goal_right
	else:
		side_goal = side_goal_left

	var to_goal = side_goal - monster.global_position
	var dist = to_goal.length()

	if dist > 1.0 and can_keep_chasing:
		var desired_dir = to_goal.normalized()

		# Avoidance contribution
		var avoidance = get_avoidance_vector()
		if avoidance.length() > 0.0001:
			desired_dir = (desired_dir + avoidance).normalized()

		var desired_velocity = desired_dir * monster.move_speed
		var steering = desired_velocity - monster.velocity
		if steering.length() > max_accel:
			steering = steering.normalized() * max_accel

		monster.velocity += steering * delta
	else:
		monster.velocity = Vector2.ZERO
		var rand2 = [1, 2].pick_random()
		if rand2 == 1:
			ChooseNewState.emit("basic_attack")
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
			push_sum += offset.normalized() * weight

	if push_sum.length() > 0.0001:
		return push_sum.normalized()
	return Vector2.ZERO


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
