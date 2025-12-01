extends State
class_name SpecialAttack

var monster: CharacterBody2D

func Enter():
	ChooseNewState.emit("basic_attack")
