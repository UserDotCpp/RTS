extends Control
 
var is_visible = false
var mouce_position = Vector2()
var start_sel_pos = Vector2()
const sel_box_col = Color(0, 1, 0)
const sel_box_line_width = 3

#__________________________________________SELECTION BOX____________________________________________
func _draw() -> void:
	if is_visible and start_sel_pos != mouce_position:
		draw_line(start_sel_pos, Vector2(mouce_position.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(start_sel_pos, Vector2(start_sel_pos.x, mouce_position.y), sel_box_col, sel_box_line_width)
		draw_line(mouce_position, Vector2(mouce_position.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(mouce_position, Vector2(start_sel_pos.x, mouce_position.y), sel_box_col, sel_box_line_width)
 
func _process(_delta) -> void:
	queue_redraw()
#___________________________________________________________________________________________________
