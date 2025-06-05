extends MarginContainer
class_name PlayerUpgradePanel

signal reroll_pressed(upgrade_panel)


@onready var reroll_button : Button = $VBoxContainer/Reroll
@onready var stats = $VBoxContainer/Stats/Label
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]
@onready var upgrade_title = $VBoxContainer/UpgradeTitle/Label


var player : Player
var disabled : bool = false
var resource_array: Array[Resource] = [load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w"), load("uid://cv4dcuvdmk4d"), load("uid://cr0ughlj0g43p")]

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self


func update_stats():
	stats.text = "HP: " + str(player.monster.max_hp) + " | STR: " + str(player.monster.base_damage) + " | MOV SPD: " + str(player.monster.move_speed)


func disable_cards():
	for card in upgrade_cards:
		card.disable()


func setup_cards():
	var temp_resources = resource_array.duplicate(true)
	for card in upgrade_cards:
		var random_resource = temp_resources.pick_random()
		if random_resource.unique:
			temp_resources.erase(random_resource)
		card.choose_card_resource(random_resource)
		card.enable()


func setup_rerolls():
	if player.rerolls > 0:
		reroll_button.text = "🎲 Reroll Upgrades " + "[x" + str(player.rerolls) + "]"
		reroll_button.disabled = false
	else:
		reroll_button.text = "No 🎲 Available"
		reroll_button.disabled = true


func _on_reroll_pressed():
	emit_signal("reroll_pressed", self) #Caught by game scene
