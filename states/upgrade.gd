extends State
class_name Upgrade

var monster: CharacterBody2D

var got_up : bool
var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox
var at_target: bool = false


func Enter():
	got_up = false
	monster.get_node("HPBar").visible = false
	monster.sent_flying = false
	monster.rotation = 0.0
	var viewport_size: Vector2i = get_viewport().size
	monster.mod_color = Color.TRANSPARENT
	monster.mod_monster(monster.mod_color)
	monster.global_position.x = clampf(monster.global_position.x, -100.0, viewport_size.x + 100.0)
	monster.global_position.y = clampf(monster.global_position.y, -100.0, viewport_size.y + 100.0)
	monster.toggle_effect_graphic(false)
	if monster.thorns:
		monster.aura.visible = true
	
	if monster.current_hp <= 0:
		monster.animation_player.play("get_up")
		get_tree().create_tween().tween_method(func(value): monster.root.material.set_shader_parameter("alpha", value), 0.5, 1.0, 0.25)
		get_tree().create_tween().tween_method(func(value): monster.root.material.set_shader_parameter("outer_color", value), Color(0.0, 0.0, 0.0, 0.0), monster.player_color, 0.25)
	else:
		got_up = true
		monster.animation_player.play("walk", -1.0, 2.0)
	monster.toggle_collisions(false)
	monster.velocity = Vector2()
	monster.modify_hp(null, monster.max_hp)
	monster.z_index = 1
	

func animation_finished(anim_name: String):
	if anim_name == "get_up":
		got_up = true
		var root: Node2D = monster.get_node("root")
		var s: Vector2 = root.scale
		if monster.target_point.x < monster.global_position.x:
			s.x = -abs(s.x)
		else:
			s.x = abs(s.x)  
		root.scale = s
		monster.animation_player.play("walk", -1.0, 2.0)
	
	if anim_name == "upgrade_react":
		monster.animation_player.play("idle")


func Physics_Update(_delta:float):
	if got_up:
		monster.global_position = monster.global_position.move_toward(monster.target_point, 800 * _delta)
		
	if monster.global_position.is_equal_approx(monster.target_point):
		var root: Node2D = monster.get_node("root")
		var s: Vector2 = root.scale
		s.x = abs(s.x)
		root.scale = s
		monster.global_position = monster.target_point
		monster.animation_player.play("idle")
		Transitioned.emit("upgradeidle")
