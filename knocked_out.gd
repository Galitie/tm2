extends State
class_name KnockedOut

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D

func Enter():
	print("I'm knocked out")
	animation_player.play("fainting")

func Physics_Update(_delta:float):
	monster.velocity = Vector2.ZERO
	hurtbox_collision.disabled = true
	body_collision.disabled = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fainting":
		animation_player.play("knocked_out")
