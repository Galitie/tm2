extends State
class_name Punch

var monster: CharacterBody2D

func Enter():
	monster.animation_player.play("basic_attack")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "basic_attack":
		ChooseNewState.emit()
