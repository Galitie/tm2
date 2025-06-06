extends State
class_name Fight

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D

var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox

func Enter():
	monster.velocity = Vector2()
	turn_on_collisions()
	monster.get_node("HPBar").visible = true
	monster.z_index = 1
	Transitioned.emit("wander")


func turn_on_collisions():
	hurtbox_collision.disabled = false
	body_collision.disabled = false
	melee_collision.disabled = true
