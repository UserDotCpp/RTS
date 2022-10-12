extends Spatial

class_name MoveUnit

var nav : Navigation
var target

var move_speed = 10.0
var move_vec : Vector3

var path = []
var path_ind = 0
var unitCueStatus = false 

var cuedOrders = [] #this is gonna be for the shift function
var auxCounter 

export var team = 0
var team_colors = {
	0: preload("res://assets/materials/matTeam1.tres"),
	1: preload("res://assets/materials/matTeam2.tres")
}

#_____________________________________________________________________________________FRAME BY FRAME
func _ready():
	$MeshInstance.material_override = team_colors[team]
	nav = get_tree().get_nodes_in_group("grpNavigation")[0]

func _physics_process(delta):
	if (unitCueStatus):
		update_move_vec()
		global_translate(move_vec * move_speed * delta)

#_________________________________________________________________________INTERACIONS WHIT "scptCam"

func get_target_move_pos():#this gives the que manager the updathed position of the path
	#return target.global_transform.origin for objets positions
	return target

func move_to(target_pos, estatus ,counter):#gets mouse target
	target = target_pos
	unitCueStatus = true
	#target = get_tree().get_nodes_in_group("grpTarget")[0]
	cuedOrders.insert(counter, counter)
	auxCounter = counter
	#print(counter)

	
func select():
	$miSelectionRing.show()
func deselect():
	$miSelectionRing.hide()	

#______________________________________________________________________________________MOVEMENT CORE

var last_straight_line_check = false

func update_move_vec():
	var current_pos = global_transform.origin
	current_pos.y = 0.0
	var straight_line_check = can_move_in_straight_line()
	
	if !straight_line_check:
		if last_straight_line_check:
			path = [get_target_move_pos()]
			path_ind = 0
		CueManager.calc_path(self, nav)#this sends to the path manager to calculate

	if straight_line_check:
		var target_pos = get_target_move_pos()
		target_pos.y = 0.0
		move_vec = current_pos.direction_to(target_pos)
		
	elif path_ind < path.size():#___________________________________________________GENERAL MOVEMENT
		var next_path_pos = path[path_ind]
		next_path_pos.y = 0.0
		while current_pos.distance_squared_to(next_path_pos) < 0.1*0.1 and path_ind < path.size() - 1:
			path_ind += 1
			next_path_pos = path[path_ind]
			next_path_pos.y = 0.0
		move_vec = current_pos.direction_to(next_path_pos)#_________________________________________
	last_straight_line_check = straight_line_check

#________________________________________________________________________STRAIGHT LINE CHECK SETINGS
var char_radius = 2 
var char_height = 2
var min_dist_to_check_los = 20.0

#________________________________________________________________________________STRAIGHT LINE CHECK
func can_move_in_straight_line():
	var pos = global_transform.origin + Vector3.UP * char_height
	var target_pos = target + Vector3.UP * char_height
	
	if pos.distance_squared_to(target_pos) <= 2.3:#end of the path
		#if auxCounter > 0:
		#	auxCounter - 1
		#	return false
		#print(auxCounter)
		unitCueStatus = false
		return false
	
	if pos.distance_squared_to(target_pos) > min_dist_to_check_los*min_dist_to_check_los:#the target isnt near the check treshhold yet
		return false 

	var right : Vector3 = target_pos - pos
	right.y = 0.0
	right = right.rotated(Vector3.UP, PI/2.0).normalized()
	var ray_right_start_pos = pos + right * char_radius
	var ray_left_start_pos = pos + -right * char_radius
	var ray_right_end_pos = target_pos + right * char_radius
	var ray_left_end_pos = target_pos + -right * char_radius	

	var space_state = get_world().direct_space_state#_________________LOOKING FOR STUF NEAR THE UNIT
	var los_left = space_state.intersect_ray(ray_left_start_pos, ray_left_end_pos, [], 1).size() == 0
	var los_right = space_state.intersect_ray(ray_right_start_pos, ray_right_end_pos, [], 1).size() == 0
	return los_left and los_right #if u make the colaiders public, u can reuse this function ass a searcher

#______________________________________________________________________SENDS PATH TO "scnCueManager"
func update_path(_path: Array):
	if _path.size() == 0.1:
		return
	path = _path
	path_ind = 0
#___________________________________________________________________________________________________
