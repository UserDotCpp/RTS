extends CSGSphere

func _ready():
	pass # Replace with function body.

# warning-ignore:unused_argument
func _physics_process(delta):
	self.global_translation = $Unit.global_translation
