extends Node2D

var variables = null
var scene = null
var orb = null
var orb_scene = null
var spawn = null
var time = 0
var gravity_formula = null
var wind_formula = null

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
	# Create formulas
	var Formula = preload("res://Scripts/Formula.gd")
	gravity_formula = Formula.new(variables)
	wind_formula = Formula.new(variables)
	# Debug formula values
	gravity_formula.terms = [1, "-", "time"]
	wind_formula.terms = [1]

func _physics_process(delta):
	# Keep track of time elapsed as a formula variable
	time += delta
	variables.set("time", time)
	# If there is no orb, don't worry about wind or gravity
	if orb == null:
		return
	# Evaluate wind and gravity formulas
	var wind = wind_formula.evaluate()
	var gravity = gravity_formula.evaluate()
	# Apply physics to the orb
	orb.add_central_force(Vector2(wind, gravity))

func make_orb():
	orb = orb_scene.instance()
	orb.position = spawn.position
	scene.add_child(orb)
