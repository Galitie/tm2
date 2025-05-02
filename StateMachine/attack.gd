extends State
class_name Attack

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox : Area2D

func Enter():
	animation_player.play("attack_front_close")
	monster.velocity = Vector2.ZERO


func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "attack_front_close":
		ChooseNewState.emit()
