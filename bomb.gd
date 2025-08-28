extends Node2D
class_name Drop

var base_damage: int = 2
var crit_multiplier: float = 1
var damage_dealt_mult: float = 1.0
var overlapping_areas : Array[Area2D]
var exploding = false

var speed: float = 200.0
var spin_speed: float = 5.0
var target: Vector2
var direction: Vector2
var spin_sign: float

@onready var monster : Monster


func _ready():
	if monster.facing == "right":
		direction = Vector2(-1, 0)
		target = position - Vector2(100,0)
	else:
		direction = Vector2(1, 0)
		target = position + Vector2(100,0)
	$ExplosionCountdown.start()


func _physics_process(delta: float) -> void:
	var goal = target - position
	if goal.length() > 1.0:
		position += direction * speed * delta
		if direction.x >= 0.0:
			spin_sign = 1.0
		else:
			spin_sign = -1.0
		rotation += spin_speed * spin_sign * delta
	
	if exploding:
		overlapping_areas = $Area2D.get_overlapping_areas()
		for area in overlapping_areas:
			if area.name == "hurtbox":
				queue_free()


func _on_explosion_countdown_timeout():
	print("bomb exploded")
	$Area2D/ExplosionHitBox.disabled = false
	$ExplosionTime.start()
	$Sprite2D.play("explode")
	exploding = true


func _on_explosion_time_timeout():
	exploding = false
	queue_free()
