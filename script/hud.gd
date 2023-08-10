extends CanvasLayer

@onready var fps_count = $fps_counter
@onready var cam = self.get_parent()

var  changes_to_cam_y = 0
var  changes_to_cam_x = 0
var  changes_to_cam_z = 0

func _process(_delta) -> void:
	fps_count.text = str(Engine.get_frames_per_second())
	cam.position.y += changes_to_cam_y
	cam.position.x += changes_to_cam_x
	cam.position.z += changes_to_cam_z
	
func _input(_event) -> void:
	if Input.is_action_just_released("mouse_wheel_up"):
		if cam.size >= 11:
			cam.size -= 6
	if Input.is_action_just_released("mouse wheel down"):
		if cam.size <= 100:
			cam.size += 6

func _on_up_mouse_entered():
	#changes_to_cam_y += 0.25
	changes_to_cam_z += 0.40
func _on_right_mouse_entered():
	changes_to_cam_x -= 0.25
func _on_left_mouse_entered():
	changes_to_cam_x += 0.25
func _on_down_mouse_entered():
	#changes_to_cam_y -= 0.25
	changes_to_cam_z -= 0.40

func _on_up_mouse_exited():
	changes_to_cam_y = 0
	changes_to_cam_z = 0
func _on_right_mouse_exited():
	changes_to_cam_x = 0
func _on_left_mouse_exited():
	changes_to_cam_x = 0
func _on_down_mouse_exited():
	changes_to_cam_y = 0
	changes_to_cam_z = 0
