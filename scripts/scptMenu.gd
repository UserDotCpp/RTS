extends MarginContainer

onready var anim_player = $CanvasLayer/fondo/AnimationPlayer
onready var selector = $CanvasLayer/select/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("fondo")
	selector.play("titleshit")
	pass # Replace with function body.

func _input(event):
	if Input.is_action_pressed("leftMouse"):
		changeMap()

func changeMap():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://scenes/scnWorldMap.tscn"))
	queue_free()
	pass
