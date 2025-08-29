extends Node
class_name Player

@export var monster : Monster
var upgrade_panel : PlayerUpgradePanel
var controller_port: int = -1

var upgrade_points : int = 0
var randomize_upgrade_points : bool = false
var rerolls : int = 0
var bonus_rerolls: int = 0
var victory_points :int = 0

var poop_summons : bool = false
var more_poops :bool = false
var larger_poops:bool = false

var caltrops: bool = false
