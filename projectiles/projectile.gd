extends Node2D
class_name Projectile
var speed = 300

var lifespan: float
var life: float = 0.0

var direction: Vector2
var monster
var emitter

@onready var pop_texture = load("uid://d1ke45wf2abuj")


func _ready() -> void:
	lifespan = randf_range(1,1.5)
	$AudioStreamPlayer.stream = load("uid://c231yi1ewk36s")


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life += delta * 1.0
	if life > lifespan:
		$AudioStreamPlayer.play()
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.texture = pop_texture
		await get_tree().create_timer(.05).timeout
		queue_free()


func area_entered(area):
	var entity = area.owner
	if area.name == "hurtbox" and entity != Summon and area != monster.hurtbox and entity != emitter:
		$Sprite2D.texture = pop_texture
		await get_tree().create_timer(.05).timeout
		queue_free()
