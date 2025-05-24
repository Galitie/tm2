extends MarginContainer
class_name PlayerUpgradePanel

var player : Player
var disabled : bool = false
@onready var stats = $VBoxContainer/Stats/Label
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self


func update_stats():
	stats.text = "HP: " + str(player.monster.max_hp) + " | " + "STR: " + str(player.monster.base_damage)


func disable_cards():
	for card in upgrade_cards:
		card.disable()


func setup_cards():
	for card in upgrade_cards:
		card.choose_card_resource()
		card.enable()
