extends StaticBody3D

var working_status = false

var haves_siganl = {}
enum Resources {wood,food,gold,stone,none}
@export var reso = 0 #this only goes if whe need to instance the resource manualy

var near_idle = []

@export var recolection_range = 3.2
@export var recolection_rate = 0.5
var recolection_time = 0.0
var resource = 30
var current_target 

@onready var detect_area = $area
@export var sight_range = 10.0



func _physics_process(delta) -> void:
	if !working_status:
		return
	update_cur_target()
	if !is_instance_valid(current_target):
		return
	if in_recolection_range_of_cur_target():
		recolection_time += delta
		if recolection_time >= recolection_rate:
			recolection_time = 0.0
			harvest()
	else:#this gonna call the unit to work
		pass


func set_the_sprite(num) -> void:
	#print(num)
	if(num >= 0 and num <= 4):
		reso = num 
		$sprites.get_child(num-1).show()
		working_status = true
		#check_surroundings()


func harvest() -> void:
	resource = (resource -1) -near_idle.size()
	if resource <= resource * 0.5:
		check_surroundings()
	if resource <= 0:
		working_status = false #redundant
		queue_free()



func update_cur_target() -> void:
	check_idle()
	current_target = get_closest_idle()



func check_idle() -> void: #call_idle
	near_idle = []
	for unit in detect_area.get_overlapping_bodies():
		if "team" in unit and unit.team == 1:#!is_instance_valid(unit) or !("team" in unit):#if it isnt deleted or if it doesnt have a "team"
			near_idle.append(unit)#if it does add it to the list



func in_recolection_range_of_cur_target():
	var dist = global_transform.origin.distance_squared_to(current_target.global_transform.origin)
	return dist < recolection_range * recolection_range


func get_closest_idle():
	var closest_idle = null
	var dist = -1
	for unit in near_idle:
		if !is_instance_valid(unit):
			continue
		var dist_to_target = global_transform.origin.distance_squared_to(unit.global_transform.origin)
		if dist < 0.0 or dist_to_target < dist:
			dist = dist_to_target
			closest_idle = unit
	return closest_idle



func check_surroundings() -> void:
	var char_radius = 2 
	var char_height = 2
	var collision_mask = 1

	var pos = global_transform.origin + Vector3.UP * char_height
	pos.y = 0
	var x_current_unit_goal_position = pos - Vector3(2,0,0)
	var z_current_unit_goal_position = pos - Vector3(0,0,2)

	var ray_right_start_pos = pos + Vector3(0,0,2)
	var ray_left_start_pos = pos + -Vector3(0,0,2)
	var ray_front_start_pos = pos + Vector3(2,0,0)
	var back_back_start_pos = pos + -Vector3(2,0,0)
	
	var ray_right_end_pos = x_current_unit_goal_position + Vector3(0,0,2)
	var ray_left_end_pos = x_current_unit_goal_position + -Vector3(0,0,2)
	var ray_front_end_pos = z_current_unit_goal_position + Vector3(2,0,0)
	var ray_back_end_pos  = z_current_unit_goal_position + -Vector3(2,0,0)

	var ray_parameters_left:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_left_start_pos,ray_left_end_pos,collision_mask)#ray_left_start_pos,ray_left_end_pos,collision_mask)
	var ray_parameters_right:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_right_start_pos,ray_right_end_pos,collision_mask)
	var ray_parameters_front:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_front_start_pos,ray_front_end_pos,collision_mask)
	var ray_parameters_back:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(back_back_start_pos,ray_back_end_pos,collision_mask)
	
	var space_state = get_world_3d().direct_space_state#_________________LOOKING FOR STUF NEAR THE UNIT

	var los_left = space_state.intersect_ray(ray_parameters_left)#.size() == 0
	var los_right = space_state.intersect_ray(ray_parameters_right)#.size() == 0
	var los_front = space_state.intersect_ray(ray_parameters_front)#.size() == 0
	var los_back = space_state.intersect_ray(ray_parameters_back)#.size() == 0
	
	if los_left:
		get_parent().get_parent().get_parent().get_node("cam_core/Camera").change_tile_to_mesh(los_left.position)
	if los_right:
		get_parent().get_parent().get_parent().get_node("cam_core/Camera").change_tile_to_mesh(los_right.position)
	if los_front:
		get_parent().get_parent().get_parent().get_node("cam_core/Camera").change_tile_to_mesh(los_front.position)
	if los_back:
		get_parent().get_parent().get_parent().get_node("cam_core/Camera").change_tile_to_mesh(los_back.position)
	#return los_left and los_right
