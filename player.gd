extends Node
class_name Player

var upgrade_points : int = 0
var randomize_upgrade_points : bool = false
var rerolls : int = 0
var bonus_rerolls: int = 0
var victory_points :int = 0
@export var monster : Monster
var controller_port: int = -1
var poop_summons : bool = false
var more_poops :bool = false
