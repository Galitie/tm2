extends State
class_name Hurt

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
var low_health_fill_style := load("uid://dlwdv81v5y0h7") as StyleBox

func Enter():
	monster.velocity = Vector2.ZERO
	take_damage()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		check_if_knocked_out()
		ChooseNewState.emit(self)


func Physics_Update(_delta:float):
	pass


func take_damage():
	monster.current_hp -= 1
	monster.current_hp_label.text = str(monster.current_hp)
	monster.hp_bar.value = monster.current_hp
	check_low_hp()
	animation_player.play("hurt")


func check_if_knocked_out():
	if monster.current_hp <= 0:
		Transitioned.emit(self, "knockedout")


func check_low_hp():
	if monster.current_hp <= (monster.max_hp / 3):
		monster.hp_bar.add_theme_stylebox_override("fill", low_health_fill_style)
