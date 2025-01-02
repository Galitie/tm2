extends PanelContainer
@export var info : Resource
signal card_pressed(node)

func _ready():
	%Title.text = info.title
	%Percent.text = "+" + str(info.stat1_value) + "%"
	%Percent2.text = "+" + str(info.stat2_value) + "%"
	

func _process(delta):
	pass


func _on_button_pressed():
	emit_signal("card_pressed", self)
	
