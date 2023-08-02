extends Spatial

class_name cUnit

var nav : Navigation
var target

var move_speed = 10.0
var move_vec : Vector3

var path = []
var path_ind = 0 
var unitCueStatus = false #this makes the unit stop calculating for paths when its done 

#var cuedOrders = [] #this is gonna be for the shift function
#var auxCounter = 0

# the teams are determined by the material of the meshInstance
export var team = 0
var team_colors = {
	0: preload("res://assets/materials/matTeam1.tres"),
	1: preload("res://assets/materials/matTeam2.tres")
}

export var idle_status = true

#_____________________________________________________________________________________FRAME BY FRAME
func _ready():
	if team in team_colors:#sets the team of the unit
		$KinematicBody/MeshInstance.material_override = team_colors[team]
	nav = get_tree().get_nodes_in_group("grpNavigation")[0]#needed to calculate path, gonna be gone in godot4 so dont worry about it

#the _physics_process(delta) runs for all the physics stuff, if u exit it when there is no work to do it ends up saving resources
func _physics_process(delta):
	if (!unitCueStatus):
		return false
	update_move_vec()
	global_translate(move_vec * move_speed * delta)
	#$KinematicBody.move_and_slide(move_speed,)
	#$KinematicBody.move_and_slide((move_vec * move_speed * delta)- Vector3(0.00001, 0, 0.00001), Vector3(0, 2, 0)) #( move_vec * move_speed * delta *0.5)
#_________________________________________________________________________INTERACIONS WHIT "scptCam"

func get_target_move_pos():#this gives the que manager the updathed position of the path coss the move_to asks for a value
	#return target.global_transform.origin for objets positions
	return target

#func move_to(target_pos, estatus ,counter):#gets mouse target
func move_to(target_pos):#this gets the mouse poss from scptCam
	target = target_pos
	unitCueStatus = true#this tells the _physics_process(delta): to start working
	idle_status = false
	#target = get_tree().get_nodes_in_group("grpTarget")[0]
	#cuedOrders.insert(counter, counter)
	#auxCounter = counter
	#print(counter)

#these are called from scptCam to denote which unit are selected
func select():
	$KinematicBody/miSelectionRing.show()
func deselect():
	$KinematicBody/miSelectionRing.hide()	

#______________________________________________________________________________________MOVEMENT CORE

var last_straight_line_check = false

func update_move_vec():
	var current_pos = global_transform.origin
	current_pos.y = 0.0
	var straight_line_check = can_move_in_straight_line()
	
	if !straight_line_check:#decide the path of the unit if it is on a set distance from the target
		if last_straight_line_check: #if the unit can move on a straight line and it could in the last cycle
			path = [get_target_move_pos()]
			path_ind = 0
		#if the unit inst on a straigt line this is gonna ask for a path calculation on a singleton called scptCueManager
		CueManager.calc_path(self, nav)#this sends to the path manager to calculate

	if straight_line_check:#if the unit IS on a straigt line to the target it just gets the next target position to the global_translate on the _physics_process(delta)
		var target_pos = get_target_move_pos()
		target_pos.y = 0.0
		move_vec = current_pos.direction_to(target_pos)#this gets the current path position
	#CALCULATE THE NEXT PATH
	elif path_ind < path.size():#if the unit isnt on a strait line to the target and it isnt the last part of the path
		var next_path_pos = path[path_ind]
		next_path_pos.y = 0.0#this gets the next path position
		while current_pos.distance_squared_to(next_path_pos) < 0.1*0.1 and path_ind < path.size() - 1:
			#el while incrementa el path y de paso se fija q no salga del path index
			path_ind += 1
			next_path_pos = path[path_ind]
			next_path_pos.y = 0.0
		#THIS GONNA BE THE NEXT PATH
		move_vec = current_pos.direction_to(next_path_pos)#_________________________________________
	last_straight_line_check = straight_line_check 

#________________________________________________________________________STRAIGHT LINE CHECK SETINGS
#this are variables so we can impruve the test range whit buffs and stuff
var char_radius = 2 
var char_height = 2
var min_dist_to_check_los = 20.0 #20 is the defualt

#________________________________________________________________________________STRAIGHT LINE CHECK
func can_move_in_straight_line():
	var pos = global_transform.origin + Vector3.UP * char_height
	var target_pos = target + Vector3.UP * char_height

	if pos.distance_squared_to(target_pos) <= 2.3:#end of the path shoud be the unit size coss its centered
		#if auxCounter > 0:
		#	return false
		#print(auxCounter)
		unitCueStatus = false
		idle_status = true
		return false
	
	if pos.distance_squared_to(target_pos) > min_dist_to_check_los * min_dist_to_check_los:#the target isnt near the check treshhold yet
		return false 

	var right : Vector3 = target_pos - pos #this is the distance to the next path on the index from the current location
	right.y = 0.0
	right = right.rotated(Vector3.UP, PI/2.0).normalized()#this makes the unit point to the target

	var ray_right_start_pos = pos + right * char_radius
	var ray_left_start_pos = pos + -right * char_radius
	var ray_right_end_pos = target_pos + right * char_radius
	var ray_left_end_pos = target_pos + -right * char_radius

	var space_state = get_world().direct_space_state#_________________LOOKING FOR STUF NEAR THE UNIT
	
	var los_left = space_state.intersect_ray(ray_left_start_pos, ray_left_end_pos, [], 1).size() == 0
	var los_right = space_state.intersect_ray(ray_right_start_pos, ray_right_end_pos, [], 1).size() == 0
	return los_left and los_right #this tells u if u r gonna collide with something AND if u make the colaiders public, u can reuse this function ass a searcher

#______________________________________________________________________GETS PATH FROM "scnCueManager" -sowwi ;)
func update_path(_path: Array):
	if _path.size() == 0.1:
		return
	path = _path
	path_ind = 0
#___________________________________________________________________________________________________
