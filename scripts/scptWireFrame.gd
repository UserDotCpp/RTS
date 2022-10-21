extends MeshInstance

var grid_size = 2
var _mesh = Mesh.new()
var _surf = SurfaceTool.new()

func cell_create(size, offset):
	var s = size / 2 
	var vertices = []
	vertices.append( Vector3( -s + offset.x, 0, -s + offset.z) )
	vertices.append( Vector3( s + offset.x, 0, -s + offset.z) )
	vertices.append( Vector3( s + offset.x, 0, -s + offset.z) )
	vertices.append( Vector3( s + offset.x, 0, s  + offset.z) )
	vertices.append( Vector3( s + offset.x, 0, s  + offset.z) )
	vertices.append( Vector3( -s + offset.x, 0, s  + offset.z) )
	vertices.append( Vector3( -s + offset.x, 0, s  + offset.z) )
	vertices.append( Vector3( -s + offset.x, 0, -s + offset.z) )

	_surf.begin(Mesh.PRIMITIVE_LINES)
	for v in vertices:
		_surf.add_vertex(v)
	_surf.index()
	_surf.commit( _mesh )

	vertices = null

func _ready():
	for x_offset in range(-30,30):
		for z_offset in range(-30,30):
			var offset = Vector3(x_offset, 0, z_offset)*grid_size + Vector3(1,0,1)*grid_size/2
			cell_create(grid_size, offset)

	set_mesh( _mesh )
