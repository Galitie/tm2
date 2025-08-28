extends CharacterBody2D
class_name Summon

@onready var monster : Monster
var is_a_summon : bool = false
var move_speed : int
var collision_added : bool = false
var poop_shoot_interval : float = 5.0
var poop_shoot_timer : float = 0.0
var base_damage: int = 1
var crit_multiplier: float = 1
var damage_dealt_mult: float = 1.0

@onready var sprite = $Sprite2D
@onready var collision = $BodyCollision
@onready var projectile = load("res://projectile.tscn")

func _ready():
	if not is_a_summon:
		collision.disabled = true
	velocity = Vector2.ZERO


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
			sprite.scale = Vector2(1,1)
		if velocity.length() > 0 and velocity.x < 0:
			sprite.scale = Vector2(-1,1)

		move_and_slide()
		
		if monster.current_hp <= 0:
			is_a_summon = false
		
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
	var projectile = projectile.instantiate()
	projectile.emitter = self
	projectile.monster = monster
	if sprite.scale == Vector2(1,1):
		projectile.direction = Vector2.RIGHT
	elif sprite.scale == Vector2(-1,1):
		projectile.direction = Vector2.LEFT
	else:
		projectile.direction = Vector2.RIGHT
	projectile.position = position + Vector2(0, -2) + (projectile.direction * 6)
	Globals.game.add_child(projectile)
