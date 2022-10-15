extends StaticBody

export var team = 0
var team_colors = {
	0: preload("res://assets/materials/matTeam1.tres"),
	1: preload("res://assets/materials/matTeam2.tres")
}


func _ready():
	if team in team_colors:
		get_parent().material_override = team_colors[team]

