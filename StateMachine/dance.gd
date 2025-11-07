extends State
class_name Dance

var monster: CharacterBody2D

#TODO: Raam, add dance animation here
func Enter():
	monster.animation_player.play("idle")
