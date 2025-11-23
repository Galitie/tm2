extends Node2D
class_name Slime

@onready var monster : Monster
@onready var sprite = $CanvasGroup/Sprite2D
@onready var lifetime = 3
@onready var lifetime_timer = $Lifetime

func _ready():
	modulate = monster.player_color
	$Lifetime.wait_time = lifetime
	$Lifetime.start()


func _physics_process(delta):
	if monster.current_hp <= 0:
		_on_lifetime_timeout()


func _on_lifetime_timeout():
	$Area/CollisionShape2D.disabled = true
	await get_tree().create_tween().tween_property(sprite, "modulate", Color(Color.DARK_GREEN,0), 1.0).finished
	queue_free()
