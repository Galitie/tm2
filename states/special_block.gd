extends State
class_name SpecialBlock

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("block")

func animation_finished(anim_name: String) -> void:
	pass
