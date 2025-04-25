extends State
class_name KnockedOut

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D 


func Enter():
	clean_up_collisions()
	monster.velocity = Vector2.ZERO
	animation_player.play("fainting")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fainting":
		monster.z_index = -10
		animation_player.play("knocked_out")
		monster.velocity = Vector2.ZERO
		monster.get_node("HPBar").visible = false
		Globals.game.count_death()


func clean_up_collisions():
	hurtbox_collision.disabled = true
	body_collision.disabled = true
	melee_collision.disabled = true
