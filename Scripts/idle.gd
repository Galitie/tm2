extends State
class_name Idle

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer

var idle_time : float

func randomize_idle():
	idle_time = randf_range(1,5)

func Enter():
	animation_player.play("idle")
	randomize_idle()
	monster.velocity = Vector2.ZERO
	
func Update(delta:float):
	if idle_time > 0:
		idle_time -= delta
	else:
		Transitioned.emit(self, "wander")
