extends Node2D
class_name Projectile
var speed = 300

var lifespan: float = 3.0
var life: float = 0.0

var direction: Vector2
var monster
var emitter


func _ready() -> void:
	add_to_group("CleanUp")


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
	life += delta * 1.0
	if life > lifespan:
		queue_free()


func area_entered(area):
	print(self, " prjectile and ", monster, " monster I belong to")
	var entity = area.owner
	if entity != emitter and entity != Poop and area != monster.hurtbox:
		queue_free()
