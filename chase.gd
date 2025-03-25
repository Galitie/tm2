extends State
class_name Chase

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer

var move_direction : Vector2
var wander_time : float


func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,5)

func Enter():
	animation_player.play("run")
	randomize_wander()

func Update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		Transitioned.emit(self, "idle")

func Physics_Update(_delta:float):
	if monster:
		monster.velocity = move_direction * (monster.move_speed + 5)
