extends State
class_name Upgrade

@export var monster: CharacterBody2D
@export var animation_player : AnimationPlayer
@export var hurtbox_collision: CollisionShape2D
@export var body_collision: CollisionShape2D
@export var melee_collision: CollisionShape2D

var got_up : bool = false
var health_fill_style := load("uid://b1cqxdsndopa") as StyleBox
var at_target: bool = false


func Enter():
	monster.get_node("HPBar").visible = true
	if monster.state_machine.current_state == KnockedOut:
		animation_player.play("get_up")
	else:
		got_up = true
		animation_player.play("run")
	turn_off_collisions()
	monster.velocity = Vector2()
	monster.get_node("MonsterContainer").modulate = Color(1,1,1,1)
	monster.apply_hp(monster.max_hp)
	monster.z_index = 1


func turn_off_collisions():
	hurtbox_collision.disabled = true
	body_collision.disabled = true
	melee_collision.disabled = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "get_up":
		got_up = true
		animation_player.play("run")


func Physics_Update(_delta:float):
	var direction = monster.target_point - monster.global_position
	if direction.length() >= 10 and got_up:
		monster.velocity = direction.normalized() * (monster.move_speed * 20)
		at_target = false
	else:
		monster.global_position = monster.target_point
		monster.velocity = Vector2()
		at_target = true
		animation_player.play("idle")
