extends State
class_name Hurt

var monster: CharacterBody2D

func Enter():
	if check_if_knocked_out():
		Transitioned.emit("knockedout")
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("hurt")

func animation_finished(anim_name: String):
	ChooseNewState.emit()

func check_if_knocked_out():
	if monster.current_hp <= 0:
		return true
	return false
