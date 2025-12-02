extends State
class_name Dance

var monster: CharacterBody2D

#TODO: Raam, add dance animation here
func Enter():
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("idle")

func animation_finished(anim_name: String) -> void:
	pass
