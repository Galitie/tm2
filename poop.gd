extends CharacterBody2D
class_name Poop

@onready var monster : Monster
var is_a_summon : bool = false
var move_speed : int
@onready var sprite = $Sprite2D
@onready var collision = $BodyCollision


func _ready():
	velocity = Vector2.ZERO
	if not is_a_summon:
		collision.disabled = true


func _physics_process(_delta):
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
