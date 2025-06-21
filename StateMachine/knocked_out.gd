extends State
class_name KnockedOut

var monster: CharacterBody2D

func Enter():
	monster.toggle_collisions(false)
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("faint")
	monster.current_hp = 0
	monster.current_hp_label.text = "0"
	monster.hp_bar.value = monster.current_hp


func animation_finished(anim_name: String) -> void:
	if anim_name == "faint":
		monster.z_index = -10
		#monster.animation_player.play("knocked_out")
		monster.velocity = Vector2.ZERO
		monster.get_node("HPBar").visible = false
		Globals.game.count_death(monster)
