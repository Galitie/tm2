extends CharacterBody2D
class_name Poop

@onready var monster : Monster
var is_a_summon : bool = false
var move_speed : int
@onready var sprite = $Sprite2D
@onready var collision = $BodyCollision
var collision_added : bool = false

func _ready():
	if not is_a_summon:
		collision.disabled = true
	velocity = Vector2.ZERO


func _physics_process(_delta):
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
		# trigger a death animation?

# Make sure poops don't spawn their colliders on each other and freak out
func is_not_colliding() -> bool:
	var bodies : Array[Node2D] = $Area2D.get_overlapping_bodies()
	if bodies.size():
		return false
	return true
