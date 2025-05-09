extends PanelContainer

var monster : Monster
signal card_pressed(resource, monster)
var resource_array: Array[Resource] = [load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq")]
var chosen_resource : Resource

func _ready():
	choose_card_resource()
	%Title.text = chosen_resource.card_name
	%Stat.text = chosen_resource.hp_name
	%Amount.text = str(chosen_resource.hp)
	%Description.text = chosen_resource.description
	if chosen_resource.description:
		%Description.visible = true
	if chosen_resource.hp:
		%Stat.visible = true
	if chosen_resource.hp_name:
		%Amount.visible = true


func _process(_delta):
	pass


func _on_button_pressed():
	emit_signal("card_pressed", chosen_resource, monster) #Caught by game scene

func choose_card_resource():
	chosen_resource = resource_array.pick_random()
