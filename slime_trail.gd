extends Node2D
class_name SlimeTrail

@onready var monster : Monster
@onready var sprite = $CanvasGroup/Sprite2D


func _ready():
	#$CanvasGroup.material.set_shader_parameter("outer_color", monster.player_color)	
	$Lifetime.start()
	modulate = monster.player_color
	

func _physics_process(delta):
	if monster.current_hp <= 0:
		_on_lifetime_timeout()


func _on_lifetime_timeout():
	await get_tree().create_tween().tween_property(sprite, "modulate", Color(Color.DARK_GREEN,0), 1.0).finished
	queue_free()
