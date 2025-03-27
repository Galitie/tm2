extends State
class_name Hurt

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer


func Enter():
	monster.velocity = Vector2.ZERO
	take_damage()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		ChooseNewState.emit(self)

func Physics_Update(_delta:float):
	check_if_knocked_out()


func take_damage():
	print("took damage")
	monster.current_hp -= 1
	monster.current_hp_label.text = str(monster.current_hp)
	monster.hp_bar.value = monster.current_hp
	animation_player.play("hurt")


func check_if_knocked_out():
	if monster.current_hp <= 0:
		Transitioned.emit(self, "knockedout")
		
