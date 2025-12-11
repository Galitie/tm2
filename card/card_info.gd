extends Resource
class_name CardResourceScript

@export var card_name : String
@export_multiline var description: String
@export_enum("basic_attack", "charge_attack", "special", "block", "passive", "immediate", "poop", "chase") var Type : String
@export var state_id : String
@export var unique : bool
@export var is_special : bool
@export var locked : bool
@export var remove_specific_states : Array[int]
@export var parts_and_acc: Array[MonsterPart]
@export_group("Attributes")
enum Attributes {NONE, HP, MOVE_SPEED, BASE_DAMAGE, REROLL, UPGRADE_POINTS, CRIT_PERCENT, CRIT_MULTIPLIER}
@export var attribute_1 : Attributes
@export var attribute_label_1 : String
@export var attribute_amount_1: int

@export var attribute_2 : Attributes
@export var attribute_label_2 : String
@export var attribute_amount_2: int

@export var attribute_3 : Attributes
@export var attribute_label_3 : String
@export var attribute_amount_3: float
@export var unlocked_cards: Array[CardResourceScript]
@export var remove_cards: Array[CardResourceScript]
