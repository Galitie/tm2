extends State
class_name KnockedOut

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D

func Enter():
	hurtbox_collision.disabled = true
	body_collision.disabled = true
	monster.velocity = Vector2.ZERO
	animation_player.play("fainting")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fainting":
		monster.z_index = -10
		animation_player.play("knocked_out")

	
