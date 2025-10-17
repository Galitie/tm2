class_name MonsterPartNode
extends Node2D

var part_ref: MonsterPart
var connection_ref: MonsterConnection
var anim_offset: Node2D
var sprite: Sprite2D

func init(monster: Monster, part: MonsterPart, back_shader: ShaderMaterial, connection: MonsterConnection = null) -> void:
	part_ref = part
	var prefix: String = MonsterPart.PART_TYPE.keys()[part_ref.type]
	name = prefix
	
	anim_offset = Node2D.new()
	anim_offset.name = prefix + "_anim_offset"
	add_child(anim_offset)
	
	sprite = Sprite2D.new()
	sprite.name = "sprite"
	sprite.offset = part_ref.offset
	sprite.texture = part_ref.texture
	sprite.self_modulate = monster.base_color
	
	anim_offset.add_child(sprite)

	connection_ref = connection
	if connection_ref != null:
		if connection_ref.is_back:
			name += "_back"
			show_behind_parent = true
			sprite.material = back_shader
			
		position = connection_ref.position
		
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
		
	#if part.monster_type != MonsterPart.MONSTER_TYPE.ACCESSORY && parent_part != null && part.monster_type != parent_part.monster_type:
		#part_sprite.offset = (part.offset + parts[parent_part.monster_type][part.type].offset) * 0.5
