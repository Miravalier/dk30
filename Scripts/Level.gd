extends Node2D

var scene = null
var orb_scene = null
var spawn = null

func _ready():
	# Find the scene, the spawn element, and the orb_scene
	scene = get_tree().get_root().get_node("Scene")
	spawn = scene.get_node("Spawn")
	orb_scene = load("res://Scenes/Prefabs/Orb.tscn")
	# Create a starting orb
	make_orb()

func make_orb():
	var orb = orb_scene.instance()
	orb.position = spawn.position
	scene.add_child(orb)
