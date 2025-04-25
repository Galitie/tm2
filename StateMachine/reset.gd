extends State
class_name Reset

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	monster.fill_hp_bar()
	animation_player.play("get_up")
	monster.get_node("HPBar").visible = true
	monster.hp_bar.add_theme_stylebox_override("fill", health_fill_style)
	monster.z_index = 1
	turn_on_collisions()
	monster.velocity = Vector2()


func turn_on_collisions():
	hurtbox_collision.disabled = false
	body_collision.disabled = false
	melee_collision.disabled = true
