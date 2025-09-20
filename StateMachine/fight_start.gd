extends State
class_name Fight

var monster: CharacterBody2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	monster.velocity = Vector2()
	monster.toggle_collisions(true)
	monster.get_node("HPBar").visible = true
	monster.z_index = 1
	var random = [1,2].pick_random()
	if random == 1:
		Transitioned.emit("chase")
	else:
		Transitioned.emit("wander")
	monster.name_label.show()

# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
