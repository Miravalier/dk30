extends Node2D

var mouse_pressed_pos
var mouse_current_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_pressed_pos = Vector2(0,0)
	mouse_current_pos = Vector2(0,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#https://godotengine.org/qa/3829/how-to-draw-a-line-in-2d
func _draw():
	draw_line(Vector2(0,0), Vector2(50, 50), Color(255, 0, 0), 1)
	
func update():
	print("updating!",mouse_pressed_pos,mouse_current_pos)
	draw_line(mouse_pressed_pos,mouse_current_pos, Color(255, 0, 0), 1)
	
