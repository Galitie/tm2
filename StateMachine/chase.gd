extends State
class_name Chase

var monster: CharacterBody2D
var target_mon: CharacterBody2D

# --- Movement tuning ---
var move_speed_adjust: int = 15
var max_accel: float = 5000.0

# --- Side position (chosen per chase) ---
const SIDE_OFFSET: float = 72.0
var side_sign: int = 1   # +1 = right, -1 = left

# --- Simple avoidance between monsters ---
var avoidance_radius: float = 96.0
var avoidance_strength: float = 10.0
var avoidance_weight: float = 5.0
var chase_time : float
var overlapping_hitbox : bool = false


func randomize_chase() -> void:
	chase_time = randf_range(3, 5)


func Enter() -> void:
	select_target()
	randomize_chase()
	if target_mon:
		monster.animation_player.play("walk", -1.0, 1.5)
		monster.move_speed += move_speed_adjust


func Exit() -> void:
	monster.move_speed -= move_speed_adjust
	overlapping_hitbox = false


func Physics_Update(delta: float) -> void:
	chase_time -= delta

	if target_mon == null or target_mon.current_hp <= 0:
		ChooseNewState.emit()
		return

	var can_keep_chasing = target_mon.current_hp > 0.0 and chase_time > 0.0

	var side_dir = Vector2(side_sign, 0.0)
	var side_goal = target_mon.global_position + side_dir * SIDE_OFFSET
	var to_side = side_goal - monster.global_position
	var dist_to_side = to_side.length()
	
	
	if overlapping_hitbox and can_keep_chasing:
		monster.velocity = Vector2.ZERO
		var rand = [1, 2].pick_random()
		if rand == 1:
			ChooseNewState.emit("basic_attack")
		else:
			ChooseNewState.emit("charge_attack")
		overlapping_hitbox = false
		return

	# ---- Steering toward the side goal with avoidance ----
	if dist_to_side > 1.0 and can_keep_chasing:
		var desired_dir = to_side.normalized()

		var avoidance = get_avoidance_vector()
		if avoidance.length() > 0.001:
			desired_dir = (desired_dir + avoidance * avoidance_weight).normalized()

		var desired_velocity = desired_dir * monster.move_speed
		var steering = desired_velocity - monster.velocity

		if steering.length() > max_accel:
			steering = steering.normalized() * max_accel

		monster.velocity += steering * delta

	if not can_keep_chasing:
		ChooseNewState.emit()


func select_target() -> void:
	var targetable_monsters = get_targetable_monsters()

	if targetable_monsters.size() > 0:
		target_mon = targetable_monsters.pick_random()

		# Choose the closer side
		var right_goal = target_mon.global_position + Vector2(1, 0) * SIDE_OFFSET
		var left_goal  = target_mon.global_position + Vector2(-1, 0) * SIDE_OFFSET

		var dist_right = (right_goal - monster.global_position).length()
		var dist_left  = (left_goal  - monster.global_position).length()

		if dist_right <= dist_left:
			side_sign = 1
		else:
			side_sign = -1
	else:
		target_mon = null
		ChooseNewState.emit()


func get_targetable_monsters() -> Array[CharacterBody2D]:
	var targetable: Array[CharacterBody2D] = []
	var mons = get_tree().get_nodes_in_group("Monster")

	mons.erase(monster)

	for mon in mons:
		if mon.current_hp > 0:
			targetable.append(mon)

	return targetable


func get_avoidance_vector() -> Vector2:
	var push_sum = Vector2.ZERO
	var neighbors = get_neighbor_monsters()

	for other in neighbors:
		var offset = monster.global_position - other.global_position
		var d = offset.length()
		if d > 0 and d < avoidance_radius:
			var weight = (1.0 - d / avoidance_radius) * avoidance_strength
			push_sum += offset.normalized() * weight

	return push_sum


func get_neighbor_monsters() -> Array[CharacterBody2D]:
	var neighbors: Array[CharacterBody2D] = []
	var mons = get_tree().get_nodes_in_group("Monster")

	for other in mons:
		if other != monster and other.current_hp > 0:
			var d = (other.global_position - monster.global_position).length()
			if d < avoidance_radius:
				neighbors.append(other)

	return neighbors


func animation_finished(anim_name: String) -> void:
	pass


func _on_proximity_chase_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtBox") and target_mon != null:
		if area == target_mon.hurtbox:
			overlapping_hitbox = true


func _on_proximity_chase_area_exited(area: Area2D) -> void:
	if area.is_in_group("HurtBox") and target_mon != null:
		if area == target_mon.hurtbox:
			overlapping_hitbox = false
