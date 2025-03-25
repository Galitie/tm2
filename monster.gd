extends CharacterBody2D

var max_hp : int
var current_hp : int
var mp : int
var damage : int = 1
var intelligence : int = 1
var move_speed : int = 40
var attack_speed : int = 1
var level : int = 1
var xp: int = 1

var main_color
var secondary_color

@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp

# attack ideas
# basic attack, special attack, block, super/big range/fullscreen
# attacks have stats: speed, mp amount, base damage, size, distance, pierce
# rerolls - not sure where this should live since it doesn't actually apply to the mon

func _ready():
	get_parent().get_node("UpgradePanel").connect("add_stats_to_mon", add_stats)
	current_hp = 1
	max_hp = 1
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


func add_stats(info):
	damage += info.stat1_value
	max_hp += info.stat2_value
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
