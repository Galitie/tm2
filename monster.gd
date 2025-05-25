extends CharacterBody2D
class_name Monster

var max_hp : int = 3
var current_hp : int = max_hp
var base_damage : int = 1
var intelligence : int = 1
var move_speed : int = 35
var attack_speed : int = 1

var mon_name : String
var main_color
var secondary_color

@export_range(-1, 1) var hue_shift : float

@onready var state_machine = $StateMachine
@export var melee_attack : Area2D
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var max_health_fill_style = load("uid://b1cqxdsndopa") as StyleBox
@onready var low_health_fill_style := load("uid://dlwdv81v5y0h7") as StyleBox
@onready var animation_player = $AnimationPlayer
@onready var animation_player_damage = $AnimationPlayer_Damage

@onready var basic_attack : State = $StateMachine/Punch
@onready var charge_attack : State
@onready var block : State
@onready var super_attack : State
var passive_1
var passive_2
var passive_3


# attacks have stats: speed, mp amount, base damage, size, distance, pierce

# attacks can be short range, long range or 
# specials with a charge up
# give them preferences? melee, range, etc.

func _ready():
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	$MonsterContainer/Parts.material.set_shader_parameter("hue_shift", hue_shift)
	


func _physics_process(_delta):
	move_and_slide()
	if velocity.length() > 0 and velocity.x > 0:
		$MonsterContainer.scale = Vector2(1,1)
	if velocity.length() > 0 and velocity.x < 0:
		$MonsterContainer.scale = Vector2(-1,1)


func apply_hp(amount):
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp
	if current_hp <= 0:
		current_hp = 0
	max_hp_label.text = str(max_hp)
	current_hp_label.text = str(current_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	if current_hp >= (max_hp / 3.0):
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
				take_damage(attacking_mon)
				attacking_mon.apply_hp(1)


func take_damage(enemy):
	if Globals.is_sudden_death_mode:
		apply_hp(-max_hp)
	else:
		apply_hp(-enemy.base_damage)
	$Damage.text = str(enemy.base_damage)
	animation_player_damage.play("damage")
	check_low_hp()


func check_low_hp():
	if current_hp <= (max_hp / 3.0):
		hp_bar.add_theme_stylebox_override("fill", low_health_fill_style)
