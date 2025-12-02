extends State
class_name Reset

var monster: CharacterBody2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	monster.modify_hp(null, monster.max_hp)
	monster.animation_player.play("get_up")
	monster.get_node("HPBar").visible = true
	monster.hp_bar.add_theme_stylebox_override("fill", health_fill_style)
	monster.z_index = 1
	monster.toggle_collisions(true)
	monster.velocity = Vector2()

# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
