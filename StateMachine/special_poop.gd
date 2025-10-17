extends State
class_name SpecialPoop

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("other")
