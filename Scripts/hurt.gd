extends State
class_name Hurt

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer


func Enter():
	print("owwwwwie I'm hurt")
	animation_player.play("hurt")
	monster.velocity = Vector2.ZERO


func _on_animation_player_animation_finished(_anim_name):
	ChooseNewState.emit(self)
