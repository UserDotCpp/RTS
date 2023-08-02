extends Node

var queue = []#this is where the querry of the unit is store
var cache = {}
var queStatus = false

var paths_calc_per_turn = 8
#________________________________________________________________________________
func _physics_process(_delta):
	if (queStatus):
		for _i in range(paths_calc_per_turn):  #how many paths do we calculated per frame
			dequeue_path_request()
#________________________________________________________________________________

func dequeue_path_request():
	if queue.size() == 0:
		return
	var calc_path_info = queue.pop_front()
	var unit: cUnit = calc_path_info.unit
	var nav: Navigation = calc_path_info.nav
	var start_pos = unit.global_transform.origin
	var end_pos = unit.get_target_move_pos()
	var new_path = nav.get_simple_path(start_pos, end_pos)#this calculates the path FOR NOW wait till godot4
	cache.erase(str(unit))
	unit.update_path(new_path)
#________________________________________________________________________________
func calc_path(unit: cUnit, nav: Navigation):#gets the values from scptUnit
	var key = str(unit)#the key gives an identifier tho each unit so 
	if key in cache:
		return
	cache[key] = ""
	queue.append({"unit": unit,"nav": nav})
#________________________________________________________________________________
