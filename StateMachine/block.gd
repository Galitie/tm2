extends State
class_name Block

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer



func Enter():
	animation_player.play("block")
	monster.velocity = Vector2.ZERO

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "block":
		ChooseNewState.emit()
