extends CharacterBody2D
class_name Monster

var max_hp : int = 10
var current_hp : int = max_hp
var base_damage : int = 1
var intelligence : int = 1
var move_speed : int = 40
var attack_speed : int = 1

var mon_name : String
var main_color
var secondary_color

@onready var state_machine = $StateMachine
@export var melee_attack : Area2D
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var max_health_fill_style = load("uid://b1cqxdsndopa") as StyleBox
@onready var low_health_fill_style := load("uid://dlwdv81v5y0h7") as StyleBox

# attack ideas
# basic attack, special attack, block, super/big range/fullscreen
# attacks have stats: speed, mp amount, base damage, size, distance, pierce
# rerolls - not sure where this should live since it doesn't actually apply to the mon

# attacks can be short range, long range or specials with a charge up
# ability slots? for short range, long range, special and passive?
# mash A to charge special?
# give them preferences? melee, range, etc.

func _ready():
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp


func _physics_process(_delta):
	move_and_slide()
	if velocity.length() > 0 and velocity.x > 0:
		$MonsterContainer.scale = Vector2(1,1)
	if velocity.length() > 0 and velocity.x < 0:
		$MonsterContainer.scale = Vector2(-1,1)


func apply_hp(amount):
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	max_hp_label.text = str(max_hp)
	current_hp_label.text = str(current_hp)
	hp_bar.value = current_hp
	if current_hp >= (max_hp / 3):
		hp_bar.add_theme_stylebox_override("fill", max_health_fill_style)


func _on_hurtbox_area_entered(area):
	if area.is_in_group("Attack") and area != melee_attack:
		state_machine.transition_state("hurt")
		var attacking_mon : Node = area.get_owner()
		var attack : String = attacking_mon.state_machine.current_state.name
		match attack.to_lower():
			"punch":
				take_damage(attacking_mon)
			"bitelifesteal":
				print("bitelifesteal")
				take_damage(attacking_mon)
				attacking_mon.apply_hp(1)


func take_damage(enemy):
	if Globals.is_sudden_death_mode:
		apply_hp(-max_hp)
	else:
		var attack_power = enemy.base_damage
		apply_hp(-enemy.base_damage)
	check_low_hp()


func check_low_hp():
	if current_hp <= (max_hp / 3):
		hp_bar.add_theme_stylebox_override("fill", low_health_fill_style)
