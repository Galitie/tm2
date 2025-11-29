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
	#MonsterPart.MONSTER_TYPE.BAT : {
		#MonsterPart.PART_TYPE.BODY : load("uid://c64sy158bma5j"),
		#MonsterPart.PART_TYPE.HEAD : load("uid://ksytcn7eqhrl"),
		#MonsterPart.PART_TYPE.HINDLEG : load("uid://cou8dbgo02cmc"),
		#MonsterPart.PART_TYPE.EAR : load("uid://bnxvdo03dka41"),
		#MonsterPart.PART_TYPE.EYE : load("uid://vmf1gswgnep4"),
		#MonsterPart.PART_TYPE.ARM : load("uid://dysgq7sk2vggr"),
	#},
}

var accessories: Array[MonsterPart] = [
	load("uid://ntacomuarces")
]

var body_animations: Dictionary[MonsterPart.MONSTER_TYPE, AnimationLibrary] = {
	MonsterPart.MONSTER_TYPE.BUNNY : load("uid://b227pe6g7ai2g"),
	MonsterPart.MONSTER_TYPE.BAT : load("uid://b227pe6g7ai2g"),
}

func _ready() -> void:
	back_shader.shader = load("uid://3uoclq0ivabh")
	
func GetRandomPart(type: MonsterPart.PART_TYPE) -> MonsterPart:
	var parts_of_type: Array[MonsterPart] = []
	for dict: Dictionary in parts.values():
		for part: MonsterPart in dict.values():
			if part.type == type:
				parts_of_type.append(part)
	return parts_of_type.pick_random()
	
# TODO: Only supports one player per monster
func GetMonsterPartsGroupName(monster: Monster) -> String:
	return "monster%f_parts" % monster.player.controller_port

func RandomizeColor(monster: Monster, set_colors: Array[Color] = []) -> Array[Color]:
	var colors : Array[Color] = []
	if set_colors != []:
		var counter = 0
		for part: MonsterPartNode in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
			if part.sprite.material != null:
				part.sprite.material.set_shader_parameter("part_color", set_colors[counter])
				counter += 1
				if part.parent_part != null && part.parent_part.sprite.material != null:
					part.sprite.material.set_shader_parameter("parent_part_color", part.parent_part.sprite.material.get_shader_parameter("part_color"))
		return set_colors
	for part: MonsterPartNode in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
		if part.sprite.material != null:
			var random_color = Color(randf(), randf(), randf())
			part.sprite.material.set_shader_parameter("part_color", random_color)
			colors.append(random_color)
			if part.parent_part != null && part.parent_part.sprite.material != null:
				part.sprite.material.set_shader_parameter("parent_part_color", part.parent_part.sprite.material.get_shader_parameter("part_color"))
	return colors
	
func ModulateMonster(monster: Monster, color: Color) -> void:
	for part: MonsterPartNode in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
		if part.sprite.material != null:
			part.sprite.material.set_shader_parameter("modulate", color)
	
func AddPartToMonster(monster: Monster, monster_part: MonsterPart) -> void:
	var part_to_replace: MonsterPartNode
	var front_part_to_replace: MonsterPartNode
	var back_part_to_replace: MonsterPartNode
	
	for part in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
			if part is MonsterPartNode:
				if monster_part.type == part.part_ref.type:
					if part.connection_ref.is_back:
						back_part_to_replace = part
					else:
						front_part_to_replace = part
						
	if front_part_to_replace != null && back_part_to_replace != null:
		var add_back_part: bool = randi() % 2
		part_to_replace = back_part_to_replace if add_back_part else front_part_to_replace
	else:
		part_to_replace = front_part_to_replace if back_part_to_replace == null else back_part_to_replace
			
	if part_to_replace != null:
		part_to_replace.sprite.offset = monster_part.offset
		part_to_replace.sprite.texture = monster_part.texture
	else:
		print("Part with type %s not found on monster: discarding part" % MonsterPart.PART_TYPE.keys()[monster_part.type])

func Generate(monster: Monster, parent: Node2D, new_part: MonsterPart, _connection: MonsterConnection = null, parent_part: MonsterPart = null) -> Node2D:
	if parent is CanvasGroup && new_part.type == MonsterPart.PART_TYPE.BODY:
		var anim_player: AnimationPlayer = parent.get_node("anim_player")
		if anim_player.has_animation_library(""):
			anim_player.remove_animation_library("")
		anim_player.add_animation_library("", body_animations[new_part.monster_type])
	
	var new_part_node: MonsterPartNode = MonsterPartNode.new()
	new_part_node.init(monster, new_part, parent, load("uid://b1h6un00sweia"), back_shader, _connection)
	
	for connection: MonsterConnection in new_part.connections:
		var part: MonsterPart
		
		if connection.is_accessory:
			part = MonsterPart.new()
			part.type = connection.part_type
			part.is_accessory = true
		else:
			part = GetRandomPart(connection.part_type)
			
		var part_node: Node2D = Generate(monster, new_part_node, part, connection, new_part)
	
	if parent_part != null && parent_part.type != MonsterPart.PART_TYPE.BODY:
		if parent is MonsterPartNode:
			parent.anim_offset.add_child(new_part_node)
	else:
		parent.add_child(new_part_node)
		
	new_part_node.add_to_group(GetMonsterPartsGroupName(monster))
	
	return parent
