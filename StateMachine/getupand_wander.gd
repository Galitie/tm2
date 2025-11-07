extends State
class_name GetupandGo

var monster: CharacterBody2D

func Enter():
	monster.animation_player.play("get_up")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String) -> void:
	if anim_name == "get_up":
		ChooseNewState.emit()
