extends CharacterBody3D

@export var team = 1
@export var cluster_id = 0
@export var cluster_resolved = true
var in_cluster_id = 0
#@export var steer = true #DOESNT WORK

var team_colors = {
	0: preload("res://resources/team_1.tres"),
	1: preload("res://resources/team_2.tres")
}

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent
@onready var navigation_timer : Timer = $navigation_timer
@onready var ray_cast : RayCast3D = $RayCast

var current_unit_goal_position:Vector3
var last_unit_position:Vector3

var haves_a_path = false
var Speed = 5

func _ready()-> void:
	#set_max_slides(20)

	$mesh.material_override = team_colors[team - 1]

	navigationAgent.velocity_computed.connect(move_unit)
	navigation_timer.timeout.connect(navigation_timer_update)


func _physics_process(delta) -> void:
	if(navigationAgent.is_navigation_finished()):
		return
	moveToPoint(delta, Speed)
	#position.y =  ray_cast.get_collision_point().y + 0.4
	#pass


func moveToPoint(_delta, speed) -> void:
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

func give_units_target_destination(reference_mouce_pos, referece_in_cluster_id) -> void:
	#$NavigationAgent.avoidance_enabled = true
	in_cluster_id = referece_in_cluster_id
	cluster_resolved = false
	current_unit_goal_position = reference_mouce_pos
	haves_a_path = true
	$timer.stop()
	$Area/CollisionShape3D.disabled = true
	#print((in_cluster_id-1)*0.006 )
	navigationAgent.target_position = (reference_mouce_pos)# + Vector3(randf_range(-1.5,1.5),0,randf_range(-1.5,1.5)))
	
	
#RESOLVE CLUSTER RUTINE_________________________________________________________
func resolve_cluster() -> void:
	#haves_a_path = false
	$timer.start()
	cluster_resolved = true
	$Area/CollisionShape3D.disabled = false
	pass

func _on_navigation_agent_navigation_finished() -> void:
	if haves_a_path and !cluster_resolved:
		resolve_cluster()
	#	Global.find_all_units_in_the_stoped_clustered(cluster_id)

func _on_timer_timeout() -> void:
	$Area/CollisionShape3D.disabled = true
	stop()
#______________________________________________________________________________


func navigation_timer_update()-> void:
	if navigationAgent.is_navigation_finished():
		haves_a_path = false
		return
	
	navigationAgent.set_target_position(current_unit_goal_position)
	stucked_unit_check()
	last_unit_position = self.global_position


var stuck_unit_count = 0

func stucked_unit_check() -> void:
	if last_unit_position.distance_squared_to(self.global_position) < 0.8:
		if stuck_unit_count < 30 : stuck_unit_count += 1
	
	if stuck_unit_count >= 3:
		if (self.global_position.distance_squared_to(current_unit_goal_position) < 10.0) or stuck_unit_count >= 30:
			stuck_unit_count = 0
			cancel_navigation()
			
			
func stop()-> void:
	navigationAgent.target_position = self.global_position
	#cancel_navigation()
	
var body_entered_once = false

func _on_area_3d_body_entered(body):
	if "cluster_id" in body and body.cluster_id == cluster_id and body != self:
		if body_entered_once:
			call_deferred("kill_colition_check")
		body.stop()
		body_entered_once = true

func kill_colition_check():
	#$NavigationAgent.avoidance_enabled = false
	$Area/CollisionShape3D.disabled = true
	$timer.stop()

func cancel_navigation() -> void:
	#$NavigationAgent.avoidance_enabled = false
	navigationAgent.emit_signal("navigation_finished")
	navigationAgent.target_position = self.global_position
