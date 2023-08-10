extends RigidBody3D

# when we are 1 pixel away from the target. depends how large your bodies are.
const TARGET_REACHED_THRESHOLD = 1.0
const ACCEL = 10 # add this to velocity every second.
const MAX_VELOCITY = 100 # clamp velocity to this to prevent accelerating indefinately
var velocity := Vector3()
var target
@export var is_following := false
var target_node = null

func set_follow_target(reference_target):
	target = reference_target
	is_following = true

func _process(delta:float):
	if is_following:
		var dist_to_target = global_position.distance_to(target)
		if dist_to_target <= TARGET_REACHED_THRESHOLD:
			is_following = false
		else:
			var direction = global_position.direction_to(target)
			velocity += direction * ACCEL * delta

func _physics_process(delta):
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.normalized() * MAX_VELOCITY
	move_and_collide(Vector3(velocity.x,0,velocity.y))
