extends State
class_name KnockedOut

var monster: CharacterBody2D

func Enter():
	monster.animation_player.play("faint")
	monster.toggle_collisions(false)
	monster.velocity = Vector2.ZERO
	monster.current_hp = 0
	monster.current_hp_label.text = "0"
	monster.hp_bar.value = monster.current_hp
	monster.z_index = -10
	monster.get_node("HPBar").visible = false
	Globals.game.count_death(monster)


func animation_finished(anim_name: String) -> void:
	if anim_name == "faint":
		pass
