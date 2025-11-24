extends CharacterBody2D
class_name Summon

@onready var monster : Monster
var is_a_summon : bool = false
var move_speed : int
var collision_added : bool = false
var poop_shoot_interval : float 
var poop_shoot_timer : float = 0.0
var base_damage: int = 1
var crit_multiplier: float = 1
var damage_dealt_mult: float = 1.0

@onready var sprite = $CanvasGroup/Sprite2D
@onready var collision = $BodyCollision
@onready var projectile = load("res://projectile.tscn")

func _ready():
	# NOTE: Calculated only on spawn
	var size_diff: float = Globals.get_window_size_diff()
	var original_line_thickness: float = $CanvasGroup.material.get_shader_parameter("line_thickness")
	var new_thickness: float = size_diff * original_line_thickness
	$CanvasGroup.material.set_shader_parameter("line_thickness", new_thickness)
	
	if is_a_summon:
		sprite.play("gun")
		$CanvasGroup.material.set_shader_parameter("outer_color", monster.player_color)
	
	if not is_a_summon:
		collision.disabled = true
		$Lifetime.wait_time = 5
		$Lifetime.start()
	velocity = Vector2.ZERO
	poop_shoot_interval = randf_range(5,15)
	$AnimationPlayer.play("idle")

func _physics_process(delta):
	if is_a_summon and is_not_colliding() and not collision_added:
		collision.disabled = false
		collision_added = true
	
	if is_a_summon:
		var direction = monster.global_position - global_position
		if direction.length() > 80 and monster.current_hp > 0:
			velocity = direction.normalized() * move_speed
		else:
			velocity = Vector2()
		
		if velocity.length() > 0 and velocity.x > 0:
			sprite.flip_h = false
		if velocity.length() > 0 and velocity.x < 0:
			sprite.flip_h = true
			
		move_and_slide()
		
		if monster.current_hp <= 0:
			is_a_summon = false
			_on_lifetime_timeout()
		
		poop_shoot_timer += delta
		if poop_shoot_timer >= poop_shoot_interval:
			poop_shoot_timer -= poop_shoot_interval
			shoot_projectile()
		# trigger a death animation?


# Make sure poops don't spawn their colliders on each other and freak out
func is_not_colliding() -> bool:
	var bodies : Array[Node2D] = $CheckToSpawnCollision.get_overlapping_bodies()
	if bodies.size():
		return false
	return true


func shoot_projectile():
	$AudioStreamPlayer.play()
	var projectile = projectile.instantiate()
	projectile.emitter = self
	projectile.monster = monster
	if !sprite.flip_h:
		projectile.direction = Vector2.RIGHT
	elif sprite.flip_h:
		projectile.direction = Vector2.LEFT
	else:
		projectile.direction = Vector2.RIGHT
	projectile.position = position + Vector2(17 * projectile.direction.x, -5)
	projectile.z_index = self.z_index
	Globals.game.add_child(projectile)
	$AnimationPlayer.play("shoot")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")

func _on_lifetime_timeout():
	await get_tree().create_tween().tween_property(sprite, "scale", Vector2(1.0, 0.0), 1.0).finished
	queue_free()
