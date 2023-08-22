extends Node3D

var word_size : Vector2i=Vector2i(256,256)


@onready var ball_a = $unit_test
@onready var FOG:Control = $fog_of_war_texture
@onready var worldmap_mesh:MeshInstance3D = $NavigationRegion/floor

var dissolve_sprite:Texture2D = preload("res://assets/textures/fog.png")

func _ready():
	FOG.new_fog_of_war(Rect2(Vector2.ZERO,word_size))
	add_unit_fog(ball_a)
	FOG.fog_updated.connect(
		func() -> void:
			(worldmap_mesh.get_material_override() as ShaderMaterial).set_shader_parameter("source_texture_fog",FOG.fog_of_war_viewport_texture)
			
			)


#https://www.youtube.com/watch?v=yP1W8fXTqG4

#min 5:11


func add_unit_fog(fog_node3D:Node3D)->void:
	var new_sprite:Sprite2D = Sprite2D.new()
	new_sprite.set_texture(get_new_dissolve_image_texture(32))
	FOG.units_in_fog.add_child(new_sprite)#units_treenode?
	
	FOG.fog_of_war_units[ball_a.get_instance_id()] = [ball_a,new_sprite]#unit data


func get_new_dissolve_image_texture(size:int) -> ImageTexture:
	var dissolve_image : Image = (dissolve_sprite.get_image() as Image)
	dissolve_image.resize(size,size)
	
	return ImageTexture.create_from_image(dissolve_image)


