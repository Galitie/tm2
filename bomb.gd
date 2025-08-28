extends Node2D
class_name Drop

var base_damage: int = 2
var crit_multiplier: float = 1
var damage_dealt_mult: float = 1.0
var overlapping_areas : Array[Area2D]
var exploding = false

@onready var monster : Monster


func _ready():
	$ExplosionCountdown.start()


func _physics_process(delta: float) -> void:
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
