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
	monster.root.modulate = Color.WHITE
	monster.global_position.x = clampf(monster.global_position.x, -100.0, viewport_size.x + 100.0)
	monster.global_position.y = clampf(monster.global_position.y, -100.0, viewport_size.y + 100.0)
	
	if monster.current_hp <= 0:
		monster.animation_player.play("get_up")
	else:
		got_up = true
		# Should be "run", but it's debatable if I should make run animations
		monster.animation_player.play("walk", -1.0, 2.0)
	monster.toggle_collisions(false)
	monster.velocity = Vector2()
	monster.apply_hp(monster.max_hp)
	monster.z_index = 1
	

func animation_finished(anim_name: String):
	if anim_name == "get_up":
		got_up = true
		if monster.target_point.x < monster.global_position.x:
			monster.get_node("root").scale = Vector2(-1, 1)
		else:
			monster.get_node("root").scale = Vector2(1, 1)
		# Should be "run", but it's debatable if I should make run animations
		monster.animation_player.play("walk", -1.0, 2.0)


func Physics_Update(_delta:float):
	if got_up:
		monster.global_position = monster.global_position.move_toward(monster.target_point, 800 * _delta)
		
	if monster.global_position.is_equal_approx(monster.target_point):
		monster.get_node("root").scale = Vector2(1, 1)
		monster.global_position = monster.target_point
		monster.animation_player.play("idle")
