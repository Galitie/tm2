extends Node

var current_state : State
var states : Dictionary = {}
@export var melee_attack : Area2D


func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(transition_state)
			child.ChooseNewState.connect(choose_new_state)
	states["idle"].Enter()
	current_state = states["idle"]


func _process(delta):
	if current_state:
		current_state.Update(delta)


func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)


#TODO: Choose state off of scenarios not randomness
# connected to "ChooseNewState" signal in state.gd
func choose_new_state(state):
	var state_choices = ["wander", "chase", "idle", "attack"]
	var new_state = state_choices.pick_random()
	transition_state(state, new_state)


# connected to "Transitioned" signal in state.gd
func transition_state(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	if current_state:
		current_state.Exit()
	new_state.Enter()
	current_state = new_state



func _on_mon_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("Attack") and area != melee_attack:
		transition_state(current_state, "hurt")
