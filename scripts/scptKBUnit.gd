extends KinematicBody
 
export var team = 0
var team_colors = {
	0: preload("res://assets/materials/matTeam1.tres"),
	1: preload("res://assets/materials/matTeam2.tres")
}

var unitCueStatus = false
var path = []
var path_ind = 0
const move_speed = 12

var nav : Navigation
var target

#_____________________________________________________________________________________FRAME BY FRAME
func _ready():
	if team in team_colors:
		
		$MeshInstance.material_override = team_colors[team]
	nav = get_tree().get_nodes_in_group("grpNavigation")[0]

func _physics_process(delta):
	if (!unitCueStatus):
		return false
	update_move_vec()

#_________________________________________________________________________INTERACIONS WHIT "scptCam"
func get_target_move_pos():#this gives the que manager the updathed position of the path
	#return target.global_transform.origin for objets positions
	return target

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	unitCueStatus = true
	path_ind = 0

func select():
	$miSelectionRing.show()
func deselect():
	$miSelectionRing.hide()

#______________________________________________________________________________________MOVEMENT CORE
var last_straight_line_check = false

func update_move_vec():
	if path_ind < path.size():
		var move_vec = (path[path_ind] - global_transform.origin)
		if move_vec.length() < 0.1:
			path_ind += 1
		else:
			move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
 

