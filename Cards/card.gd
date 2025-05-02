extends PanelContainer

var test_resource = load("uid://c37d7vyo0m6jb")
var monster : Monster
signal card_pressed(resource, monster)


func _ready():
	$Button/MarginContainer/VBoxContainer/Title.text = test_resource.card_name
	$Button/MarginContainer/VBoxContainer/Items/Stat1/Stat.text = test_resource.hp_name
	$Button/MarginContainer/VBoxContainer/Items/Stat1/Amount.text = str(test_resource.hp)


func _process(_delta):
	pass


func _on_button_pressed():
	emit_signal("card_pressed", test_resource, monster)
