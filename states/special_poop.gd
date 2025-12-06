extends State
class_name SpecialPoop

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("poop")

func animation_finished(anim_name: String) -> void:
	pass
