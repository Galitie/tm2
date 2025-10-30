extends Node2D
class_name SlimeTrail

@onready var monster : Monster
@onready var sprite = $CanvasGroup/Sprite2D


func _ready():
	modulate = monster.player_color
	$Lifetime.start()
	
	

func _physics_process(delta):
	if monster.current_hp <= 0:
		_on_lifetime_timeout()


func _on_lifetime_timeout():
	$Area/CollisionShape2D.disabled = true
	await get_tree().create_tween().tween_property(sprite, "modulate", Color(Color.DARK_GREEN,0), 1.0).finished
	queue_free()
