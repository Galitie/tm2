extends State
class_name Bite

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer

func Enter():
	print("biting!")
	animation_player.play("attack_front_close")
	monster.velocity = Vector2.ZERO


func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "attack_front_close" and monster.state_machine.current_state == monster.state_machine.states["bitelifesteal"]:
		ChooseNewState.emit()
