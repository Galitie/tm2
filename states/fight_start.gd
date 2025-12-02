extends State
class_name Fight

var monster: CharacterBody2D
var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

var moving_in: bool = false
var arrival_speed: float = 800.0

func Enter() -> void:
	monster.velocity = Vector2()
	monster.toggle_collisions(true)
	monster.get_node("HPBar").visible = true
	monster.z_index = 1
	monster.name_label.show()

	if monster.target_point != null:
		moving_in = true
		monster.animation_player.play("walk", -1.0, 2.0)


func Physics_Update(delta: float) -> void:
	if moving_in:
		monster.global_position = monster.global_position.move_toward(monster.target_point, arrival_speed * delta)
		
		var root: Node2D = monster.get_node("root")
		var s: Vector2 = root.scale
		if monster.target_point.x < monster.global_position.x:
			s.x = -abs(s.x)
		else:
			s.x = abs(s.x)  
		root.scale = s

		if monster.global_position.is_equal_approx(monster.target_point):
			moving_in = false
			monster.global_position = monster.target_point
			monster.animation_player.play("idle")
			_emit_next_behavior()


func _emit_next_behavior() -> void:
	var next_pool = [ "chase", "wander" ]
	var next_state = next_pool.pick_random()
	Transitioned.emit(next_state)


func animation_finished(anim_name: String) -> void:
	pass
