extends State
class_name KnockedOut

var monster: CharacterBody2D

#Temp stuff for explosion
var temp_timer = Timer.new()
var temp_area = Area2D.new()
# ^^^^^^^^^^^^^^^^^^^^^^^

func Enter():
	monster.velocity = Vector2.ZERO
	monster.current_hp = 0
	monster.current_hp_label.text = "0"
	monster.hp_bar.value = monster.current_hp
	monster.z_index = -10
	monster.get_node("HPBar").visible = false
	Globals.game.count_death(monster)
	monster.name_label.hide()

	
	if monster.player.death_explode:
		# Temp stuff for explosion TODO: Raam add animation
		temp_timer = Timer.new()
		temp_timer.timeout.connect(_on_temp_timer_timeout)
		temp_area = Area2D.new()
		var temp_collision = CollisionShape2D.new()
		var temp_shape_resource = CircleShape2D.new()
		var temp_sprite = Sprite2D.new()
		temp_timer.wait_time = .25
		temp_sprite.texture = load("uid://cgrc4jxdyeooy")
		temp_sprite.scale = Vector2(3,3)
		temp_shape_resource.radius = monster.hurtbox_collision.shape.size.x * 1.50
		temp_collision.shape = temp_shape_resource
		temp_area.add_to_group("TEMP_EXPLOSION")
		temp_area.add_child(temp_collision)
		temp_area.add_child(temp_timer)
		temp_area.add_child(temp_sprite)
		monster.add_child(temp_area)
		temp_timer.start()
		# temp to be removed ^^^^^^^^^^
		monster.animation_player.play("faint")
	monster.toggle_collisions(false)
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

#Temp to be removed
func _on_temp_timer_timeout():
	temp_area.queue_free()
# ^^^^^^^^^^^^^^^^
