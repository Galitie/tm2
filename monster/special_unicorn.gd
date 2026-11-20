extends State
class_name SpecialUnicorn

var monster: CharacterBody2D

func Enter():
	monster.start_unicorn_immunity()
	ChooseNewState.emit()


func animation_finished(_anim_name: String) -> void:
	pass
