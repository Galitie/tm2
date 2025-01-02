extends CharacterBody2D

var hp : int
var mp : int
var damage : int = 1
var intelligence : int = 1
var move_speed : int = 40
var attack_speed : int = 1
var level : int = 1
var xp: int = 1

var main_color
var secondary_color


# attack ideas
# basic attack, special attack, block, super
# attacks have stats: speed, mp amount, base damage, size, distance, pierce
# rerolls - not sure where this should live since it doesn't actually apply to the mon

func _ready():
	get_parent().get_node("UpgradePanel").connect("add_stats_to_mon", add_stats)

	
func _physics_process(_delta):
	move_and_slide()
	if velocity.length() > 0 and velocity.x > 0:
		$MonsterContainer.scale = Vector2(1,1)
	if velocity.length() > 0 and velocity.x < 0:
		$MonsterContainer.scale = Vector2(-1,1)


func add_stats(info):
	damage += info.stat1_value
	print(damage)
	hp += info.stat2_value
	print(hp)
