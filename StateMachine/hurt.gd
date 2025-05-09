extends State
class_name Hurt

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer



func Enter():
	monster.velocity = Vector2.ZERO
	animation_player.play("hurt")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		if check_if_knocked_out():
			return
		ChooseNewState.emit()

func check_if_knocked_out():
	if monster.current_hp <= 0:
		Transitioned.emit("knockedout")
		return true
	return false
