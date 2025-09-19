extends State
class_name KnockedOut

var monster: CharacterBody2D

func Enter():
	monster.toggle_collisions(false)
	monster.velocity = Vector2.ZERO
	monster.current_hp = 0
	monster.current_hp_label.text = "0"
	monster.hp_bar.value = monster.current_hp
	monster.z_index = -10
	monster.get_node("HPBar").visible = false
	Globals.game.count_death(monster)
	monster.name_label.hide()
	
	if !Globals.is_sudden_death_mode:
		monster.animation_player.play("faint")
	else:
		monster.root.modulate = Color("ff0e1b")
		
func Update(delta:float):
	if monster.sent_flying:
		monster.rotation += 50.0 * delta
		monster.global_position += Vector2(monster.knockback, -1.0) * 2000.0 * delta


func animation_finished(anim_name: String) -> void:
	if anim_name == "faint":
		pass
