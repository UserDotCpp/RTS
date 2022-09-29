extends Spatial

var target = preload("res://scenes/scnTarget.tscn")
const MOVE_MARGIN = 20
const MOVE_SPEED = 50
const ray_length = 1000
onready var cam = $cmCam
var team = 0
var selected_units = []

var counter = 1

onready var selection_box = $cSelectionBox
var start_sel_pos = Vector2()


#________________________________________________________________________________________________________IMPUTS/FRAME BY FRAME
#this runs heach frame
func _process(delta):
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos, delta)
	
	
	if Input.is_action_pressed("shift"):#if is press
		if Input.is_action_just_pressed("rightMouse"):
			counter = counter + 1
			move_selected_units(m_pos)
	else:
		counter = 0
	if Input.is_action_just_released("shift"):#when is freed
		counter = 0
	
	
	if Input.is_action_just_pressed("rightMouse"):
		move_selected_units(m_pos)
	
	if Input.is_action_just_pressed("leftMouse"):
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
		
	if Input.is_action_pressed("leftMouse"):#if is press
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("leftMouse"):#when is freed
		select_units(m_pos)

#________________________________________________________________________________________________________BOX MANAGMENT
func select_units(m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units


func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x: #gets x poss
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y: #gets Y poss
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp

	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("gUnit"):

		if unit.team == team and box.has_point(cam.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units
#________________________________________________________________________________________________________CAM INTERACTION/MOUSE POINTER
func calc_move(m_pos, delta):
	var v_size = get_viewport().size #screen size
	var move_vec = Vector3() #so this vector moves the cam
 
	if m_pos.x < MOVE_MARGIN:
		move_vec.x -= 1
	if m_pos.y < MOVE_MARGIN:
		move_vec.z -= 1
	if m_pos.x > v_size.x - MOVE_MARGIN:
		move_vec.x += 1
	if m_pos.y > v_size.y - MOVE_MARGIN:
		move_vec.z += 1
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	global_translate(move_vec * delta * MOVE_SPEED)

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos) #convert the mouce position in to a real possition
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length #end position
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)
#________________________________________________________________________________________________________UNITS COMANDS
func move_selected_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		for unit in selected_units:
			unit.move_to(result.position , true , counter)
			CueManager.queStatus = true
			
			
func move_all_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:	
		get_tree().call_group("gUnit", "move_to", result.position , true)
		#var targetInstance = target.instance()
		#get_parent().get_node("TargetBase").add_child(targetInstance)
		#get_parent().get_node("TargetBase/Position3D").translation = testt
		CueManager.queStatus = true	
#________________________________________________________________________________________________________
