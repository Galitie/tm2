extends State
class_name Upgrade

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	turn_off_collisions()
	monster.velocity = Vector2()
	monster.get_node("MonsterContainer").modulate = Color(1,1,1,1)
	animation_player.play("get_up")
	monster.set_hp_bar_max()
	monster.get_node("HPBar").visible = false
	monster.z_index = 1


func turn_off_collisions():
	hurtbox_collision.disabled = true
	body_collision.disabled = true
	melee_collision.disabled = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "get_up":
		animation_player.play("idle")
