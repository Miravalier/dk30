extends Node2D

var variables = null
var scene: Node2D = null
var orb: RigidBody2D = null
var orb_scene = null
var spawn: Node2D = null
var time: float = 0
var wind_formula: Expression = null
var gravity_formula: Expression = null

var mouse_pressed_pos
var mouse_current_pos
var linenode

func _ready():
	# Global map that stores formula values
	variables = get_tree().get_root().get_node("FormulaVariables")
	# Find the scene, the spawn element, and the orb_scene
	scene = get_tree().get_root().get_node("Scene")
	spawn = scene.get_node("Spawn")
	orb_scene = load("res://Scenes/Prefabs/Orb.tscn")
	# Set the starting formula variable values
	variables.set("hp", 100)
	variables.set("time", time)
	# Create a starting orb
	mouse_pressed_pos = Vector2(0,0)
	mouse_current_pos = Vector2(0,0)
	make_orb()


func _physics_process(delta: float):
	# Keep track of time elapsed as a formula variable.
	time += delta
	variables.set("time", time)
	# If there is no orb, don't worry about wind or gravity.
	if orb == null:
		return
	# Read wind and gravity forces.
	var wind: float = 0 if wind_formula == null else wind_formula.execute(variables.values())
	var gravity: float = 0 if gravity_formula == null else gravity_formula.execute(variables.values())
	# Apply physics to the orb.
	orb.add_central_force(Vector2(wind, gravity))


func make_orb():
	orb = orb_scene.instance()
	orb.position = spawn.position
	scene.add_child(orb)


func take_stroke():
	time = 0
	# Disable button.
	var take_stroke_button: Button = find_node("TakeStrokeButton")
	take_stroke_button.disabled = true
	
	# Parse expression from inputs.
	var wind_input: LineEdit = find_node("WindInput")
	var wind_input_val: String = "0" if wind_input.text == "" else wind_input.text
	# Reset the expression.
	wind_formula = Expression.new()
	wind_formula.parse(wind_input_val, variables.keys())
	wind_formula.execute(variables.values())
	# Test execute expression. If it fails, return error.
	if wind_formula.has_execute_failed():
		print("Wind expression execution failed: ", wind_formula.get_error_text())
		take_stroke_button.disabled = false
		return
		
	# Parse expression from inputs.
	var gravity_input: LineEdit = find_node("WindInput")
	var gravity_input_val: String = "0" if gravity_input.text == "" else gravity_input.text
	# Reset the expression.
	gravity_formula = Expression.new()
	gravity_formula.parse(gravity_input_val, variables.keys())
	gravity_formula.execute(variables.values())
	# Test execute expression. If it fails, return error.
	if gravity_formula.has_execute_failed():
		print("Gravity expression execution failed: ", gravity_formula.get_error_text())
		take_stroke_button.disabled = false
		return

# partly copied from https://docs.godotengine.org/en/stable/tutorials/inputs/mouse_and_input_coordinates.html
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)
		var index
		index=event.get_button_index()
		#BUTTON_LEFT = 1 --- Left mouse button.
		if index==1:
			if event.is_pressed():
				#start drawing +
				mouse_pressed_pos=event.position
				print("click Mouse Click/Unclick at: ", event.position)
			else:
				#stop drawing start shot.
				Vector2(0,0)
				linenode=get_node("Line")
				linenode.mouse_pressed_pos=Vector2(0,0)
				linenode.mouse_current_pos=Vector2(0,0)
				linenode.update()
				print("release Mouse Click/Unclick at: ", event.position)
				
	if event is InputEventMouseMotion:
		#adjust line drawing
		#print("moved to: ", event.position)
		mouse_current_pos = event.position
		linenode=get_node("Line")
		linenode.mouse_pressed_pos=mouse_pressed_pos
		linenode.mouse_current_pos=mouse_current_pos
		linenode.update()
		pass

#supposedly cleaner way to get inputs but I couldn't find how to get the event
#func _process(delta):
	#if Input.is_action_pressed("left_mouse"):
		
		# Move right.


