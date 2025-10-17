extends State
class_name Wander

var monster: CharacterBody2D
var move_direction: Vector2
var wander_time: float

# --- Avoidance tuning ---
var avoidance_radius: float = 96.0
var avoidance_strength: float = 1.0
var max_accel: float = 5000.0
var screen_margin: float = 50.0        # start steering back this far from the edges
var boundary_strength: float = 2.0  

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 8)


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

		# Flocking-style avoidance
		var avoidance = get_avoidance_vector()
		# New: boundary avoidance
		var edge_avoid = get_boundary_avoidance_vector()

		# Blend desired with both avoidance terms
		if avoidance.length() > 0.0001 or edge_avoid.length() > 0.0001:
			desired_dir = (desired_dir + avoidance + edge_avoid).normalized()

		var desired_velocity = desired_dir * monster.move_speed
		var steering = desired_velocity - monster.velocity
		if steering.length() > max_accel:
			steering = steering.normalized() * max_accel

		monster.velocity += steering * delta

		# Optional tiny hard clamp (prevents rare tunneling off-screen on big dt spikes)
		var rect: Rect2 = monster.get_viewport().get_visible_rect()
		var next_pos := monster.global_position + monster.velocity * delta
		var minp := rect.position + Vector2(screen_margin, screen_margin)
		var maxp := rect.position + rect.size - Vector2(screen_margin, screen_margin)
		if next_pos.x < minp.x or next_pos.x > maxp.x:
			monster.velocity.x = 0.0
		if next_pos.y < minp.y or next_pos.y > maxp.y:
			monster.velocity.y = 0.0


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



func get_boundary_avoidance_vector() -> Vector2:
	var rect: Rect2 = monster.get_viewport().get_visible_rect()
	var pos: Vector2 = monster.global_position
	var force := Vector2.ZERO

	var left  := rect.position.x + screen_margin
	var right := rect.position.x + rect.size.x - screen_margin
	var top   := rect.position.y + screen_margin
	var bottom:= rect.position.y + rect.size.y - screen_margin

	# Push proportionally to how far we’ve crossed into the margin band
	if pos.x < left:
		force.x += ((left - pos.x) / screen_margin) * boundary_strength
	elif pos.x > right:
		force.x -= ((pos.x - right) / screen_margin) * boundary_strength

	if pos.y < top:
		force.y += ((top - pos.y) / screen_margin) * boundary_strength
	elif pos.y > bottom:
		force.y -= ((pos.y - bottom) / screen_margin) * boundary_strength

	return force
	
# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
