extends Node2D

var variables = null
var scene: Node2D = null
var orb: RigidBody2D = null
var orb_scene = null
var spawn: Node2D = null
var time: float = 0
var wind_formula: Expression = null


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
	# Apply physics to the orb.
	orb.add_central_force(Vector2(wind, 0))


func make_orb():
	orb = orb_scene.instance()
	orb.position = spawn.position
	scene.add_child(orb)


func take_stroke():
	# Disable button.
	var take_stroke_button: Button = find_node("TakeStrokeButton")
	take_stroke_button.disabled = true
	# Parse expression from inputs.
	var wind_input: String = "0" if find_node("WindInput").text == "" else find_node("WindInput").text
	# Reset the expression.
	time = 0
	wind_formula = Expression.new()
	wind_formula.parse(wind_input, variables.keys())
	wind_formula.execute(variables.values())
	# Test execute expression. If it fails, return error.
	if wind_formula.has_execute_failed():
		print("Wind expression execution failed: ", wind_formula.get_error_text())
		take_stroke_button.disabled = false
		return
