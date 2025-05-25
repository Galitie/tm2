extends Node

var current_state : State
var states : Dictionary = {}
var state_choices = ["wander", "chase", "idle", "punch", "block", "charge"]
@export var monster = CharacterBody2D


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
func choose_new_state():
	var new_state = state_choices.pick_random()
	transition_state(new_state)

# Scenarios for state
# Doesn't see a creature
# -> Wander or idle

# See a creature 
# -> if far > chase or attack
# -> if close > run away, block or attack
# -> if creature is charging up > run away or block

# connected to "Transitioned" signal in state.gd
func transition_state(new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	current_state.Exit()
	current_state = new_state
	current_state.Enter()
