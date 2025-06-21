extends State
class_name Hurt

var monster: CharacterBody2D

func Enter():
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("hurt")

func animation_finished(anim_name: String):
	if anim_name == "hurt":
		if check_if_knocked_out():
			return
		ChooseNewState.emit()

func check_if_knocked_out():
	if monster.current_hp <= 0:
		Transitioned.emit("knockedout")
		return true
	return false
