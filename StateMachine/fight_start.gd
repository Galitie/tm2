extends State
class_name Fight

var monster: CharacterBody2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	monster.velocity = Vector2()
	monster.toggle_collisions(true)
	monster.get_node("HPBar").visible = true
	monster.z_index = 1
	Transitioned.emit("wander")
	monster.name_label.show()

# Don't remove these
func animation_finished(anim_name: String) -> void:
	pass
