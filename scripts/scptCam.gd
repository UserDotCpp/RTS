extends Spatial

#camera variables 
const MOVE_MARGIN = 20
const MOVE_SPEED = 50
#const ray_length = 1000

#the onready anchor a node tho this scene so it takes less time importing it just once
onready var cam = $cmCam #onready coss whe need to know the mouse position at all times
onready var selector = get_parent().get_node("spBuilding_selector/msSelector") #the selector for the building placement
onready var map = get_parent().get_node("nvNavigationCore/nviNavMesh/gm1x1") #the gridmap
onready var resource = preload("res://scenes/scnResource.tscn")

var team = 0
var selected_units = []

#dumm zoom variables 
#var viewport_resolution = Vector2()
#var viewport_resolution_varience = 600
#var viewport_minimum = 200

var m_pos #live mouse position 
#var counter = 1

onready var selection_box = $cSelectionBox
var start_sel_pos = Vector2()

#________________________________________________________________________________________________________IMPUTS/FRAME BY FRAME
#this runs each frame
func _process(delta):
	m_pos = get_viewport().get_mouse_position()
	calc_move( delta)

#selector colors, this gives the shader what color to show in the builder_cube/the selector when u press "q"  (rn its black dont know why)
export (Color , RGB) var yellow
export (Color , RGB) var red

func _input(event):
#catches all the user action pre stated on the "Input Map"<- (on the project settings)
	if Input.is_action_just_pressed("rightMouse"):
		move_selected_units(m_pos)
		

	if Input.is_action_just_pressed("leftMouse"): 
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
		if(Input.is_action_pressed("q")):#for testing
			return false
		var pos = map.world_to_map(raycast_from_mouse(event.position, 1).position)
		var tile = map.get_cell_item(pos.x ,0 ,pos.z)
		if (tile != -1):
			map.set_cell_item(pos.x ,0 ,pos.z, -1, 0)
			var reso = resource.instance()
			get_parent().get_node("nvNavigationCore/nviNavMesh").add_child(reso)
			reso.set_name(str("@"+str(tile)+"@")) #when instansing the first one doenst have the @, FUNNN
			reso.translation = Vector3((pos.x + 0.5) * 2, 1, (pos.z + 0.5) * 2)
			pos = map.get_cell_item(pos.x ,0 ,pos.z)
			reso.show_sprite(tile)



	if Input.is_action_pressed("leftMouse"):#if is press
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("leftMouse"):#when is freed
		select_units(m_pos)


	if (Input.is_action_pressed("q")):#building placement function
		#print(map.world_to_map(raycast_from_mouse(m_pos, 1).position))
		#selector.translation = Vector3(map.world_to_map(raycast_from_mouse(m_pos, 1).position).x,1,map.world_to_map(raycast_from_mouse(m_pos, 1).position).z)
		var poss = raycast_from_mouse(m_pos, 1).position
		selector.get_surface_material(0).set_shader_param("current_color", yellow)#sets the shader of the selector box 

		#the translation of the mouse position on the gridmap and the tile is the sentered tile inside the selector position 
		selector.translation = Vector3(round(poss.x ), 0, round(poss.z))  #round(poss.y)/ 2
		var tile = map.get_cell_item(round(poss.x+ 0.9) / 2, 0, round(poss.z+ 0.9) / 2) #round(poss.y)/ 2
		if (tile >= 0 ):
			#if there is something iside the tile, the selector goes on top of it, get rid of this when the "q" is done
			selector.get_surface_material(0).set_shader_param("current_color", red)
			selector.translation = Vector3(round(poss.x), 4, round(poss.z))
		if event is InputEventMouseButton:
			var posi = event.position#for some reason the event position is more acurred that the live mouse position, ://///
			if event.pressed:
				var tile_pos= map.world_to_map(raycast_from_mouse(posi, 1).position)
				if (map.get_cell_item(tile_pos.x ,0 ,tile_pos.z) == -1):
					print((str(raycast_from_mouse(m_pos, 1).collider)))
					map.set_cell_item(tile_pos.x ,0 ,tile_pos.z ,4 ,0 )#(int x, int y, int z, int item of the grid map, int orientation= 0 )
	if Input.is_action_just_released("q"):#this hides the selector under the ground 
		selector.translation = Vector3(0,-4,0)

	if Input.is_action_pressed("escape"):#reloads the map
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://scenes/scnWorldMap.tscn"))
		queue_free()
		pass
		#get_tree().reload_current_scene()

	#had a cue system in the making but more pressing matters arouse 
	#if Input.is_action_pressed("shift"):#if is press
	#	if Input.is_action_just_pressed("rightMouse"):
	#		counter = counter + 1
	#		move_selected_units(m_pos)
	#else:
	#	counter = 0
	#if Input.is_action_just_released("shift"):#when is freed
	#	counter = 0

	#if (Input.is_action_just_pressed("mouse_wheel_up")):
	#	if cam.size > 5:
	#		cam.size -= 1
	#		_adjust_viewport_size()
	#if (Input.is_action_just_pressed("mouse_wheel_down")):
	#	if cam.size > 5:
	#		cam.size += 1
	#		_adjust_viewport_size()

#________________________________________________________________________________________________________BOX MANAGMENT
func select_units(fake_m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:#this checks if u press far enough to trigger a selection box 
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, fake_m_pos)

	if new_selected_units.size() != 0:#this manages which units are selected 
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units

func get_unit_under_mouse(fake_m_pos):#this checks if the unit under the mouse is from your team 
	var result = raycast_from_mouse(fake_m_pos, 1)
	print(result)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x: #gets from  x poss
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y: #gets from Y poss
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	#______________________________________________
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("gUnit"):#this checks if the unit under the box are from your team 
		if unit.team == team and box.has_point(cam.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units

#________________________________________________________________________________________________________CAM INTERACTION/MOUSE POINTER
func calc_move(delta):
	#TO DO - gotta change all of this cuz it's running on _process(delta),if there is a cambas layer, whe can use hitboxes to stop looking for positions 
	var v_size = get_viewport().size #screen size
	var move_vec = Vector3() #so this vector moves the cam
 
	if m_pos.x < MOVE_MARGIN:
		move_vec.x -= 1
		move_vec.z -= 0.55
	if m_pos.y < MOVE_MARGIN:
		move_vec.z -= 1
		move_vec.x += 0.55
	if m_pos.x > v_size.x - MOVE_MARGIN:
		move_vec.x += 1
		move_vec.z += 0.55
	if m_pos.y > v_size.y - MOVE_MARGIN:
		move_vec.z += 1
		move_vec.x -= 0.55
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	global_translate(move_vec * delta * MOVE_SPEED)

#func _adjust_viewport_size():
	#this is the zoom stuff, doesnt work coss viewport_resolution affects ortogonal camera, and getting the cam closer fuck up model details 
	#viewport_resolution.x = (cam.size / 100) * viewport_resolution_varience + viewport_minimum
	#viewport_resolution.y = (cam.size / 100) * viewport_resolution_varience + viewport_minimum
	#get_tree().get_root().set_size(Vector2(viewport_resolution.x,viewport_resolution.y))

func raycast_from_mouse(fake_m_pos, collision_mask):#this gives the position of the mouse in relation with the ground(or anything that haves the designated collision mask)
	var ray_start = cam.project_ray_origin(fake_m_pos) #convert the mouce position in to a real possition
	var ray_end = ray_start + cam.project_ray_normal(fake_m_pos) * 1000 #the 1000 was a ray_length #end position
	var space_state = get_world().direct_space_state
	#print(space_state.intersect_ray(ray_start, ray_end, [], collision_mask).collider)
	#checks if the target is the ground
	#if(space_state.intersect_ray(ray_start, ray_end, [], collision_mask).collider != get_parent().get_node("nvNavigationCore/nviNavMesh/miPlane/piso")):
	#	return false
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask) # the [] can be use to exclude stuff from the colition
	
#IMPORTANT FOR TESTING/from "raycast_from_mouse" the returned object is a dictionary with the following fields:
#collider: The colliding object.
#collider_id: The colliding object's ID.
#normal: The object's surface normal at the intersection point.
#position: The intersection point.
#rid: The intersecting object's RID.
#shape: The shape index of the colliding shape.
#________________________________________________________________________________________________________UNITS COMANDS
func move_selected_units(fake_m_pos):
	var result = raycast_from_mouse(fake_m_pos, 1)
	if result:
		for unit in selected_units:
			#unit.move_to(result.position , 1 , counter)
			unit.move_to(result.position)
			CueManager.queStatus = true
#________________________________________________________________________________________________________
