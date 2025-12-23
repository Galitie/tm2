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
	add_to_group("DepthEntity")
	var size_diff: float = Globals.get_window_size_diff()
	var original_line_thickness: float = $CanvasGroup.material.get_shader_parameter("line_thickness")
	var new_thickness: float = size_diff * original_line_thickness
	$CanvasGroup.material.set_shader_parameter("line_thickness", new_thickness)
	$CanvasGroup.material.set_shader_parameter("outer_color", monster.player_color)
	lifespan = randf_range(1,1.5)
	$AudioStreamPlayer.stream = load("uid://c231yi1ewk36s")


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life += delta * 1.0
	if life > lifespan:
		$AudioStreamPlayer.play()
		$Area2D/CollisionShape2D.disabled = true
		$CanvasGroup/Sprite2D.texture = pop_texture
		await get_tree().create_timer(.05).timeout
		queue_free()


func area_entered(area):
	var entity = area.owner
	if area.name == "hurtbox" and entity != Summon and area != monster.hurtbox and entity != emitter:
		$CanvasGroup/Sprite2D.texture = pop_texture
		await get_tree().create_timer(.05).timeout
		queue_free()
