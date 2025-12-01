extends State
class_name SpecialBlock

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("block")
