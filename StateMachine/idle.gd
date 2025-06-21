extends State
class_name Idle

var monster: CharacterBody2D

var idle_time : float

func randomize_idle():
	idle_time = randf_range(1,5)


func Enter():
	monster.animation_player.play("idle")
	randomize_idle()
	monster.velocity = Vector2.ZERO


func Update(delta:float):
	if idle_time > 0:
		idle_time -= delta
	else:
		ChooseNewState.emit()

func animation_finished(anim_name: String) -> void:
	pass
