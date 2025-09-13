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

func GeneratePart(monster: Monster, part: MonsterPart, connection: MonsterConnection = null, parent_part: MonsterPart = null) -> Node2D:
	var position_node: Node2D = Node2D.new()
	var part_sprite: Sprite2D = Sprite2D.new()
	
	if part.type != MonsterPart.PART_TYPE.EYE:
		match part.type:
			MonsterPart.PART_TYPE.FORELEG:
				part_sprite.self_modulate = monster.base_color
			MonsterPart.PART_TYPE.HINDLEG:
				part_sprite.self_modulate = monster.base_color
			MonsterPart.PART_TYPE.BODY:
				part_sprite.self_modulate = monster.base_color
			MonsterPart.PART_TYPE.HAT:
				pass
			_:
				part_sprite.self_modulate = monster.secondary_color
				
	position_node.name = MonsterPart.PART_TYPE.keys()[part.type];
	
	if connection != null:
		if connection.is_back:
			position_node.name += "_back"
			position_node.z_index = -1
			part_sprite.material = back_shader
			
		position_node.position = connection.position
	
	part_sprite.texture = part.texture
	part_sprite.name = "sprite"
	
	part_sprite.offset = part.offset
	if part.monster_type != MonsterPart.MONSTER_TYPE.ACCESSORY && parent_part != null && part.monster_type != parent_part.monster_type:
		part_sprite.offset = (part.offset + parts[parent_part.monster_type][part.type].offset) * 0.5
	
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
	
# TODO: Only supports one player per monster
func GetMonsterPartsGroupName(monster: Monster) -> String:
	return "monster%f_parts" % monster.player.controller_port
	
func AddPartToMonster(monster: Monster, monster_part: MonsterPart) -> void:
	var part_found: bool = false
	
	for part in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
		var monster_part_index = MonsterPart.PART_TYPE.keys().find(part.name)
		if monster_part.type == MonsterPart.PART_TYPE.values()[monster_part_index]:
			var part_sprite: Sprite2D = part.get_child(0).get_child(0)
			part_sprite.offset = monster_part.offset
			part_sprite.texture = monster_part.texture
			
			part_found = true
			break
			
	if !part_found:
		print("Part with type %s not found on monster: discarding part" % monster.name)

func Generate(monster: Monster, parent: Node2D, new_part: MonsterPart, _connection: MonsterConnection = null, parent_part: MonsterPart = null) -> Node2D:
	if parent is CanvasGroup && new_part.type == MonsterPart.PART_TYPE.BODY:
		var anim_player: AnimationPlayer = parent.get_node("anim_player")
		if anim_player.has_animation_library(""):
			anim_player.remove_animation_library("")
		anim_player.add_animation_library("", body_animations[new_part.monster_type])
	
	var new_part_node: Node2D = GeneratePart(monster, new_part, _connection, parent_part)
	
	for connection: MonsterConnection in new_part.connections:
		var part: MonsterPart = null
		
		if connection.part_type == MonsterPart.PART_TYPE.HAT:
			#part = accessories[0];
			pass
		else:
			part = GetRandomPart(connection.part_type)
			
		if part != null:
			var part_node: Node2D = Generate(monster, new_part_node, part, connection, new_part)
	
	if parent_part != null && parent_part.type != MonsterPart.PART_TYPE.BODY:
		var anim_offset_node: Node2D = parent.get_child(0)
		anim_offset_node.add_child(new_part_node)
	else:
		parent.add_child(new_part_node)
		
	new_part_node.add_to_group(GetMonsterPartsGroupName(monster))
	
	return parent
	

# TODO: Figure out this color nonsense
func SetColors(monster: Monster) -> void:
	var canvas_rect: Array[float] = [get_viewport().size.x, get_viewport().size.y, 0.0, 0.0];
	
	for part in get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster)):
		var child = part.get_child(0)
		
		# Skip animation offset nodes
		if child is Node2D:
			child = child.get_child(0)
			
		if child is Sprite2D:
			var min_x: float = child.global_position.x - (child.texture.get_width() / 2)
			if min_x < canvas_rect[0]:
				canvas_rect[0] = min_x
				
			var max_x: float = child.global_position.x + (child.texture.get_width() / 2)
			if max_x > canvas_rect[2]:
				canvas_rect[2] = max_x
				
			var min_y: float = child.global_position.y - (child.texture.get_height() / 2)
			if min_y < canvas_rect[1]:
				canvas_rect[1] = min_y
				
			var max_y: float = child.global_position.y + (child.texture.get_height() / 2)
			if max_y > canvas_rect[3]:
				canvas_rect[3] = max_y
				
			var test = "%f, %f, %f, %f"
			var format = test % [min_x, max_x, min_y, max_y]
	
	var part_positions_in_canvas_space: Array[Vector2] = [];
	part_positions_in_canvas_space.resize(10)
	part_positions_in_canvas_space.fill(Vector2.ZERO)
	
	var part_colors: Array[Vector4] = [];
	part_colors.resize(10)
	part_colors.fill(Vector4.ZERO)
	
	var parts: Array[Node] = get_tree().get_nodes_in_group(GetMonsterPartsGroupName(monster))
	
	for i in range(parts.size()):
		var child = parts[i].get_child(0)
		if child is Node2D && child.get_child(0) != null:
			child = child.get_child(0)
			
		part_positions_in_canvas_space[i].x = remap(child.global_position.x, canvas_rect[0], canvas_rect[2], 0.0, 1.0)
		part_positions_in_canvas_space[i].y = remap(child.global_position.y, canvas_rect[1], canvas_rect[3], 0.0, 1.0)
		
		var random_color: Color = Color(randf(), randf(), randf())
		part_colors[i] = Vector4(random_color.r, random_color.g, random_color.b, 1.0)

	monster.root.material.set_shader_parameter("positions", part_positions_in_canvas_space)
	monster.root.material.set_shader_parameter("colors", part_colors)
