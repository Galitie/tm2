extends State
class_name Attack

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer


func Enter():
	animation_player.play("attack")
	monster.velocity = Vector2.ZERO

#still manually moving to wander state, want this to not be hardcoded
func _on_animation_player_animation_finished(_anim_name):
	Transitioned.emit(self, "idle")