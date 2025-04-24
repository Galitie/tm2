extends State
class_name Reset

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D


func Enter():
	monster.fill_hp_bar()
	animation_player.play("get_up")
	monster.get_node("HPBar").visible = true
	monster.z_index = 1
	turn_on_collisions()


func turn_on_collisions():
	hurtbox_collision.disabled = false
	body_collision.disabled = false
	melee_collision.disabled = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "get_up":
		animation_player.play("idle")
