extends CharacterBody2D

@onready var monster : Monster
@onready var canvas = $canvas
@onready var anim_player = $anim_player
##State Machine
#Idle
#Nap
#Follow
#Throw
#Firebreath
##Flags?
##Owner
##OutlineColor


func _ready():
	# NOTE: Calculated only on spawn
	var size_diff: float = Globals.get_window_size_diff()
	var original_line_thickness: float = canvas.material.get_shader_parameter("line_thickness")
	var new_thickness: float = size_diff * original_line_thickness
	canvas.material.set_shader_parameter("line_thickness", new_thickness)
	canvas.material.set_shader_parameter("outer_color", monster.player_color)
	velocity = Vector2.ZERO
	anim_player.play("tyler_idle")
