extends Node2D
class_name Drop

var base_damage: int = 2
var crit_multiplier: float = 1
var damage_dealt_mult: float = 1.0
var overlapping_areas : Array[Area2D]
var exploding = false

var speed: float = 200.0
var spin_speed: float = 40.0
var target: Vector2
var direction: Vector2
var spin_sign: float
var distance: float

@onready var monster : Monster
@onready var sprite: AnimatedSprite2D = $CanvasGroup/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("idle")
	$CanvasGroup.material.set_shader_parameter("outer_color", monster.player_color)
	
	if monster.facing == "right":
		direction = Vector2(-1, 0)
		target = position - Vector2(randi_range(50,125),0)
		spin_sign = -1
	else:
		direction = Vector2(1, 0)
		target = position + Vector2(randi_range(50,125),0)
		spin_sign = 1
	distance = position.distance_to(target)
	if monster.player.faster_bombs:
		$ExplosionCountdown.wait_time = randf_range(1,3)
		$ExplosionCountdown.start()
		await get_tree().create_timer(1.5).timeout
	else:
		$ExplosionCountdown.wait_time = randf_range(3,5)
		$ExplosionCountdown.start()
		await get_tree().create_timer(2.5).timeout
	animation_player.play("freakout")


func _physics_process(delta: float) -> void:
	var decay = position.distance_to(target) / distance
	position.x = move_toward(position.x, target.x, speed * delta)
	rotation += spin_speed * spin_sign * delta * decay


func _on_explosion_countdown_timeout():
	$Area2D/ExplosionHitBox.disabled = false
	$ExplosionTime.start()
	animation_player.play("explode")
	exploding = true
	$AudioStreamPlayer.play()


func _on_explosion_time_timeout():
	$Area2D/ExplosionHitBox.disabled = true
	remove_from_group("DepthEntity")
	z_index = 50
	exploding = false
	visible = false
	await $AudioStreamPlayer.finished
	queue_free()
