extends Spatial
var life = 10

func _ready():
	pass # Replace with function body.
	
func die():
	if (life <= 0):
		queue_free()
