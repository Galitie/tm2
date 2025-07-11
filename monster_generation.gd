extends Node

@onready var back_shader: ShaderMaterial = ShaderMaterial.new()

var parts: Dictionary[MonsterPart.MONSTER_TYPE, Dictionary] = {
	MonsterPart.MONSTER_TYPE.BUNNY : {
		MonsterPart.PART_TYPE.BODY : load("uid://k5mg1uekaadx"),
		MonsterPart.PART_TYPE.HEAD : load("uid://c1qes5l3mnpru"),
		MonsterPart.PART_TYPE.FORELEG : load("uid://cg0nw8y85tiab"),
		MonsterPart.PART_TYPE.HINDLEG : load("uid://dknimsr4tbg3y"),
		MonsterPart.PART_TYPE.TAIL : load("uid://dq7v87yxuvy1k"),
		MonsterPart.PART_TYPE.EAR : load("uid://c7kbcfhprqc84"),
		MonsterPart.PART_TYPE.EYE : load("uid://bup2objw1mx86"),
	},
	MonsterPart.MONSTER_TYPE.BAT : {
		MonsterPart.PART_TYPE.BODY : load("uid://c64sy158bma5j"),
		MonsterPart.PART_TYPE.HEAD : load("uid://ksytcn7eqhrl"),
		MonsterPart.PART_TYPE.HINDLEG : load("uid://cou8dbgo02cmc"),
		MonsterPart.PART_TYPE.EAR : load("uid://bnxvdo03dka41"),
		MonsterPart.PART_TYPE.EYE : load("uid://vmf1gswgnep4"),
		MonsterPart.PART_TYPE.ARM : load("uid://dysgq7sk2vggr"),
	},
}

var body_animations: Dictionary[MonsterPart.MONSTER_TYPE, AnimationLibrary] = {
	MonsterPart.MONSTER_TYPE.BUNNY : load("uid://q44b3cgf6gx6"),
	MonsterPart.MONSTER_TYPE.BAT : load("uid://q44b3cgf6gx6"),
}

func _ready() -> void:
	back_shader.shader = load("uid://3uoclq0ivabh")

func GeneratePart(part: MonsterPart, connection: MonsterConnection = null, parent: MonsterPart = null) -> Node2D:
	var position_node: Node2D = Node2D.new()
	var part_sprite: Sprite2D = Sprite2D.new()
		
	match part.type:
		MonsterPart.PART_TYPE.BODY:
			position_node.name = "body"
		MonsterPart.PART_TYPE.TAIL:
			position_node.name = "tail"
		MonsterPart.PART_TYPE.FORELEG:
			position_node.name = "foreleg"
		MonsterPart.PART_TYPE.HINDLEG:
			position_node.name = "hindleg"
		MonsterPart.PART_TYPE.HEAD:
			position_node.name = "head"
		MonsterPart.PART_TYPE.EAR:
			position_node.name = "ear"
		MonsterPart.PART_TYPE.EYE:
			position_node.name = "eye"
		MonsterPart.PART_TYPE.ARM:
			position_node.name = "arm"
	
	if connection != null:
		if connection.is_back:
			position_node.name += "_back"
			position_node.z_index = -1
			part_sprite.material = back_shader
			
		position_node.position = connection.position
	
	part_sprite.texture = part.texture
	part_sprite.name = "sprite"
	
	part_sprite.offset = part.offset
	if parent != null && part.monster_type != parent.monster_type:
		part_sprite.offset = (part.offset + parts[parent.monster_type][part.type].offset) * 0.5
	
	if part.hurtbox_size:
		var hurtbox: Area2D = Area2D.new()
		hurtbox.add_to_group("HurtBox")
		hurtbox.name = "hurtbox"
		
		var shape: CollisionShape2D = CollisionShape2D.new()
		shape.name = "shape"
		
		var rect: RectangleShape2D = RectangleShape2D.new()
		
		rect.size = part.hurtbox_size
		shape.shape = rect
		shape.position = part.hurtbox_offset
		
		hurtbox.add_child(shape)
		position_node.add_child(hurtbox)
	
	var anim_offset: Node2D = Node2D.new()
	anim_offset.name = position_node.name + "_anim_offset"
	anim_offset.add_child(part_sprite)
	position_node.add_child(anim_offset)
	
	return position_node
	
func GetRandomPart(type: MonsterPart.PART_TYPE) -> MonsterPart:
	var parts_of_type: Array[MonsterPart] = []
	for dict: Dictionary in parts.values():
		for part: MonsterPart in dict.values():
			if part.type == type:
				parts_of_type.append(part)
	return parts_of_type.pick_random()

func Generate(parent: Node2D, new_part: MonsterPart, _connection: MonsterConnection = null, parent_part: MonsterPart = null) -> Node2D:
	if parent is CanvasGroup && new_part.type == MonsterPart.PART_TYPE.BODY:
		var anim_player: AnimationPlayer = parent.get_node("anim_player")
		if anim_player.has_animation_library(""):
			anim_player.remove_animation_library("")
		anim_player.add_animation_library("", body_animations[new_part.monster_type])
	
	var new_part_node: Node2D = GeneratePart(new_part, _connection, parent_part)
	
	for connection: MonsterConnection in new_part.connections:
		var part: MonsterPart = GetRandomPart(connection.part_type)
		var part_node: Node2D = Generate(new_part_node, part, connection, new_part)
		
	parent.add_child(new_part_node)
	
	return parent
