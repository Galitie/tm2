extends State
class_name SpecialAttack

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("basic_attack")

func animation_finished(_anim_name: String) -> void:
	pass
