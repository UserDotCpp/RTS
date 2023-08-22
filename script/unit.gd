extends CharacterBody3D

@export var team = 1
@export var cluster_id = 0
@export var cluster_resolved = true

@export var job = 0

var in_cluster_id = 0
#@export var steer = true #DOESNT WORK

#tasks 0 == idle | 1 == move | 2 == interact_whit_building | 3 == gatter_resources | 4 == looking_for_resources | 5 == attack
@export var task = 0#= {0,1,2}

var team_colors = {
	0: preload("res://resources/team_1.tres"),
	1: preload("res://resources/team_2.tres")
}

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent
@onready var navigation_timer : Timer = $navigation_timer
@onready var ray_cast : RayCast3D = $RayCast
@onready var cluster_check_area_collision_shape = $cluster_check_area/collision_shape

var current_unit_goal_position:Vector3
var last_unit_position:Vector3

var haves_a_path = false
@export var Speed = 5



func _ready()-> void:
	#set_max_slides(20)

	$mesh.material_override = team_colors[team - 1]

	navigationAgent.velocity_computed.connect(move_unit)
	navigation_timer.timeout.connect(navigation_timer_update)




func _physics_process(delta) -> void:
	if(navigationAgent.is_navigation_finished()):
		return
	move_to_location(delta, Speed)
	#position.y =  ray_cast.get_collision_point().y + 0.4
	#pass




func give_units_target_destination(reference_mouce_pos, referece_in_cluster_id, assigned_job) -> void:
	#$NavigationAgent.avoidance_enabled = true
	assign_job(assigned_job)
	in_cluster_id = referece_in_cluster_id
	cluster_resolved = false
	current_unit_goal_position = reference_mouce_pos
	haves_a_path = true
	$timer.stop()
	cluster_check_area_collision_shape.disabled = true
	#print((in_cluster_id-1)*0.006 )
	navigationAgent.target_position = (reference_mouce_pos)# + Vector3(randf_range(-1.5,1.5),0,randf_range(-1.5,1.5)))





func move_to_location(_delta, speed) -> void:
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
#	face_direction(targetPos)
	
	# DOESNT WORK 
	#var steering_velocity = Vector3(0,0,0)
	#if steer:
	#	var steering_speed = 1.0
	#	steering_velocity = (direction - (direction * speed) * delta * steering_speed)
	move_unit(direction * speed) #+ steering_velocity)




#func face_direction(direction):
#	print(direction)
#	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func move_unit(reference_velocity) -> void:
	velocity = reference_velocity

	if !haves_a_path:
		return
	# DOESNT WORK NEITHER 
	#var collision:KinematicCollision3D = move_and_collide(reference_velocity * get_physics_process_delta_time())
	#if collision:
	#	var collider:Object = collision.get_collider()
	#	if collider is CharacterBody3D:
	#		if "team" in collider and collider.team == team:
	#			velocity = reference_velocity.slide(collision.get_normal())
	#	elif collider is StaticBody3D:
	move_and_slide()



func select() -> void:
	$selection_ring.show()


func deselect() -> void:
	$selection_ring.hide()




func assign_job(reference_job) -> void:
	if reference_job == 1:
		job = reference_job
		self.set_collision_mask_value(24,true)
		self.set_collision_layer_value(24,true)




func navigation_timer_update()-> void:
	if navigationAgent.is_navigation_finished():
		haves_a_path = false
		return
	
	navigationAgent.set_target_position(current_unit_goal_position)
	stucked_unit_check()
	last_unit_position = self.global_position

#_______________________________RESOLVE CLUSTER RUTINE BY TIMER_____________________________________

var stuck_unit_count = 0

func stucked_unit_check() -> void:
	if last_unit_position.distance_squared_to(self.global_position) < 0.8:
		if stuck_unit_count < 30 : stuck_unit_count += 1

	if stuck_unit_count >= 3:
		if (self.global_position.distance_squared_to(current_unit_goal_position) < 10.0) or stuck_unit_count >= 30:
			stuck_unit_count = 0
			cancel_navigation()

func cancel_navigation() -> void:
	#$NavigationAgent.avoidance_enabled = false
	navigationAgent.emit_signal("navigation_finished")
	navigationAgent.target_position = self.global_position

#___________________________________________________________________________________________________







#_______________________________RESOLVE CLUSTER RUTINE BY COLLISION_________________________________
func resolve_cluster() -> void:
	#haves_a_path = false
	$timer.start()
	cluster_resolved = true
	cluster_check_area_collision_shape.disabled = false
	pass

func _on_navigation_agent_navigation_finished() -> void:
	if haves_a_path and !cluster_resolved:
		resolve_cluster()
	if task == 3:
		pass
	#	Global.find_all_units_in_the_stoped_clustered(cluster_id)

func _on_timer_timeout() -> void:
	cluster_check_area_collision_shape.disabled = true
	stop()

func stop()-> void:
	navigationAgent.target_position = self.global_position
	#cancel_navigation()

#__________________________COLLISION SHAPE STUFF________________________________
var body_entered_once = false

func _on_cluster_check_area_body_entered(body) -> void:
	if "cluster_id" in body and body.cluster_id == cluster_id and body != self:
		if body_entered_once:
			call_deferred("kill_colition_check")
		body.stop()
		body_entered_once = true



func kill_colition_check() -> void:
	#$NavigationAgent.avoidance_enabled = false
	cluster_check_area_collision_shape.disabled = true
	$timer.stop()
#_______________________________________________________________________________
#___________________________________________________________________________________________________





