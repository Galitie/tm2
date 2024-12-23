extends Node

var current_state : State
var states : Dictionary = {}


func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(transition_state)
	states["idle"].Enter()
	current_state = states["idle"]

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

# Right now, you have to set which state the mon goes to
# I want this to be weighted in the future
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


func _on_area_2d_area_entered(_area):
	if current_state == states.wander:
		transition_state(current_state, "idle")
