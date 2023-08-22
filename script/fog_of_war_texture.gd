extends Control

signal fog_updated


@onready var fog_camera = $sub_viewport_container/sub_viewport/fog_camera
@onready var  fog_viewport = $sub_viewport_container/sub_viewport
@onready var fog_sprite = $sub_viewport_container/sub_viewport/fog_sprite
@onready var units_in_fog = $sub_viewport_container/sub_viewport/units_in_fog
@onready var timer = $timer

var fog_of_war_stored : Array
var fog_of_war_image : Image
var fog_of_war_texture : ImageTexture
var fog_of_war_viewport_texture : ImageTexture


var fog_of_war_units : Dictionary = {}

var map_rect : Rect2
#var dissolve_sprite:Texture2D = preload("res://assets/textures/fog.png")

func _ready():
	fog_sprite.centered = false
	timer.timeout.connect(fog_of_war_tick_loop)
	timer.start()
	#new_fog_of_war(Rect2(0,0,512,512)) #for the click test

func fog_of_war_tick_loop() -> void:
	fog_of_war_units_data_process()
	fog_of_war_dissolve_all_fog_units()
	fog_of_war_viewport_texture = ImageTexture.create_from_image( fog_viewport.get_texture().get_image())
	
	emit_signal("fog_updated")


func new_fog_of_war(new_map_rect:Rect2) -> void:
	map_rect.size = map_rect.size
	map_rect = new_map_rect
	
	fog_viewport.size = map_rect.size
	
	(fog_viewport.get_parent() as SubViewportContainer).size = map_rect.size
	
	#center the camera
	fog_camera.position = Vector2.ZERO + map_rect.size * 0.50
	
	fog_of_war_image = Image.create(int(map_rect.size.x),(int(map_rect.size.y)),false,Image.FORMAT_RGBA8)
	fog_of_war_image.fill( Color(0.0, 0.0, 0.0, 1.0) )
	update_texture()

func update_texture() -> void:
	fog_of_war_texture = ImageTexture.create_from_image(fog_of_war_image)
	fog_sprite.set_texture(fog_of_war_texture)#main texture


func fog_disolve(dissolve_position:Vector2,dissolve_image:Image) -> void:
		var dissolve_image_used_rect : Rect2 = dissolve_image.get_used_rect()
		dissolve_position -= dissolve_image_used_rect.size *0.50
		
		var map_pos = map_rect.position + dissolve_position
		fog_of_war_image.blend_rect(dissolve_image,dissolve_image_used_rect,dissolve_position)
		
		update_texture()








func fog_of_war_units_data_process() -> void:
	#{unit_id : [node_tracking,sprite_node] }
	for unit_id in fog_of_war_units.keys():
		var unit_data:Array = (fog_of_war_units[unit_id] as Array)
		
		var position_to_2D:Vector2 = Vector2((unit_data[0] as Node3D).global_position.x,(unit_data[0] as Node3D).global_position.z)
		(unit_data[1] as Sprite2D).set_position(position_to_2D)

func fog_of_war_dissolve_all_fog_units() -> void:
	for fow_sprite in units_in_fog.get_children():
		var fog_sprite_image : Image = (fow_sprite as Sprite2D).get_texture().get_image()

		var sprite_stored_position_size:Vector3i = Vector3i((fow_sprite as Sprite2D).position.x,(fow_sprite as Sprite2D).position.y,(fow_sprite as Sprite2D).get_texture().get_size().x)
		
		if !sprite_stored_position_size in fog_of_war_stored:
			var dissolve_position:Vector2=(fow_sprite as Sprite2D ).position
			fog_disolve(dissolve_position ,  fog_sprite_image)
			fog_of_war_stored.append(sprite_stored_position_size)






#FOR TESTING
#func _input(event:InputEvent) -> void:
#	if Input.is_action_just_pressed("left_click"):
#		var mouse_pos : Vector2 = get_global_mouse_position()
#		fog_disolve(mouse_pos,dissolve_sprite.get_image())
