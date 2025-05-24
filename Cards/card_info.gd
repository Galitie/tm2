extends Resource


@export var card_name : String
@export_multiline var description: String
@export_enum("attack", "charge_attack", "special", "block", "passive", "immediate") var type : String
@export var state_id : String
@export var limited_to_one : bool

@export_group("Attributes")
enum Attributes {NONE, HP, MOVE_SPEED}
@export var attribute_1 : Attributes
@export var attribute_label_1 : String
@export var attribute_amount_1: int

@export var attribute_2 : Attributes
@export var attribute_label_2 : String
@export var attribute_amount_2: int

@export var attribute_3 : Attributes
@export var attribute_label_3 : String
@export var attribute_amount_3: int
