extends State
class_name Zombie

var monster: CharacterBody2D

func Enter():
	monster.animation_player.play("faint")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String) -> void:
	pass
