class_name MonsterPart
extends Resource

enum MONSTER_TYPE { ACCESSORY, BUNNY, BAT }
enum PART_TYPE { BODY, HEAD, EAR, TAIL, ARM, FORELEG, HINDLEG, EYE, HAT }

@export var monster_type: MONSTER_TYPE
@export var type : PART_TYPE
@export var texture : Texture2D
@export var offset : Vector2
@export var connections: Array[MonsterConnection]
@export var hurtbox_offset: Vector2
@export var hurtbox_size: Vector2
