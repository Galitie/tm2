extends Node
var game : Game
var is_sudden_death_mode : bool = false
var debug_mode : bool = false
var player_states : Array[Player.PlayerState] = [Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE]
