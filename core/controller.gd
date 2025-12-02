extends Node
const DEADZONE: float = 0.2

var status_timer: Timer = Timer.new()

class Gamepad:
	var device_id: int = -1
	var connected: bool = false
	
	var left_stick: Vector2 = Vector2.ZERO
	var right_stick: Vector2 = Vector2.ZERO
	
	var right_trigger: float
	var left_trigger: float
	
	var button_states: PackedByteArray = [
		0, # JOY_BUTTON_A
		0, # JOY_BUTTON_B
		0, # JOY_BUTTON_X
		0, # JOY_BUTTON_Y
		0, # JOY_BUTTON_BACK
		0, # JOY_BUTTON_GUIDE
		0, # JOY_BUTTON_START
		0, # JOY_BUTTON_LEFT_STICK
		0, # JOY_BUTTON_RIGHT_STICK
		0, # JOY_BUTTON_LEFT_SHOULDER
		0, # JOY_BUTTON_RIGHT_SHOULDER
		0, # JOY_BUTTON_DPAD_UP
		0, # JOY_BUTTON_DPAD_DOWN
		0, # JOY_BUTTON_DPAD_LEFT
		0, # JOY_BUTTON_DPAD_RIGHT
	]
	
	var prev_button_states: PackedByteArray = button_states.duplicate()

@onready var gamepads: Array = [
	Gamepad.new(),
	Gamepad.new(),
	Gamepad.new(),
	Gamepad.new()
]

func _ready() -> void:
	set_joypads()
	status_timer.name = "Controller Status Timer"
	status_timer.autostart = true
	status_timer.one_shot = false
	status_timer.timeout.connect(set_joypads)
	add_child(status_timer)

# important that this syncs up with the game
func _physics_process(_delta: float) -> void:
	for gamepad in gamepads:
		if gamepad.connected:
			UpdateState(gamepad.device_id)
			
func set_joypads() -> void:
	var device_ids: Array = Input.get_connected_joypads()
	for id in device_ids:
		if id < gamepads.size():
			gamepads[id].device_id = id
			gamepads[id].connected = true

func UpdateState(device_id: int) -> void:
	var gamepad: Gamepad = gamepads[device_id]
	gamepad.prev_button_states = gamepad.button_states.duplicate()
	gamepad.left_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X), Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y))
	if gamepad.left_stick.x > -DEADZONE && gamepad.left_stick.x < DEADZONE:
		gamepad.left_stick.x = 0
	if gamepad.left_stick.y > -DEADZONE && gamepad.left_stick.y < DEADZONE:
		gamepad.left_stick.y = 0
	gamepad.right_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y))
	if gamepad.right_stick.x > -DEADZONE && gamepad.right_stick.x < DEADZONE:
		gamepad.right_stick.x = 0
	if gamepad.right_stick.y > -DEADZONE && gamepad.right_stick.y < DEADZONE:
		gamepad.right_stick.y = 0
	
	gamepad.right_trigger = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT)
	gamepad.left_trigger = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT)
	for i in range(gamepad.button_states.size()):
		gamepad.button_states[i] = int(Input.is_joy_button_pressed(gamepad.device_id, i))


func IsButtonJustPressed(device_id: int, button: int) -> int:
	if gamepads[device_id].button_states[button] == 1:
		if gamepads[device_id].button_states[button] != gamepads[device_id].prev_button_states[button]:
			return 1
	return 0


func IsButtonJustReleased(device_id: int, button: int) -> int:
	if gamepads[device_id].button_states[button] == 0:
		if gamepads[device_id].button_states[button] != gamepads[device_id].prev_button_states[button]:
			return 1
	return 0


func IsButtonPressed(device_id: int, button: int) -> int:
	if gamepads[device_id].button_states[button] == 1:
		return 1
	return 0

# Helper function to shorten accessing the vector
func GetLeftStick(device_id: int) -> Vector2:
	return gamepads[device_id].left_stick
	
func Vibrate(device_id: int, weak_level: int, strong_level : int, duration : float = 0):
	Input.start_joy_vibration(device_id, weak_level, strong_level, duration)
