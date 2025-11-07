extends Node
class_name Player

@export var monster : Monster
var upgrade_panel : PlayerUpgradePanel
var customize_panel : PlayerCustomizePanel
var controller_port: int = -1

var special_name: String = ""
var special_used : bool = false

var upgrade_points : int = 0
var randomize_upgrade_points : bool = false
var rerolls : int = 0
var bonus_rerolls: int = 0
var victory_points: int = 0

var poop_summons : bool = false
var more_poops : bool = false
var larger_poops : bool = false
var death_explode : bool = false
var matrix : bool = false
var poop_on_hit: bool = false
var slime_trail : bool = false
var caltrops: bool = false
var block_longer: bool = false

var current_small_cards : int = 0
var current_big_cards : int = 0
