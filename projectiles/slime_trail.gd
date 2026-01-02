extends Node2D
class_name Slime

@onready var monster : Monster
@onready var sprite = $CanvasGroup/Sprite2D
@onready var lifetime = 4
@onready var lifetime_timer = $Lifetime


func _ready():
	modulate = monster.player_color
	$Lifetime.wait_time = lifetime
	$Lifetime.start()
	
	if monster.root.scale.x < 0.0:
		scale.x = -scale.x
	$AudioStreamPlayer.stream = load(["uid://gpbmgj3eyv5y", "uid://jt4sbg1e01h6"].pick_random())
	$AudioStreamPlayer.pitch_scale = randf_range(.5,2)
	$AudioStreamPlayer.play()


func _physics_process(_delta):
	if monster.current_hp <= 0:
		_on_lifetime_timeout()


func _on_lifetime_timeout():
	if self != null:
		$Area/CollisionShape2D.disabled = true
		await get_tree().create_tween().tween_property(sprite, "modulate", Color(Color.DARK_GREEN,0), 1.0).finished
		queue_free()


func remove_slime():
	call_deferred("_on_lifetime_timeout")
