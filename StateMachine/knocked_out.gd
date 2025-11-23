extends State
class_name KnockedOut

var monster: CharacterBody2D



func Enter():
	monster.velocity = Vector2.ZERO
	monster.current_hp = 0
	monster.current_hp_label.text = "0"
	monster.hp_bar.value = monster.current_hp
	monster.z_index = -10
	monster.get_node("HPBar").visible = false
	monster.name_label.hide()

	if !Globals.is_sudden_death_mode:
		monster.animation_player.play("faint")
		get_tree().create_tween().tween_method(func(value): monster.root.material.set_shader_parameter("alpha", value), 1.0, 0.5, 1.0)
		monster.root.material.set_shader_parameter("outer_color", Color.TRANSPARENT)

func Update(delta:float):
	if monster.sent_flying:
		monster.rotation += 50.0 * delta
		monster.global_position += Vector2(monster.knockback, -1.0) * 2000.0 * delta


func animation_finished(anim_name: String) -> void:
	if anim_name == "faint":
		pass
