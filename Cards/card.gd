extends PanelContainer
@export var info : Resource
signal test
# Called when the node enters the scene tree for the first time.
func _ready():
	%Title.text = info.title
	%Percent.text = "+" + str(info.stat1_value) + "%"
	%Percent2.text = "+" + str(info.stat2_value) + "%"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	pass
	# emit signal to mon
	# emit signal to upgrade container
