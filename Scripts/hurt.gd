extends State
class_name Hurt

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer


func Enter():
	animation_player.play("hurt")
	monster.velocity = Vector2.ZERO

#still manually moving to wander state, want this to not be hardcoded
func _on_animation_player_animation_finished(anim_name):
	Transitioned.emit(self, "wander")
