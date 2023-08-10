extends Camera3D

var mouce_position

func _ready()-> void:
	pass 

var team = 1
var start_sel_pos = Vector2()
@onready var selection_box = $selection_box
var selected_units = []
@onready var cursor = self.get_parent().get_parent().get_node("cursor")

@onready var resource_grid_map = self.get_parent().get_parent().get_node("NavigationRegion/GridMap")

@onready var resource = preload("res://scenes/resource.tscn")

@onready var navigation_region = self.get_parent().get_parent().get_node("NavigationRegion")

@onready var selector = self.get_parent().get_parent().get_node("selector")

var selector_placement_status = {
	0: preload("res://resources/selector_0.tres"),
	1: preload("res://resources/selector_1.tres")
}

func _process(_delta) -> void:
	mouce_position = get_viewport().get_mouse_position()
	

var last_poss = Vector3(0,-4,0)

func _input(event) -> void:
#floor UV1 was 135

	if Input.is_action_pressed("q"):
		var poss = raycast_from_mouse(mouce_position, 2).position
		#selector.get_surface_material(0).set_shader_param("current_color", yellow)#sets the shader of the selector box 
		selector.get_node("selector_mesh").material_override = selector_placement_status[1]
		#the translation of the mouse position on the gridmap and the tile is the sentered tile inside the selector position 
		selector.position = Vector3(round(poss.x ), 0.5, round(poss.z))  #round(poss.y)/ 2

		var tile = resource_grid_map.get_cell_item(Vector3(poss.x, 0, poss.z))#Vector3(round(poss.x+ 0.9) / 2, 0, round(poss.z+ 0.9) / 2)) #round(poss.y)/ 2

		last_poss = poss
		if (tile >= 1 ):
			#if there is something iside the tile, the selector goes on top of it, get rid of this when the "q" is done
			selector.get_node("selector_mesh").material_override = selector_placement_status[0]
			#selector.position = Vector3(round(poss.x), 4, round(poss.z))

		if event is InputEventMouseButton and event.button_index <= 1:
			var posi = event.position#for some reason the event position is more acurred that the live mouse position, ://///
			if event.pressed:
				var tile_pos= resource_grid_map.local_to_map(raycast_from_mouse(posi, 2).position)
				print(resource_grid_map.get_cell_item(Vector3(tile_pos.x ,0 ,tile_pos.z)))
				if (resource_grid_map.get_cell_item(Vector3(tile_pos.x ,0 ,tile_pos.z)) == -1):
					#print((str(raycast_from_mouse(mouce_position, 3).collider)))
					resource_grid_map.set_cell_item(Vector3(tile_pos.x ,0 ,tile_pos.z) ,0 ,0 )#(int x, int y, int z, int item of the grid map, int orientation= 0 )
					call_deferred("update_the_nav_mesh")
	else:#if Input.actt("q"):#this hides the selector under the ground 
		selector.position = Vector3(0,-4,0)




	if Input.is_action_just_pressed("right_click"):
		cursor.get_node("cursor_mesh/ap").stop()
		cursor.transform.origin = raycast_from_mouse(mouce_position, 2).position
		cursor.get_node("cursor_mesh/ap").play("click")
		cursor.get_node("Area/CollisionShape").disabled = false

		var pos = resource_grid_map.local_to_map(raycast_from_mouse(mouce_position, 3).position)
		var tile = resource_grid_map.get_cell_item(Vector3(pos.x ,0 ,pos.z))
		if tile >= 1:
			print(tile)
			resource_grid_map.set_cell_item(Vector3(pos.x ,0 ,pos.z),-1)
			var reso =  resource.instantiate()
			reso.set_name(str(tile,"/x/",pos.x,"z",pos.y,")"))
			self.get_parent().get_parent().get_node("NavigationRegion/resources").add_child(reso)
			reso.position = Vector3((pos.x + 0.5) * 2, 0, (pos.z + 0.5) * 2)
			#pos = resource_grid_map.get_cell_item(pos.x ,0 ,pos.z)
			reso.set_the_sprite(tile)
			call_deferred("update_the_nav_mesh")
		move_selected_units(mouce_position)


	if Input.is_action_just_pressed("left_click"):
			selection_box.start_sel_pos = mouce_position
			start_sel_pos = mouce_position

	if Input.is_action_pressed("left_click"):#if is press
		selection_box.mouce_position = mouce_position
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("left_click"):#when is freed
		select_units(mouce_position)

func raycast_from_mouse(reference_mouce_pos, collision_mask):
	var ray_start = self.project_ray_origin(reference_mouce_pos)
	var ray_end = ray_start + self.project_ray_normal(reference_mouce_pos) * 1000 #the 1000 was a ray_length, if else this doesnt work in ortogonal view

	var ray_parameters:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start,ray_end,collision_mask)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_parameters)
	if result:
		return result
	#return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)



# UNIT SELECTION RUTINE_________________________________________________________
func select_units(reference_mouce_pos) -> void:
	var new_selected_units = []
	if mouce_position.distance_squared_to(start_sel_pos) < 16:#this checks if u dragged far enough to trigger a selection box 
		var u = get_unit_under_mouse(mouce_position)
		if u != null:
			new_selected_units.append(u)
		else:
			for unit in selected_units:
				unit.deselect()
			new_selected_units = []
	else:
		new_selected_units = get_units_in_box(start_sel_pos, reference_mouce_pos)

	if new_selected_units.size() != 0:#this manages which units are selected 
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units

func get_unit_under_mouse(reference_mouce_pos): 
	var result = raycast_from_mouse(reference_mouce_pos, 1)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x: #gets from x poss
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
	for unit in get_tree().get_nodes_in_group("unit_group"):#this checks if the unit under the box are from your team 
		if unit.team == team and box.has_point(self.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units

#_______________________________________________________________________________

func move_selected_units(reference_mouce_pos) -> void:
	var result = raycast_from_mouse(reference_mouce_pos, 2)
	if result:
		var count = 0
		for unit in selected_units:
			count += 1
			#unit.move_to(result.position , 1 , counter)
			unit.give_units_target_destination(result.position, count)
		Global.create_unit_cluster(selected_units,result.position,len(selected_units))
		#var unit_cluster_query_local = ([selected_units,result.position,len(selected_units)])
		
		#print(unit_cluster_query_local)


func _on_area_body_entered(body):
	if "team" in body and body.team != team:
		print("atack this dude : ", body)
	call_deferred("kill_cursor_collition_area")

func kill_cursor_collition_area():
	cursor.get_node("Area/CollisionShape").disabled = true


func update_the_nav_mesh() -> void:
		navigation_region.bake_navigation_mesh()

func _on_navigation_region_bake_finished():
	pass # Replace with function body.
