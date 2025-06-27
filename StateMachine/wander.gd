extends State
class_name Wander

var monster: CharacterBody2D

var move_direction : Vector2
var wander_time : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,5)

func Enter():
	monster.animation_player.play("walk")
	randomize_wander()

func Update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		ChooseNewState.emit()

func Physics_Update(_delta:float):
	if monster:
		monster.velocity = move_direction * monster.move_speed

# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
