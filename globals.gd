extends Node
var game : Game
var is_sudden_death_mode : bool = false
var debug_mode : bool = false
var player_states : Array[Player.PlayerState] = [Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE]

func get_window_size_diff() -> float:
	var window_size: Vector2 = DisplayServer.window_get_size()
	var size_diff: float = (window_size.x + window_size.y) / (1152 + 648)
	return size_diff
