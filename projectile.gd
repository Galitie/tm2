extends Node2D
class_name Projectile
var speed = 300

var lifespan: float
var life: float = 0.0

var direction: Vector2
var monster
var emitter


func _ready() -> void:
	lifespan = randf_range(1,1.5)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life += delta * 1.0
	if life > lifespan:
		queue_free()


func area_entered(area):
	var entity = area.owner
	if area.name == "hurtbox" and entity != Summon and area != monster.hurtbox and entity != emitter:
		queue_free()
