extends State
class_name Win

var monster: CharacterBody2D


func Enter():
	pass

func animation_finished(anim_name: String) -> void:
	pass

func Physics_Update(_delta:float):
	monster.global_position = monster.global_position.move_toward(monster.target_point, 800 * _delta)
		
	if monster.global_position.is_equal_approx(monster.target_point):
		monster.global_position = monster.target_point
		monster.animation_player.play("dance")
