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


func set_the_sprite(num):
	print(num)
	if(num >= 0 and num <= 4):
		reso = num 
		$sprites.get_child(num-1).show()
		working_status = true


func _physics_process(delta):
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

func check_idle(): #call_idle
	near_idle = []
	for unit in detect_area.get_overlapping_bodies():
		if "team" in unit and unit.team == 1:#!is_instance_valid(unit) or !("team" in unit):#if it isnt deleted or if it doesnt have a "team"
			near_idle.append(unit)#if it does add it to the list
		
		
func in_recolection_range_of_cur_target():
	var dist = global_transform.origin.distance_squared_to(current_target.global_transform.origin)
	return dist < recolection_range * recolection_range

func harvest():
	resource = (resource -1) -near_idle.size()
	print(resource)
	if resource <= 0:
		working_status = false #redundant
		queue_free()

func update_cur_target():
	check_idle()
	current_target = get_closest_idle()

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
