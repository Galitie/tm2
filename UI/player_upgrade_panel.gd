extends MarginContainer
class_name PlayerUpgradePanel

var player : Player
var disabled : bool = false
@onready var stats = $VBoxContainer/Stats/Label
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]

var resource_array: Array[Resource] = [load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w"), load("uid://cv4dcuvdmk4d")]

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self
	

func update_stats():
	stats.text = "HP: " + str(player.monster.max_hp) + " | STR: " + str(player.monster.base_damage) + " | MOV_SPD: " + str(player.monster.move_speed)


func disable_cards():
	for card in upgrade_cards:
		card.disable()


func setup_cards():
	var temp_resources = resource_array.duplicate(true)

	for card in upgrade_cards:
		var random_resource = temp_resources.pick_random()
		if random_resource.limited_to_one:
			temp_resources.erase(random_resource)
		card.choose_card_resource(random_resource)
		card.enable()
	if player.rerolls != 0:
		$VBoxContainer/Reroll.text = "Reroll Upgrades " + "[x" + str(player.rerolls)+ "]"
	else:
		$VBoxContainer/Reroll.text = "Out of Rerolls"

func _on_reroll_pressed():
	if player.rerolls > 0:
		player.rerolls -= 1
		setup_cards()
