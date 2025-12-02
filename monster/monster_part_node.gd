class_name MonsterPartNode
extends Node2D

var part_ref: MonsterPart
var connection_ref: MonsterConnection
var parent_part: MonsterPartNode
var anim_offset: Node2D
var sprite: Sprite2D

func init(monster: Monster, part: MonsterPart, parent: Node2D, front_shader: Shader, back_shader: ShaderMaterial, connection: MonsterConnection = null) -> void:
	part_ref = part
	var prefix: String = MonsterPart.PART_TYPE.keys()[part_ref.type]
	name = prefix
	
	anim_offset = Node2D.new()
	add_child(anim_offset)
	
	sprite = Sprite2D.new()
	sprite.name = "sprite"
	sprite.offset = part_ref.offset
	sprite.texture = part_ref.texture
	
	anim_offset.add_child(sprite)

	connection_ref = connection
	if connection_ref != null:
		if connection_ref.is_back:
			name += "_back"
			show_behind_parent = true
			sprite.material = back_shader
			
		position = connection_ref.position
		
	anim_offset.name = name + "_anim_offset"
		
	if part_ref.hurtbox_size:
		var hurtbox: Area2D = Area2D.new()
		hurtbox.add_to_group("HurtBox")
		hurtbox.name = "hurtbox"
		
		var shape: CollisionShape2D = CollisionShape2D.new()
		shape.name = "shape"
		
		var rect: RectangleShape2D = RectangleShape2D.new()
		
		rect.size = part_ref.hurtbox_size
		shape.shape = rect
		shape.position = part_ref.hurtbox_offset
		
		hurtbox.add_child(shape)
		add_child(hurtbox)
		
	if parent is MonsterPartNode:
		parent_part = parent
		
	if part_ref.is_accessory || part_ref.type == MonsterPart.PART_TYPE.EYE:
		return
		
	if connection_ref == null || !connection_ref.is_back:
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = front_shader
		shader_material.resource_local_to_scene = true
		sprite.material = shader_material
		
		if parent_part != null:
			sprite.material.set_shader_parameter("parent_part_world_pos", parent_part.sprite.global_position)
			sprite.material.set_shader_parameter("parent_part_color", parent_part.sprite.material.get_shader_parameter("part_color"))
		
		# NOTE: https://stackoverflow.com/questions/43044/algorithm-to-randomly-generate-an-aesthetically-pleasing-color-palette
		# Randomly select a fixed palette and generate colors from there
		var part_color: Color = Color(randf(), randf(), randf())
		sprite.material.set_shader_parameter("part_color", part_color)
		
	#if part.monster_type != MonsterPart.MONSTER_TYPE.ACCESSORY && parent_part != null && part.monster_type != parent_part.monster_type:
		#part_sprite.offset = (part.offset + parts[parent_part.monster_type][part.type].offset) * 0.5

func _physics_process(delta: float) -> void:
	if part_ref.type == MonsterPart.PART_TYPE.EYE || part_ref.is_accessory:
		return
	
	if parent_part != null:
		sprite.material.set_shader_parameter("parent_part_world_pos", parent_part.sprite.global_position)
