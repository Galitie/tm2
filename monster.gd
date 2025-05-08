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
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var max_health_fill_style = load("uid://b1cqxdsndopa") as StyleBox

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


func set_hp_bar_max():
	current_hp = max_hp
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	hp_bar.add_theme_stylebox_override("fill", max_health_fill_style)
