extends State
class_name Bite

var monster: CharacterBody2D

func Enter():
	monster.animation_player.play("bite")
	monster.velocity = Vector2.ZERO

func animation_finished(anim_name: String):
	if anim_name == "bite" and monster.state_machine.current_state == monster.state_machine.states["bite"]:
		ChooseNewState.emit()
